#!/bin/bash -l
#SBATCH -A pawsey0001-gpu
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --partition=gpu
#SBATCH --time=10:00:00

#run with single device
export OMP_NUM_THREADS=1
module load singularity/4.1.0-slurm

#export JAX_TRACEBACK_FILTERING=off
#export HIP_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
#export HSA_XNACK=1
#export TF_FORCE_UNIFIED_MEMORY="1"
#export XLA_PYTHON_CLIENT_MEM_FRACTION="8.0"
#export XLA_PYTHON_CLIENT_ALLOCATOR="platform"
#export TF_FORCE_GPU_ALLOW_GROWTH="true"


######s
###### NOTE: 
###### If you do not have `export XLA_PYTHON_CLIENT_ALLOCATOR="platform"` then `export TF_FORCE_UNIFIED_MEMORY="1"` will result in `external/xla/xla/stream_executor/rocm/rocm_driver.cc:1297] Feature not supported on ROCm platform (UnifiedMemoryAllocate)`, and it will fail to allocate even a small amount of VRAM
######


#export XLA_PYTHON_CLIENT_MEM_FRACTION=2 
#export TF_FORCE_UNIFIED_MEMORY=1
#echo "3013aa, alphafold_rocm6.1.1_openmm8.0.0.sif, exclusive node export HIP_VISIBLE_DEVICES=0,1,2,3,4,5,6,7, export TF_FORCE_UNIFIED_MEMORY="1", export XLA_PYTHON_CLIENT_MEM_FRACTION="8.0", export XLA_PYTHON_CLIENT_ALLOCATOR="platform", export TF_FORCE_GPU_ALLOW_GROWTH="true" srun -N 1 -n 1 -c 64 --gpus-per-node=8 --gpus-per-task=8"
#echo "10 aa, alphafold_rocm6.1.1_openmm8.0.0.sif, exclusive node export HIP_VISIBLE_DEVICES=0,1,2,3,4,5,6,7, export TF_FORCE_UNIFIED_MEMORY="1" srun -N 1 -n 1 -c 64 --gpus-per-node=8 --gpus-per-task=8"

echo "3013aa, alphafold_rocm6.1.1.sif exclusive node VANILLA ONLY srun -N 1 -n 1 -c 64 --gpus-per-node=8 --gpus-per-task=8"

srun -N 1 -n 1 -c 64 --gpus-per-node=8 --gpus-per-task=8 \
  singularity exec alphafold_rocm6.1.1_openmm8.0.0.sif python /opt/alphafold/run_alphafold.py \
  --fasta_paths=/scratch/pawsey0001/sbeecroft/alpha_validation/3013aa.fasta \
  --model_preset=monomer \
  --use_gpu_relax=True \
  --benchmark=False \
  --uniref90_database_path=/scratch/references/alphafold_feb2024/databases/uniref90/uniref90.fasta \
  --mgnify_database_path=/scratch/references/alphafold_feb2024/databases/mgnify/mgy_clusters_2022_05.fa \
  --pdb70_database_path=/scratch/references/alphafold_feb2024/databases/pdb70/pdb70 \
  --data_dir=/scratch/references/alphafold_feb2024/databases/ \
  --template_mmcif_dir=/scratch/references/alphafold_feb2024/databases/pdb_mmcif/mmcif_files \
  --obsolete_pdbs_path=/scratch/references/alphafold_feb2024/databases/pdb_mmcif/obsolete.dat \
  --small_bfd_database_path=/scratch/references/alphafold_feb2024/databases/small_bfd/bfd-first_non_consensus_sequences.fasta \
  --output_dir=/scratch/pawsey0001/sbeecroft/3013aa/${SLURM_JOB_ID} \
  --max_template_date=2023-05-14 \
  --db_preset=reduced_dbs \
  --logtostderr \
  --hhsearch_binary_path=/opt/hh-suite/bin/hhsearch \
  --hhblits_binary_path=/opt/hh-suite/bin/hhblits
