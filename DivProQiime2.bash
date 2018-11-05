#!/bin/bash
#get CPU and RAM metrics
CORES=$(nproc)
RAM=$(free -g | tr -s "[:space:]" "\t" | cut -f11)

#Set colour variables
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
NOCOLOUR='\033[0m'

#get screen size and maximise
LINE=`xrandr -q | grep Screen`
WIDTH=`echo ${LINE} | awk '{ print $8 }'`
HEIGHT=`echo ${LINE} | awk '{ print $10 }' | awk -F"," '{ print $1 }'`
echo -e "\e[4;$HEIGHT;${WIDTH}t"


#Start qiime2 environment in conda
source activate qiime2

#Make tab completion available
source tab-qiime

# Look for a 'Parameters' text file in a 'metadata' folder that stores the user input
# If no file is present, or the variables are present in the file, set the variables to 'nil'
if [ -e "$1/Metadata/Parameters.txt" ]; then
	echo -e "${BLUE}Parameter file detected...obtaining previously entered options${NOCOLOUR}"
	ParFile="$1/Metadata/Parameters.txt"
	Meta="$1/Metadata"

	if grep -i -q "User" $ParFile; then Dir=$(grep -i "User" $ParFile | cut -f2); echo -e "${GREEN}User: $Dir${NOCOLOUR}";else Dir="nil"; fi
	if grep -i -q "Project" $ParFile; then Project=$(grep -i "Project" $ParFile | cut -f2); echo -e "${GREEN}Project directory: $Project${NOCOLOUR}";else Project="nil"; fi
	if grep -i -q "Original reads" $ParFile; then ReadDir=$(grep -i "Original reads" $ParFile | cut -f2); echo -e "${GREEN}Reads directory: $ReadDir${NOCOLOUR}";else ReadDir="nil";fi
	if grep -i -q "Sample names" $ParFile; then Species=$(grep -i "Sample names" $ParFile | cut -f2);echo -e "${GREEN}Sample prefix: $Species${NOCOLOUR}";else Species="nil";fi
	if grep -i -q "Diversity profile target" $ParFile; then divprotarget=$(grep -i "Diversity profile target" $ParFile | cut -f2);echo -e "${GREEN}Diversity profile target: $divprotarget${NOCOLOUR}";else divprotarget="nil";fi

#could have 'adapters in mapping file'
	if grep -i -q "Adapters" $ParFile; then Adapter=$(grep -i "Adapters" $ParFile | cut -f2); echo -e "${GREEN}Adapters to trim: $Adapter${NOCOLOUR}";else Adapters="nil";fi
	if grep -i -q "Taxonomy database" $ParFile; then taxa=$(grep -i "Taxonomy database" $ParFile | cut -f2); echo -e "${GREEN}Taxonomy database: $taxa${NOCOLOUR}";else taxa="nil";fi
	if grep -i -q "Rarefraction Low" $ParFile; then taxa=$(grep -i "Rarefraction Low" $ParFile | cut -f2); echo -e "${GREEN}Rarefraction Low: $rarefractionlow${NOCOLOUR}";else rarefractionlow="nil";fi
	if grep -i -q "Rarefraction High" $ParFile; then taxa=$(grep -i "Rarefraction High" $ParFile | cut -f2); echo -e "${GREEN}Rarefraction High: $rarefractionhigh${NOCOLOUR}";else rarefractionhigh="nil";fi
	if grep -i -q "Iterations" $ParFile; then iterations=$(grep -i "Iterations" $ParFile | cut -f2); echo -e "${GREEN}Iterations: $iterations${NOCOLOUR}";else iterations="nil";fi
	if grep -i -q "Depth" $ParFile; then Depth=$(grep -i "Depth" $ParFile | cut -f2); echo -e "${GREEN}Subsampling depth: $Depth${NOCOLOUR}"; else Depth="nil";fi
	if grep -i -q "Keep Singletons? (Y/N=1/0)" $ParFile; then singles=$(grep -i "Keep Singletons? (Y/N=1/0)" $ParFile | cut -f2); echo -e "${GREEN}Keep Singletons? (Y/N=1/0): $singles${NOCOLOUR}"; else singles="nil";fi
	if grep -i -q "Minimum length for clustering" $ParFile; then Truncate=$(grep -i "Minimum length for clustering" $ParFile | cut -f2); echo -e "${GREEN}Minimum length for clustering: $Depth${NOCOLOUR}"; else Truncate="nil";fi
# forward primer
# reverse primer (could also be in mapping file)
# diversity profiling target (ITS or 16S)

	sleep 1
else
	Dir="nil"
	Project="nil"
	ReadDir="nil"
	Species="nil"
	divprotarget="nil"
	Adapters="nil"
	taxa="nil"
	rarefractionlow="nil"
	rarefractionhigh="nil"
	iterations="nil"
	Depth="nil"
	singles="nil"
	Truncate="nil"
fi

# If running for the first time ask user the name of the project for
# file and directory naming purposes
if [ $Dir == "nil" ]; then
	Switch=0
	while [ "$Switch" -eq "0" ]; do
		echo -e "${BLUE}Please enter your home directory ${YELLOW}(ie: Documents/YOURNAME):${NOCOLOUR}"
		read -e Dir
		if [ ! -d $Dir ]; then
			echo -e "${RED}No directory of that name exists${NOCOLOUR}"
			echo -e "Would you like to create it? (Y/N)${NOCOLOUR}"
			read -N 1 yesno
			echo -e "\n"
			yesno=$(echo -e "$yesno" | tr '[:upper:]' '[:lower:]')
			if [ $yesno = "y" ]; then
				mkdir "$Dir/"
				Switch=1
			fi
		else
			Switch=1
		fi
	done
fi

if [ $Project == "nil" ]; then
#ask user the name of the project for file name/directory purposes
	echo -e "${BLUE}Please enter a project title:${NOCOLOUR}"
	read -e Project
	echo -e "${BLUE}You entered: ${GREEN}$Project${NOCOLOUR}"
fi

ProjectDir="${Dir}/${Project}" #the location to store the project files

if [ ! -e $ParFile ]; then
	ParFile="$ProjectDir/Metadata/Parameters.txt"
fi


#have to make the metadata file high up in the list!
if [ ! -d "$ProjectDir" ]; then #if the project directory doesn't exist, create all appropriate folders and sub-folders
	mkdir $ProjectDir
	mkdir $ProjectDir/Results_Summary
	mkdir $ProjectDir/Metadata
	mkdir $ProjectDir/Analysis
	mkdir $ProjectDir/Analysis/alpha
	mkdir $ProjectDir/Analysis/read_stats/
	mkdir $ProjectDir/Analysis/Statistics
	mkdir $ProjectDir/Analysis/Heatmaps
	mkdir $ProjectDir/Analysis/Normalised
	mkdir $ProjectDir/Analysis/Normalised/Heatmaps
	mkdir $ProjectDir/Analysis/Normalised/Statistics
	mkdir $ProjectDir/Analysis/diversityplots
fi

if ! grep -i -q "User" $ParFile; then echo -e "User	$Dir" >> $ParFile; fi
if ! grep -i -q "Project" $ParFile; then echo -e "Project	$Project" >> $ParFile; fi

if [ $ReadDir == "nil" ]; then
	Switch=0
	while [ "$Switch" -eq "0" ]; do
		echo -e "${BLUE}Please enter the file location of your reads ${RED}(your files MUST be paired end reads ending in a #.fastq):${NOCOLOUR}"
		read -e ReadDir
		if [ -d $ReadDir ]; then
			Switch=1
			echo -e "${BLUE}You entered: ${GREEN}$ReadDir${NOCOLOUR}"
			echo -e "Original reads	$ReadDir" >> $ParFile
			# create a list of the sequences to use with appropriate headings for QIIME2
			echo -e "sample-id,absolute-filepath,direction" >> "$ProjectDir/Metadata/import-list.csv"

			# Generate list of forward reads (assumes reads end in R1.fastq.gz)
			ls $ReadDir/*R1.fastq.gz | while read i; do
			     echo "$(basename $i | cut -f 1 -d '-'),$ReadDir/$i,forward" >> "$ProjectDir/Metadata/import-list.csv"
			done

			# Generate list of reverse reads (assumes reads end in R2.fastq.gz)
			ls $ReadDir/*R2.fastq.gz | while read i; do
			     echo "$(basename $i | cut -f 1 -d '-'),$ReadDir/$i,reverse" >> "$ProjectDir/Metadata/import-list.csv"
			done
		else
			echo -e "${RED}Directory does not exist: ${GREEN}$ReadDir${NOCOLOUR}"
		fi
	done
fi


# Adjust to remove case sensitivity (see below in $taxa)
if [ $divprotarget == "nil" ]; then
	Switch=0
	while [ "$Switch" -eq "0" ]; do
		echo -e "${BLUE}Please enter the diversity target (16S or ITS)${NOCOLOUR}"
		read -e divprotarget
		divprotarget=$(echo -e "$divprotarget" | tr '[:lower:]' '[:upper:]')	# HAVENT TESTED IF THIS WORKS
		if [ $divprotarget == "ITS" ]; then
			Switch=1
			echo -e "${BLUE}You entered: ${GREEN}$divprotarget${NOCOLOUR}"
		elif [ $divprotarget == "16S" ]; then
			Switch=1
			echo -e "${BLUE}You entered: ${GREEN}$divprotarget${NOCOLOUR}"
		else
			echo -e "${RED}Please only enter one of ITS or 16S${NOCOLOUR}"
		fi
	done
fi

if ! grep -i -q "Diversity profile target" $ParFile; then echo -e "Diversity profile target	$divprotarget" >> $ParFile; fi

F_primer="CCTAYGGGRBGCASCAG"
R_primer="GGACTACNNGGGTATCTAAT"

#Would be good to change this to a 'case'
if [ $taxa == "nil" ]; then
	if [ $divprotarget == "ITS"]; then
		taxa="ITS"
	else
		Switch=0
		while [ "$Switch" -eq "0" ]; do
			echo -e "${BLUE}Would you like the use Greengenes or SILVA for classification? Enter one${NOCOLOUR}"
			read -e -N 1 taxa
			taxa=$(echo -e "$taxa" | tr '[:upper:]' '[:lower:]')
			if [ $taxa = "g" ]; then
				Switch=1
				echo -e "${BLUE}You entered: ${GREEN}GreenGenes${NOCOLOUR}"
				taxa="Greengenes"
			elif [ $taxa = "s" ]; then
				Switch=1
				echo -e "${BLUE}You entered: ${GREEN}SILVA${NOCOLOUR}"
				taxa="SILVA"
			else
				echo -e "${RED}The option you entered is not available${NOCOLOUR}"
			fi
		done
	fi
	if ! grep -i -q "Taxonomy database" $ParFile; then echo -e "Taxonomy database	$taxa" >> $ParFile; fi
fi

Progress="$Dir/$Project.progress.txt"

if [ ! -e "$ProjectDir/Metadata/$Project.txt" ]; then
	Switch=0
	while [ "$Switch" -eq "0" ]; do
		echo -e "${BLUE}Please indicate the location of your Metadata/Mapping file${NOCOLOUR}"
		read -e Mapping
		if [ -e $Mapping ]; then
			Switch=1
			echo -e "${BLUE}You entered ${GREEN}$Mapping${NOCOLOUR}"
			echo -e "${BLUE}Moving mapping file to ${GREEN}$ProjectDir/Metadata/$Project.qzv${NOCOLOUR}" | tee -a $Progress
			cat $Mapping > "$ProjectDir/Metadata/$Project.metadata.tsv"
			# Load metadata file into qiime2
			qiime metadata tabulate \
				--m-input-file "$Mapping" \
				--o-visualization "$ProjectDir/Metadata/$Project.tabulated-sample-metadata.qzv"
			# MapHead="$ProjectDir/Metadata/$Project.head.tsv"
			# head -1 $Mapping > $MapHead
		else
			echo -e "${RED}File does not exist: ${GREEN}$Mapping${NOCOLOUR}"
		fi
	done
fi

#Import reads to qiime format from 'import-list' generated with previous code
if [ ! -e "$ProjectDir/Original_reads/original-paired-end.qza" ]; then
			if [ ! -d  "$ProjectDir/Original_reads" ]; then
				mkdir "$ProjectDir/Original_reads"
			fi
			qiime tools import \
		     --type 'SampleData[PairedEndSequencesWithQuality]' \
		     --input-path "$ProjectDir/Metadata/import-list.csv" \
		     --output-path "$ProjectDir/Original_reads/original-paired-end.qza" \
		     --source-format PairedEndFastqManifestPhred33 # make this a selecctable variable
fi

# Run dada2 on paired end reads, trimming 15 bases from left and right, and truncating reads longer than 300 bp (should be none!)

if [ ! -e "$ProjectDir/dada2/dada2-rep-seqs.qza" ]; then
	if [ ! -d "$ProjectDir/dada2" ]; then
		mkdir "$ProjectDir/dada2"
	fi
	qiime dada2 denoise-paired \
	     --i-demultiplexed-seqs "$ProjectDir/Original_reads/original-paired-end.qza" \
	     --p-trim-left-f 15 \
	     --p-trim-left-r 15 \
	     --p-trunc-len-f 300 \
	     --p-trunc-len-r 300 \
	     --o-table "$ProjectDir/dada2/out-table.qza" \
	     --o-representative-sequences "$ProjectDir/dada2/rep-seqs.qza" \
	     --o-denoising-stats "$ProjectDir/dada2/denoising-stats.qza"
fi

if [ ! -e "$ProjectDir/dada2/out-table.qzv" ]; then
	#FeatureTable and FeatureData summaries
	qiime feature-table summarize \
	  --i-table "$ProjectDir/dada2/out-table.qza" \
	  --o-visualization "$ProjectDir/dada2/out-table.qzv" \
	  --m-sample-metadata-file "$ProjectDir/Metadata/$Project.metadata.tsv"
fi

if [ ! -e "$ProjectDir/dada2/out-table.qzv" ]; then
	qiime feature-table tabulate-seqs \
	  --i-data "$ProjectDir/dada2/rep-seqs.qza" \
	  --o-visualization "$ProjectDir/dada2/rep-seqs.qzv"
fi

if [ ! -e ~/Sequences/16S_metagenomics/ReferenceSets/SILVA/rep_set/rep_set_16S_only/97/silva_132_97_16S.qza ]; then
	     # Load SILVA representative sequences
	qiime tools import \
	     --type 'FeatureData[Sequence]' \
	     --input-path ~/Sequences/16S_metagenomics/ReferenceSets/SILVA/rep_set/rep_set_16S_only/97/silva_132_97_16S.fna \
	     --output-path ~/Sequences/16S_metagenomics/ReferenceSets/SILVA/rep_set/rep_set_16S_only/97/silva_132_97_16S.qza
fi

if [ ! -e ~/Sequences/16S_metagenomics/ReferenceSets/SILVA/taxonomy/16S_only/97/consensus_taxonomy_all_levels.qza ]; then
	     # Load associated SILVA taxonomy
	qiime tools import \
	     --type 'FeatureData[Taxonomy]' \
	     --source-format HeaderlessTSVTaxonomyFormat \
	     --input-path ~/Sequences/16S_metagenomics/ReferenceSets/SILVA/taxonomy/16S_only/97/consensus_taxonomy_all_levels.txt \
	     --output-path ~/Sequences/16S_metagenomics/ReferenceSets/SILVA/taxonomy/16S_only/97/consensus_taxonomy_all_levels.qza
fi

if [ ! -e ~/Sequencs/16S_metagenomics/ReferenceSets/SILVA/rep_set/rep_set_16S_only/97/silva_132_97_16S_V3V4.qza ]; then
	     # Remove sections of reads outside V3-V4, better for classifier
	qiime feature-classifier extract-reads \
	     --i-sequences ~/Sequencs/16S_metagenomics/ReferenceSets/SILVA/rep_set/rep_set_16S_only/97/silva_132_97_16S.qza \
	     --p-f-primer $F_primer \
	     --p-r-primer $R_primer \
	     --o-reads ~/Sequencs/16S_metagenomics/ReferenceSets/SILVA/rep_set/rep_set_16S_only/97/silva_132_97_16S_V3V4.qza \
		--verbose
fi

if [ ! -e ~/Sequencs/16S_metagenomics/ReferenceSets/SILVA/97-V3V4-classifier.qza ]; then
	     # Run naive bayes classifier on samples (training of classifier)
	qiime feature-classifier fit-classifier-naive-bayes \
	     --i-reference-reads ~/Sequencs/16S_metagenomics/ReferenceSets/SILVA/rep_set/rep_set_16S_only/97/silva_132_97_16S_V3V4.qza \
	     --i-reference-taxonomy ~/Sequencs/16S_metagenomics/ReferenceSets/SILVA/taxonomy/16S_only/97/consensus_taxonomy_all_levels.qza \
	     --o-classifier ~/Sequencs/16S_metagenomics/ReferenceSets/SILVA/97-V3V4-classifier.qza \
	     --verbose
fi

if [ ! -d "$ProjectDir/Taxonomy" ]; then
	mkdir $ProjectDir/Taxonomy/
fi

if [ ! -e "$ProjectDir/Taxonomy/$taxa.qza" ]; then
     # Use sklearn to classify taxonomy of the representative reads
	qiime feature-classifier classify-sklearn \
	     --i-classifier 16S_metagenomics/ReferenceSets/SILVA/97-V3V4-classifier.qza \
	     --i-reads "$ProjectDir/dada2/rep-seqs.qza" \
	     --o-classification "$ProjectDir/Taxonomy/$taxa.qza" \
		--verbose
fi

# Generates an output of the taxa to view in browser
if [ ! -e "$ProjectDir/Taxonomy/$taxa.qzv" ]; then
	qiime metadata tabulate \
		--m-input-file "$ProjectDir/Taxonomy/$taxa.qza" \
		--o-visualization "$ProjectDir/Taxonomy/$taxa.qzv" \
		--verbose
fi

# Generates bar charts of taxa
if [ ! -e "$ProjectDir/Taxonomy/$taxa-bar-plots.qzv" ]; then
	qiime taxa barplot \
		--i-table "$ProjectDir/dada2/out-table.qza" \
		--i-taxonomy "$ProjectDir/Taxonomy/$taxa.qza" \
		--m-metadata-file "$ProjectDir/Metadata/$Project.metadata.tsv" \
		--o-visualization "$ProjectDir/Taxonomy/$taxa-bar-plots.qzv"
fi



##########################################

# Differential abundance testing with ANCOM

if [ ! -d "$ProjectDir/ANCOM" ]; then
	mkdir "$ProjectDir/ANCOM"
fi

# Filter a Category by a particular variable, commented out for now

# if [ ! -e "$ProjectDir/ANCOM/$filter-table.qza" ]
# 	qiime feature-table filter-samples \
# 		--i-table "$ProjectDir/dada2/out-table.qza" \
# 		--m-metadata-file "$ProjectDir/Metadata/$Project.metadata.tsv" \
# 		--p-where "$Category='$filter'" \
# 		--o-filtered-table "$ProjectDir/ANCOM/$filter-table.qza"
# fi

if [ ! -e "$ProjectDir/ANCOM/pseudo-table.qza" ]; then
	qiime composition add-pseudocount \
		--i-table "$ProjectDir/dada2/out-table.qza" \
		--o-composition-table "$ProjectDir/ANCOM/$taxa.pseudo-table.qza"
fi

if [ ! -e "$ProjectDir/ANCOM/ancom-$Category.qzv" ]; then
	qiime composition ancom \
		--i-table "$ProjectDir/ANCOM/pseudo-table.qza" \
		--m-metadata-file "$ProjectDir/Metadata/$Project.metadata.tsv" \
		--m-metadata-column $Category \
		--o-visualization "$ProjectDir/ANCOM/ancom-$Category.qzv"
fi

# Collapse at various levels and analyse with ANCOM
Count="6"
while [ $Count -gt "0" ]; do
	if [ ! -e "$ProjectDir/Taxonomy/$taxa.L$Count.qza" ]; then
		qiime taxa collapse \
			--i-table "$ProjectDir/dada2/out-table.qza" \
			--i-taxonomy "$ProjectDir/Taxonomy/$taxa.qza" \
			--p-level $Count \
			--o-collapsed-table "$ProjectDir/Taxonomy/$taxa.L$Count.qza"
	fi

	     # Add pseudocount for expression/abundance comparsion (removes zeros)
	if [ ! -e "$ProjectDir/ANCOM/$taxa.L$Count.pseudo-table.qza" ]; then
		qiime composition add-pseudocount \
			--i-table "$ProjectDir/Taxonomy/$taxa.L$Count.qza" \
			--o-composition-table "$ProjectDir/ANCOM/$taxa.L$Count.pseudo-table.qza"
	fi

	# Composition comparison at specified level with ANCOM
	if [ ! -e "$ProjectDir/ANCOM/ancom-L$Count-$Category.qzv" ]; then
		qiime composition ancom \
			--i-table "$ProjectDir/ANCOM/$taxa.L$Count.pseudo-table.qza" \
			--m-metadata-file "$ProjectDir/Metadata/$Project.metadata.tsv" \
			--m-metadata-column $Category \
			--o-visualization "$ProjectDir/ANCOM/ancom-L$Count-$Category.qzv"
	fi
	Count=$((Count - 1))
done


#Generate a tree for phylogenetic diversity analyses¶

mkdir $ProjectDir/Phylogeny

qiime phylogeny align-to-tree-mafft-fasttree \
	--i-sequences "$ProjectDir/dada2/rep-seqs.qza" \
	--o-alignment "$ProjectDir/Phylogeny/aligned-rep-seqs.qza" \
	--o-masked-alignment "$ProjectDir/Phylogeny/masked-aligned-rep-seqs.qza" \
	--o-tree "$ProjectDir/Phylogeny/unrooted-tree.qza" \
	--o-rooted-tree "$ProjectDir/Phylogeny/rooted-tree.qza"

#Alpha and beta diversity analysis
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table.qza \
  --p-sampling-depth 30000 \  ### change this
  --m-metadata-file sample-metadata.tsv \
  --output-dir core-metrics-results



## Output artifacts:
if [ ! -e "$ProjectDir/Metadata/$Project.alpha-metrics.txt" ]; then
	cat << EOT >> "$ProjectDir/Metadata/$Project.alpha-metrics.txt"
evenness_vector.qza
faith_pd_vector.qza
shannon_vector.qza
rarefied_table.qza
observed_otus_vector.qza
EOT
sed -i 's/\.qza//g' "$ProjectDir/Metadata/$Project.alpha-metrics.txt"
fi


if [ ! -e "$ProjectDir/Metadata/$Project.beta-metrics.txt" ]; then
	cat << EOT >> "$ProjectDir/Metadata/$Project.beta-metrics.txt"
bray_curtis_distance_matrix.qza
bray_curtis_pcoa_results.qza
unweighted_unifrac_distance_matrix.qza
unweighted_unifrac_pcoa_results.qza
weighted_unifrac_distance_matrix.qza
weighted_unifrac_pcoa_results.qza
jaccard_distance_matrix.qza
jaccard_pcoa_results.qza
EOT
sed -i 's/\.qza//g' "$ProjectDir/Metadata/$Project.beta-metrics.txt"
fi


while read i; do
     qiime diversity alpha-group-significance \
      --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
      --m-metadata-file sample-metadata.tsv \
      --o-visualization core-metrics-results/faith-pd-group-significance.qzv


      core-metrics-results/faith-pd-group-significance.qzv
      core-metrics-results/evenness-group-significance.qzv

      qiime diversity beta-group-significance \
     --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
     --m-metadata-file sample-metadata.tsv \
     --m-metadata-column BodySite \
     --o-visualization core-metrics-results/unweighted-unifrac-body-site-significance.qzv \
     --p-pairwise

     qiime diversity beta-group-significance \
     --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
     --m-metadata-file sample-metadata.tsv \
     --m-metadata-column Subject \
     --o-visualization core-metrics-results/unweighted-unifrac-subject-group-significance.qzv \
     --p-pairwise

     core-metrics-results/unweighted-unifrac-body-site-significance.qzv
     core-metrics-results/unweighted-unifrac-subject-group-significance.qzv


source deactivate
