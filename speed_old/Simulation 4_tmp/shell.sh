#!/bin/bash
#
#SBATCH --job=Simulation_TTE
#SBATCH --output="./out/prints_hpc_%x_%j.txt"
#
#SBATCH --cpus-per-task=2
#SBATCH --time=72:00:00
#SBATCH --mem-per-cpu=10G
#SBATCH --chdir="./"
#SBATCH --mail-type=ALL
#SBATCH --mail-user=f.j.metwaly@umcutrecht.nl
#
#SBATCH --array=1-100


python3 scripts/setup_wrapper.py $SLURM_ARRAY_TASK_ID 500
python3 scripts/setup_wrapper.py $SLURM_ARRAY_TASK_ID 5000
python3 scripts/setup_wrapper.py $SLURM_ARRAY_TASK_ID 50000
python3 scripts/setup_wrapper.py $SLURM_ARRAY_TASK_ID 500000
python3 scripts/setup_wrapper.py $SLURM_ARRAY_TASK_ID 5000000