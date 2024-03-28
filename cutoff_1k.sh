#!/bin/bash -l
## Name:  stats.sh
## Gets stats on bam files
## Meant to be run in the same directory as original bams

module load GCC/11.3.0
module load SAMtools/1.16.1

# Find all files ending in "final.bam" within the working directory
bam_files=$(find . -name "*final.bam")

# Create an array to hold the names of files with counts > 1000
files_with_count_gt_1000=()

for bam_file in $bam_files; do
    # Obtain alignment count using samtools flagstat
    alignment_count=$(samtools flagstat "$bam_file" | grep "properly paired" | awk '{print $1}')

    # Check if alignment count is greater than 1000
    if [ "$alignment_count" -gt 1000 ]; then
        files_with_count_gt_1000+=("$bam_file")
    fi
done

# Export the list of files with counts > 1000
echo "Files with counts > 1000 properly paired alignments:"
for file in "${files_with_count_gt_1000[@]}"; do
    # Extract only the file name without the path and remove the "#./" suffix if present
    file_name=$(basename "$file" | sed 's/#\.\///')
    echo "$file_name"
done > cv_juv_1kaln_cutoff.bamlist
