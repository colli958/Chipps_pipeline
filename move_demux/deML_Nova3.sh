#!/bin/bash
##Name: deML_demultiplex.sh
#mem requirements very low--5G more than enough

# cd /mnt/scratch/colli958/Novaseq3_4/demux/Nova3_4
# ./deML_Nova3.sh deML_manifest.nova3_4.csv mmttnova3_R1_001.fastq mmttnova3_R4_001.fastq mmttnova3_R2_001.fastq mmttnova3_R3_001.fastq 
# files called are the script, manifest with sample names and indexes, 2 fastq file names to be paired, 2 files with the indexes  
# mmttnova3_R1_001.fastq and mmttnova3_R4_001.fastq are the read files
# mmttnova3_R2_001.fastq and mmttnova3_R3_001.fastq are the index files - figured this out by file size and the head command revealed much shorter sequences


manifest=$1
r1=$2	#read1 file
r2=$3	#read2 file
i1=$4	#index1 (i7)
i2=$5	#index2 (i5)
outpre="deML"	#path and prefix of output files--it automatically adds an underscore to the end.
summary="deML_summary_Nova3"	#name of summary file
error="deML_error_Nova3"	#name of error file

/mnt/home/colli958/deML/src/deML -i ${manifest} -f ${r1} -r ${r2} -if1 ${i1} -if2 ${i2} -o ${outpre} -s ${summary} -e ${error}
