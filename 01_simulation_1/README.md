# Simulation 1

Simulation 1 aim to replicate the conditions of Limozin et. al. (2024) with the difference of conducting an ITT analysis instead of a PP analysis. This folder contains all scripts and results for the simulation study. The simulation study is conducted in R and Julia, with the R code being used for the analysis of the results. The simulation study is conducted using a Monte Carlo approach, with 1000 iterations for each simulation.

## Simulation Parameters

Outcome event rate  | Sample size   | Confounding strength  | Treatment prevelance  |
--------------------|---------------|-----------------------|-----------------------|
-4.7                | 200           | 0.1                   | -1                    |
-3.8                | 1000          | 0.5                   | 0                     |
-3.0                | 5000          | 0.9                   | 1                     |

The number of visits is set to 5. All simulations are run with 1000 iterations.

## Files
- `datasets/`: A placeholder folder for the datasets. As the datasets are simulated on a High Performance Computer (HPC), the datasets are not included in the repository. The datasets can be generated using the code in the `01_simulation_1/` folder. For a description of how to replicate the datasets and results, see the Results section.
- `out/`
    - `Julia/`: Contains the results of the bootstrapped confidence intervals. The results are saved in `.arrow` files, which can be read using the `arrow` package in R. The structure of naming is as follows: `Julia_MRD_data_[sample size]_[outcome event rate]_[confounding strength]_[treatment prevelance].arrow`.
    - `R/`: Contains the results of the sandwich-type confidence intervals. The results are saved in `.arrow` files, which can be read using the `arrow` package in R. The structure of naming is as follows: `R_MRD_data_[sample size]_[outcome event rate]_[confounding strength]_[treatment prevelance].arrow`.
    - `measures/`: Contains the calculated performance emasures for each scenario. The results are saved in `.arrow` files. Two versions of the performance measures are saved. `measures_[R/Julia]_[sample size]_[outcome event rate]_[confounding strength]_[treatment prevelance].arrow` contains the performance measures of each simulation run. `measures_agg_[R/Julia]_[sample size]_[outcome event rate]_[confounding strength]_[treatment prevelance].arrow` contains the aggregated performance measures.
    - `plots/`: all plots used in the thesis.
    - `true_values/`: Generated true values for the simulation study.
    - `all_measures`: An .xlsx file containing human readable results of the simulation study. This includes all performance measures and their respective Monte Carlo Errors (MCE).
- `scripts/`: Contains all script necessary to replicate the simulation and all results. The following scripts are included:
    - `gen_data.R`: Script to generate the datasets. The datasets are saved in the `datasets/` folder. The datasets are generated using the `simulate_MSM_simplified.R` script. The script is run on a High Performance Computer (HPC) using the `shell.sh` script.
    - `gen_true.R`: Script to generate the true values for the simulation study. The true values are saved in the `true_values/` folder. The script is run on a High Performance Computer (HPC) using the `shell.sh` script.
    - `est_surv_Julia.jl`: Script to estimate the estimate of interest and the confidence interval using the Julia package `TargetTrialEmualtion.jl`. The script is run on a High Performance Computer (HPC) using the `shell.sh` script.
    - `est_surv_R.R`: Script to estimate the estimate of interest and the confidence interval using the R package `TrialEmualtion`. The script is run on a High Performance Computer (HPC) using the `shell.sh` script.
    - `simulate_MSM_simplified.R`: Script to simulate the datasets. The script is run on a High Performance Computer (HPC) using the `shell.sh` script. The script is taken from the Limozin et. al. (2024) repository and modified to fit the needs of this project.
    - `process_R_new.R`: Script to process the results of the R simulation.
    - `process_Julia_new.R`: Script to process the results of the Julia simulation.
    - `outputs.R`: Script to create the output files, i.e. all plots and the .xlsx file with the performance measures.
    - `shell.sh`: Shell script to run the simulation on a High Performance Computer (HPC). The script is run using the `sbatch` command. The script is used to run the `gen_data.R`, `gen_true.R`, `est_surv_Julia.jl`, and `est_surv_R.R` scripts on the HPC.
- `README.md`: This file.


## Results
The simulation is run on a High Performance Computer (HPC) using the `shell.sh` script. The script is used to run the `gen_data.R`, `gen_true.R`, `est_surv_Julia.jl`, and `est_surv_R.R` scripts on the HPC. The datasets can not be stored here as they are too big (~100GB in total). The datasets can be exactly recreated using the seeded `gen_data.R` script. The results are saved in the `out/` folder. The results are saved in `.arrow` files, which can be read using the `arrow` package in R. The results are saved in the following format: `[R/Julia]_[sample size]_[outcome event rate]_[confounding strength]_[treatment prevelance].arrow`. The results can be processed using the `process_R_new.R` and `process_Julia_new.R` scripts and the outputs can be recreated using the `outputs.R` script.

## References
- Limozin, J. M., Seaman, S. R., & Su, L. (2024). Inference procedures in sequential trial emulation with survival outcomes: comparing confidence intervals based on the sandwich variance estimator, bootstrap and jackknife. *arXiv preprint arXiv:2407.08317*.