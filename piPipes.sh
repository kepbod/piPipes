#! /bin/bash

# piPipes, a set of pipelines for PIWI-interacting RNA (piRNA) and transposon analysis
# Copyright (C) 2014  Bo Han, Wei Wang, Zhiping Weng, Phillip Zamore
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# https://github.com/bowhan/piPipes.git
# A pipeline collection for piRNA and transposon analysis 
# from small RNA seq, RNA-seq, CAGE/Degradome/RACE-seq, ChIP-seq and Genomic-seq
# Wei Wang
# Bo W Han
# the Zamore lab and the Weng lab
# Howard Hughes Medical Institute
# RNA Therapeutics Institute
# University of Massachusetts Medical School


##########
# Config #
##########
export COLOR_RED="\e[31;40m"; export  COLOR_GREEN="\e[32;40m"; export  COLOR_YELLOW="\e[33;40m"; export  COLOR_BLUE="\e[34;40m"; export  COLOR_MAGENTA="\e[35;40m"; export  COLOR_CYAN="\e[36;40m"; export COLOR_RED_BOLD="\e[31;1m"; export COLOR_RED_LIGHT="\e[91m"; export COLOR_GREEN_BOLD="\e[32;1m"; export COLOR_GREEN_LIGHT="\e[92m"; export  COLOR_YELLOW_BOLD="\e[33;1m"; export  COLOR_BLUE_BOLD="\e[34;1m"; export  COLOR_MAGENTA_BOLD="\e[35;1m"; export  COLOR_CYAN_BOLD="\e[36;1m"; export COLOR_END="\e[0m"; 
export RESET=`echo -ne '\e[0m'`; export BOLD=`echo -ne '\e[1m'`; export UNDERLINE=`echo -ne '\e[4m'`; export BLINK=`echo -ne '\e[5m'`; 
export SMALLRNA_COLOR=`echo -ne $COLOR_RED`; export RNASEQ_COLOR=`echo -ne $COLOR_GREEN`; export DEG_COLOR=`echo -ne $COLOR_YELLOW`; export CHIP_COLOR=`echo -ne $COLOR_MAGENTA`; export GENOME_COLOR=`echo -ne $COLOR_CYAN`; 
export COMMENT=`echo -ne $COLOR_BLUE`; export REQUIRED=`echo -ne $COLOR_RED_LIGHT`;  export OPTIONAL=`echo -ne $COLOR_GREEN_LIGHT`
export PACKAGE_NAME="piPipes"
export CONTACT_EMAILS=${UNDERLINE}"piPipesQ@gmail.com"$RESET
export PIPELINE_DIRECTORY=$(dirname `readlink -f $0`)
export PATH=${PIPELINE_DIRECTORY}/bin:$PATH
. $PIPELINE_DIRECTORY/bin/piPipes_bash_functions

###########
# Version #
###########
export SMALLRNA_VERSION=1.1.0
export SMALLRNA2_VERSION=1.1.0
export RNASEQ_VERSION=1.1.0
export RNASEQ2_VERSION=1.1.0
export CHIPSEQ_VERSION=1.3.0
export CHIPSEQ2_VERSION=1.1.0
export DEG_VERSION=1.1.0
export GENOMESEQ_VERSION=1.1.0

#########
# Intro #
#########
export piPipes_INTRO='
Integrated, shell based pipeline collection for piRNA/transposon analysis via 
small RNA-seq, RNA-seq, Degradome/RACE/CAGE-seq, ChIP-seq and Genomic DNA seq. 
'

export INSTALL_USAGE='
install
=======
Due to the limitation on the size of files by github, piPipes does not ship with all of the genome
sequences and annotation. Thus we provide this pipeline to download genome assemly files
from illumina iGenome project. Please make sure internet is available during this process. 
This pipeline will also install R packages that are unavaiable in your current system.

Most hpcc limits the Internet access to the head node, which is only supposed to used for submiting
jobs but not for heavy computation including building index. piPipes provide -D option to separate 
downloading and other works to solve this issue.

Currently, piPipes provides full annotations of three genomes, hg19, mm9/mm10 and dm3/dm6. 
For other genomes, the user need to provide three annotations.
(1) piRNA cluster annotation. 
Without this annotation some pipier functions might not run. The user might want to use piRNA cluster
annotation tool, like proTRAC, to make a piRNA cluster annotation file in BED format.
(2) transposon consensus sequences from repBase. 
piPipes already include the fasta for repBase in the "common" folder. Due to the naming, we are not able
to retrieve the sequences for one organism correctly. The user will have to retrieve that information manually. 
(3) BED files for genomic structural analysis. 
The user might also want to provide a list of BED files to be used for detailed analysis on genomic features,
such as genes, exons, introns, UTRs. Due to the inconsistent naming of UCSC mySQL TABLEs, we found it very 
hard to download those information automatically. 
For genomes without iGenome support, piPipes also provide custom installation pipeline to install 
the genome with at least five files.
Please visit our github wiki for detailed instructions. 
'

export SMALLRNA_INTRO=$SMALLRNA_COLOR'
small: small RNA pipeline, single library mode
==============================================
small RNA library typically clones 18–40nt small RNAs, including miRNA, siRNA and piRNA. 
This pipeline maps those reads to rRNA, microRNA hairpin, genome, repbase annotated transposons, 
piRNA clusters with Bowtie and uses BEDtools and eXpress to assign them to different annotations.
For each feature, length distrition, seqlogo, ping-pong score, et al,.  are calculated and graphed.
'

export SMALLRNA2_INTRO=$SMALLRNA_COLOR'
small: small RNA pipeline, dual library mode
============================================
This pipelines takes the output directories of the single library mode pipeline and do pair-wise
comparision between the two samples on microRNAs and piRNAs. Six different normalization methods
are provided. 
'

export RNASEQ_INTRO=$RNASEQ_COLOR'
rnaseq: RNASeq pipeline, single library mode
============================================
RNASeq pipeline was developped for both dUTR (default) and ligation based RNASeq method. It uses 
Bowtie2 to align paired-end reads to rRNA and STAR to align the unmapped reads to genome; Then 
it uses cufflinks for gene transcripts quantification. It also directly align reads to 
transcriptome, repbase annotated transposon, piRNA clusters using Bowtie2. Quantification was 
done using eXpress. Basic statistics and graphs will be given.
'

export RNASEQ2_INTRO=$RNASEQ_COLOR'
rnaseq: RNASeq pipeline, dual library mode
==========================================
This pipelines takes the output directory of the single library mode pipeline and do pair-wise
comparision between the two samples. It uses CuffDiff and cummeRbund as routine RNA-seq analysis.
It also uses the eXpress outputs to draw scatter-plot. 
'

export CAGE_DEG_INTRO=$DEG_COLOR'
cage/deg: CAGE & Degradome pipeline
===================================
Both types of libraries are designed to gather the information of the five prime end of RNAs. 
CAGE clones RNAs with Cap and Degradome clones RNAs with five prime monophosphate. 
The pipeline will aligns paired end reads to rRNA with Bowtie2, genome using STAR. 
Different from RNASeq, this pipeline emphasizes on the accuracy of the five prime ends.
If you have small RNA library from the same genotype, you could perform ping-pong analysis
between small RNA and degradome library on different genomic structures. Turning on this option
by -s.
'

export CHIP_INTRO=$CHIP_COLOR'
chip: ChIP-seq pipeline, single library mode
============================================
ChIP Seq pipeline aligns the paired-end to genome with Bowtie2 with the default behavior of 
reporting ONE random alignemnt for multiple mappers. The user can restrict the analysis to unique
mappers only by specifying a high threshold for MAPQ, like 10. 
Peak calling was done using MASC2. 
Then the control (Input) and the treated (IP) were compared using MACS2 with three different methods:
Poisson Pvalue, log10 fold enrichment, log10 likelihood between ChIP-enriched model and open 
chromatin model. Please refer to MACS2 manual for more details. 
The output bedGraph/bigWig is used to draw metagene plot using bwtool in three different ways: 
(1) N nucleotides up/downstream of the 5 prime end of each genomic feature; 
(2) N nucleotides up/downstream of the 3 prime end of each genomic feature;  
(3) the whole body of each genomic feature been scaled with the same extension. 
'

export CHIP2_INTRO=$CHIP_COLOR'
chip: ChIP-seq pipeline, dual library mode
==========================================
This pipelines takes the output directory of the single library mode pipeline and do pair-wise
comparision between the two samples. MACS2 bdgdiff is used. Since it requires no normalization, 
peak calling is redone without normalization. Same as the single library mode, TSS/TES and metagene 
plots for those newly annotated loci were drawn for each genomic features, using the normalized 
signal from single library mode.
'

export GENOMIC_INTRO=$GENOME_COLOR'
dna: Genomic Seq pipeline
=========================
Genomic Seq pipelines aligns the paired-end reads to genome with Bowtie2, BWA-MEM and mrFast.
Variations, including transposon insertion and excision, were called using different algorithms,
including retroSeq, TEMP and VariationHunter.
'

#########
# USAGE #
#########
usage () {
cat << EOF
======
$BLINK$BOLD$PACKAGE_NAME$RESET
======
$piPipes_INTRO
${UNDERLINE}usage${RESET}:

$COMMENT# to install genome and R packages in one step$RESET
$0	install -g dm3|mm9|hg19...	
$COMMENT# to only download the genome and install R packages (if the node/machine is not appropriate to be used for heavy computing such as building indexes); please run "install" without -D later to finish the installation$RESET
$0	install -g dm3|mm9|hg19 -D	
$COMMENT# to use iGenome that piPipes does not know yet by providing the link. iGenome website: "https://support.illumina.com/sequencing/sequencing_software/igenome.ilmn"$RESET
$0	install -g hg18 -l ftp://igenome:G3nom3s4u@ussd-ftp.illumina.com/Homo_sapiens/UCSC/hg18/Homo_sapiens_UCSC_hg18.tar.gz	

$COMMENT# run small RNA pipeline for fly (dm3) sample, use 24 CPUs and output to out_dir, using genomic unique mapper exlucing miRNA as normalization method$RESET
$SMALLRNA_COLOR$0	small -i input.trimmed.fq[.gz] -g dm3 -c 24 -o output_dir -N uniqueXmiRNA
$COMMENT# run dual sample small RNA pipeline from small_rna_pipeline_output_dir1 and small_rna_pipeline_output_dir2 for fly (dm3), using 24 CPUs, normalizing to siRNA (millions of siRNA reads)$RESET
$SMALLRNA_COLOR$0	small2	-a small_rna_pipeline_output_dir1 -b small_rna_pipeline_output_dir2 -g dm3 -c 8 -o output_dir -A wild-type -B mutant -N siRNA

$COMMENT# run RNASeq pipeline for mouse (mm9), dUTR based library$RESET
$RNASEQ_COLOR$0	rnaseq	-l left.fq -r right.fq -g mm9 -c 8 -o output_dir 
$COMMENT# run RNASeq pipeline for mouse (mm9), ligation based library$RESET
$RNASEQ_COLOR$0	rnaseq	-l left.fq -r right.fq -g mm9 -c 8 -o output_dir -L 
$COMMENT# run dual sample RNASeq pipeline for fly (dm3), sample name: w1 and piwi$RESET
$RNASEQ_COLOR$0	rnaseq2	-a rnaseq_pipeline_output_dir1_rep1,rnaseq_pipeline_output_dir1_rep2 -b rnaseq_pipeline_output_dir2_rep1,rnaseq_pipeline_output_dir2_rep2 -g dm3 -c 24 -A w1 -B piwi 

$COMMENT# run Degradome/CAGE-seq for fly (dm3), under current working directory$RESET
$DEG_COLOR$0	deg -l left.fq -r right.fq -g dm3
$COMMENT# run Degradome/CAGE-seq for fly (dm3), and perform the ping-pong analysis between small RNA and degradome$RESET
$DEG_COLOR$0	deg -l left.fq -r right.fq -g dm3 -s /path/to/smallRNA_pipeline_output

$COMMENT# run ChIP-seq pipeline for mouse sample, Narrow peak (transcriptional factor), under current working directory$RESET
$CHIP_COLOR$0	chip -l left.IP.fq -r right.IP.fq -L left.INPUT.fq -R right.INPUT.fq -g mm9 -c 8 
$COMMENT# run ChIP-seq pipeline for mouse sample, Broad peak (H3K9me3), under current working directory$RESET
$CHIP_COLOR$0	chip -l left.IP.fq -r right.IP.fq -L left.INPUT.fq -R right.INPUT.fq -g mm9 -c 8 -B
$COMMENT# run ChIP-seq pipeline for mouse sample, only using unique mappers (otherwise Bowtie2 randomly choose one best alignment for each read)$RESET
$CHIP_COLOR$0	chip -l left.IP.fq -r right.IP.fq -L left.INPUT.fq -R right.INPUT.fq -g mm9 -c 8 -Q 10
$COMMENT# run ChIP-seq pipeline for single-end library
$CHIP_COLOR$0	chip -i IP.fq -I INPUT.fq -g mm9 -c 8 -o single_end
$COMMENT# to run ChIP-seq library in dual library mode, extending 2000nt for TSS/TES/meta analysis, name two samples w1 and piwi respectively$RESET
$CHIP_COLOR$0	chip2 -a chipseq_pipeline_output_dir1 -b chipseq_pipeline_output_dir2 -g mm9 -x 2000 -A w1 -B piwi

$COMMENT# run Genome Seq library, set VCF filtering depth to 500 (passed to "vcfutils.pl varFilter -D" and "retroseq.pl -call -depth")$RESET
$GENOME_COLOR$0	dna -l left.fq -r right.fq -g dm3 -d 500
${RESET}

Please email $CONTACT_EMAILS for any questions, suggestions or bugs. 
Visit our github website <github.com/bowhan/piPipes.git> for more information. 
Thank you for using it. 

EOF
echo -ne ${COLOR_END}
}

#######
# Run #
#######
if [ $# -lt 1 ]; then usage; exit 1; fi
PROGRAM=`echo ${1} | tr '[A-Z]' '[a-z]'`
case $PROGRAM in
i|install)
	shift && bash $DEBUG piPipes_install_genomes.sh "$@" ;; # genome installation pipeline
s|small|smallrna|smallrna-seq|sra)
	shift && bash $DEBUG piPipes_smallRNA.sh "$@" ;; # small RNA pipeline, single library mode
s2|small2|smallrna2|smallrna-seq2|sra2)
	shift && bash $DEBUG piPipes_smallRNA2.sh "$@" ;; # small RNA pipeline, dual library mode
r|rnaseq|rna-seq|rsq|rna)
	shift && bash $DEBUG piPipes_RNASeq.sh "$@" ;; # RNASeq pipeline, single library mode
r2|rnaseq2|rna-seq2|rsq2|rna2)
	shift && bash $DEBUG piPipes_RNASeq2.sh "$@" ;; # RNASeq pipeline, dual library mode
d|deg|degseq|deg-seq|degradome|race|cage|cage-seq|cageseq)
	shift && bash $DEBUG piPipes_DegradomeSeq.sh "$@" ;; # degradome/CAGE/RACE pipeline
c|chip|chipseq|chip-seq)
	shift && bash $DEBUG piPipes_ChIPSeq.sh "$@" ;; # ChIP-seq pipeline, single library mode
c2|chip2|chipseq2|chip-seq2)
	shift && bash $DEBUG piPipes_ChIPSeq2.sh "$@" ;; # ChIP-seq pipeline, dual library mode
g|genomic|genome|genome-seq|genomeseq|dna|dnaseq|dna-seq)
	shift && bash $DEBUG piPipes_GenomeSeq.sh "$@" ;; # Genome-seq library
*)
	echo2 "unrecognized option \"${1}\"! \nplease type \"${PACKAGE_NAME}\" without options to see all the options and usage." "error" ;;
esac






