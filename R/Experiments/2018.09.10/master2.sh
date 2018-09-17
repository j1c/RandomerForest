#!/bin/bash

#SBATCH
#SBATCH --job-name=rerf_subsample
##SBATCH --array=1-23,25-106
#SBATCH --array=4,19
#SBATCH --time=3-0:0:0
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --mem=120G
#SBATCH --partition=parallel
#SBATCH --exclusive
#SBATCH --mail-type=end
#SBATCH --mail-user=jaewonc78@gmail.com

module restore j1_env
# Print this sub-job's task ID
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID

# NAME_FILE=../../../Data/processed/names.txt
NAME_FILE=~/work/jaewon/data/uci/processed/names.txt
DATASET=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $NAME_FILE)

sed "s/abalone/${DATASET}/g" run_benchmarks_2018_09_10.R > task${SLURM_ARRAY_TASK_ID}.R

Rscript task${SLURM_ARRAY_TASK_ID}.R

rm task${SLURM_ARRAY_TASK_ID}.R

echo "job complete"
