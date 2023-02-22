#!/bin/bash

####################################################################
# Benjamin Heuclin, UR AIDA, PERSYST, CIRAD              
# February 2023
# script batch for openMP job soumission
###################################################################

#SBATCH --partition=agap_short  # The partition
#SBATCH --job-name ex1          # Job name
#SBATCH --nodes=1               # NB nodes (MPI processe, openMP -> 1)
#SBATCH --ntasks=1              # NB tasks (MPI processe, openMP -> 1)
#SBATCH --ntasks-per-node=1     # NB tasks per node (MPI processe, openMP -> 1)
#SBATCH --cpus-per-task=10      # NB CPUs per task
#SBATCH --mem-per-cpu=100M      # Memory per CPU
#SBATCH --time=00:10:00         # Time limite

module purge 
module load cv-standard
module load R/3.6.1

# OpenMP runtime settings
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

cd $SLURM_SUBMIT_DIR    # To go to the directory where the .sh is executed

mkdir ./Rout            # Create the "Rout"" folder for the R console outputs
mkdir ./results         # Create the "results" folder to save my results
R CMD BATCH ./main_script.R    ./Rout/main_script.Rout # submit the R job

# To get job information after running (used memory, time, ...) in the .out file
seff $SLURM_JOB_ID


