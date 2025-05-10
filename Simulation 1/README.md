# Simulation 1

Simulation 1 aim to replicate the conditions of (...) with the difference of conducting an ITT analysis instead of a PP analysis.

## Simulation Parameters

Outcome event rate  | Sample size   | Confounding strength  | Treatment prevelance  |
-4.7                | 200           | 0.1                   | -1                    |
-3.8                | 1000          | 0.5                   | 0                     |
-3.0                | 5000          | 0.9                   | 1                     |

The number of visits is set to 5. All simulations are run with 1000 iterations.

## Files
    - simulate_MSM_simplified.R: retreived from https://github.com/juliettelimozin/Multiple-trial-emulation-IPTW-MSM-CIs/blob/ab7652133df470cbfb4e2d7ff9e7122eb40306fd/Code/simulate_MSM_simplified.R#L5

    The Monte Carlo Errors (MCE) can be found in the file `out/MCE/MCE.csv`, plots of the MCE can be found in the folder `out/MCE/plots/`.