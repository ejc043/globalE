#!/bin/bash

inputdir=/stg3/data1/eunice/script/21_SpectralEntropy/alzheimers_pseudobulks
reference=/new-stg/home/eunice_2/Entropy/00_LocalKL/18_new/hg38_res.3000.bed_res.3000.bed.size.200.bed

outputdir=/stg3/data1/eunice/script/21_SpectralEntropy/pseudobulk_entropy
mkdir -p ${outputdir}
intersect_out=${outputdir}/int
mkdir -p ${intersect_out}
#entropy_out=${outputdir}/hist
entropy_out=${outputdir}/spectralE
#entropy_out=${outputdir}/shannon
mkdir -p ${entropy_out}

#### code 
codedir=/stg3/data1/eunice/script/21_SpectralEntropy/code
intersect=${codedir}/intersect.sh
entropy_array=${codedir}/entropy.sh
py_array=${codedir}/spectralE.py
#py_array=${codedir}/hist_shannonE.py
#py_array=${codedir}/shannon.py


#### inputfiles
intersect_input=${outputdir}/.input
find ${inputdir} -type f -name "*.bdg" > ${intersect_input}





################### STEP 1 ######################
echo 'overlapping coordinate files with query bedgraph files'
N=20

# ### intersect
FILECOUNT=$(wc -l < "${intersect_input}")
if (( $FILECOUNT > ${N} )); then
  PARALLELJOBS=${N}
else
  PARALLELJOBS=$FILECOUNT
fi

ARRAYCOMMAND="1-${FILECOUNT}%${PARALLELJOBS}"
sbatch --wait -a $ARRAYCOMMAND ${intersect} ${intersect_input} ${reference} ${intersect_out}
wait 

################### STEP 2 ######################
#### inputfiles
ge_input=${outputdir}/.input
find ${intersect_out} -type f -name "*bdg" > ${ge_input}

### globalE
FILECOUNT=$(wc -l < "${ge_input}")
if (( $FILECOUNT > ${N} )); then
  PARALLELJOBS=${N}
else
  PARALLELJOBS=$FILECOUNT
fi

ARRAYCOMMAND="1-${FILECOUNT}%${PARALLELJOBS}"
sbatch --wait -a $ARRAYCOMMAND ${entropy_array} ${ge_input} ${entropy_out} ${py_array}
wait 
