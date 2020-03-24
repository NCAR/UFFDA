#!/bin/bash
#SBATCH -t 00:30:00
#SBATCH --qos=batch
#SBATCH --account=ap-fc
#SBATCH --nodes=1-1
#SBATCH --tasks-per-node=24
#SBATCH --job-name=run_UFFDA

./run.sh

exit
