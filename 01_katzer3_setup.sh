#!/bin/bash

# This script is to setup katzer3 data on mortimer in BIDS format
# developed by CRB, April 2023

#SBATCH --account=bowman2 --output=logs/katzer3_01_%j.out --mem=5000 

SSID=$1
ORDER=$2

WDIR=~/Data/katzer3/data/bids
SCANDIR=~/Data/katzer3/data/raw/$SSID
FACEDIR=~/Data/shared_tools/mri_deface_templates

for s in $SSID
do

	mkdir -p $WDIR/sub-${s}
	mkdir -p $WDIR/sub-${s}/func
	mkdir -p $WDIR/sub-${s}/anat
	mkdir -p $WDIR/sub-${s}/beh

	# Convert anatomical dicoms to nii
	cd $SCANDIR/2_AX\ 3D\ \(Noncontrast\)/DICOM # go to directory with anatomical
	
	# Remove any previously converted files
	rm *AX_3D*
	
	dcm2niix -z y * # actual conversion
	mri_deface *AX_3D*.nii.gz $FACEDIR/talairach_mixed_with_skull.gca $FACEDIR/face.gca T1w.nii.gz #deface and rename image
	mv T1w.nii.gz $WDIR/sub-${s}/anat/T1w.nii.gz # put it into the bids-structured directory

	for r in 1 2 3 4 5 6
	do
		cd $SCANDIR/*Visual\ Task\ Run\ ${r}/DICOM
		rm *Run_${r}*
	
		
		# Actual conversion
		dcm2niix -z y *
		
		# Get rid of the first 4 volumes for signal stabilization
		fslroi *Run_${r}*.nii.gz Run_${r}_stable.nii.gz 4 241
		
		# Give files their proper names and move them to the BIDS folders
		# ORDER variable signals whether participants saw the pictures with or without labels first
		# ORDER 1 = no labels first, ORDER 2 = labels first
		if [ $ORDER -eq 1 ]
		then 
			if [ ${r} -lt 3 ]
			then
				mv Run_${r}_stable.nii.gz $WDIR/sub-${s}/func/sub-${s}_task-perception_nolabels_run-${r}_bold.nii.gz
			fi
	
			if [ ${r} -gt 2 ] && [ ${r} -lt 5 ]
			then
				thisrun=$(( $r - 2))
				mv Run_${r}_stable.nii.gz $WDIR/sub-${s}/func/sub-${s}_task-perception_labels_run-${thisrun}_bold.nii.gz
			fi
		fi

		if [ $ORDER -eq 2 ]
		then 
	
			if [ ${r} -lt 3 ]
			then
				mv Run_${r}_stable.nii.gz $WDIR/sub-${s}/func/sub-${s}_task-perception_labels_run-${r}_bold.nii.gz
			fi
	
			if [ ${r} -gt 2 ] && [ ${r} -lt 5 ]
			then
				thisrun=$(( ${r} - 2))
				mv Run_${r}_stable.nii.gz $WDIR/sub-${s}/func/sub-${s}_task-perception_nolabels_run-${thisrun}_bold.nii.gz
			fi
		fi
		
		if [ ${r} -gt 4 ]
		then
			thisrun=$(( ${r} - 4))
			mv Run_${r}_stable.nii.gz $WDIR/sub-${s}/func/sub-${s}_task-recall_run-${thisrun}_bold.nii.gz
		fi
	done
done