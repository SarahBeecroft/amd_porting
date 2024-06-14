#!/bin/bash -l
#SBATCH -A pawsey1017-gpu
#SBATCH --nodes=1
#SBATCH --partition=gpu-highmem
#SBATCH --time=10:00:00
#SBATCH --gres=gpu:1
#SBATCH --output=output_%A_%x.out  # Output file naming convention
#SBATCH --error=error_%A_%x.err    # Error file naming convention

#run with single device
export OMP_NUM_THREADS=1

module load singularity/3.11.4-slurm
export XLA_PYTHON_CLIENT_MEM_FRACTION=2
export TF_FORCE_UNIFIED_MEMORY=1
echo "3013aa.fasta export XLA_PYTHON_CLIENT_MEM_FRACTION=2 export TF_FORCE_UNIFIED_MEMORY=1 -N 1 -n 1 -c 8 --gres=gpu:1 --gpu-bind=closest"
srun -N 1 -n 1 -c 8 --gres=gpu:1 --gpu-bind=closest \
  singularity exec alphafold_rocm6.0_noROCM_TF.sif python /opt/alphafold/run_alphafold.py \
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
  --output_dir=/scratch/pawsey0001/sbeecroft/${SLURM_JOB_ID} \
  --max_template_date=2023-05-14 \
  --db_preset=reduced_dbs \
  --logtostderr \
  --hhsearch_binary_path=/opt/hh-suite/bin/hhsearch \
  --hhblits_binary_path=/opt/hh-suite/bin/hhblits
