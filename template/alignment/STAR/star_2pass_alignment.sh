#!/usr/bin/env bash
# interface params
input=($1)
param=$2  #No param here
output=$3
info=$4

# herein params
sample=$info
fq1=${input[0]}
fq2=${input[1]}

set -x
checkpoint=1
if [ -s ${JOB_NAME}.sign ]
then
    $checkpoint=`cat ${JOB_NAME}.sign`
fi

if [ $checkpoint -eq 1 ]
then
echo Begin at `date` && \
STAR --runThreadN 16 \
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
	--outSAMstrandField intronMotif && echo Begin at `date` && \
	((checkpoint -- )) && echo $checkpoint >${JOB_NAME}.sign
fi

if [ $checkpoint -eq 0 ]
then
    echo End at `date`
    exit 0
fi


