#!/bin/bash --login
########## SBATCH Lines for Resource Request ##########

#SBATCH --time=80:00:00              # limit of wall clock time - how long the job will run (same as -t)
#SBATCH --nodes=1-5                  # number of different nodes - could be an exact number or a range of nodes (same as -N)
#SBATCH --ntasks=3                   # number of tasks - how many tasks (nodes) that you require (same as -n)
#SBATCH --cpus-per-task=20           # number of CPUs (or cores) per task (same as -c)
#SBATCH --mem-per-cpu=2G             # memory required per allocated CPU (or core)
#SBATCH --job-name samtools_Novaseq2   # you can give your job a name for easier identification (same as -J)
#SBATCH --mail-type=ALL              # Mail type
#SBATCH --mail-user=colli958@msu.edu # Mail user
#SBATCH --output=%x-%j.SLURMout      # Standard out and error:

########## Command Lines for Job Running ##########

### change to the directory where your code is located and load modules.
cd /mnt/scratch/colli958/Novaseq2/sam_output
module load GCC/11.3.0
module load SAMtools/1.16.1

### call your executable. (use srun instead of mpirun.)

# use samtools to sort and qc the final bam files
# example sam file name: CHIN-Chipps-Island-12_GGAAACATCGTGCAGG.sam
# example barcode: CHIN-Chipps-Island-12_GGAAACATCGTGCAGG
# Execute this script with sh scriptname.sh
# Make sure to have this script and all of the fastq files in the same directory

#!/bin/bash

# Loop over all the SAM files in the directory
for sam_file in *.sam; do
   # Extract sample ID from the SAM file name
    sample_ID=$(basename "$sam_file" .sam)
    #create bam files and rm the sam file
    samtools view -b "$sam_file" > "${sample_ID}.og1.bam"
    samtools flagstat "${sample_ID}.og1.bam" > "${sample_ID}.stats"
    #sort by name for fixmate compatibility
    samtools sort -n -o "${sample_ID}.namesort2.bam" "${sample_ID}.og1.bam"
    #run fixmate to add ms and MC tags for markdup (marks and removes duplicates)
	samtools fixmate -m "${sample_ID}.namesort2.bam" "${sample_ID}.fixmate_m3.bam"
	#sort by position for markdup compatability
	samtools sort -o "${sample_ID}.positionsort4.bam" "${sample_ID}.fixmate_m3.bam"
	#remove duplicates and mark supplemental reads of dups as dups
	samtools markdup -r -S "${sample_ID}.positionsort4.bam" "${sample_ID}.markdup5.bam"
	echo "ZZZZZZZZ markdup remove duplicates ZZZZZZZZZZZZ" >> "${sample_ID}.stats"
	samtools flagstat "${sample_ID}.markdup5.bam" >> "${sample_ID}.stats"
	#only keep proper pairs
	samtools view -b -f 0x2 "${sample_ID}.markdup5.bam" > "${sample_ID}.proper.bam"
	# final position sort
	samtools sort -o "${sample_ID}.final.bam" "${sample_ID}.proper.bam"
	# index
	samtools index "${sample_ID}.final.bam"
	echo "ZZZZZZZZZZ_final_ZZZZZZZZZZZ" >> "${sample_ID}.stats"
	samtools flagstat "${sample_ID}.final.bam" >> "${sample_ID}.stats"

    # Remove intermediate files
    rm "$sam_file"
    rm "${sample_ID}.og1.bam"
	rm "${sample_ID}.namesort2.bam"
    rm "${sample_ID}.fixmate_m3.bam"
    rm "${sample_ID}.positionsort4.bam"
    rm "${sample_ID}.markdup5.bam"
    rm "${sample_ID}.proper.bam"
done















