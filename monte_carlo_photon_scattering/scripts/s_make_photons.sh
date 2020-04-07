#!/bin/bash

#SBATCH --job-name=makeCompilers
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --exclusive

binary=tiny_mc_photons
dir=bin

declare -a options

options[0]="-O2"
options[1]="-O2 -march=native"
options[2]="-O3 -march=native"
options[3]="-O2 -fno-signed-zeros -fno-trapping-math -fassociative-math -freciprocal-math -march=native"
options[4]="-O3 -fno-signed-zeros -fno-trapping-math -fassociative-math -freciprocal-math -march=native"

options_len=${#options[@]}

for (( i=0; i < ${options_len}; i++))
do
    for p in {30000..230000..20000}
    do
        make -f MakefilePhotons PHOTONS=$p NUM=$i OPT="${options[$i]}"
        make -f MakefilePhotons clean
    done
done


for (( i=0; i < ${options_len}; i++))
do
    for p in {30000..230000..20000}
    do
        ${dir}/${binary}_${i}_${p}
        sleep 30s
    done
done
