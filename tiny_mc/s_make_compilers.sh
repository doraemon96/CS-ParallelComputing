#!/bin/bash

#SBATCH --job-name=makeCompilers
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SSBATCH --output=c.txt

opt=(-O0 -O1 -O2 -O3 -Os -Ofast)
com=(gcc-9 clang-9)

binary=tiny_mc_perf

for op in "${opt[@]}"; do
	for cxx in "${com[@]}"; do
		make -f MakefileCompilers CC=${cxx} LINKER=${cxx} OPT=${op}
		make clean
	done
done


for op in "${opt[@]}"; do
	for cxx in "${com[@]}"; do
        ./${binary}_${cxx}_${op}
	done
done
