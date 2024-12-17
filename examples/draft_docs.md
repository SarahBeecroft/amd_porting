# Running AlphaFold2 on Setonix
## Overview

This guide explains how to run AlphaFold2 (AF2) on Pawsey's Setonix supercomputer. Please note there is currently a memory limitation that restricts computations to proteins of approximately 3,013 amino acids or less. Attempting to process larger proteins will result in out-of-memory errors.

## Reference Data Location

AlphaFold2 requires several reference databases. On Setonix, these are located at:
```
/scratch/references/alphafold_feb2024/databases/
```

The following databases are available:
- UniRef90 (uniref90.fasta)
- MGnify (mgy_clusters_2022_05.fa)
- PDB70
- Small BFD
- PDB mmCIF files

## Job Script Template

Below is a template SLURM script for running AlphaFold2. Save this as `run_af2.slurm`:

```bash
#!/bin/bash -l
#SBATCH -A ${PAWSEYPROJECT}-gpu
#SBATCH --nodes=1
#SBATCH --partition=gpu
#SBATCH --time=10:00:00
#SBATCH --gres=gpu:1

# Set thread count
export OMP_NUM_THREADS=1

# Load required module
module load singularity/4.1.0-slurm

# Run AlphaFold2
srun -N 1 -n 1 -c 8 --gres=gpu:1 --gpus-per-task=1 --gpu-bind=closest \
  singularity exec alphafold2.sif python /opt/alphafold/run_alphafold.py \
  --fasta_paths=/path/to/your/sequence.fasta \
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
  --output_dir=${MYSCRATCH}/alphafold2/output/${SLURM_JOB_ID} \
  --max_template_date=2023-05-14 \
  --db_preset=reduced_dbs \
  --logtostderr \
  --hhsearch_binary_path=/opt/hh-suite/bin/hhsearch \
  --hhblits_binary_path=/opt/hh-suite/bin/hhblits
```

## Important Notes and Limitations

1. **Fasta file input**: Please note you must change the template script to point to your FASTA file `--fasta_paths=/path/to/your/sequence.fasta`

2. **Template date**: Please note you should change the `--max_template_date` to suit your analysis.

3. **Output Directory**: Remember to modify the `--output_dir` path to suit your needs if required

4. **Database Preset**: The script uses `reduced_dbs` preset for faster processing. For higher accuracy, you can change to `full_dbs` but this will increase runtime.

## Running Your Job

1. Submit your job:
   ```bash
   sbatch run_af2.slurm
   ```

2. Monitor your job:
   ```bash
   squeue -u $USER
   ```

## Output Files

AlphaFold2 will create a directory with the job ID under your specified output directory. This will contain:
- Predicted structures in PDB format
- Confidence scores (pLDDT and PAE)
- Log files
- MSA visualization files

## Support

For issues or questions, please contact the Pawsey Help Desk at help@pawsey.org.au
