#!/bin/bash

input=$1
output=$2
py_array=$3

query=$(sed -n -e "$SLURM_ARRAY_TASK_ID p" ${input} | awk -F"\t" '{print $1}')

python ${py_array} ${query} ${output}
