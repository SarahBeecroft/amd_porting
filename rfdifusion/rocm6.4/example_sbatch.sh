#!/bin/bash -l
#SBATCH --job-name=rfdiffusion
#SBATCH -A pawsey0012-gpu
#SBATCH --nodes=1
#SBATCH --partition=gpu
#SBATCH --time=2:00:00
#SBATCH --gres=gpu:1

# Load required modules
module load singularity/3.11.4-nompi

ContainerImage=/scratch/pawsey0001/sbeecroft/amd_porting/rfdifussion/rfdiff.sif

export PYTHONPATH="/app/RFdiffusion:$PYTHONPATH"

# Set up working directory and output directory. This can be edited to suit you
WORKDIR=${MYSCRATCH}/rfdiffusion_runs/${SLURM_JOB_ID}
mkdir -p ${WORKDIR}
cd ${WORKDIR}
OUTDIR=${WORKDIR}/test_outputs/test
mkdir -p ${OUTDIR}
#Create schedules dir for RFDiffusion to use
mkdir -p schedules
export PYTHONWARNINGS="ignore"
# Run RFdiffusion
srun -N 1 -n 1 -c 8 --gres=gpu:1 \
singularity exec \
-B schedules:/app/RFdiffusion/rfdiffusion/inference/../../schedules \
${ContainerImage} \
run_inference.py \
inference.model_directory_path=/app/RFdiffusion/models \
inference.output_prefix=${OUTDIR} \
'contigmap.contigs=[150-150]' \
inference.num_designs=10
