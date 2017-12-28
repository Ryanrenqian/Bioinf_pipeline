#!/bin/bash

## bin ##
RSEM=/mnt/nfs/user/renqian/bin/RSEM-1.3.0
STAR=/mnt/nfs/user/renqian/bin/STAR-2.5.3a/bin/Linux_x86_64/STAR

## database ##
refgtf=/mnt/cfs/prj17a/M373000/user/yangjie/20171103.rnaseq/database/gencode.v27lift37.annotation.gtf
refdata=/mnt/nfs/database/hg19/reference/ucsc.hg19.fasta

## database_index ##
ref=/mnt/cfs/prj17a/M373000/user/yangjie/20171103.rnaseq/database/STARhg19
input=/mnt/cfs/prj17a/TG79000/renqian/RNA_result/alignment
outdir=/mnt/cfs/prj17a/TG79000/renqian/RNA_result/expression

while read smpid smpname sample
do

output=$outdir/$sample
mkdir -p $output/$sample/rsem
bam=$input/$sample/${sample}.Aligned.toTranscriptome.out.bam

cat >$output/RSEM_expression_${sample}.sh <<EOF
#!/bin/bash
$RSEM/rsem-calculate-expression --bam --no-bam-output -p 16 --paired-end  \\
	$bam \\
	$ref/STAR_hg19 $output/$sample/rsem >& \\
	$output/$sample/rsem.log
echo Begin at \`date\`
EOF
qsub -wd $output -l vf=2g -P M373000 -q med.q $output/RSEM_expression_${sample}.sh

done </mnt/cfs/prj17a/TG79000/renqian/RNA_result/sample.list
