#!/bin/bash

#SBATCH --job-name=makeCompilers
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --exclusive

binary=tiny_mc_phot

declare -a options

options[0]="-O2"
options[1]="-O2 -funroll-loops"
options[2]="-O2 -march=native"
options[3]="-O2 -funroll-loops -march=native"
options[4]="-O3 -funroll-loops -march=native"

options_len=${#options[@]}

for (( i=0; i < ${options_len}; i++))
do
    for p in {30000..210000..30000}
    do
        make -f MakefilePhotons PHOTONS=$p NUM=$i OPT="${options[$i]}"
        make -f MakefilePhotons clean
    done
done


for (( i=0; i < ${options_len}; i++))
do
    for p in {30000..210000..30000}
    do
        ./${binary}_${i}_${p}
        sleep 1m
    done
done
