#!/bin/bash
#
#SBATCH --job=Simulation_TTE
#SBATCH --output="./out/prints_hpc_%x_%j.txt"
#
#SBATCH --ntasks=1
#SBATCH --time=96:00:00
#SBATCH --cpus-per-task=27
#SBATCH --mem-per-cpu=10G
#SBATCH --chdir="./"
#SBATCH --mail-type=ALL
#SBATCH --mail-user=f.j.metwaly@umcutrecht.nl
#





#echo "Generating data"
#Rscript "./scripts/gen_data.R" &> out/gen_data_log.txt

#echo "TTE Julia"
#julia --threads 70 "./scripts/est_surv_Julia.jl" &> out/julia_log.txt

#echo "TTE R"
#Rscript "./scripts/est_surv_R.R" &> out/r_log.txt

# Read the file path corresponding to this array task
FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" file_list.txt)

# Pass it to R
Rscript est_naive.R "$FILE"