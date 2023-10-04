#!/bin/bash

#SBATCH --mem=4000 --output=logs/17_fame_effect_mvpa_%j.txt 

source ~/Data/conda/bin/activate ''
conda activate dicat_RSA

python fame_effect_class.py 