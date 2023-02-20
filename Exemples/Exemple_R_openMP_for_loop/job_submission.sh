#!/bin/bash

####################################################################
# Benjamin Heuclin, UR AIDA, PERSYST, CIRAD              
# février 2023
# script batch pour soumission job en openMP
###################################################################

#SBATCH --partition=agap_short  # la partition
#SBATCH --job-name ex1          # nom du job
#SBATCH --nodes=1               # NB noeuds (MPI processes, openMP -> 1)
#SBATCH --ntasks=1              # NB tâches (MPI processes, openMP -> 1)
#SBATCH --ntasks-per-node=1     # NB tâches par noeud (MPI processes, openMP -> 1)
#SBATCH --cpus-per-task=10      # NB CPUs par task
#SBATCH --mem-per-cpu=100M      # Mémoire par CPU
#SBATCH --time=00:10:00         # Temps limite


module purge
module load cv-standard
module load R/3.6.1

# OpenMP runtime settings
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

cd $SLURM_SUBMIT_DIR

mkdir ./Rout 
mkdir ./results
R CMD BATCH ./main_script.R    ./Rout/main_script.Rout

# Rscript ./main_script.R 

# Pour obtenir des informations sur le job dans le fichier de sortie .out
seff $SLURM_JOB_ID



