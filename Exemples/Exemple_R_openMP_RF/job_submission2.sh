#!/bin/bash
#SBATCH --partition=agap_short  # la partition
#SBATCH --job-name openMP_RF2   # nom du job
#SBATCH --nodes=1               # NB noeuds (openMP -> 1)
#SBATCH --ntasks=10             # NB tasks (MPI processes)
#SBATCH --mem-per-cpu=100M      # Mémoire par CPU
#SBATCH --time=00:10:00         # Temps limite
#
#SBATCH --mail-type=begin       # send email when job begins
#SBATCH --mail-type=end         # send email when job ends
#SBATCH --mail-user=benjamin.heuclin@cirad.fr

module purge
module load cv-standard
module load R/3.6.1



cd $SLURM_SUBMIT_DIR

mkdir ./Rout 
mkdir ./results 
R CMD BATCH ./script_RF.R    ./Rout/script_RF.Rout

# Rscript ./script_RF.R 




