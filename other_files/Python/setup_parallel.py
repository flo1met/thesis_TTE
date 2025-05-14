import subprocess
from pathlib import Path
from multiprocessing import Pool
from tqdm import tqdm 

seeds = range(1, 20)

def run_scripts(seed):
    subprocess.run(["Rscript", "R/Sim1/gen_data.R", str(seed)], check=True)

    julia_process = subprocess.Popen(["julia", "Julia/Sim1/TTE.jl", str(seed)])
    r_process = subprocess.Popen(["Rscript", "R/Sim1/TTE.R", str(seed)])

    julia_process.wait()
    r_process.wait()

    # Remove the generated data
    Path(f"out/Sim1/data_gen_sim{seed}.csv").unlink()

def run_scripts_parallel(seeds):
    with Pool() as p:
        list(tqdm(p.imap_unordered(run_scripts, seeds), total=len(seeds)))

def main():
    run_scripts_parallel(seeds)

if __name__ == "__main__":
    main()
