#!/bin/bash --login
########## SBATCH Lines for Resource Request ##########

#SBATCH --time=120:00:00             # limit of wall clock time - how long the job will run (same as -t)
#SBATCH --nodes=1-5                  # number of different nodes - could be an exact number or a range of nodes (same as -N)
#SBATCH --ntasks=3                   # number of tasks - how many tasks (nodes) that you require (same as -n)
#SBATCH --cpus-per-task=20           # number of CPUs (or cores) per task (same as -c)
#SBATCH --mem-per-cpu=2G             # memory required per allocated CPU (or core)
#SBATCH --job-name bwa-mem_Novaseq1  # you can give your job a name for easier identification (same as -J)
#SBATCH --mail-type=ALL              # Mail type
#SBATCH --mail-user=colli958@msu.edu # Mail user
#SBATCH --output=%x-%j.SLURMout      # Standard out and error:

########## Command Lines for Job Running ##########

### change to the directory where your demultiplexed fastq files are located.
cd /mnt/scratch/colli958/Novaseq1/cutadapt

### call your executable. (use srun instead of mpirun.)

#!/bin/bash -v

# align all demultiplexed and adapter trimmed individuals to the reference genome and output .sam files
# example demultiplexed file name: cutadapt_CHIN-Chipps-Island-12_RA_GGAAACATCGTGCAGG.fastq__RA.fq.gz
# example base_name is: cutadapt_CHIN-Chipps-Island-12_RA_GGAAACATCGTGCAGG
# example barcode: GGAAACATCGTGCAGG


# Define paths and variables outside the loop
prefix="cutadapt_CHIN-Chipps-Island-"
reference="/mnt/home/colli958/reference_genome/GCF_018296145.1_Otsh_v2.0_genomic.fna"
bwa_path="/mnt/home/colli958/bwa-mem2-2.2.1_x64-linux/bwa-mem2"

# Check if BWA-MEM2 is present in the specified location
if [ ! -x "$bwa_path" ]; then
  echo "Error: BWA-MEM2 not found at $bwa_path. Please provide the correct path."
  exit 1
fi

# Check if the reference genome file exists
if [ ! -f "$reference" ]; then
  echo "Error: Reference genome file not found at $reference. Please provide the correct path."
  exit 1
fi

output_dir="/mnt/scratch/colli958/Novaseq1/sam_output"  # sam file output directory
mkdir -p "$output_dir"     # Create the directory if it doesn't exist

for f1 in ${prefix}*_RA.fq.gz
do
  f2="${f1/__RA/__RB}"  # substitution for f2
  barcode=$(basename "${f1}" .fastq__RA.fq.gz | cut -d "_" -f 4)
  base_name=$(basename "${f1}" .fastq__RA.fq.gz | cut -d "_" -f 1-3)
  out="${output_dir}/${base_name}_${barcode}.sam"
  
  echo "Forward file: $f1"
  echo "Reverse file: $f2"
  echo "Out file: $out"

  # Align reads to the reference genome
  "$bwa_path" mem "$reference" "$f1" "$f2" > "$out"
  
done



