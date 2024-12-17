#!/bin/bash 
#SBATCH --job-name=colabbatch
#SBATCH --partition=gpu-highmem
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --mem=0
#SBATCH --time=01:00:00
#SBATCH --account=${PAWSEYPROJECT}-gpu

module load singularity/4.1.0-mpi
 
A3M=/path/to/a3m #path to input MSA alignment file
OUT=$MYSCRATCH/colabfold/${SLURM_JOB_ID} # name of the output directory 

export SINGULARITYENV_XLA_PYTHON_CLIENT_PREALLOCATE=0
export SINGULARITYENV_TF_FORCE_UNIFIED_MEMORY="1"
export SINGULARITYENV_XLA_PYTHON_CLIENT_MEM_FRACTION="4.0"
export SINGULARITYENV_TF_FORCE_GPU_ALLOW_GROWTH="true"
export SINGULARITYENV_JAX_PLATFORMS="rocm"
export SINGULARITYENV_AMD_LOG_LEVEL=3
openssl s_client -connect api.colabfold.com:443 

# Run colab container
srun -N 1 -n 1 -c 8 --gres=gpu:1 --gpu-bind=closest \
  singularity exec colabfoldv8.sif bash -c "colabfold_batch --num-recycle 5 --pair-mode unpaired --model-type alphafold2_multimer_v3 --num-models 3 $A3M $OUT"
