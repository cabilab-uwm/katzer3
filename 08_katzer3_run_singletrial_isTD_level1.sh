#!/bin/bash

# this script runs first level models for coat data

# needs: 
#	subject number

#SBATCH --mem=5000 --output=logs/katzer3_08_run_singletrial_isTD_level1_%j.out

sbj=$1
rnr="perceptionLabels_run-1 perceptionLabels_run-2 perceptionNolabels_run-1 perceptionNolabels_run-2 recall_run-1 recall_run-2"
dur="dur1 dur4"

## single trial model - each trial separately
for d in ${dur}
do
	for r in ${rnr}
	do
		sbjdir=~/Data/katzer3/sub-${sbj}/func/singletrial_isTD_crb
		mkdir -p ${sbjdir}
	
		outfsf=${sbjdir}/${r}_${d}_isTD_level1.fsf
		sed -e "s|SUBNUM|${sbj}|g" -e "s|RUN|${r}|g" -e "s|DUR|${d}|g" <~/Data/katzer3/scripts/feat_templates/singletrial_isTD_crb.fsf>${outfsf}
		feat ${outfsf}
	done
done
