from threading import Thread
import subprocess
import time
import psutil
from pathlib import Path
import sys
import csv


# these come from the SLURM wrapper script
seed = int(sys.argv[1])      # SLURM_ARRAY_TASK_ID (arg 1)
sample_size = int(sys.argv[2])  # Sample Size (arg 2)


log_dir = Path("out/logs")
log_dir.mkdir(parents=True, exist_ok=True)

summary_path = log_dir / "timing_summary.csv"
# check if file exists if not write header
write_header = not summary_path.exists()


def monitor_process(proc, log_path, result_dict, label):
    with open(log_path, "w") as log_file:
        start_time = time.time()
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

    result_dict[label] = (round(runtime / 60, 2), round(peak_mem / 1024**2, 2))

def main():
    subprocess.run(
    ["Rscript", "scripts/gen_data.R", str(seed), str(sample_size)],
    check=True,
    stdout=open(f"out/logs/gen_data_seed{seed}_n{sample_size}.log", "w"),
    stderr=subprocess.STDOUT
    ) 

    result = {}

    julia_log = log_dir / f"julia_out_seed{seed}_n{sample_size}.log"
    r_log = log_dir / f"r_out_seed{seed}_n{sample_size}.log"

    julia_proc = subprocess.Popen(["julia", "scripts/est_surv_Julia.jl", str(seed), str(sample_size)], stdout=open(julia_log, "w"), stderr=subprocess.STDOUT)
    r_proc = subprocess.Popen(["Rscript", "scripts/est_surv_R.R", str(seed), str(sample_size)], stdout=open(r_log, "w"), stderr=subprocess.STDOUT)

    # monitor processes
    t1 = Thread(target=monitor_process, args=(julia_proc, julia_log, result, "Julia"))
    t2 = Thread(target=monitor_process, args=(r_proc, r_log, result, "R"))

    t1.start()
    t2.start()
    # wait for both threads to finish
    t1.join()
    t2.join()

    # Save CSV
    with open(summary_path, "a", newline="") as csvfile:
        writer = csv.writer(csvfile)
        if write_header:
            writer.writerow(["seed", "sample_size", "language", "runtime_min", "peak_memory_MB"])

        for lang in ["Julia", "R"]:
            runtime, mem = result[lang]
            writer.writerow([seed, sample_size, lang, runtime, mem])

if __name__ == "__main__":
    main()
