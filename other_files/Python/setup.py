import subprocess
from pathlib import Path
from multiprocessing import Pool

seeds = [6,7,8,9]

def run_scripts(seeds):
    for seed in seeds:
        subprocess.run(["Rscript", "R/Sim1/gen_data.R", str(seed)], check=True)

        julia_process = subprocess.Popen(["julia", "Julia/Sim1/TTE.jl", str(seed)])
        r_process = subprocess.Popen(["Rscript", "R/Sim1/TTE.R", str(seed)])

        # Wait for both scripts to finish for the given seed
        julia_process.wait()
        r_process.wait()

        # remove the generated data
        Path.unlink(f"out/Sim1/data_gen_sim{seed}.csv")

    print("\nAll scripts finished executing")


def main():
    run_scripts(seeds)


# add progress bar

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