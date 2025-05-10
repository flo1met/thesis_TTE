from threading import Thread
import subprocess
import time
import psutil
from pathlib import Path
import sys
import csv
from filelock import FileLock 

# Arguments from SLURM
seed = int(sys.argv[1])         # SLURM_ARRAY_TASK_ID
sample_size = int(sys.argv[2])  # Sample Size

data_dir = Path("out/datasets")
data_dir.mkdir(parents=True, exist_ok=True)

log_dir = Path("out/logs")
log_dir.mkdir(parents=True, exist_ok=True)

summary_path = log_dir / "timing_summary.csv"
summary_lock = summary_path.with_suffix(".lock") 

def monitor_process(proc, result_dict, label):
    p = psutil.Process(proc.pid)
    start_time = time.time()

    alloc_total = 0
    prev_mem = 0

    try:
        while proc.poll() is None:
            mem = p.memory_info().rss
            if mem > prev_mem:
                alloc_total += mem - prev_mem
            prev_mem = mem
            time.sleep(0.05)
    except psutil.NoSuchProcess:
        pass

    proc.wait()
    runtime = round((time.time() - start_time) / 60, 2)
    allocated_MB = round(alloc_total / 1024**2, 2)

    result_dict[label] = (runtime, allocated_MB)

def main():
    # Generate data
    gen_log = log_dir / f"gen_data_seed{seed}_n{sample_size}.log"
    subprocess.run(
        ["Rscript", "scripts/gen_data.R", str(seed), str(sample_size)],
        check=True,
        stdout=open(gen_log, "w"),
        stderr=subprocess.STDOUT
    )

    result = {}

    # Logs
    julia_log = log_dir / f"julia_out_seed{seed}_n{sample_size}.log"
    julia_arrow_log = log_dir / f"julia_arrow_out_seed{seed}_n{sample_size}.log"
    r_log = log_dir / f"r_out_seed{seed}_n{sample_size}.log"

    # Subprocesses
    julia_proc = subprocess.Popen(
        ["julia", "scripts/est_surv_Julia.jl", str(seed), str(sample_size)],
        stdout=open(julia_log, "w"),
        stderr=subprocess.STDOUT
    )
    julia_arrow_proc = subprocess.Popen(
        ["julia", "scripts/est_surv_Julia_arrow.jl", str(seed), str(sample_size)],
        stdout=open(julia_arrow_log, "w"),
        stderr=subprocess.STDOUT
    )
    r_proc = subprocess.Popen(
        ["Rscript", "scripts/est_surv_R.R", str(seed), str(sample_size)],
        stdout=open(r_log, "w"),
        stderr=subprocess.STDOUT
    )

    # Monitor in parallel
    t1 = Thread(target=monitor_process, args=(julia_proc, result, "Julia"))
    t2 = Thread(target=monitor_process, args=(julia_arrow_proc, result, "Julia_arrow"))
    t3 = Thread(target=monitor_process, args=(r_proc, result, "R"))

    t1.start()
    t2.start()
    t3.start()
    t1.join()
    t2.join()
    t3.join()

    # Save CSV with file lock to avoid concurrent header writes
    with FileLock(str(summary_lock)):
        file_exists = summary_path.exists()
        with open(summary_path, "a", newline="") as csvfile:
            writer = csv.writer(csvfile)
            if not file_exists:
                writer.writerow(["seed", "sample_size", "language", "runtime_min", "allocated_MB"])

            for lang in ["Julia", "Julia_arrow", "R"]:
                runtime, mem = result[lang]
                writer.writerow([seed, sample_size, lang, runtime, mem])

if __name__ == "__main__":
    main()
