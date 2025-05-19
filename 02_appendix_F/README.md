# Appendix F

In Appendix F we conduct a speed test comparison between R and Julia in the context of sequential Target Trial Emulation. 

## Files
- `datasets/`: Contains the datasets used in the speed test. The datasets are generated using the `gen_data.R` script.
- `out/`: Contains the results of the speed test. The results are saved in `.csv` files. All plots are contained in the `plots/` folder.
- `scripts/`: Contains all script necessary to replicate the speed test. The following scripts are included:
    - `gen_data.R`: Script to generate the datasets. The datasets are saved in the `datasets/` folder. 
    - `speed.R`: Script to conduct the speed test in R.
    - `speed.jl`: Script to conduct the speed test in Julia.
    - `speed_noCI.R`: Script to conduct the speed test in R without confidence interval estimation.
    - `speed_noCI.jl`: Script to conduct the speed test in Julia without confidence interval estimation.
    - `plots.R`: Script to create the plots for the speed test.

## Results
All results can be recreated using the seeded scripts described above, in the order they are listed. The results then are saved in the `out/` folder.