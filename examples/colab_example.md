# Running ColabFold on Setonix
## Overview

This guide explains how to run ColabFold batch jobs on Pawsey's Setonix supercomputer. ColabFold is a simplified and accelerated implementation of AlphaFold that can work with pre-computed Multiple Sequence Alignments (MSAs). Please note there is currently a memory limitation that restricts computations to proteins of approximately 3,013 amino acids or less. Attempting to process larger proteins will result in out-of-memory errors.

## Prerequisites

- A Pawsey account with GPU allocation
- Pre-computed MSA file in A3M format
- Basic familiarity with SLURM job submission

## Job Script Template

Below is a template SLURM script for running ColabFold. Save this as `run_colabfold.slurm`:

```bash
#!/bin/bash 
#SBATCH --job-name=colabbatch
#SBATCH --partition=gpu-highmem
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --mem=0
#SBATCH --time=01:00:00
#SBATCH --account=${PAWSEYPROJECT}-gpu

# Load required module
module load singularity/4.1.0-mpi

# Set input and output paths
A3M=/path/to/your/msafile.a3m
OUT=$MYSCRATCH/colabfold/${SLURM_JOB_ID}

# Environment settings for optimal GPU performance
export SINGULARITYENV_XLA_PYTHON_CLIENT_PREALLOCATE=0
export SINGULARITYENV_TF_FORCE_UNIFIED_MEMORY="1"
export SINGULARITYENV_XLA_PYTHON_CLIENT_MEM_FRACTION="4.0"
export SINGULARITYENV_TF_FORCE_GPU_ALLOW_GROWTH="true"
export SINGULARITYENV_JAX_PLATFORMS="rocm"
export SINGULARITYENV_AMD_LOG_LEVEL=3

# Verify connection to ColabFold API
openssl s_client -connect api.colabfold.com:443 

# Run ColabFold
srun -N 1 -n 1 -c 8 --gres=gpu:1 --gpu-bind=closest \
  singularity exec colabfoldv8.sif bash -c "colabfold_batch \
    --num-recycle 5 \
    --pair-mode unpaired \
    --model-type alphafold2_multimer_v3 \
    --num-models 3 \
    $A3M $OUT"
```

## Key Parameters and Settings

1. **Resource Allocation**:
   - Uses the `gpu-highmem` partition
   - Requests 1 GPU
   - Sets unlimited memory (`--mem=0`)
   - Default runtime is 1 hour
   - Uses 8 CPU cores

2. **Environment Variables**:
   ```bash
   SINGULARITYENV_XLA_PYTHON_CLIENT_PREALLOCATE=0
   SINGULARITYENV_TF_FORCE_UNIFIED_MEMORY="1"
   SINGULARITYENV_XLA_PYTHON_CLIENT_MEM_FRACTION="4.0"
   SINGULARITYENV_TF_FORCE_GPU_ALLOW_GROWTH="true"
   SINGULARITYENV_JAX_PLATFORMS="rocm"
   SINGULARITYENV_AMD_LOG_LEVEL=3
   ```
   These settings optimize GPU memory usage and performance on Setonix's AMD GPUs.

3. **ColabFold Settings**:
   - `--num-recycle 5`: Number of prediction refinement cycles
   - `--pair-mode unpaired`: For single chain predictions
   - `--model-type alphafold2_multimer_v3`: Uses the latest multimer model
   - `--num-models 3`: Generates 3 prediction models

## Before Running

1. Modify the input path:
   ```bash
   A3M=/path/to/your/msafile.a3m
   ```

2. Optional: Adjust the output directory:
   ```bash
   OUT=$MYSCRATCH/colabfold/${SLURM_JOB_ID}
   ```

3. Replace `${PAWSEYPROJECT}` with your project code.

## Running Your Job

1. Submit your job:
   ```bash
   sbatch run_colabfold.slurm
   ```

2. Monitor your job:
   ```bash
   squeue -u $USER
   ```

## Output Files

ColabFold will create a directory with the job ID containing:
- Predicted structures in PDB format
- Confidence scores
- Ranking information
- Log files

## Common Issues and Solutions

1. **API Connection**: The script checks the connection to the ColabFold API. If this fails, ensure you have internet connectivity from your compute node.

2. **Memory Issues**: If you encounter memory errors:
   - Try adjusting `XLA_PYTHON_CLIENT_MEM_FRACTION`
   - Consider using a shorter runtime with more attempts
   - Check if your input MSA is too large

## Support

For issues or questions:
- Contact Pawsey Help Desk: help@pawsey.org.au
- Visit the ColabFold GitHub repository for software-specific issues
