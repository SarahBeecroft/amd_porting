# amd_porting
Repository for Docker recipes for porting codes to AMD/ROCM

## Using the vram monitoring
1. submit the job to slurm, see which node it's assigned to
2. login to the node
3. run with bash vram_monitoring.sh job_id

You can change the print frequency by changing the sleep interval in the script.
