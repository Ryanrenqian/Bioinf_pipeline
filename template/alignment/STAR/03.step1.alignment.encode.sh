## bin #
RSEM=/mnt/nfs/user/renqian/bin/RSEM-1.3.0
STAR=/mnt/nfs/user/renqian/bin/STAR-2.5.3a/bin/Linux_x86_64/STAR

## database ##
refgtf=/mnt/cfs/prj17a/M373000/user/yangjie/20171103.rnaseq/database/gencode.v27lift37.annotation.gtf
refdata=/mnt/nfs/database/hg19/reference/ucsc.hg19.fasta

## database_index ##
ref=/mnt/cfs/prj17a/M373000/user/yangjie/20171103.rnaseq/database/STARhg19
input=/mnt/cfs/prj17a/TG79000/renqian/rnacleandata
outdir=/mnt/cfs/prj17a/TG79000/renqian/RNA_result/alignment

while read smpid smpname sample
do

output=$outdir/$sample
mkdir -p $output
fq1=$input/${smpname}_1.clean.fq.gz
fq2=$input/${smpname}_2.clean.fq.gz

cat >$output/star_alignment_${sample}.sh <<EOF
#!/bin/bash
set -x
echo Begin at \`date\` && \\
$STAR --runThreadN 16 \
	--genomeDir $ref \
	--runMode alignReads \
	--readFilesIn $fq1 $fq2 \
	--readFilesCommand zcat \
	--quantMode TranscriptomeSAM \
	--outSAMtype BAM Unsorted \
	--outSAMunmapped Within \
	--outFilterType BySJout \
	--outSAMattributes NH HI AS NM MD \
	--outFilterMultimapNmax 20 \
	--outFilterMismatchNmax 10 \
	--outFilterMismatchNoverReadLmax 0.04 \
	--alignSJoverhangMin 8 \
	--alignSJDBoverhangMin 1 \
	--alignIntronMin 20 \
	--alignIntronMax 1000000 \
	--alignMatesGapMax 1000000 \
	--sjdbScore 2 \
	--outFileNamePrefix $output/${sample}. \
	--genomeLoad NoSharedMemory \
	--outFilterMatchNminOverLread 0.33 \
	--outFilterScoreMinOverLread 0.33 \
	--outSAMstrandField intronMotif && \\
echo Begin at \`date\`
EOF
qsub -wd $output -l vf=40g -P TG79000 -q prj.q $output/star_alignment_${sample}.sh
done <sample.list
