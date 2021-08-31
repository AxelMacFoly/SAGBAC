# SAGBAC
Semi-Automated Graph-Based Assembly Curator

## Install instructions
* Each assembly should be processed in a newly created directory!
* Create a new directory which will be your "work directory".
* Go into the "work directory" and clone the SAGBAC repository.

## Dependencies
Please be sure to install the following programs in order to be able to run SAGBAC properly.

Legacy BLAST: ftp://ftp.ncbi.nlm.nih.gov/blast/executables/legacy.NOTSUPPORTED/2.2.26/

BWA 0.7.17 (or newer version): https://sourceforge.net/projects/bio-bwa/files/bwa-0.7.17.tar.bz2

Samtools 1.9 (or newer version): https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2

UCSC utilities: http://hgdownload.soe.ucsc.edu/admin/exe/

After downloading and installing the software, please be sure to assign the correct commands in the very first lines for the variables "bwa", "samtools", "formatdb", "blastall" in the ISEIS.sh shellscript.

## Example data
* Download the assembly data IDBA_assemblies_berS.fasta.gz from figshare (https://doi.org/XXXXXXXX) und gunzip it.
* Create a subfolder in your <source and data directory> called example_data and go into it
* Download the SRA accessions XXX with fastq_dump or directly from the NCBI SRA homepage.

## Generate initial graph for O. villaricae
* bash SAGBAC.sh "</path/to/work directory>"/IDBA_assemblies_berS.fasta berS "</path/to/work directory>"/example_data/"<SRA_R1.fastq>" "</path/to/work directory>"/example_data/"<SRA_R1.fastq>" initial_graph_berS 3 noChanges 100,3000,1000 1,2,3
* open iGraph_Bert_allLevels_CleanedUp_1_noChanges.pdf which was created in your initial_graph_4Bert directory

## Generate final graph for O. villaricae
* Rscript </path/to/work directory>/SAGBAC.R generateGraph </path/to/work directory>/initial_graph_4Bert/ IDBA_assemblies_berS.fasta.blastout.cutted.tsv berS_illumina-ON-IDBA_assemblies_berS.fasta 49 berS RemoveSmallContigs 0 '854,864,873' '' 1 1.1
* open iGraph_Bert_allLevels_CleanedUp_1_RemoveSmallContigs.pdf which was also created in your initial_graph_4Bert directory

## Reorder Blast output
* Rscript "</path/to/work directory>"/SAGBAC.R reorderBlastOutput "</path/to/work directory>"/initial_graph_berS Blastdata4MastercirclePath_Bert_DATE_RemoveSmallContigs.txt newOrder_bertMergePath.csv Bert_illumina-ON-IDBA_assemblies_berS

## Generate Master circle
* Rscript "</path/to/work directory>"/SAGBAC.R generateMasterCircle "</path/to/work directory>"/initial_graph_berS Reordered_Blastdata4MastercirclePath_Bert_DATE_RemoveSmallContigs.txt IDBA_assemblies_berS.fasta MasterCircle.fasta "Oenothera villaricae [mitochondrion]"

## Predicting PMG isoforms
Rscript "</path/to/work directory>"/SAGBAC.R calculateSubcircles "</path/to/work directory>"/initial_graph_berS graphML_Bert_DATE_RemoveSmallContigs.xml '121,443,518,539,795,773' 2 predictions.pdf

## Citation
Please cite the following paper if you used SAGBAC for your data analysis:
  
