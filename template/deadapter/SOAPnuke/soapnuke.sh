#!/usr/bin/env bash

input=($1)
params=$2
output=$3
info=($4)
sample=$5
# inner params
fq1=${input[0]}
fq2=${input[1]}
params=" -n 0.1 -l 5 -q 0.5 -5 1 "

checkpoint=2
checkfile=${JOB_NAME}.sign
set -x
if [ -s $checkfile ]
then
checkpoint=`echo $checkfile`
fi
if [ $checkpoint -eq 2 ]
then
mkdir -p $output
soapnuke filter -G -f ${info[0]} -r ${info[1]} -1 ${input[0]} -2 ${input[1]} $params -i $tile -o output \
    -C ${sample}_1.clean.fq.gz -D ${sample}_2.clean.fq.gz && ((checkpoint--)) && \
    echo  $checkpoint >$checkfile
fi
if [ $checkpoint -eq 1 ]
then
rm -f ${output}/Raw_*.gz && \
rm -f ${output}/*.tmp && \
((checkpoint--)) && echo $checkpoint >$checkfile
fi
if [ $checkpoint -eq 1 ]
then
echo End at `date`
exit 0
fi