import subprocess
from pathlib import Path

seeds = 1 # slurm ID
sample_size = 500 # input form bash script

def run_scripts(seeds):
    for seed in seeds:
        subprocess.run(["Rscript", "scripts/gen_data.R", str(seed)], check=True)

        julia_process = subprocess.Popen(["julia", "scripts/TTE.jl", str(seed)])
        r_process = subprocess.Popen(["Rscript", "scripts/TTE.R", str(seed)])


def main():
    run_scripts(seeds)

if __name__ == "__main__":
    main()





# seed 3 error R:
"""
Warning messages:
1: In eval(family$initialize) : non-integer #successes in a binomial glm!
2: glm.fit: fitted probabilities numerically 0 or 1 occurred 
Error in mvtnorm::rmvnorm(n = samples, mean = coef(model), sigma = object$robust$matrix) :
  sigma must be a symmetric matrix
Calls: predict -> predict.TE_msm -> rbind -> <Anonymous>
Execution halted
"""

# Try and catch error?