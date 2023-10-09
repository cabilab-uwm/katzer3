#!/bin/bash

#SBATCH --mem=2000 
#--output=logs/katzer3_00_filerename/%j.out


subs=("301" "302" "304" "305" "307" "308" "309" "310" "311" "312" "313")
basedir=~/Data/katzer3

for s in ${!subs[@]}
do

thissub=${subs[$s]}

# # Start with the bids version of the data
# cd ${basedir}/data/bids/sub-${thissub}/func

# mv *perceptionLabels*run*1* sub-${thissub}_task-perceptionLabels_run-1_bold.nii.gz
# mv *perceptionLabels*run*2* sub-${thissub}_task-perceptionLabels_run-2_bold.nii.gz
# mv *perceptionNolabels*run*1* sub-${thissub}_task-perceptionNolabels_run-1_bold.nii.gz
# mv *perceptionNolabels*run*2* sub-${thissub}_task-perceptionNolabels_run-2_bold.nii.gz

# mv *perception_labels_run-1* sub-${thissub}_task-perceptionLabels_run-1_bold.nii.gz
# mv *perception_labels_run-2* sub-${thissub}_task-perceptionLabels_run-2_bold.nii.gz
# mv *perception_nolabels_run-1* sub-${thissub}_task-perceptionNolabels_run-1_bold.nii.gz
# mv *perception_nolabels_run-2* sub-${thissub}_task-perceptionNolabels_run-2_bold.nii.gz

# mv *recall_run*1* sub-${thissub}_task-recall_run-1_bold.nii.gz
# mv *recall_run*2* sub-${thissub}_task-recall_run-2_bold.nii.gz

# # Check the prepro files
# cd ${basedir}/sub-${thissub}/func/prepro

# rename perception_labels perceptionLabels *
# rename perception_nolabels perceptionNolabels *

# echo "This is subject: " ${thissub}
# echo $( ls *_brain.nii.gz)

# Check the antsreg files
cd ${basedir}/sub-${thissub}/func/prepro/antsreg/functionals

rename perception_labels perceptionLabels *
rename perception_nolabels perceptionNolabels *

rename run1 run-1 *
rename run2 run-2 *

echo "This is subject: " ${thissub}
echo $( ls )

# Check the various models
# models=("singleitem_isTD" "singleitem_noTD" "singletrial_isTD" "singletrial_noTD" "task_v_bsln_isTD" "task_v_bsln_noTD")

# 	for m in ${!models[@]}
# 	do
# 		thismodel=${models[$m]}
# 		cd ${basedir}/sub-${thissub}/func/${thismodel}
# 		rename perception_labels perceptionLabels *
# 		rename perception_nolabels perceptionNolabels *

# 		echo "This is subject: " ${thissub} " and model " ${thismodel}
# 		echo $( ls *perception*)
# 	done

done