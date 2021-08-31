#!/bin/bash
bwa="bwa"
samtools="samtools"
formatdb="formatdb"
blastall="blastall2226"
if [ $# -ne 9 ]
then
    echo "=============================================================================="
    echo "One or more arguments are missing please review parameter settings as follows:"
    echo "Please always use absolute pathes to your files"
    echo "=============================================================================="    
    echo "ISEIS.sh <fasta_file> <sample_name> <fastq_file_1> <mate_suffices> <working_directory> <source_directory> <number_of_threads> <output_prefix> <read_length> <cov_cutoff>"
    echo "=============================================================================="
    echo "PARAMETETRS:"
    echo "=============================================================================="
    echo "Param 1:  Absolute path to the fasta file from the de-novo assembler of your choice. Please be aware the contig identifier need to fit to the following regular expression: />[A-za-z]+_[0-9]+/"
    echo "Param 2:  Sample name without white spaces in between"
    echo "Param 3:  Absolute path to the first fastq file from your paired-end run. Normally it has the following file extension: _R1.fastq or _1.fastq or _1_somenames.fastq"
    echo "Param 4:  Absolute path to the second fastq file from your paired-end run. Normally it has the following file extension: _R2.fastq or _2.fastq or _2_somenames.fastq"
    echo "Param 5:  Name of the directory which is created directly in the directory where you started ISEIS.sh"
    echo "Param 6:  Number of threads/cpus which are used for some calculations (mapping with bwa and sorting the bam file wirth samtools)"
    echo "Param 7:  Output suffix for the generated pdf files in order distiguish between different ISEIS.R runs with different filters."
    echo "Param 8:  Comma seperated cutoffs: <Read length of Sequencing run>,<Coverage cut-off to select for high confidence contigs ('trusted_contigs')>,<Contig size cut-off to select for high confidence contigs ('trusted_contigs')"
    echo "Param 9: Sections (of commands) that will be executed. Normal order is 1,2,3. Section 2 needs section 1 to be completed as well as Section 3 needs a completed section 2. If for example a command aborts in section 2 you can skip Section 1, or Section 3 commands abort, you can skip Section 1 and 2. See below which section will which command chain."
    echo "=============================================================================="
    echo "SECTIONS:"
    echo "=============================================================================="
    echo "Section 1: Commands executed for the blast all against all search: formatdb, blastall, xsltproc"
    echo "Section 2: Commands executed for the alignment with BWA: 'bwa index', 'bwa mem' and 'samtools view -bS', 'samtools sort', 'samtools index', 'samtools idxstats' and 'samtools flagstat'"
    echo "Section 3: Computing ratios out of the idxstats output using Param 9 and 10 as well as filter for high confidence contigs (alias trusted_contigs). Running the R script ISEIS.R at last."
    echo "=============================================================================="
    exit
fi
fafile=$1
sample=$2
fq1file=$3
fq2file=$4
workdir=$5
sourcedir=`pwd`
cpus=$6
out_suffix=$7
cutoffs_string=$8
read_length=`echo $cutoffs_string | cut -f1 -d','`
cov_cutoff=`echo $cutoffs_string | cut -f2 -d','`
size_cutoff=`echo $cutoffs_string | cut -f3 -d','`
steps=$9
if [[ ! -e $workdir ]]; then
    mkdir $workdir
elif [[ ! -d $workdir ]]; then
    echo "$dir already exists but is not a directory" 1>&2
fi
cp $fafile ${workdir}/.
cd $workdir
fafile=`basename $fafile`
ref_prefix=$fafile
for step in `echo $steps | sed "s/,/ /g"`
do
    if [ $step -eq 1 ]
    then
	echo "Starting Command Section 1"
	echo "Construct Blast database"
	$formatdb -p F -i ${fafile}
	echo "Blast against Itself"
	$blastall -m 7 -a 2 -e 1e-10 -p blastn -i $fafile -d $fafile >${fafile}.blastout.xml 2>${fafile}.blastout.log
	xsltproc ${sourcedir}/blast2tsv.xsl ${fafile}.blastout.xml | perl -ne 's/^\s+//;print;'  | cut -f1-16 -d';' >${fafile}.blastout.cutted.tsv
    elif [ $step -eq 2 ]
    then
	echo "Starting Command Section 2"
	echo "Fasta Indexing"
	$bwa index -a is $fafile >${fafile}.bwaIndexing.log 2>&1
	echo "BWA MEM mapping"
	$bwa mem -t $cpus $fafile $fq1file $fq2file 2>${sample}_illumina-ON-${ref_prefix}.bam.log | $samtools view -u -F 2048 - >${sample}_illumina-ON-${ref_prefix}.bam
	echo "Samtools Sorting"
	$samtools sort -@ $cpus -m 1024M -o ${sample}_illumina-ON-${ref_prefix}.srt.bam ${sample}_illumina-ON-${ref_prefix}.bam 2>${sample}_illumina-ON-${ref_prefix}.srt.log
	echo "Samtools Indexing"
	$samtools index ${sample}_illumina-ON-${ref_prefix}.srt.bam
	echo "Samtools Flagstats"
	$samtools flagstat ${sample}_illumina-ON-${ref_prefix}.srt.bam >${sample}_illumina-ON-${ref_prefix}.srt.bam.flagstats
	echo "Samtools Idxstats"
	idxstats=${sample}_illumina-ON-${ref_prefix}.srt.bam.idxstats
	$samtools idxstats ${sample}_illumina-ON-${ref_prefix}.srt.bam >$idxstats
	$samtools view ${sample}_illumina-ON-${ref_prefix}.bam | cut -f1-9 | perl -e '$i=1;while(<STDIN>){if($i%2==1){chomp;@TMP=split("\t",$_);}else{push @TMP,split("\t",$_);$TMP[0]=~/([0-9]:[0-9]+:[0-9]+:[0-9]+)$/;@NEW=($1,$TMP[1],$TMP[10],$TMP[2],$TMP[11],$TMP[3],$TMP[12],$TMP[4],$TMP[13],$TMP[5],$TMP[14],abs($TMP[8]));print "".join("\t",@NEW)."\n";}$i++;}' >${sample}_illumina-ON-${ref_prefix}.bam.mates
	awk '$4!=$5' ${sample}_illumina-ON-${ref_prefix}.bam.mates >${sample}_illumina-ON-${ref_prefix}.bam.mates.MappedOnDiffContig
	perl -e 'open(MATES,"<".$ARGV[0]);while(<MATES>){s/IDBA_//g;@TMP=split("\t",$_);$l=$TMP[3];$r=$TMP[4];if($r<$l){$TMP[3]=$r;$TMP[4]=$l;}print "".join("\t",@TMP);}' ${sample}_illumina-ON-${ref_prefix}.bam.mates.MappedOnDiffContig | sort -k4,4n -k5,5n | cut -f4,5 | uniq -c | awk 'BEGIN{OFS="\t";}{print $2,$3,$1}' >${sample}_illumina-ON-${ref_prefix}.bam.mates.MappedOnDiffContig.pairCounts
    elif [ $step -eq 3 ]
    then
	echo "Starting Command Section 3"
	idxstats=${sample}_illumina-ON-${ref_prefix}.srt.bam.idxstats
	awk -v rl=$read_length 'BEGIN{FS="\t";OFS="\t";}{if($2!=0){ratio=$3*rl/$2;}else{ratio=0}if(ratio>0){print $0,int(ratio);}}' $idxstats >${idxstats}.ratios.txt
	awk -v sc=$size_cutoff -v cc=$cov_cutoff -v rl=$read_length '{if($2!=0){ratio=$3*rl/$2;}else{ratio=0}if(ratio>=cc && $2>=sc){print $1;}}' $idxstats >${idxstats}.trustedContigs.txt
	prefix=`basename $fafile .fa`
	echo "Rscript ${sourcedir}/SAGBAC.R generateGraph ${sourcedir}/${workdir}/ ${fafile}.blastout.cutted.tsv ${sample}_illumina-ON-${fafile} 49 $sample ${out_suffix} 0 '' '' 1 1.1"
	Rscript ${sourcedir}/SAGBAC.R generateGraph ${sourcedir}/${workdir}/ ${fafile}.blastout.cutted.tsv ${sample}_illumina-ON-${fafile} 49 $sample ${out_suffix} 0 '' '' 1 1.1
    fi
done
cd $sourcedir
