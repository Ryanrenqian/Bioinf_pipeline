#!/bin/bash

## database ##

refgtf=/mnt/cfs/prj17a/M373000/user/yangjie/20171103.rnaseq/database/gencode.v27lift37.annotation.gtf
ref=/mnt/nfs/database/hg19/reference/ucsc.hg19.fasta
refdir=/mnt/cfs/prj17a/M373000/user/yangjie/20171103.rnaseq/database/STARhg19
refgatk=/mnt/cfs/prj17a/M373000/user/yangjie/20171103.rnaseq/database/GATK
indelvcf=/mnt/cfs/prj17a/M373000/user/yangjie/20171103.rnaseq/database/GATK/Mills_and_1000G_gold_standard.indels.hg19.vcf
snpvcf=/mnt/cfs/prj17a/M373000/user/yangjie/20171103.rnaseq/database/GATK/All_20160408.vcf.gz

## bin ##
java=/mnt/nfs/software/share/jre1.8.0_91/bin/java
picard=/mnt/nfs/software/share/picard-tools-1.134/picard.jar
GATK=/mnt/nfs/software/share/GenomeAnalysisTK-3.6/GenomeAnalysisTK.jar
STAR=/mnt/nfs/user/renqian/bin/STAR-2.5.3a/bin/Linux_x86_64/STAR

input=/mnt/cfs/prj17a/TG79000/renqian/RNA_result/alignment
outdir=/mnt/cfs/prj17a/TG79000/renqian/RNA_result/alignment
vardir1=/mnt/cfs/prj17a/TG79000/renqian/RNA_result/variant
hg19_2pass=/mnt/cfs/prj17a/TG79000/renqian/RNA_result/star2passref

mkdir -p $hg19_2pass
while read smpid smpname sample
do
output=$outdir/$sample
vardir=$vardir1/$sample
hg19_2passdir=$hg19_2pass/$sample

mkdir -p $output
mkdir -p $vardir 
mkdir -p $hg19_2passdir
cat >$output/GATK.${sample}.sh <<EOF
#!/bin/bash
fq1=/mnt/cfs/prj17a/TG79000/renqian/rnacleandata/${smpname}_1.clean.fq.gz
fq2=/mnt/cfs/prj17a/TG79000/renqian/rnacleandata/${smpname}_2.clean.fq.gz

inbam=$input/$sample/${sample}.2pass.Aligned.out.bam
bam=$input/$sample/${sample}.rg_added_sorted.bam
dedbam=$input/$sample/${sample}.dedupped.bam
out1bam=$output/${sample}.split.bam
out2bam=$output/${sample}.realignedBam.bam
out3bam=$output/${sample}.BQSR.bam

echo "start at star-2-pass mode \`date\`" && \\
$STAR --runMode genomeGenerate \
		--genomeDir  $hg19_2passdir \
		--genomeFastaFiles $ref \
		--sjdbOverhang 150 \
		--runThreadN 16 \
		--sjdbFileChrStartEnd $output/${sample}.SJ.out.tab && \\

echo Begin at \`date\` && \\

$STAR --runThreadN 16 \
		--genomeDir $hg19_2passdir \
		--runMode alignReads \
		--readFilesIn \$fq1 \$fq2 \
		--readFilesCommand zcat \
		--outSAMtype BAM Unsorted \
		--outSAMunmapped Within \
		--outSAMattributes NH HI AS NM MD \
		--outFileNamePrefix $output/${sample}.2pass. && \\

echo "start at picard \`date\`" && \\
java -Xmx32g -jar $picard AddOrReplaceReadGroups I=\$inbam O=$input/$sample/${sample}.rg_added_sorted.bam SO=coordinate RGID=id RGLB=library RGPL=illumina RGPU=machine RGSM=sample && \\
/mnt/nfs/software/bin/samtools index \$bam $input/$sample/${sample}.rg_added_sorted.bai && \\
#java -Xmx32g -jar $picard MarkDuplicates I=$input/$sample/${sample}.rg_added_sorted.bam O=$input/$sample/${sample}.dedupped.bam CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=$input/$sample/output.metrics && \\

echo "start at realign \`date\`"
$java -Xmx32g -jar $GATK -T SplitNCigarReads -R $ref -I \$bam -o \$out1bam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS && \\
echo "start at IndelRealigner \`date\`" && \\
$java -Xmx32g -jar $GATK -T IndelRealigner -R $ref -I \$out1bam -known $indelvcf --targetIntervals $refgatk/intervalListFromRTC.intervals  -o \$out2bam && \\
echo "start at BaseRecalibrator \`date\`" && \\
$java -Xmx32g -jar $GATK -T BaseRecalibrator -I \$out2bam -R $ref --knownSites $snpvcf -o $output/recalibration_report.grp && \\
echo "start at PrintReads \`date\`" && \\
$java -Xmx32g -jar $GATK -T PrintReads -R $ref -I \$out2bam -BQSR $output/recalibration_report.grp -o \$out3bam && \\
echo "start at variant calling \`date\`" && \\
# variant calling
echo "start at HaplotypeCaller \`date\`"  && \\
$java -Xmx32g -jar $GATK -T HaplotypeCaller -R $ref -I \$out3bam -dontUseSoftClippedBases -stand_call_conf 20.0 -o $vardir/${sample}.vcf && \\
# variant filter
echo "start at variant filter\`date\`" && \\
$java -Xmx32g -jar $GATK -T VariantFiltration -R $ref -V $vardir/${sample}.vcf -window 35 -cluster 3 -filterName FS -filter "FS > 30.0" -filterName QD -filter "QD < 2.0" -o $vardir/${sample}.filter.vcf && \\
echo "end at \`date\`"
EOF
qsub -wd $output -l vf=36g -P TG79000 -q prj.q $output/GATK.${sample}.sh

done </mnt/cfs/prj17a/TG79000/renqian/RNA_result/sample.list
