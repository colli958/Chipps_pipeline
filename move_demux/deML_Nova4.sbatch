#!/bin/bash --login
########## SBATCH Lines for Resource Request ##########

#SBATCH --time=120:00:00              # limit of wall clock time - how long the job will run (same as -t)
#SBATCH --nodes=1-5                  # number of different nodes - could be an exact number or a range of nodes (same as -N)
#SBATCH --ntasks=3                   # number of tasks - how many tasks (nodes) that you require (same as -n)
#SBATCH --cpus-per-task=20           # number of CPUs (or cores) per task (same as -c)
#SBATCH --mem-per-cpu=2G             # memory required per allocated CPU (or core)
#SBATCH --job-name deML_Nova4        # you can give your job a name for easier identification (same as -J)
#SBATCH --mail-type=ALL              # Mail type
#SBATCH --mail-user=colli958@msu.edu # Mail user
#SBATCH --output=%x-%j.SLURMout      # Standard out and error:

########## Command Lines for Job Running ##########

### change to the directory where your code is located.
cd /mnt/scratch/colli958/Novaseq3_4/demux/Nova3_4

### call your executable. (use srun instead of mpirun.)

./deML_Nova4.sh deML_manifest.nova3_4_additional.csv mmttnova4_R1_001.fastq mmttnova4_R4_001.fastq mmttnova4_R2_001.fastq mmttnova4_R3_001.fastq 
