#!/bin/bash

#SBATCH --mem=4000 --output=logs/15_mm_effect_mvpa_%j.txt 

source ~/Data/conda/bin/activate ''
conda activate dicat_RSA

python mm_effect_class.py 