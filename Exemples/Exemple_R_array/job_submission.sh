#!/bin/bash

####################################################################
# Benjamin Heuclin, UR AIDA, PERSYST, CIRAD              
# février 2023
# script batch pour soumission job en array 
###################################################################

#SBATCH --partition=agap_short  # la partition
#SBATCH --job-name array        # nom du job
#SBATCH --array=1-12
#SBATCH -o array-%a.out
#SBATCH --mem-per-cpu=100M      # Mémoire par CPU
#SBATCH --time=00:30:00         # Temps limite

module purge
module load R/4.1.0 R/packages/4.1.0


cd $SLURM_SUBMIT_DIR

mkdir ./results
Rscript ./main_script.R $SLURM_ARRAY_TASK_ID

# Pour obtenir des informations sur le job dans le fichier de sortie .out
seff $SLURM_JOB_ID


