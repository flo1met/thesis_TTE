import subprocess
from concurrent.futures import ThreadPoolExecutor

seeds = [1, 2, 3, 4, 5]

# Step 1: Generate Data Sequentially (R Script)
for seed in seeds:
    subprocess.run([r"C:\Program Files\R\R-4.4.1\bin\Rscript.exe", "R/Sim1/gen_data.R", str(seed)], check=True)

# Step 2: Run Julia and R Scripts in Parallel
def run_scripts(seed):
    """Run both Julia and R analysis scripts in parallel."""
    julia_process = subprocess.Popen(["julia", "Julia/Sim1/TTE.jl", str(seed)])
    r_process = subprocess.Popen(["Rscript", "R/Sim1/TTE.R", str(seed)])
    
    # Wait for both scripts to finish for the given seed
    julia_process.wait()
    r_process.wait()

# Use ThreadPoolExecutor to parallelize execution across seeds
with ThreadPoolExecutor() as executor:
    executor.map(run_scripts, seeds)

print("All scripts finished executing.")
