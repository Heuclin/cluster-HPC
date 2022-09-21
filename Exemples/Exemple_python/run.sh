#!/bin/bash
#SBATCH --partition=agap_short
#SBATCH --job-name=py-job        # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem=1G         
#SBATCH --time=00:01:00          # total run time limit (HH:MM:SS)
#SBATCH -o outfile.out  		 # send stdout to outfile
#SBATCH -e errfile.err  		 # send stderr to errfile
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=benjamin.heuclin@cirad.fr

module purge
module load python/Anaconda/3-5.1.0
# conda activate ml-env

python matrix_inverse.py