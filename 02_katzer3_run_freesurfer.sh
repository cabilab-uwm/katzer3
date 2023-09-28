#!/bin/bash

# This script is to run freesurfer on camcan data - regular segmentation

#SBATCH --account=bowman2 --output=logs/katzer3_02_%j.out --mem=4000 

SSID=$1
EXPDIR=~/Data/katzer3

for SUBNUM in $SSID
do


	SUBPATH=$EXPDIR/sub-$SUBNUM/anat
	ANATDIR=$EXPDIR/data/bids/sub-$SUBNUM/anat
	FSDIR=$EXPDIR/fs_katzer3/sub-$SUBNUM/mri

	mkdir -p $SUBPATH

	export SUBJECTS_DIR=$EXPDIR/fs_katzer3/


	## Start with the regular Freesurfer parcels
	echo Run Freesurfer started on: `date`

	recon-all -subject sub-$SUBNUM -i $ANATDIR/T1w.nii.gz -all

	echo Run Freesurfer finished on: `date`

	echo Starting conversion on: `date`

	# convert brainmask
	mri_convert $FSDIR/brainmask.mgz $SUBPATH/brainmask.nii.gz
	fslreorient2std $SUBPATH/brainmask.nii.gz $SUBPATH/brainmask.nii.gz

	# convert orig
	mri_convert $FSDIR/orig.mgz $SUBPATH/orig.nii.gz
	fslreorient2std $SUBPATH/orig.nii.gz $SUBPATH/orig.nii.gz

	# skull strip orig

	bet $SUBPATH/orig.nii.gz $SUBPATH/orig_brain.nii.gz -R

	# convert parcelations
	mri_convert $FSDIR/aparc+aseg.mgz $SUBPATH/parcels.nii.gz
	fslreorient2std $SUBPATH/parcels.nii.gz $SUBPATH/parcels.nii.gz

	mri_convert $FSDIR/aparc.a2009s+aseg.mgz $SUBPATH/parcels2009.nii.gz
	fslreorient2std $SUBPATH/parcels2009.nii.gz $SUBPATH/parcels2009.nii.gz

	echo Finished conversion on: `date`

	## DOESN'T WORK ON MORTIMER - FOR CAMCAN, CRB RAN ON LOCAL
	## Start with hipp seg
	# echo Run Freesurfer hipp seg started on: `date`

	# segmentHA_T1.sh sub-$SUBNUM 

	# echo Run Freesurfer hipp seg finished on: `date`

done



