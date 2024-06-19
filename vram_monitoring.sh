#!/bin/bash

# Set your SLURM job ID here
SLURM_JOB_ID=$1

while true; do
    # Check if the SLURM job is still running
    if squeue -j $SLURM_JOB_ID --noheader --format="%t" | grep -q "R\|PD"; then
        # Log the date and VRAM usage if the job is still running
        echo echo -e "$(date +"%Y-%m-%d %H:%M:%S")\n$(rocm-smi --showmemuse | grep 'use' | awk '{print $7}')" >> ${SLURM_JOB_ID}_vram_usage.log
        sleep 60
    else
        # Exit the loop if the job is no longer running
        echo "SLURM job $SLURM_JOB_ID has completed."
        break
    fi
done
