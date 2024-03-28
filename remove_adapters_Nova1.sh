#!/bin/bash
##Name: remove_adapters.sh
# to execute: 	cd /mnt/scratch/colli958/Novaseq1/demux
#				sh remove_adapters.sh
# example input fastq file name CHIN-Chipps-Island-6_RA_GGCATCAAGTTGCAGG.fastq

module load GNU/7.3.0-2.30
module load OpenMPI/3.1.1-CUDA
module load cutadapt/2.1-Python-3.6.6

input_dir="/mnt/scratch/colli958/Novaseq1/demux"  # Change this to the directory containing your FASTQ files
output_dir="/mnt/scratch/colli958/Novaseq1/cutadapt"  # Change this to the desired output directory
mkdir -p "$output_dir"

shopt -s nullglob

for forward_fastq in "$input_dir"/*_RA_*.fastq; do
    if [[ ! -f "$forward_fastq" ]]; then
        continue  # Skip non-existent files
    fi

    forward_filename=$(basename "$forward_fastq")
    reverse_filename="${forward_filename/_RA_/_RB_}"

    reverse_fastq="$input_dir/$reverse_filename"

    if [[ -f "$reverse_fastq" ]]; then
        c1=$(echo "$forward_filename" | cut -d'_' -f1-3)  # Extracts the plate ID by splitting by underscores and keeping chunks 1-3
        c2=$(echo "$forward_filename" | cut -d'_' -f4)    # Extracts the well barcode by splitting by underscores and only keeping chunk 4
        output_prefix="${c1}_${c2}"

        echo "#!/bin/bash -xv
        module load cutadapt/2.1-Python-3.6.6

        cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -A CCTGCANNNNNNNNCCAGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT -o $output_dir/cutadapt_${output_prefix}_RA.fq.gz -p $output_dir/cutadapt_${output_prefix}_RB.fq.gz ${forward_fastq} ${reverse_fastq}
        " > cutadapt_${output_prefix}.sh

        sbatch -p med --mem=2G -t 2:00:00 cutadapt_${output_prefix}.sh
    else
        echo "Reverse read file not found for ${forward_filename}"
    fi
done

