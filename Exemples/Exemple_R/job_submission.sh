#!/bin/bash
#SBATCH --partition=agap_short
#SBATCH --job-name ex1
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem-per-cpu=1G
#SBATCH --time=01:00:00
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=benjamin.heuclin@cirad.fr


module load cv-standard
module load R
module load gcc

R CMD BATCH /storage/replicated/cirad/projects/AIDA/Atelier_cluster/Exemple_1/main_script.R    /storage/replicated/cirad/projects/AIDA/Atelier_cluster/Exemple_1/Rout/main_script.Rout





