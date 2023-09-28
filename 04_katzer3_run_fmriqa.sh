#!/bin/bash

#SBATCH --mem=4000 --output=logs/katzer3_04_fmriqa_%j.out


ssid=$1
sbjdir=~/Data/katzer3/sub-${ssid}/func/prepro
scriptdir=$(pwd)
qadir=~/Data/fmriqa


cd ${qadir}

source ~/Data/conda/bin/activate ''

conda activate fmriqa


RUNS="perceptio_labels_run-1 perception_label_run-2 perception_nolabel_run-1 perception_nolabels_run-2 recall_run-1 recall_run-2"

for runNr in $RUNS
do

python fmriqa.py ${sbjdir}/${runNr}_brain_mcf.nii.gz 2

mv ${sbjdir}/QA ${sbjdir}/QA_${runNr}

done

conda deactivate

cd ${scriptdir}
