#!/bin/bash
#SBATCH --mem=90G 
#SBATCH --cpus-per-task=6
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=ejc043@ucsd.edu


resolution=3000
size=200
species='hg38'
blacklist_path=/stg3/data1/eunice/Annotation/hg38blacklist/hg38-blacklist.bed
telomere_path='/stg3/data1/eunice/Annotation/UCSC/hg38_telomere_centromere_UCSC_GAP.bed'

final_output_name=${species}_res.${resolution}.bed 

# #### resolution bed file indexed
fetchChromSizes ${species} | awk -v FS="\t" -v OFS="\t" '{ print $1, "0", $2; }' | bedops --chop "$((${resolution}-1))" --stagger ${resolution}  -  > $final_output_name

#### split by 200bp
cat $final_output_name | bedops --chop $((${size}-1)) --stagger ${size} -  | \
    bedtools intersect -a stdin -b ${blacklist_path}  ${telomere_path} -v \
    > $(basename ${final_output_name}_res.${resolution}.bed ).size.${size}.bed



