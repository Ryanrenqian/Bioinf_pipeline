#!/bin/bash
# the RSEM should be updated due to some command have been changed and some
# error has been fixed. To facilitate the DEGs Analysis I suggest use the
# latest Version.
# and here is the latest version that I downloaded from official site.
RSEM=/mnt/nfs/user/renqian/bin/RSEM-1.3.0

STAR=/mnt/nfs/software/share/STAR-STAR_2.4.1d/bin/Linux_x86_64

#this is the old version supplied in share
#RSEM=/mnt/nfs/software/share/RSEM-1.2.22/

#++++++++++++++++++prepare reference++++++++++++++++++++++++++++++++++
refgtf=/mnt/cfs/project/test_freshman/renqian/ref/gencode.v25.annotation.gtf
refdata=/mnt/nfs/database/grch38p7/reference/GRCh38_p7_genome.fa
refoutput=/mnt/cfs/project/test_freshman/renqian/all-patient/RSEM
mkdir -p $refoutput/ref
refname=STAR_human_ref

#+++++++++++++++++++software path+++++++++++++++++++++++++++++++++++++
bowtie2=/mnt/nfs/software/share/bowtie2-2.2.5
star=/mnt/nfs/user/renqian/bin/STAR-2.5.3a/bin/Linux_x86_64


#There is no change in building reference 
 $RSEM/rsem-prepare-reference --gtf $refgtf \
 	--star \
 	--star-path $STAR  \
	-p 5 -q \
 	$refdata \
 	$refoutput/ref/$refname

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

input=/mnt/cfs/project/test_freshman/renqian/all-patient/RSEM
output=/mnt/cfs/project/test_freshman/renqian/all-patient/RSEM





#if your bam file failed to be converted, one solution is using fq file instead of bam file
#+++++++++++++++++++++++++++++++This is for bam+++++++++++++++++++++++++++++++++++++++++++++++

#check the bam satisfy the requriment before calculate expression
# it`s worth to point out that Hisat bam is not supported. you might ensure a bam

# file with a header.So STAR or bowtie is recommended! 
#$RSEM/rsem-sam-validator $input

#This is for old version but it so slowly partly because of disability of modification of param
#if not adjacent:you need to convert it to suitable file

#$RSEM/convert-sam-for-rsem  -T $output $input $output/LUAD_G1_01N

#-T in above is set the temporary dir to save byproduct


#This is for new version
#$RSEM/convert-sam-for-rsem -p 8 --memory-per-thread 1G $input $output/LUAD_G1_01N
#outputname=test
#$RSEM/rsem-calculate-expression   --paired-end \
#				-p 8 \
#				$input \
#				$refname \
#				$outputnamme
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++This is for fq+++++++++++++++++++++++++++++++++++++++++++++++
output=/mnt/cfs/project/test_freshman/renqian/all-patient/RSEM
fq1=$input/F2/test_1.fq.gz
fq2=$input/F2/test_2.fq.gz
$RSEM/rsem-calculate-expression -p 8 --paired-end \
	--star --star-path $STAR \
	--star-gzipped-read-file \
	--strandedness reverse  \
	$fq1 $fq2 \
	$refoutput/ref/$refname \
 	$output/Star.sample

#++++++++++++++++++++++++++++++++Extract result to matrix++++++++++++++++++++++++++++++++++++
$RSEM/rsem-generate-data-matrix sample2.isoforms.results sample.isoforms.results >output.counts.matrix

#++++++++++++++++++++++++++++++++comparied+++++++++++++++++++++++++++++++++++++++++++++++++++
$RSEM/rsem-run-ebseq output.counts.matrix 1,1 GeneMat.results
