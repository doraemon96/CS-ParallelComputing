#!/bin/bash

#SBATCH --job-name=makeCompilers
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --exclusive

makefiles=(MakefilePerf MakefileFLogPerf MakefileFLogRand MakefileFLogRandPerf)
binaries=(tiny_mc_perf tiny_mc_flog_perf tiny_mc_flog_rand_perf)
dir=.
odir=bin

for m in "${makefiles[@]}"
do
    make -f ${dir}/$m
done

for b in "${binaries[@]}"
do
    ${odir}/${b}
done
