# SAGBAC
Semi-Automated Graph-Based Assembly Curator

## Install instructions
Each assembly should be processed in a newly created directory!
Create a new directory which will be your <work directory>.
Go into the <work directory> and clone the SAGBAC repository.

## Dependencies
Please be sure to install the following programs in order to be able to run SAGBAC properly.

Legacy BLAST: ftp://ftp.ncbi.nlm.nih.gov/blast/executables/legacy.NOTSUPPORTED/2.2.26/

BWA 0.7.17 (or newer version): https://sourceforge.net/projects/bio-bwa/files/bwa-0.7.17.tar.bz2

Samtools 1.9 (or newer version): https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2

UCSC utilities: http://hgdownload.soe.ucsc.edu/admin/exe/

After downloading and installing the software, please be sure to assign the correct commands in the very first lines for the variables "bwa", "samtools", "formatdb", "blastall" in the ISEIS.sh shellscript.

## Example data
Download the assembly data IDBA_assemblies_berS.fasta.gz from figshare (https://doi.org/XXXXXXXX) und gunzip it.
Create a subfolder in your <source and data directory> called example_data and go into it
Download the SRA accessions XXX with fastq_dump or directly from the NCBI SRA homepage.

## Generate initial graph for O. villaricae
bash ISEIS.sh </path/to/work directory>/IDBA_443revcomp_adaptedToNewFinalBert.srt.fa Bert </path/to/work directory>/example_data/<SRA_R1.fastq> </path/to/work directory>/example_data/<SRA_R1.fastq> initial_graph_4Bert 3 noChanges 100,3000,1000 1,2,3
open iGraph_Bert_allLevels_CleanedUp_1_<actual DATE>_noChanges.pdf which was created in your <work directory>/initial_graph_4Bert
  
## Generate final graph for O. villaricae
Rscript </path/to/work directory>/ISEIS_wDiffScriptModes.R generateGraph </path/to/work directory>/initial_graph_4Bert/ IDBA_assemblies_berS.fasta.blastout.cutted.tsv Bert_illumina-ON-IDBA_assemblies_berS.fasta 49 Bert RemoveSmallContigs 0 '854,864,873' '' 1 1.1
open iGraph_Bert_allLevels_CleanedUp_1_<actual DATE>_RemoveSmallContigs.pdf

Citation
Please cite the following paper if you used SAGBAC for your data analysis:
  
