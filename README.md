# Chipps_pipeline
 raw data to bams


# install bwa-mem2, module load does not load supporting libraries
curl -L https://github.com/bwa-mem2/bwa-mem2/releases/download/v2.2.1/bwa-mem2-2.2.1_x64-linux.tar.bz2 | tar jxf -

# index reference genome
cd ~
bwa-mem2-2.2.1_x64-linux/bwa-mem2 index /mnt/research/MeekLab/Chinook/Chipps_Island/data/reference_genome/GCF_018296145.1_Otsh_v2.0_genomic.fna
module load GCC/11.3.0
module load SAMtools/1.16.1
samtools faidx /mnt/research/MeekLab/Chinook/Chipps_Island/data/reference_genome/GCF_018296145.1_Otsh_v2.0_genomic.fna

# 1. move files from google drive to hpcc
move_Nova1.sbatch
move_Nova2.sbatch
move_Nova3_4.sbatch

# 2. unzip after move 
cd /mnt/scratch/colli958/Novaseq1/demux
gunzip *.gz
# unzip tar files
cd /mnt/scratch/colli958/Novaseq2/demux
tar -xvf nova2.tar.gz
cd Nova2
gunzip *.gz
cd /mnt/scratch/colli958/Novaseq3_4/demux
tar -xvf nova3_4.tar.gz
cd Nova3_4
gunzip *.gz

# 3. demultiplex after unzipping
# Nova 1 and 2 unzipped to the plate level, only need to demultiplex samples
# need to unzip before running these scripts with gunzip *.gz
sbatch demux_Nova1.sbatch
sbatch demux_Nova2.sbatch
# Nova 3_4 first need to be demultiplexed to the plate level, then demultiplex samples as above
deML_Nova3.sbatch
deML_Nova4.sbatch
# make sure the scripts called by the sbatch files for demultiplexing to the plate are in the directory
deML_Nova3.sh
deML_Nova4.sh
# then demultiplex, but need to unzip first
gunzip *.gz
sbatch demux_Nova3_4.sbatch
# make sure there is a copy of this file in each directory
sh run_BestRadSplit_well_MSU.sh

# 4. remove adapters
cd /mnt/scratch/colli958/Novaseq1/demux
remove_adapters_Nova1.sh 
cd /mnt/scratch/colli958/Novaseq2/demux/Nova2
sh remove_adapters_Nova2.sh
cd /mnt/scratch/colli958/Novaseq3_4/demux/Nova3_4
sh remove_adapters_Nova3_4.sh

# 5. align to reads
# do these as arrays
bwa_mem_Nova1.sbatch
bwa_mem_Nova2.sbatch
bwa_mem_Nova3_4.sbatch

# 6. samtools
samtools_Nova1.sbatch
samtools_Nova2.sbatch
samtools_Nova3_4.sbatch

# 7. rename
cd /mnt/scratch/colli958/Novaseq1/sam_output
./rename_bam_Nova1.sh well_bc_file_for_rename.txt
cd /mnt/scratch/colli958/Novaseq2/sam_output
./rename_bam_Nova2.sh well_bc_file_for_rename.txt
cd /mnt/scratch/colli958/Novaseq3_4/sam_output
./rename_bam_Nova3_4.sh well_bc_file_for_rename.txt
./rename_bam_Nova3_4.add.sh well_bc_file_for_rename.txt
./rename_bam_Nova3_4.2.sh well_bc_file_for_rename.txt
./rename_bam_Nova3_4.2.add.sh well_bc_file_for_rename.txt
# copy well_bc_file_for_rename.txt to each Novaseq directory

# 8. filter by 1000
cutoff_1k.sh
# put a copy of this script in each novaseq directory with final bam files

# 9. move all final bams and bamlists to the final_bams directory in my home directory on the hpcc
cp *.final.bam /mnt/home/colli958/final_bams/
cp *.final.bam.bai /mnt/home/colli958/final_bams/
cp *.stats /mnt/home/colli958/final_bams/
# rename the cv_juv_1kaln_cutoff.bamlist to Nova1_cv_juv_1kaln_cutoff.bamlist and move to final bams dir
cp cv_juv_1kaln_cutoff.bamlist Nova1_cv_juv_1kaln_cutoff.bamlist
cp Nova1_cv_juv_1kaln_cutoff.bamlist /mnt/home/colli958/final_bams/
cp cv_juv_1kaln_cutoff.bamlist Nova2_cv_juv_1kaln_cutoff.bamlist
cp Nova2_cv_juv_1kaln_cutoff.bamlist /mnt/home/colli958/final_bams/
cp cv_juv_1kaln_cutoff.bamlist Nova3_4_cv_juv_1kaln_cutoff.bamlist

ANGSD
# create likelihood genotypes 
./angsd_gt_Nova1.sh cv_juv_1kaln_cutoff.bamlist angsd_gt snp_panel.sites

# genetic diversity stats


# troubleshoot angsd error to reindex reference because dates do not match up, this means reference.fai is missing and can run the lines below to generate
module load GCC/11.3.0
module load SAMtools/1.16.1
samtools faidx /mnt/research/MeekLab/Chinook/Chipps_Island/data/reference_genome/GCF_018296145.1_Otsh_v2.0_genomic.fna




















