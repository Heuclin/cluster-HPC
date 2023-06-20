#!/bin/bash

####################################################################
# Benjamin Heuclin, UR AIDA, PERSYST, CIRAD              
# février 2023
# script batch pour soumission job sur 10 CPUs sur 1 noeud
###################################################################

#SBATCH --partition=agap_short  # la partition
#SBATCH --job-name ex1.2          # nom du job
#SBATCH --nodes=1               # NB noeuds (openMP -> 1)
#SBATCH --ntasks=10             # NB tasks (MPI processes)
#SBATCH --mem-per-cpu=100M      # Mémoire par CPU
#SBATCH --time=00:10:00         # Temps limite
#
#SBATCH --mail-type=all         # send email notifications
#SBATCH --mail-user=benjamin.heuclin@cirad.fr

module purge
module load cv-standard
module load R/4.1.0 R/packages/4.1.0



cd $SLURM_SUBMIT_DIR

mkdir ./Rout 
mkdir ./results
R CMD BATCH ./main_script.R    ./Rout/main_script.Rout

# Rscript ./main_script.R 

# Pour obtenir des informations sur le job dans le fichier de sortie .out
seff $SLURM_JOB_ID


