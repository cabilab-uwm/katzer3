#!/bin/bash

#SBATCH --mem=4000 --output=logs/18_mvpa_%j.txt 

source ~/Data/conda/bin/activate ''
conda activate dicat_RSA

python category_class.py 