#!/bin/bash

input=$1
reference=$2
output_parent=$3

query=$(sed -n -e "$SLURM_ARRAY_TASK_ID p" ${input} | awk -F"\t" '{print $1}')


# tmp=${output_parent}/.tmp
# mkdir $tmp 
# tmp_out=${tmp}/$(basename $query)
# bedtools intersect -wa -a $reference -b $query | gzip > ${tmp_out}

bedtools intersect -wao -a ${reference} -b $query  > ${output_parent}/$(basename $query .bed.gz).bdg

rm ${tmp_out}

