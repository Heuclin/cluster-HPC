#!/bin/bash

#SBATCH --partition=agap_short       # la partition
#SBATCH --job-name ex          # nom du job
#SBATCH --nodes=1              # NB noeuds (openMP -> 1)
#SBATCH --ntasks=1             # NB tasks (MPI processes)
#SBATCH --mem-per-cpu=100M       # Mémoire par CPU
#SBATCH --time=0-0:02:00       # Temps limite

module purge
module load python/3.7.2

cd $SLURM_SUBMIT_DIR

python matrix_inverse.py



