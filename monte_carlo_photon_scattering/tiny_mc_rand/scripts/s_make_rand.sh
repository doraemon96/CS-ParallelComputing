#!/bin/bash

#SBATCH --job-name=makeCompilers
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --exclusive

makefiles=(MakefilePerf MakefileRand MakefileRand2 MakefileRandPerf MakefileRand2Perf)
binaries=(tiny_mc_perf tiny_mc_rand tiny_mc_rand2 tiny_mc_rand_perf tiny_mc_rand2_perf)
dir=.
odir=bin

for m in "${makefiles[@]}"
do
    make -f ${dir}/$m
    make -f ${dir}/$m clean
done

for b in "${binaries[@]}"
do
    ${odir}/${b}
done
