#!/bin/bash

#SBATCH --job-name=makeCompilers
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --exclusive

sudo=sudo

declare -a options

options[0]="-O2"
options[1]="-O2 -march=native"
options[2]="-O2 -fno-signed-zeros -fno-trapping-math -fassociative-math -freciprocal-math"
options[3]="-O2 -fno-signed-zeros -fno-trapping-math -fassociative-math -freciprocal-math -march=native"

options_len=${#options[@]}

p=50000

for (( i=0; i < ${options_len}; i++))
do
    make -f Makefile PHOTONS=$p CFLAGS+="${options[$i]}"
    mv bin/tiny_mc bin/tiny_mc_pperf_${i}_${p}
    make -f Makefile clean

    ${sudo} perf stat -d -r 10 bin/tiny_mc_pperf_${i}_${p} 2> data/out_pperf_${i}_${p}.txt
done

