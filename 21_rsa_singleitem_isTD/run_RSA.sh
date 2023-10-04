#!/bin/bash

#SBATCH --mem=4000 --output=logs/21_rsa_%j.txt 



source ~/Data/conda/bin/activate ''
conda activate dicat_RSA

python katzer_rsa.py

