#!/bin/bash

#SBATCH --mem=2000 --output=logs/katzer3_05_%j.out

SUBNUM=$1
EXPPATH=~/Data/katzer3
SUBDIR=$EXPPATH/sub-${SUBNUM}

mkdir -p $SUBDIR/anat/antsreg/masks
SUBOUTROIPATH=$SUBDIR/anat/antsreg/masks

cd ${SUBOUTROIPATH}

cp $SUBDIR/anat/antsreg/anat/parcels_func.nii.gz parcels.nii.gz
cp $SUBDIR/anat/antsreg/anat/parcels2009_func.nii.gz parcels2009.nii.gz


# MTL regions

fslmaths parcels.nii.gz -thr 1006 -uthr 1006 -bin l_erc.nii.gz
fslmaths parcels.nii.gz -thr 2006 -uthr 2006 -bin r_erc.nii.gz
fslmaths l_erc.nii.gz -add r_erc.nii.gz b_erc.nii.gz

fslmaths parcels.nii.gz -thr 1016 -uthr 1016 -bin l_phc.nii.gz
fslmaths parcels.nii.gz -thr 2016 -uthr 2016 -bin r_phc.nii.gz
fslmaths l_phc.nii.gz -add r_phc.nii.gz b_phc.nii.gz

fslmaths parcels.nii.gz -thr 17 -uthr 17 -bin l_hip.nii.gz
fslmaths parcels.nii.gz -thr 53 -uthr 53 -bin r_hip.nii.gz
fslmaths l_hip.nii.gz -add r_hip.nii.gz b_hip.nii.gz


# Early visual regions

fslmaths parcels.nii.gz -thr 1011 -uthr 1011 -bin l_lo.nii.gz
fslmaths parcels.nii.gz -thr 2011 -uthr 2011 -bin r_lo.nii.gz
fslmaths l_lo.nii.gz -add r_lo.nii.gz b_lo.nii.gz

fslmaths parcels.nii.gz -thr 1013 -uthr 1013 -bin l_lingual.nii.gz
fslmaths parcels.nii.gz -thr 2013 -uthr 2013 -bin r_lingual.nii.gz
fslmaths l_lingual.nii.gz -add r_lingual.nii.gz b_lingual.nii.gz

# Ventral visual regions

fslmaths parcels.nii.gz -thr 1007 -uthr 1007 -bin l_fus.nii.gz
fslmaths parcels.nii.gz -thr 2007 -uthr 2007 -bin r_fus.nii.gz
fslmaths l_fus.nii.gz -add r_fus.nii.gz b_fus.nii.gz

fslmaths parcels.nii.gz -thr 1009 -uthr 1009 -bin l_it.nii.gz
fslmaths parcels.nii.gz -thr 2009 -uthr 2009 -bin r_it.nii.gz
fslmaths l_it.nii.gz -add r_it.nii.gz b_it.nii.gz

# Frontal regions

fslmaths parcels.nii.gz -thr 1012 -uthr 1012 -bin l_lofc.nii.gz
fslmaths parcels.nii.gz -thr 2012 -uthr 2012 -bin r_lofc.nii.gz
fslmaths l_lofc.nii.gz -add r_lofc.nii.gz b_lofc.nii.gz

fslmaths parcels.nii.gz -thr 1018 -uthr 1018 -bin l_oper.nii.gz
fslmaths parcels.nii.gz -thr 2018 -uthr 2018 -bin r_oper.nii.gz
fslmaths l_oper.nii.gz -add r_oper.nii.gz b_oper.nii.gz

fslmaths parcels.nii.gz -thr 1019 -uthr 1019 -bin l_orbi.nii.gz
fslmaths parcels.nii.gz -thr 2019 -uthr 2019 -bin r_orbi.nii.gz
fslmaths l_orbi.nii.gz -add r_orbi.nii.gz b_orbi.nii.gz

fslmaths parcels.nii.gz -thr 1020 -uthr 1020 -bin l_tria.nii.gz
fslmaths parcels.nii.gz -thr 2020 -uthr 2020 -bin r_tria.nii.gz
fslmaths l_tria.nii.gz -add r_tria.nii.gz b_tria.nii.gz

fslmaths parcels.nii.gz -thr 1014 -uthr 1014 -bin l_mofc.nii.gz
fslmaths parcels.nii.gz -thr 2014 -uthr 2014 -bin r_mofc.nii.gz
fslmaths l_mofc.nii.gz -add r_mofc.nii.gz b_mofc.nii.gz

fslmaths parcels.nii.gz -thr 1032 -uthr 1032 -bin l_fropo.nii.gz
fslmaths parcels.nii.gz -thr 2032 -uthr 2032 -bin r_fropo.nii.gz
fslmaths l_fropo.nii.gz -add r_fropo.nii.gz b_fropo.nii.gz

fslmaths parcels.nii.gz -thr 1028 -uthr 1028 -bin l_sfg.nii.gz
fslmaths parcels.nii.gz -thr 2028 -uthr 2028 -bin r_sfg.nii.gz
fslmaths l_sfg.nii.gz -add r_sfg.nii.gz b_sfg.nii.gz

fslmaths parcels.nii.gz -thr 1027 -uthr 1027 -bin l_rmfg.nii.gz
fslmaths parcels.nii.gz -thr 2027 -uthr 2027 -bin r_rmfg.nii.gz
fslmaths l_rmfg.nii.gz -add r_rmfg.nii b_rmfg.nii.gz

fslmaths parcels.nii.gz -thr 1003 -uthr 1003 -bin l_cmfg.nii.gz
fslmaths parcels.nii.gz -thr 2003 -uthr 2003 -bin r_cmfg.nii.gz
fslmaths l_cmfg.nii.gz -add r_cmfg.nii.gz b_cmfg.nii.gz

fslmaths b_oper.nii.gz -add b_orbi.nii.gz -add b_tria.nii.gz b_ifg.nii.gz
fslmaths l_oper.nii.gz -add l_orbi.nii.gz -add l_tria.nii.gz l_ifg.nii.gz
fslmaths r_oper.nii.gz -add r_orbi.nii.gz -add r_tria.nii.gz r_ifg.nii.gz

# Lateral temporal regions (ITG labeled as IT in Ventral visual)

fslmaths parcels.nii.gz -thr 1030 -uthr 1030 -bin l_stg.nii.gz
fslmaths parcels.nii.gz -thr 2030 -uthr 2030 -bin r_stg.nii.gz
fslmaths l_stg.nii.gz -add r_stg.nii.gz b_stg.nii.gz

fslmaths parcels.nii.gz -thr 1015 -uthr 1015 -bin l_mtg.nii.gz
fslmaths parcels.nii.gz -thr 2015 -uthr 2015 -bin r_mtg.nii.gz
fslmaths l_mtg.nii.gz -add r_mtg.nii.gz b_mtg.nii.gz

fslmaths parcels.nii.gz -thr 1033 -uthr 1033 -bin l_tmppole.nii.gz
fslmaths parcels.nii.gz -thr 2033 -uthr 2033 -bin r_tmppole.nii.gz
fslmaths l_tmppole.nii.gz -add r_tmppole.nii.gz b_tmppole.nii.gz 

# Parietal regions

fslmaths parcels.nii.gz -thr 1008 -uthr 1008 -bin l_ipar.nii.gz
fslmaths parcels.nii.gz -thr 2008 -uthr 2008 -bin r_ipar.nii.gz
fslmaths l_ipar.nii.gz -add r_ipar.nii.gz b_ipar.nii.gz

fslmaths parcels.nii.gz -thr 1029 -uthr 1029 -bin l_supar.nii.gz
fslmaths parcels.nii.gz -thr 2029 -uthr 2029 -bin r_supar.nii.gz
fslmaths l_supar.nii.gz -add r_supar.nii.gz b_supar.nii.gz

fslmaths parcels.nii.gz -thr 1031 -uthr 1031 -bin l_smarg_big.nii.gz
fslmaths parcels.nii.gz -thr 2031 -uthr 2031 -bin r_smarg_big.nii.gz
fslmaths l_smarg_big.nii.gz -add r_smarg_big.nii.gz b_smarg_big.nii.gz

fslmaths parcels.nii.gz -thr 1025 -uthr 1025 -bin l_precuneus.nii.gz
fslmaths parcels.nii.gz -thr 2025 -uthr 2025 -bin r_precuneus.nii.gz
fslmaths l_precuneus.nii.gz -add r_precuneus.nii.gz b_precuneus.nii.gz

fslmaths parcels2009.nii.gz -thr 11125 -uthr 11125 -bin l_angular.nii.gz
fslmaths parcels2009.nii.gz -thr 12125 -uthr 12125 -bin r_angular.nii.gz
fslmaths l_angular.nii.gz -add r_angular.nii.gz b_angular.nii.gz

fslmaths parcels2009.nii.gz -thr 11126 -uthr 11126 -bin l_smarg_small.nii.gz
fslmaths parcels2009.nii.gz -thr 12126 -uthr 12126 -bin r_smarg_small.nii.gz
fslmaths l_smarg_small.nii.gz -add r_smarg_small.nii.gz b_smarg_small.nii.gz

fslmaths b_ipar.nii.gz -add b_supar.nii.gz b_latpar.nii.gz


# Basal ganglia

fslmaths parcels.nii.gz -thr 11 -uthr 11 -bin l_caudate.nii.gz
fslmaths parcels.nii.gz -thr 50 -uthr 50 -bin r_caudate.nii.gz
fslmaths l_caudate.nii.gz -add r_caudate.nii.gz b_caudate.nii.gz

fslmaths parcels.nii.gz -thr 12 -uthr 12 -bin l_putamen.nii.gz
fslmaths parcels.nii.gz -thr 51 -uthr 51 -bin r_putamen.nii.gz
fslmaths l_putamen.nii.gz -add r_putamen.nii.gz b_putamen.nii.gz

fslmaths parcels.nii.gz -thr 13 -uthr 13 -bin l_pallidum.nii.gz
fslmaths parcels.nii.gz -thr 52 -uthr 52 -bin r_pallidum.nii.gz
fslmaths l_pallidum.nii.gz -add r_pallidum.nii.gz b_pallidum.nii.gz

fslmaths b_caudate.nii.gz -add b_putamen.nii.gz b_striatum.nii.gz 

# Major divisions

fslmaths parcels.nii.gz -thr 1000 -uthr 1035 -bin l_ctx.nii.gz
fslmaths parcels.nii.gz -thr 2000 -uthr 2035 -bin r_ctx.nii.gz
fslmaths l_ctx.nii.gz -add r_ctx.nii.gz b_ctx.nii.gz

fslmaths parcels.nii.gz -thr 9 -uthr 13 -bin l_subco.nii.gz
fslmaths parcels.nii.gz -thr 18 -uthr 18 -add l_subco -add l_hip -bin l_subco.nii.gz
fslmaths parcels.nii.gz -thr 48 -uthr 54 -bin r_subco.nii.gz
fslmaths l_subco.nii.gz -add r_subco.nii.gz b_subco.nii.gz

fslmaths b_subco -add b_ctx b_gray

fslmaths parcels.nii.gz -thr 24 -uthr 24 -bin csf.nii.gz

fslmaths parcels.nii.gz -thr 2 -uthr 2 -bin l_wm.nii.gz
fslmaths parcels.nii.gz -thr 41 -uthr 41 -bin r_wm.nii.gz
fslmaths l_wm.nii.gz -add r_wm.nii.gz b_wm.nii.gz

fslmaths parcels.nii.gz -thr 1 -bin wholebrain.nii.gz

# Other 

fslmaths parcels.nii.gz -thr 1024 -uthr 1024 -bin l_motor.nii.gz
fslmaths parcels.nii.gz -thr 2024 -uthr 2024 -bin r_motor.nii.gz
fslmaths l_motor.nii.gz -add r_motor.nii.gz -bin b_motor.nii.gz

fslmaths parcels.nii.gz -thr 28 -uthr 28 -bin l_vidc.nii.gz
fslmaths parcels.nii.gz -thr 60 -uthr 60 -bin r_vidc.nii.gz
fslmaths l_vidc.nii.gz -add r_vidc.nii.gz b_vidc.nii.gz



rm parcels.nii.gz
rm parcels2009.nii.gz


module load matlab

echo "Split the hippocampus and fusiform gyrus"
matlab -nodisplay -nodesktop -r "run ${EXPPATH}/scripts/split_fus_hip_func(${SUBNUM})"