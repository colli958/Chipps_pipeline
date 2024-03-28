#!/bin/bash

# The script should be run with the TXT file as an argument (e.g., ./rename_bam.sh well_bc_file_for_rename.txt).
# Make sure to include a copy of the TXT file in the directory.

# example input file cutadapt_CHIN-Chipps-Island-12_RA_GGAAACATCGTGCAGG.final.bam
# example c1 is A02
# example c2 is GGAAACATCGTGCAGG

F1=$1   #file with two columns: wells and corresponding barcodes

n=$(wc -l "$F1" | awk '{print $1}')

x=1     #when no header exists
#x=2    #account for header line

while [ $x -le $n ] 
do
    string="sed -n ${x}p \"$F1\""
    str=$(eval "$string")
    var=$(echo "$str" | awk -F"," '{print $1,$2}')
    set -- $var
    c1=$1   #well
    c2=$(echo "$2" | tr -d '\r')   # well barcode without carriage return

    echo "Processing line $x: c1=$c1, c2=$c2"

    # Renaming files using the extracted values
    for i in $(seq 17 28); do # !!! important to change this based on the file names !!!!
        # renaming files ending in .final.bam
        old_filename="cutadapt_nova2_CHIN-Chipps-Island-${i}_RA_${c2}.final.bam"
        new_filename="CHIN-Chipps-Island-${i}_${c1}.final.bam"
        mv "$old_filename" "$new_filename"
        # renaming files ending in .final.bam.bai
        old_filename_index="cutadapt_nova2_CHIN-Chipps-Island-${i}_RA_${c2}.final.bam.bai"
        new_filename_index="CHIN-Chipps-Island-${i}_${c1}.final.bam.bai"
        mv "$old_filename_index" "$new_filename_index"
        # renaming files ending in .stats
        old_filename_index="cutadapt_nova2_CHIN-Chipps-Island-${i}_RA_${c2}.stats"
        new_filename_index="CHIN-Chipps-Island-${i}_${c1}.stats"
        mv "$old_filename_index" "$new_filename_index"

        echo "Renaming $old_filename to $new_filename"
    done

    x=$(( $x + 1 ))

done