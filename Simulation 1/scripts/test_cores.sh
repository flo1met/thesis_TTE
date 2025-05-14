#!/bin/bash

echo "=== SLURM info ==="
echo "SLURM_CPUS_ON_NODE = $SLURM_CPUS_ON_NODE"
echo "SLURM_CPUS_PER_TASK = $SLURM_CPUS_PER_TASK"
echo "SLURM_JOB_CPUS_PER_NODE = $SLURM_JOB_CPUS_PER_NODE"
echo "SLURM_NTASKS = $SLURM_NTASKS"

echo ""
echo "=== System info ==="
echo "Total cores visible to this job:"
nproc

echo ""
echo "Detailed CPU info:"
lscpu | grep -E '^CPU\(s\)|^Thread|^Core|^Socket|Model name'
