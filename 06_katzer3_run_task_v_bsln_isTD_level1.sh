#!/bin/bash

# this script runs the task_v_bsln first level model for katzer3 data

# needs: 
#	subject number

#SBATCH --mem=5000 --output=logs/katzer3_06_run_task_v_bsln_isTD_level1_%j.out

sbj=$1
rnr="perception_labels_run-1 perception_labels_run-2 perception_nolabels_run-1 perception_nolabels_run-2 
recall_run-1 recall_run-2"
dur="dur1 dur4"

## univariate task v. baseline model at both durations, with the temporal derivative 
for d in ${dur}
do
	for r in ${rnr}
	do
		sbjdir=~/Data/katzer3/sub-${sbj}/func/task_v_bsln_isTD
		mkdir -p ${sbjdir}
	
		outfsf=${sbjdir}/${r}_${d}_isTD_level1.fsf
		sed -e "s|SUBNUM|${sbj}|g" -e "s|RUN|${r}|g" -e "s|DUR|${d}|g" 
<~/Data/katzer3/scripts/feat_templates/task_v_bsln_isTD.fsf>${outfsf}
		feat ${outfsf}
	done
done
