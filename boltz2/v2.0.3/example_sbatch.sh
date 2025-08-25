#!/bin/bash -l
#SBATCH --account=${PAWSEY_PROJECT}-gpu
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=02:00:00
#SBATCH --job-name=boltz_prediction

# Load required modules
module load pawseyenv/2023.08
module load singularity/3.11.4-nompi

mkdir -p $MYSCRATCH/boltz/inputs
cd $MYSCRATCH/boltz/inputs

# Set container
containerImage=/scratch/pawsey0001/sbeecroft/boltz_git/boltz2.0.3.sif
# Set input dir
INPUTDIR=$MYSCRATCH/boltz/inputs

# Set output directory
OUTDIR=$MYSCRATCH/boltz/${SLURM_JOB_ID}
mkdir -p ${OUTDIR}

# Set cache directory
CACHEDIR=$MYSCRATCH/boltz/cache
mkdir -p ${CACHEDIR}
# Set numba cache dir
export numba_cache_dir=$MYSCRATCH/numba_cache_dir/${SLURM_JOB_ID}
mkdir -p ${numba_cache_dir}
# Run Boltz prediction with bind mounting for the directories we need
srun -N 1 -n 1 -c 8 --gres=gpu:1 \
    singularity exec \
    -B ${numba_cache_dir} \
    -B ${INPUTDIR} \
    -B ${OUTDIR} \
    -B ${CACHEDIR} \
    -B ${CACHEDIR}:/usr/local/lib/python3.12/dist-packages/trifast/configs/ \
    ${containerImage} boltz predict \
    ${INPUTDIR}/5u6x.fasta \
    --cache ${CACHEDIR} \
    --use_msa_server \
    --out_dir ${OUTDIR}
