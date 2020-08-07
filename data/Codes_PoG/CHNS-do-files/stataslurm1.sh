#!/bin/sh
#!/bin/bash
#SBATCH --partition=general-bionic
#SBATCH --ntasks=1            # One task
#SBATCH --job-name=BPP
#SBATCH --cpus-per-task=6    # Use up to 6 CPUs in this task
#SBATCH --mem=100000         # 100000 MB of RAM
                             # The job will be automatically killed if it goes > 10000 minutes
#SBATCH --time=10000:00

#This batch can be run in Linux by typing the following command: sbatch stataSLURM1.sh

export STATATMP=/lcl/data/lscratch 

cd `pathf $SLURM_SUBMIT_DIR`  # Go to the calling directory


srun stata-mp -b do /msu/home/m1rxk02/Edmund/time-aggregation/Papers/PriceOfGrowth/data/Codes_PoG/CHNS-do-files/CHNS-master.do
