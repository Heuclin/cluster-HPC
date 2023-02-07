#!/bin/bash
#SBATCH --partition=agap_short  # la partition
#SBATCH --job-name ex1          # nom du job
#SBATCH --nodes=1               # NB noeuds (MPI processes, openMP -> 1)
#SBATCH --ntasks=1              # NB tâches (MPI processes, openMP -> 1)
#SBATCH --ntasks-per-node=1     # NB tâches par noeud (MPI processes, openMP -> 1)
#SBATCH --cpus-per-task=10      # NB CPUs par task
#SBATCH --mem-per-cpu=100M      # Mémoire par CPU
#SBATCH --time=00:10:00         # Temps limite
#
#SBATCH --mail-type=begin       # send email when job begins
#SBATCH --mail-type=end         # send email when job ends
#SBATCH --mail-user=benjamin.heuclin@cirad.fr

module purge
module load cv-standard
module load R/3.6.1

# OpenMP runtime settings
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

cd $SLURM_SUBMIT_DIR

mkdir ./Rout 
R CMD BATCH ./main_script.R    ./Rout/main_script.Rout

# Rscript ./main_script.R 




