#!/bin/bash
#SBATCH --partition=agap_short  # la partition
#SBATCH --job-name array          # nom du job
#SBATCH --array=1-12
#SBATCH -o array-%a.out
#SBATCH --mem-per-cpu=100M      # Mémoire par CPU
#SBATCH --time=00:30:00         # Temps limite
#
#SBATCH --mail-type=begin       # send email when job begins
#SBATCH --mail-type=end         # send email when job ends
#SBATCH --mail-user=benjamin.heuclin@cirad.fr

module purge
module load cv-standard
module load R/3.6.1


cd $SLURM_SUBMIT_DIR

Rscript ./main_script.R $SLURM_ARRAY_TASK_ID




