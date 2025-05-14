import subprocess
import time
import psutil
from pathlib import Path
import sys
import csv

# These come from the SLURM wrapper script
seed = int(sys.argv[1])      # e.g., SLURM_ARRAY_TASK_ID
sample_size = int(sys.argv[2])  # 500, 5000, etc.

log_dir = Path("out/logs")
log_dir.mkdir(parents=True, exist_ok=True)

summary_path = log_dir / "timing_summary.csv"
# check if file exists if not write header
write_header = not summary_path.exists()


def run_and_monitor(cmd, log_path):
    with open(log_path, "w") as log_file:
        start_time = time.time()
        proc = subprocess.Popen(cmd, stdout=log_file, stderr=subprocess.STDOUT)
        p = psutil.Process(proc.pid)
        peak_mem = 0

        while proc.poll() is None:
            try:
                mem = p.memory_info().rss
                peak_mem = max(peak_mem, mem)
            except psutil.NoSuchProcess:
                break
            time.sleep(0.1)

        proc.wait()
        runtime = time.time() - start_time

    return round(runtime / 60, 2), round(peak_mem / 1024**2, 2)  # seconds, MB


def main():
    # Generate data
    subprocess.run(["Rscript", "scripts/gen_data.R", str(seed), str(sample_size)], check=True)

    # Run Julia
    julia_log = log_dir / f"julia_out_seed{seed}_n{sample_size}.log"
    julia_runtime, julia_mem = run_and_monitor(["julia", "scripts/TTE.jl", str(seed)], julia_log)

    # Run R
    r_log = log_dir / f"r_out_seed{seed}_n{sample_size}.log"
    r_runtime, r_mem = run_and_monitor(["Rscript", "scripts/TTE.R", str(seed)], r_log)

    # Save timing + memory summary
    with open(summary_path, "a", newline="") as csvfile:
        writer = csv.writer(csvfile)
        if write_header:
            writer.writerow(["seed", "sample_size", "language", "runtime_min", "peak_memory_MB"])

        writer.writerow([seed, sample_size, "Julia", julia_runtime, julia_mem])
        writer.writerow([seed, sample_size, "R", r_runtime, r_mem])

if __name__ == "__main__":
    main()
