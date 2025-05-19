# Appendix G

In Appendix G we recreate a bootstrap scenario to investigate the problems in confidence interval estimation. We confirm the suspicion that the bootstrap results in a skewed distribution.

## Files
- `datasets/`: Contains the datasets used in the bootstrap scenario. The datasets are generated using the `gen_data.R` script.
- `out/`: Contains the results of the bootstrap scenario. The results are saved in `.csv` files. All plots are saved as `.png` files.
- `scripts/`: Contains all script necessary to replicate the bootstrap scenario. The following scripts are included:
    - `gen_data.R`: Script to generate the datasets. The datasets are saved in the `datasets/` folder. 
    - `BS_save_distribution.jl`: Script to conduct the bootstrap scenario in Julia and save the bootstrap distributions.
    - `plots.R`: Script to create the plots for the bootstrap scenario.

## Results
All results can be recreated using the seeded scripts described above, in the order they are listed. The results then are saved in the `out/` folder.