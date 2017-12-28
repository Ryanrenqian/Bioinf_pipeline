# the RSEM should be updated due to some command have been changed and some
# error has been fixed. To facilitate the DEGs Analysis I suggest use the
# latest Version.
# and here is the latest version that I downloaded from official site.
RSEM=/mnt/nfs/user/renqian/bin/RSEM-1.3.0


#this is the old version supplied in share
#RSEM=/mnt/nfs/software/share/RSEM-1.2.22/

#++++++++++++++++++prepare reference++++++++++++++++++++++++++++++++++
refgtf=/mnt/nfs/user/liupeng/Data/Reference_chr/gencode.v25.annotation.gtf
bowtie=/mnt/nfs/software/share/bowtie2-2.2.5
refdata=/mnt/nfs/user/liupeng/Data/Reference_chr
refoutput=/mnt/cfs/project/test_freshman/renqian/all-patient/RSEM
#mkdir -p $refoutput/ref
refname=human_ref
#gencode

#There is no change in building reference 
#$RSEM/rsem-prepare-reference --gtf $refgtf \
#	--bowtie2 \
#	--bowtie2-path $bowtie \
#	$refdata/GRCh38.p7.genome.fa \
#	$refoutput/ref/$refname

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

input=/mnt/cfs/project/test_freshman/renqian/all-patient/RSEM/test2

#output=/mnt/cfs/project/test_freshman/renqian/all-patient/RSEM





#when your bam file failed to be converted, one solution is using fq file instead of bam file
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
# you should notice --strandedness --aligment --star --bowtie2 --phred33-quals
# --phred-64-quals 



output=sample2
#/mnt/cfs/project/test_freshman/renqian/all-patient/RSEM/sample
 fq1=$input/test_1.fq.gz
 fq2=$input/test_2.fq.gz
$RSEM/rsem-calculate-expression -p 8 --paired-end \
	--strandedness reverse \
 	--bowtie2 --bowtie2-path $bowtie \
 	$fq1 $fq2 $refoutput/ref/$refname $output
#$RSEM/rsem-calculate-expression -p 8 --paired-end --bowtie2 --bowtie2-path $bowtie $fq1 $fq2 $refoutput/ref/$refname $output
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#+++++++++++++++++++++++Different Expression Analysis+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# After you get all samples` data, you should apply rsem-generate-data-matrix
# to extract input matrix from expression result.
#
# $RSEM/rsem-generate-data-matrix sample2.isoforms.results sample.isoforms.results >output.counts.matrix 
#
#
# Then EBSeq will do DEA for you. 1,1 means that there two condition each with
# 1 sample
#
# $RSEM/rsem-run-ebseq output.counts.matrix 1,1 GeneMat.results





