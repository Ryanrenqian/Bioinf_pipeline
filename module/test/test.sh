#!/usr/bin/env bash
input=$1
output=$2
params=$3
mkdir -p $output
echo "$input $output $params $output/example.log"
echo "$input $output $params" >$output/example.log