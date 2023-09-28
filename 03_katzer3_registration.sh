#!/bin/bash

## Registers data using ANTS:
## Strips skull from BOLD files
## Within run motion correction using MCFLIRT on BOLD files
## Across run correction using ANTS to compare 1st volume of each run to the first volume of the first run, then apply to entire series
## Register freesurfer anatomicals to the functionals by comparing freesurfer brainmask to functional reference volume, the applying transformation to 
##    brainmask and parcellations

## Input is subject ID

#SBATCH --mem=4000 --output=logs/katzer3_03_%j.out


SUBNR=$1
refrun="recall_run-1"
RUNS="perception_labels_run-1 perception_labels_run-2 perception_nolabels_run-1 perception_nolabels_run-2 recall_run-1 recall_run-2"

export expdir=~/Data/katzer3

for s in $SUBNR
do

## Point to a bunch of directories with useful stuff
export subdir=${expdir}/sub-${s}
export origfuncdir=${expdir}/data/bids/sub-${s}/func # where to find the unprocessed functional images
export bolddir=${subdir}/func/prepro # where to put the preprocessed functional images
export anatdir=${subdir}/anat # where to find the hi-res anatomical images

## Make a bunch of directories to save output to
mkdir -p ${bolddir}
mkdir -p ${bolddir}/antsreg
mkdir -p ${bolddir}/antsreg/functionals
mkdir -p ${bolddir}/antsreg/transforms
mkdir -p ${anatdir}/antsreg/anat
mkdir -p ${anatdir}/antsreg/transforms
mkdir -p ${bolddir}/antsreg/logs
mkdir -p ${anatdir}/antsreg/logs


## make a log file
now=$(date +"%m%d%Y")
antsfile_func="${bolddir}/antsreg/logs/log_reg_bold_${now}_ants"
antsfile_anat="${anatdir}/antsreg/logs/log_reg_bold_${now}_ants"

## Get rid of the skull from the functional images
 echo "........................................................"
 echo "Brain extraction"

 	for r in $RUNS
 	do
 		echo "Brain extraction: ${r}"
 		bet ${origfuncdir}/sub-${s}_task-${r}_bold.nii.gz ${bolddir}/${r}_brain.nii.gz -F
 	done


## Run the within-run motion correction (realignment)
echo "........................................................"
echo "Motion correction"
	for r in $RUNS
	do
		echo "Motion correction: ${r}"
		mcflirt -in ${bolddir}/${r}_brain.nii.gz -plots -sinc_final  
	done


## reference volume for between-run realignment
echo "........................................................"
echo "Getting reference run"
refts=${bolddir}/${refrun}_brain_mcf.nii.gz

## extract the first volume from each run to calculate the transformations
echo "........................................................"
echo "extract the first volume from each run to calculate the transformations"

	for r in $RUNS
	do
		echo "extracting 1st volume in ${r}_brain_mcf"
		fslroi ${bolddir}/${r}_brain_mcf.nii.gz ${bolddir}/${r}_vol1.nii.gz 0 1
	done


## copy the reference volume
echo "........................................................"
echo "copy the reference volume"
refvol=${bolddir}/${refrun}_vol1.nii.gz
cp ${refvol} ${bolddir}/antsreg/functionals/refvol.nii.gz



 
 	for r in $RUNS
 	do
 		## except the reference - you don't need to realign the reference run to the reference run
 		if [ ${r} != ${refrun} ]
 		then
 			# calculate the affine transformation to the reference image
 			echo "calculating the affine transformation to the reference image for ${r}"
 			ANTS 3 -m MI[${refvol},${bolddir}/${r}_vol1.nii.gz,1,100] -o ${bolddir}/antsreg/transforms/${r}_to_ref_ --rigid-affine true -i 0 >>"$antsfile_func"
 			
 			# apply it to the whole time series
 			echo "applying it to the whole time series"
 			WarpTimeSeriesImageMultiTransform 4 ${bolddir}/${r}_brain_mcf.nii.gz ${bolddir}/antsreg/functionals/${r}_reg.nii.gz -R ${bolddir}/${r}_vol1.nii.gz ${bolddir}/antsreg/transforms/${r}_to_ref_Affine.txt >> "$antsfile_func"
 		fi	
 		
 		
 		if [ ${r} == ${refrun} ]
 		then 
 			echo "just copying reference into antsreg folder: ${refrun}_1"
 			cp ${bolddir}/${r}_brain_mcf.nii.gz ${bolddir}/antsreg/functionals/${r}_reg.nii.gz
 		fi
 	done


## calculate FS Brain to FUNC transforms so you can get ROIs in functional space
echo "........................................................"
echo "calculate FS Brain to FUNC transforms"
ANTS 3 -m MI[${refvol},${anatdir}/brainmask.nii.gz,1,32] -t a -o ${anatdir}/antsreg/transforms/fsbrain_to_func_ --rigid-affine true -i 0

## Apply transformations to FUNCTIONAL space
echo "........................................................"
echo "Apply transformations to FUNCTIONAL space"
WarpImageMultiTransform 3 ${anatdir}/brainmask.nii.gz ${anatdir}/antsreg/anat/brainmask_func.nii.gz -R ${refvol} ${anatdir}/antsreg/transforms/fsbrain_to_func_Affine.txt --use-NN >> "$antsfile_anat"
WarpImageMultiTransform 3 ${anatdir}/orig_brain.nii.gz ${anatdir}/antsreg/anat/orig_brain_func.nii.gz -R ${refvol} ${anatdir}/antsreg/transforms/fsbrain_to_func_Affine.txt --use-NN >> "$antsfile_anat"
WarpImageMultiTransform 3 ${anatdir}/parcels.nii.gz ${anatdir}/antsreg/anat/parcels_func.nii.gz -R ${refvol} ${anatdir}/antsreg/transforms/fsbrain_to_func_Affine.txt --use-NN >> "$antsfile_anat"
WarpImageMultiTransform 3 ${anatdir}/parcels2009.nii.gz ${anatdir}/antsreg/anat/parcels2009_func.nii.gz -R ${refvol} ${anatdir}/antsreg/transforms/fsbrain_to_func_Affine.txt --use-NN >> "$antsfile_anat"

done
