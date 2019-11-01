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

# Look for a 'Parameters' text file in a 'metadata' folder that stores the user input
# If no file is present, or the variables are present in the file, set the variables to 'nil'
if [ -e "$1/00-Metadata/Parameters.txt" ]; then
	echo -e "${BLUE}Parameter file detected...obtaining previously entered options${NOCOLOUR}"
	ParFile="$1/00-Metadata/Parameters.txt"
	Meta="$1/00-Metadata"

	if grep -i -q "Environment" $ParFile; then environment=$(grep -i "Environment" $ParFile | cut -f2); echo -e "${GREEN}Environment: $environment${NOCOLOUR}";else environment="nil"; fi

	if grep -i -q "Project folder" $ParFile; then Dir=$(grep -i "Project folder" $ParFile | cut -f2); echo -e "${GREEN}Project folder: $Dir${NOCOLOUR}";else Dir="nil"; fi
	if grep -i -q "Project name" $ParFile; then Project=$(grep -i "Project name" $ParFile | cut -f2); echo -e "${GREEN}Project name: $Project${NOCOLOUR}";else Project="nil"; fi
	if grep -i -q "Original reads" $ParFile; then ReadDir=$(grep -i "Original reads" $ParFile | cut -f2); echo -e "${GREEN}Reads directory: $ReadDir${NOCOLOUR}";else ReadDir="nil";fi
	if grep -i -q "Diversity profile target" $ParFile; then divprotarget=$(grep -i "Diversity profile target" $ParFile | cut -f2);echo -e "${GREEN}Diversity profile target: $divprotarget${NOCOLOUR}";else divprotarget="nil";fi

#could have 'adapters in mapping file'
#	if grep -i -q "Adapters" $ParFile; then Adapter=$(grep -i "Adapters" $ParFile | cut -f2); echo -e "${GREEN}Adapters to trim: $Adapter${NOCOLOUR}";else Adapters="nil";fi
	if grep -i -q "Taxonomy database" $ParFile; then taxa=$(grep -i "Taxonomy database" $ParFile | cut -f2); echo -e "${GREEN}Taxonomy database: $taxa${NOCOLOUR}";else taxa="nil";fi
#	if grep -i -q "Rarefraction Low" $ParFile; then taxa=$(grep -i "Rarefraction Low" $ParFile | cut -f2); echo -e "${GREEN}Rarefraction Low: $rarefractionlow${NOCOLOUR}";else rarefractionlow="nil";fi
#	if grep -i -q "Rarefraction High" $ParFile; then taxa=$(grep -i "Rarefraction High" $ParFile | cut -f2); echo -e "${GREEN}Rarefraction High: $rarefractionhigh${NOCOLOUR}";else rarefractionhigh="nil";fi
#	if grep -i -q "Iterations" $ParFile; then iterations=$(grep -i "Iterations" $ParFile | cut -f2); echo -e "${GREEN}Iterations: $iterations${NOCOLOUR}";else iterations="nil";fi
#	if grep -i -q "Depth" $ParFile; then Depth=$(grep -i "Depth" $ParFile | cut -f2); echo -e "${GREEN}Subsampling depth: $Depth${NOCOLOUR}"; else Depth="nil";fi
#	if grep -i -q "Keep Singletons? (Y/N=1/0)" $ParFile; then singles=$(grep -i "Keep Singletons? (Y/N=1/0)" $ParFile | cut -f2); echo -e "${GREEN}Keep Singletons? (Y/N=1/0): $singles${NOCOLOUR}"; else singles="nil";fi
#	if grep -i -q "Minimum length for clustering" $ParFile; then Truncate=$(grep -i "Minimum length for clustering" $ParFile | cut -f2); echo -e "${GREEN}Minimum length for clustering: $Truncate${NOCOLOUR}"; else Truncate="nil";fi

	if grep -i -q "F_primer name" $ParFile; then F_primerName=$(grep -i "F_primer name" $ParFile | cut -f2); echo -e "${GREEN}Forward primer name: $F_primerName${NOCOLOUR}"; else F_primerName="nil";fi
	if grep -i -q "Forward primer" $ParFile; then F_primer=$(grep -i "Forward primer" $ParFile | cut -f2); echo -e "${GREEN}Forward primer sequence: $F_primer${NOCOLOUR}"; else F_primer="nil";fi
	if grep -i -q "F_primer start" $ParFile; then F_Position=$(grep -i "F_primer start" $ParFile | cut -f2); echo -e "${GREEN}Forward primer start: $F_Position${NOCOLOUR}"; else F_Position="nil";fi
	if grep -i -q "R_primer name" $ParFile; then R_primerName=$(grep -i "R_primer name" $ParFile | cut -f2); echo -e "${GREEN}Reverse primer name: $R_primerName${NOCOLOUR}"; else R_primerName="nil";fi
	if grep -i -q "Reverse primer" $ParFile; then R_primer=$(grep -i "Reverse primer" $ParFile | cut -f2); echo -e "${GREEN}Reverse primer sequence: $R_primer${NOCOLOUR}"; else R_primer="nil";fi
	if grep -i -q "R_primer start" $ParFile; then R_Position=$(grep -i "R_primer start" $ParFile | cut -f2); echo -e "${GREEN}Reverse primer name: $R_Position${NOCOLOUR}"; else R_Position="nil";fi
	if grep -i -q "Read Length" $ParFile; then ReadLength=$(grep -i "Read Length" $ParFile | cut -f2); echo -e "${GREEN}Desired single read length: $ReadLength${NOCOLOUR}"; else ReadLength="nil";fi


	if grep -i -q "Taxonomy FNA directory" $ParFile; then classifier_fna_dir=$(grep -i "Taxonomy FNA directory" $ParFile | cut -f2); echo -e "${GREEN}Taxonomy FNA directory: $classifier_fna_dir${NOCOLOUR}"; else classifier_fna_dir="nil";fi
	if grep -i -q "Taxonomy FNA file" $ParFile; then classifier_fna=$(grep -i "Taxonomy FNA file" $ParFile | cut -f2); echo -e "${GREEN}Taxonomy FNA file: $classifier_fna${NOCOLOUR}"; else classifier_fna="nil";fi
	if grep -i -q "Taxonomy taxa name directory" $ParFile; then classifier_taxa_dir=$(grep -i "Taxonomy taxa name directory" $ParFile | cut -f2); echo -e "${GREEN}Taxonomy taxa name directory: $classifier_taxa_dir${NOCOLOUR}"; else classifier_taxa_dir="nil";fi
	if grep -i -q "Taxonomy taxa name file" $ParFile; then classifier_taxa=$(grep -i "Taxonomy taxa name file" $ParFile | cut -f2); echo -e "${GREEN}Taxonomy taxa name file: $classifier_taxa${NOCOLOUR}"; else classifier_taxa="nil";fi

	if grep -i -q "Taxonomy classifier" $ParFile; then classifier_method=$(grep -i "Taxonomy classifier" $ParFile | cut -f2); echo -e "${GREEN}Taxonomy classification method: $classifier_method${NOCOLOUR}"; else classifier_method="nil";fi

	sleep 1
else
	environment="nil"
	Dir="nil"
	Project="nil"
	ReadDir="nil"
	#Species="nil"
	divprotarget="nil"
	#Adapters="nil"
	taxa="nil"
	#rarefractionlow="nil"
	#rarefractionhigh="nil"
	#iterations="nil"
	#Depth="nil"
	#singles="nil"
	#Truncate="nil"
	F_primerName="nil"
	F_primer="nil"
	F_Position="nil"
	R_primerName="nil"
	R_primer="nil"
	R_Position="nil"
	ReadLength="nil"
	classifier_fna_dir="nil"
	classifier_fna="nil"
	classifier_taxa_dir="nil"
	classifier_taxa="nil"
	classifier_method="nil"
fi

if [ $environment == "nil" ]; then
	echo -e "${BLUE}Please enter the name of your qiime2 environment${NOCOLOUR}"
	if [ -d ~/miniconda3/envs ]; then
		if  [ $(ls ~/miniconda3/envs/ | wc -l) -eq "1" ]; then
			environment=$(basename ~/miniconda3/envs/*)
			echo -e "The only conda environment present is: $environment"
		else
			echo -e "Possible options are:"
			echo -e "$(ls ~/miniconda3/envs/)"
			read -e environment
		fi
	else
		read -e environment
	fi

fi

#Start qiime2 environment in conda
echo "Loading qiime2 environment: $environment"
source activate $environment
#Make tab completion available, not needed in a pipeline, but here to remind me!
#	source tab-qiime


# If running for the first time ask user the name of the project for
# file and directory naming purposes
if [ $Dir == "nil" ]; then
	Switch="0"
	while [ "$Switch" -eq "0" ]; do
		echo -e "${BLUE}Please the directory where you keep your projects${YELLOW}(eg: Documents/YOURNAME):${NOCOLOUR}"
		read -e Dir #need to strip last / from autocomplete
		if [ ! -d $Dir ]; then
			echo -e "${RED}No directory of that name exists${NOCOLOUR}"
			echo -e "Would you like to create it? (Y/N)${NOCOLOUR}"
			read -e -N 1 yesno
			yesno=$(echo -e "$yesno" | tr '[:upper:]' '[:lower:]')
			if [ $yesno = "y" ]; then
				mkdir "$Dir"
				Switch="1"
			fi
		else
			Switch="1"
		fi
	done
fi

if [ $Project == "nil" ]; then
#ask user the name of the project for file name/directory purposes
	echo -e "${BLUE}Please enter a title for your project:${NOCOLOUR}"
	read -e Project
fi

#the location to store the project files
ProjectDir="${Dir}/${Project}"

#have to make the metadata file high up in the list!
#if the project directory doesn't exist, create all appropriate folders and sub-folders
if [ ! -d "$ProjectDir" ]; then
	echo -e "Creating directory: $Project"
	mkdir $ProjectDir
fi

if [ ! -d "$ProjectDir/00-Metadata" ]; then
	echo -e "Creating Metadata subdirectory"
	mkdir "$ProjectDir/00-Metadata"
fi

# if [ ! -d "$ProjectDir/Results_Summary" ]; then
# 	echo -e "Creating Results subdirectory"
# 	mkdir "$ProjectDir/Results_Summary"
# fi

if [ -z $ParFile ] || [ ! -e $ParFile ]; then
	echo -e "Writing Parameters file"
	ParFile="$ProjectDir/00-Metadata/Parameters.txt"
	echo -e "Project folder	$Dir" >> $ParFile
	echo -e "Project name	$Project" >> $ParFile
	echo -e "Environment	$environment" >> $ParFile
fi

if ! grep -i -q "Project folder" $ParFile; then echo -e "Project folder	$Dir" >> $ParFile; fi
if ! grep -i -q "Project name" $ParFile; then echo -e "Project name	$Project" >> $ParFile; fi
if ! grep -i -q "Environment" $ParFile; then echo -e "Environment	$environment" >> $ParFile; fi

if [ $ReadDir == "nil" ]; then
	Switch="0"
	while [ "$Switch" -eq "0" ]; do
		echo -e "${BLUE}Please enter the file location of your reads ${RED}(your files MUST be paired end reads ending in a #.fastq):${NOCOLOUR}"
		read -e ReadDir
		ReadDir=$(realpath "$ReadDir")
		if [ -d $ReadDir ]; then
			Switch="1"
			echo -e "${BLUE}You entered: ${GREEN}$ReadDir${NOCOLOUR}"
			echo -e "Original reads	$ReadDir" >> $ParFile
			# create a list of the sequences to use with appropriate headings for QIIME2
			echo -e "sample-id,absolute-filepath,direction" >> "$ProjectDir/00-Metadata/import-list.csv"

			# Generate list of forward reads (assumes reads end in R1.fastq.gz)
			ls $ReadDir/*R1*fastq* | while read i; do
			     echo "$(basename $i | cut -f 1 -d '-'),$i,forward" >> "$ProjectDir/00-Metadata/import-list.csv"
			done

			# Generate list of reverse reads (assumes reads end in R2.fastq.gz)
			ls $ReadDir/*R2*fastq* | while read i; do
			     echo "$(basename $i | cut -f 1 -d '-'),$i,reverse" >> "$ProjectDir/00-Metadata/import-list.csv"
			done
		else
			echo -e "${RED}Directory does not exist: ${GREEN}$ReadDir${NOCOLOUR}"
		fi
	done
fi



if [ $divprotarget == "nil" ]; then
	Switch="0"
	while [ "$Switch" -eq "0" ]; do
		echo -e "${BLUE}Please enter the diversity target (16S or ITS)${NOCOLOUR}"
		read -e divprotarget
		divprotarget=$(echo -e "$divprotarget" | tr '[:lower:]' '[:upper:]')
		if [ $divprotarget == "ITS" ]; then
			Switch="1"
			echo -e "${BLUE}You entered: ${GREEN}$divprotarget${NOCOLOUR}"
		elif [ $divprotarget == "16S" ]; then
			Switch="1"
			echo -e "${BLUE}You entered: ${GREEN}$divprotarget${NOCOLOUR}"
		else
			echo -e "${RED}Please only enter one of ITS or 16S${NOCOLOUR}"
		fi
	done
fi

if ! grep -i -q "Diversity profile target" $ParFile; then echo -e "Diversity profile target	$divprotarget" >> $ParFile; fi


if [ $taxa == "nil" ]; then
	if [ $divprotarget == "ITS" ]; then
		taxa="ITS"
	else
		taxa="SILVA"
	fi
fi

if ! grep -i -q "Taxonomy database" $ParFile; then echo -e "Taxonomy database	$taxa" >> $ParFile; fi


if [ $classifier_fna == "nil" ]; then
	echo -e "${BLUE}Please enter location of the sequence/fna database (eg SILVA/rep_set/rep_set_16S_only/97/silva_132_97_16S.fna)${NOCOLOUR}"
	read -e classifier_fna
	classifier_fna_dir=$(dirname $classifier_fna)
	classifier_fna=$(basename -s ".fna" $classifier_fna)
	echo -e "${BLUE}Please enter location of the taxonomy database (eg SILVA/03-Taxonomy/16S_only/97/majority_taxonomy_7_levels.txt)${NOCOLOUR}"
	read -e classifier_taxa
	classifier_taxa_dir=$(dirname $classifier_taxa)
	classifier_taxa=$(basename -s ".txt" $classifier_taxa)
fi

if ! grep -i -q "Taxonomy FNA directory" $ParFile; then echo -e "Taxonomy FNA directory	$classifier_fna_dir" >> $ParFile; fi
if ! grep -i -q "Taxonomy FNA file" $ParFile; then echo -e "Taxonomy FNA file	$classifier_fna" >> $ParFile; fi
if ! grep -i -q "Taxonomy taxa name directory" $ParFile; then echo -e "Taxonomy taxa name directory	$classifier_taxa_dir" >> $ParFile; fi
if ! grep -i -q "Taxonomy taxa name file" $ParFile; then echo -e "Taxonomy taxa name file	$classifier_taxa" >> $ParFile; fi

if [ $classifier_method == "nil" ]; then
	Switch="0"
	while [ $Switch -eq "0" ]; do
		echo -e "${BLUE}Please enter the number corresponding to the classification method to use${NOCOLOUR}"
		echo -e "${YELLOW}"
		echo -e "1) Naive bayes"
		echo -e "2) Consensus BLAST"
		echo -e "${NOCOLOUR}"
		read -e methodSelect
		case $methodSelect in
			1)
			classifier_method="classify-sklearn"
			Switch="1"
			;;
			2)
			classifier_method="classify-consensus-blast"
			Switch="1"
			;;
			*)
			echo -e "${RED}ERROR: Please enter an appropriate number${NOCOLOUR}"
			;;
		esac
	done
fi

if ! grep -i -q "Taxonomy classifier" $ParFile; then echo -e "Taxonomy classifier	$classifier_method" >> $ParFile; fi


if [ $divprotarget == "16S" ]; then
	if [ $F_primer == "nil" ]; then
		Switch="0"
		while [ $Switch -eq "0" ]; do
			echo -e "${BLUE}Please enter the number corresponding to your FORWARD primer, or 'C' for custom${NOCOLOUR}"
			echo -e "${YELLOW}"
			echo -e "1) V1\t27F\tAGAGTTTGATCMTGGCTCAG"
			echo -e "2) V3\t341F\tCCTAYGGGRBGCASCAG"
			echo -e "${NOCOLOUR}"
			read -e primerSelect
			case $primerSelect in
				1)
				F_primer="AGAGTTTGATCMTGGCTCAG"
				F_primerName="V1"
				F_Position="27"
				Switch="1"
				;;
				2)
				F_primer="CCTAYGGGRBGCASCAG"
				F_primerName="V3"
				F_Position="341"
				Switch="1"
				;;
				c|C)
				reserved="1"
				while [ $reserved -eq "1" ]; do
					echo -e "${BLUE}Please enter the NAME of your FORWARD primer (e.g V2-custom): ${NOCOLOUR}"
					read -e F_primerName
					if [ $F_primerName == "V1" ] || [ $F_primerName == "V3" ]; then
						echo -e "${RED}ERROR: Sorry but that name is reserved ${NOCOLOUR}"
					else
						reserved="0"
					fi
				done
				echo -e "${BLUE}Please enter the sequence of your FORWARD primer: ${NOCOLOUR}"
				read -e F_primer
				echo -e "${BLUE}Please enter the start position of your FORWARD primer (if unknown please enter 0): ${NOCOLOUR}"
				read -e F_Position
				Switch="1"
				;;
				*)
				echo -e "${RED}ERROR: Please enter an appropriate number OR enter C for custom input${NOCOLOUR}"
				;;
			esac
		done
	fi
	if [ $R_primer == "nil" ]; then
		Switch="0"
		while [ $Switch -eq "0" ]; do
			echo -e "${BLUE}Please enter the number corresponding to your REVERSE primer, or 'C' for custom${NOCOLOUR}"
			echo -e "${YELLOW}"
			echo -e "1) V3\t519R\tGWATTACCGCGGCKGCTG"
			echo -e "2) V4\t806R\tGGACTACNNGGGTATCTAAT"
			echo -e "${NOCOLOUR}"
			read -e primerSelect
			case $primerSelect in
				1)
				R_primer="GWATTACCGCGGCKGCTG"
				R_primerName="V3"
				R_Position="519"
				Switch="1"
				;;
				2)
				R_primer="GGACTACNNGGGTATCTAAT"
				R_primerName="V4"
				R_Position="806"
				Switch="1"
				;;
				c|C)
				reserved="1"
				while [ $reserved -eq "1" ]; do
					echo -e "${BLUE}Please enter the NAME of your REVERSE primer (e.g V5-custom): ${NOCOLOUR}"
					read -e R_primerName
					if [ $F_primerName == "V3" ] || [ $F_primerName == "V4" ]; then
						echo -e "${RED}ERROR: Sorry but that name is reserved ${NOCOLOUR}"
					else
						reserved="0"
					fi
				done
				echo -e "${BLUE}Please enter the sequence of your REVERSE primer: ${NOCOLOUR}"
				read -e R_primer
				echo -e "${BLUE}Please enter the start position of your REVERSE primer (if unknown please enter 0): ${NOCOLOUR}"
				read -e R_Position
				Switch="1"
				;;
				*)
				echo -e "${RED}ERROR: Please enter an appropriate number OR enter C for custom input${NOCOLOUR}"
				;;
			esac
		done
	fi
else
	if [ $F_primer == "nil" ]; then
		F_primer="CTTGGTCATTTAGAGGAAGTAA"
		F_primerName="ITS1F"
		F_Position="0"
		R_primer="GCTGCGTTCTTCATCGATGC"
		R_primerName="ITS2"
		R_Position="0"
	fi
fi

if ! grep -i -q "F_primer name" $ParFile; then echo -e "F_primer name	$F_primerName" >> $ParFile; fi
if ! grep -i -q "Forward primer" $ParFile; then echo -e "Forward primer	$F_primer" >> $ParFile; fi
if ! grep -i -q "F_primer start" $ParFile; then echo -e "F_primer start	$F_Position" >> $ParFile; fi
if ! grep -i -q "R_primer name" $ParFile; then echo -e "R_primer name	$R_primerName" >> $ParFile; fi
if ! grep -i -q "Reverse primer" $ParFile; then echo -e "Reverse primer	$R_primer" >> $ParFile; fi
if ! grep -i -q "R_primer start" $ParFile; then echo -e "R_primer start	$R_Position" >> $ParFile; fi


if [ $ReadLength == "nil" ]; then
	echo -e "${BLUE}Please enter the desired length of all reads (e.g. MiSeq will be 250 or 300)${NOCOLOUR}"
	read -e ReadLength
fi

if ! grep -i -q "Read Length" $ParFile; then echo -e "Read Length	$ReadLength" >> $ParFile; fi


Progress="$Dir/$Project.progress.txt"

if [ ! -e "$ProjectDir/00-Metadata/$Project.tabulated-sample-metadata.qzv" ]; then
	Switch="0"
	while [ "$Switch" -eq "0" ]; do
		echo -e "${BLUE}Please indicate the location of your Metadata/Mapping file${NOCOLOUR}"
		read -e Mapping
		if [ -e $Mapping ]; then
			Switch="1"
			echo -e "${BLUE}You entered ${GREEN}$Mapping${NOCOLOUR}" | tee -a $Progress
			MappingCount=$(grep -c '' $Mapping)
			MappingCount=$((MappingCount-2))
			echo -e "${BLUE}Samples detected in mapping file = ${GREEN}$MappingCount${NOCOLOUR}"
			sleep 1s
			SampleCount=$(wc -l < "$ProjectDir/00-Metadata/import-list.csv") #counts (wc) the number of lines (-l) in an input file (<). Putting the command within $() allows you to save the value to a variable, which we can then print to the terminal
			SampleCount=$((SampleCount-1))
			SampleCount=$((SampleCount/2))
			echo -e "${BLUE}Samples detected in directory = ${GREEN}$SampleCount${NOCOLOUR}"

			if [ $SampleCount -ne $MappingCount ]; then
				echo -e "${RED}The number of samples in the mapping file ($MappingCount) does not match the number detected in the read directory ($SampleCount), please rectify to continue${NOCOLOUR}"
			else
				echo -e "${BLUE}Moving mapping file to ${GREEN}$ProjectDir/00-Metadata/$Project.(tsv|qzv)${NOCOLOUR}" | tee -a $Progress
				cat $Mapping > "$ProjectDir/00-Metadata/$Project.metadata.tsv"
				# Load metadata file into qiime2
				qiime metadata tabulate \
					--m-input-file "$Mapping" \
					--o-visualization "$ProjectDir/00-Metadata/$Project.tabulated-sample-metadata.qzv"

				Mapping="$ProjectDir/00-Metadata/$Project.metadata.tsv"
				MapHead="$ProjectDir/00-Metadata/$Project.head.tsv"
				head -2 $Mapping > $MapHead
			fi
		else
			echo -e "${RED}File does not exist: ${GREEN}$Mapping${NOCOLOUR}"
		fi
	done
fi

### ADD CATEGORIES FOR TESTING HERE

echo -e "${BLUE}The first two rows of your mapping file look like this:${YELLOW}"
head -2 "$ProjectDir/00-Metadata/$Project.head.tsv"
sleep 1s

if [ ! -e "$ProjectDir/00-Metadata/Groups.txt" ]; then
	echo -e "${BLUE}How many group/treatment variables would you like to compare (can only be 'categorical' variables)${NOCOLOUR}"
	read -e TreatmentNo
	Count=0
	while [ "$Count" -ne "$TreatmentNo" ]; do
		echo -e "${BLUE}Please name treatment/group $((Count+1)) exactly as it appears in the mapping file${NOCOLOUR}"
		read Treatment
		if grep -q $Treatment $MapHead; then
			echo -e "$Treatment" >> "$ProjectDir/00-Metadata/Groups.txt"
			echo -e "$Treatment was input as a treatment/group" | tee -a $Progress
			Count=$((Count+1))
		else
			echo -e "${RED}Error: That treatment group does not appear in your mapping file, please try again${YELLOW}"
			head -2 "$ProjectDir/00-Metadata/$Project.txt"
			echo -e "${NOCOLOUR}"
		fi
	done

	if [ "$TreatmentNo" -gt "0" ]; then
		echo -e "${BLUE}Your selected treatments are:${GREEN}"
		cat "$ProjectDir/00-Metadata/Groups.txt"
		echo -e "${NOCOLOUR}"
		Comparisons="$TreatmentNo"
	else
		echo -e "${BLUE}No treatments selected${GREEN}"
		echo -e "${NOCOLOUR}"
		Comparisons="0"
	fi
else
	echo -e "${BLUE}Treatment file detected, comparison groups are: ${GREEN}"
	cat "$ProjectDir/00-Metadata/Groups.txt"
	Switch="0"
	while [ $Switch -eq "0" ]; do
		echo -e "${BLUE}Would you like to add another treatment group (Y/N)? ${NOCOLOUR}"
		read -e -N 1 yesno
		yesno=$(echo -e "$yesno" | tr '[:upper:]' '[:lower:]')
		if [ $yesno = "y" ]; then
			echo -e "${BLUE}How many group/treatment variables would you like to compare (can only be 'categorical' variables)${NOCOLOUR}"
			read -e TreatmentNo
			Count=0
			while [ "$Count" -ne "$TreatmentNo" ]; do
				echo -e "${BLUE}Please name treatment/group $((Count+1)) exactly as it appears in the mapping file${NOCOLOUR}"
				read Treatment
				if grep -q $Treatment $MapHead; then
					echo -e "$Treatment" >> "$ProjectDir/00-Metadata/Groups.txt"
					echo -e "$Treatment was input as a treatment/group" | tee -a $Progress
					Count=$((Count+1))
				else
					echo -e "${RED}Error: That treatment group does not appear in your mapping file, please try again${YELLOW}"
					head -2 "$ProjectDir/00-Metadata/$Project.head.tsv"
					echo -e "${NOCOLOUR}"
				fi
			done
		fi
		echo -e "${BLUE}Your selected treatments are:${GREEN}"
		cat "$ProjectDir/00-Metadata/Groups.txt"
		echo -e "${NOCOLOUR}"
		Comparisons=$(wc -l < "$ProjectDir/00-Metadata/Groups.txt")
		Switch="1"
		done
fi




#Import reads to qiime format from 'import-list' generated with previous code
if [ ! -e "$ProjectDir/01-Original_reads/original-paired-end.qza" ]; then
	if [ ! -d  "$ProjectDir/01-Original_reads" ]; then
		mkdir "$ProjectDir/01-Original_reads"
	fi
	echo -e "$(date)" | tee -a $Progress
	echo -e "importing reads" | tee -a $Progress
	qiime tools import \
		--type 'SampleData[PairedEndSequencesWithQuality]' \
		--input-path "$ProjectDir/00-Metadata/import-list.csv" \
		--output-path "$ProjectDir/01-Original_reads/original-paired-end.qza" \
		--input-format PairedEndFastqManifestPhred33 # make this a selecctable variable
fi



# Run dada2 on paired end reads, trimming 15 bases from left and right, and truncating reads longer than 300 bp (should be none!)

#length=$(($R_Position - $F_Position))

if [ ! -d "$ProjectDir/02-dada2" ]; then
	mkdir "$ProjectDir/02-dada2"
fi

if [ ! -e "$ProjectDir/02-dada2/rep-seqs.qza" ]; then
	echo -e "$(date)" | tee -a $Progress
	echo -e "Running dada2" | tee -a $Progress
	qiime dada2 denoise-paired \
	     --i-demultiplexed-seqs "$ProjectDir/01-Original_reads/original-paired-end.qza" \
		--p-n-threads 0 \
	     --p-trim-left-f ${#F_primer} \
	     --p-trim-left-r ${#R_primer} \
	     --p-trunc-len-f $ReadLength \
	     --p-trunc-len-r $ReadLength \
	     --o-table "$ProjectDir/02-dada2/out-table.qza" \
	     --o-representative-sequences "$ProjectDir/02-dada2/rep-seqs.qza" \
	     --o-denoising-stats "$ProjectDir/02-dada2/denoising-stats.qza" \
		--verbose
fi

if [ ! -e "$ProjectDir/02-dada2/rep-seqs.qzv" ]; then
	qiime feature-table tabulate-seqs \
	  --i-data "$ProjectDir/02-dada2/rep-seqs.qza" \
	  --o-visualization "$ProjectDir/02-dada2/rep-seqs.qzv"
fi

if [ ! -e "$ProjectDir/02-dada2/denoising-stats.qzv" ]; then
	qiime metadata tabulate \
	  --m-input-file "$ProjectDir/02-dada2/denoising-stats.qza" \
	  --o-visualization "$ProjectDir/02-dada2/denoising-stats.qzv"
fi

#USE BELOW TO UNZIP FILES AND PULL OUT DATA!
#unzip 16S.L1.qza -d tmp; mv tmp/*/data 16S.L1; rm -R tmp

#Need to convert biom tables to tsv as often as possible
#biom convert --to-tsv -i 464737bc-ad72-448c-a36c-d013c621a95e/data/feature-table.biom -o feature-table.tsv



if [ ! -e "$classifier_fna_dir/$classifier_fna.qza" ]; then
	# Load representative sequences
	echo -e "$(date)" | tee -a $Progress
	echo -e "importing classifier fna from $classifier_fna_dir/$classifier_fna.fna" | tee -a $Progress
	qiime tools import \
	     --type 'FeatureData[Sequence]' \
	     --input-path "$classifier_fna_dir/$classifier_fna.fna" \
	     --output-path "$classifier_fna_dir/$classifier_fna.qza"
fi

if [ ! -e "$classifier_taxa_dir/$classifier_taxa.qza" ]; then
	echo -e "$(date)" | tee -a $Progress
	echo -e "importing taxa for classifier from $classifier_taxa_dir/$classifier_taxa.txt" | tee -a $Progress
	     # Load associated taxonomy
	qiime tools import \
	     --type 'FeatureData[Taxonomy]' \
	     --input-format HeaderlessTSVTaxonomyFormat \
	     --input-path "$classifier_taxa_dir/$classifier_taxa.txt" \
	     --output-path "$classifier_taxa_dir/$classifier_taxa.qza"
fi

if [ ! -e "$classifier_fna_dir/${classifier_fna}_${F_primerName}-${R_primerName}.qza" ]; then
	echo -e "$(date)" | tee -a $Progress
	echo -e "trimming classifier fna to input primers $F_primerName and $R_primerName" | tee -a $Progress
	     # Remove sections of reads outside V3-V4, better for classifier
	qiime feature-classifier extract-reads \
	     --i-sequences "$classifier_fna_dir/$classifier_fna.qza" \
	     --p-f-primer "$F_primer" \
	     --p-r-primer "$R_primer" \
	     --o-reads "$classifier_fna_dir/${classifier_fna}_${F_primerName}-${R_primerName}.qza" \
		--verbose
fi

if [ ! -e "$ProjectDir/02-dada2/rep-seqs-filtered.qza" ]; then
	echo -e "$(date)" | tee -a $Progress
	echo -e "Filtering dada2 output sequences based on minimum 80% identity and 90% coverage to ${classifier_fna}_${F_primerName}-${R_primerName}.qza" | tee -a $Progress
	qiime quality-control exclude-seqs \
		--i-query-sequences "$ProjectDir/02-dada2/rep-seqs.qza" \
		--i-reference-sequences "$classifier_fna_dir/${classifier_fna}_${F_primerName}-${R_primerName}.qza" \
		--p-method vsearch \
		--p-perc-identity 0.80 \
		--p-perc-query-aligned 0.90 \
		--p-threads -1 \
		--o-sequence-hits "$ProjectDir/02-dada2/rep-seqs-filtered.qza" \
		--o-sequence-misses "$ProjectDir/02-dada2/removed-seqs-filtered.qza" \
		--verbose
fi


if [ ! -e "$ProjectDir/02-dada2/out-table.qzv" ]; then
	echo -e "$(date)" | tee -a $Progress
	echo -e "producing dada2 visualization" | tee -a $Progress
	#FeatureTable and FeatureData summaries
	qiime feature-table summarize \
	  --i-table "$ProjectDir/02-dada2/out-table.qza" \
	  --o-visualization "$ProjectDir/02-dada2/out-table.qzv" \
	  --m-sample-metadata-file "$ProjectDir/00-Metadata/$Project.metadata.tsv"
fi

if [ ! -e "$ProjectDir/02-dada2/rep-seqs-filtered.qzv" ]; then
	qiime feature-table tabulate-seqs \
	  --i-data "$ProjectDir/02-dada2/rep-seqs-filtered.qza" \
	  --o-visualization "$ProjectDir/02-dada2/rep-seqs-filtered.qzv"
fi


# #remove Singletons
# if [ ! -e "$ProjectDir/02-dada2/out-table-NoSingletons.qza" ]; then
# 	qiime feature-table filter-features \
# 	  --i-table "$ProjectDir/02-dada2/out-table.qza" \
# 	  --p-min-samples 2 \
# 	  --o-filtered-table "$ProjectDir/02-dada2/out-table-NoSingletons.qza"
# fi

basename -a -s '.qzv' $ProjectDir/02-dada2/*qzv | while read i; do
	if [ ! -d "$ProjectDir/02-dada2/$i-viz" ]; then
		unzip -q -d "$ProjectDir/02-dada2/$i-viz" "$ProjectDir/02-dada2/$i.qzv"
	fi
done

basename -a -s '.qza' $ProjectDir/02-dada2/*qza | while read i; do
	if [ ! -d "$ProjectDir/02-dada2/$i" ]; then
		unzip -q -d "$ProjectDir/02-dada2/$i" "$ProjectDir/02-dada2/$i.qza"
	fi
done




if [ ! -d "$ProjectDir/03-Taxonomy" ]; then
	mkdir $ProjectDir/03-Taxonomy
fi

if [ $classifier_method == "classify-sklearn" ]; then
	if [ ! -e "$classifier_fna_dir/${classifier_fna}_${F_primerName}-${R_primerName}-classifier.qza" ]; then
		echo -e "$(date)" | tee -a $Progress
		echo -e "Running naive bayes classifier" | tee -a $Progress
		     # Run naive bayes classifier on samples (training of classifier)
		qiime feature-classifier fit-classifier-naive-bayes \
		     --i-reference-reads "$classifier_fna_dir/${classifier_fna}_${F_primerName}-${R_primerName}.qza" \
		     --i-reference-taxonomy "$classifier_taxa_dir/$classifier_taxa.qza" \
		     --o-classifier "$classifier_fna_dir/${classifier_fna}_${F_primerName}-${R_primerName}-classifier.qza" \
		     --verbose
	fi
	if [ ! -e "$ProjectDir/03-Taxonomy/$divprotarget-taxa.qza" ]; then
		echo -e "$(date)" | tee -a $Progress
		echo -e "Assigning taxonomy of ref-seqs based on naive bayes classifier" | tee -a $Progress
	     Use sklearn to classify taxonomy of the representative reads
		qiime feature-classifier classify-sklearn \
			--p-n-jobs -1 \
		     --i-classifier "$classifier_fna_dir/${classifier_fna}_${F_primerName}-${R_primerName}-classifier.qza" \
		     --i-reads "$ProjectDir/02-dada2/rep-seqs.qza" \
		     --o-classification "$ProjectDir/03-Taxonomy/$divprotarget-taxa.qza" \
			--verbose
	fi
else
	if [ ! -e "$ProjectDir/03-Taxonomy/$divprotarget-taxa.qza" ]; then
		echo -e "$(date)" | tee -a $Progress
		echo -e "Assigning taxonomy of ref-seqs based on consensus blast" | tee -a $Progress
		qiime feature-classifier classify-consensus-blast \
			--i-query "$ProjectDir/02-dada2/rep-seqs.qza" \
			--i-reference-reads "$classifier_fna_dir/${classifier_fna}_${F_primerName}-${R_primerName}.qza" \
			--i-reference-taxonomy "$classifier_taxa_dir/$classifier_taxa.qza" \
			--verbose \
			--o-classification "$ProjectDir/03-Taxonomy/$divprotarget-taxa.qza"
	fi
fi

if [ ! -e "$ProjectDir/02-dada2/out-table-filtered.qza" ]; then
	echo -e "$(date)" | tee -a $Progress
	echo -e "Filtering taxonomy" | tee -a $Progress
	qiime taxa filter-table \
	   --i-table "$ProjectDir/02-dada2/out-table.qza" \
	   --i-taxonomy "$ProjectDir/03-Taxonomy/$divprotarget-taxa.qza" \
	   --o-filtered-table "$ProjectDir/02-dada2/out-table-filtered.qza" \
	   --verbose \
	   --p-exclude  "D_0__Bacteria;__,Unassigned,mitochondria,chloroplast,D_0__Archaea,k__Archaea"  \

fi
#
# qiime feature-table summarize \
#   --i-table dada2-out-table-trim-primer-250.FILTER.qza \
#   --o-visualization dada2-out-table-trim-primer-250.FILTER.qzv \
#   --m-sample-metadata-file ../pig_metadata.txt
#
# ## Filtering sequences
# qiime taxa filter-seqs \
#   --i-sequences ../dada2/dada2-rep-seqs-trim-primer-250.qza \
#   --i-taxonomy ../taxonomy/clustered-taxonomy-250.qza \
#   --p-include p__ \
#   --p-exclude mitochondria,chloroplast \
#   --o-filtered-sequences dada2-rep-seqs-trim-primer-250.FILTER.qza
#
# #Generate bar charts of taxa
# qiime taxa barplot \
#   --i-table dada2-out-table-trim-primer-250.FILTER.qza \
#   --i-taxonomy ../taxonomy/clustered-taxonomy-250.qza \
#   --m-metadata-file ../pig_metadata.txt \
#   --o-visualization bar-plots-250-filter.qzv



# Generates an output of the taxa to view in browser
if [ ! -e "$ProjectDir/03-Taxonomy/$divprotarget-taxa.qzv" ]; then
	qiime metadata tabulate \
		--m-input-file "$ProjectDir/03-Taxonomy/$divprotarget-taxa.qza" \
		--o-visualization "$ProjectDir/03-Taxonomy/$divprotarget-taxa.qzv" \
		--verbose
fi




# Generates bar charts of taxa
if [ ! -e "$ProjectDir/03-Taxonomy/$divprotarget-bar-plots.qzv" ]; then
	echo -e "$(date)" | tee -a $Progress
	echo -e "generating bar plots" | tee -a $Progress
	qiime taxa barplot \
		--i-table "$ProjectDir/02-dada2/out-table.qza" \
		--i-taxonomy "$ProjectDir/03-Taxonomy/$divprotarget-taxa.qza" \
		--m-metadata-file "$ProjectDir/00-Metadata/$Project.metadata.tsv" \
		--o-visualization "$ProjectDir/03-Taxonomy/$divprotarget-bar-plots.qzv"
fi

# Generates bar charts of filtered taxa
if [ ! -e "$ProjectDir/03-Taxonomy/$divprotarget-filtered-bar-plots.qzv" ]; then
	echo -e "$(date)" | tee -a $Progress
	echo -e "generating bar plots" | tee -a $Progress
	qiime taxa barplot \
		--i-table "$ProjectDir/02-dada2/out-table-filtered.qza" \
		--i-taxonomy "$ProjectDir/03-Taxonomy/$divprotarget-taxa.qza" \
		--m-metadata-file "$ProjectDir/00-Metadata/$Project.metadata.tsv" \
		--o-visualization "$ProjectDir/03-Taxonomy/$divprotarget-filtered-bar-plots.qzv"
fi

basename -a -s '.qzv' $ProjectDir/03-Taxonomy/*qzv | while read i; do
	if [ ! -d "$ProjectDir/03-Taxonomy/$i-viz" ]; then
		unzip -q -d "$ProjectDir/03-Taxonomy/$i-viz" "$ProjectDir/03-Taxonomy/$i.qzv"
	fi
done

# basename -a -s '.qza' $ProjectDir/03-Taxonomy/*qza | while read i; do
# 	if [ ! -d "$ProjectDir/03-Taxonomy/$i" ]; then
# 		unzip -q -d "$ProjectDir/03-Taxonomy/$i" "$ProjectDir/03-Taxonomy/$i.qza"
# 		biom convert -i "$ProjectDir/03-Taxonomy/$i/"*"/data/feature-table.biom" -o "$ProjectDir/03-Taxonomy/$i/"*"/data/feature-table.tsv" --to-tsv
# 	fi
# done
# Convoluted way of getting the median sample number from the overview.html file...first have to extract the file
# grep -i -A 1 "Median Frequency" data/overview.html | head -2 | tail -1 | sed 's/<\/..>//g' | sed 's/<..>//g' | sed 's/\ //g' | sed 's/,//g' | sed 's/\..*//g'
# could then do a 'while' loop to pick the next highest number?? eg if the median is 18000 and a sample has 19484, this would become the sampling depth
# can pull the sample counts from the data/sample-frequency-detail.csv
# cat data/sample-frequency-detail.csv | cut -f2 -d "," | sed 's/\..*//g' | while read i; do if [ "$i" -lt "$(grep -i -A 1 "Median Frequency" data/overview.html | head -2 | tail -1 | sed 's/<\/..>//g' | sed 's/<..>//g' | sed 's/\ //g' | sed 's/,//g' | sed 's/\..*//g')" ]; then echo $j; break; else j=$i; fi; done

# The above works, but I think a standard deviation from the mean would be more suitable, or something similar (as the results may not be normal)


################################################################################

# Differential abundance testing with ANCOM

if [ $Comparisons -gt "0" ]; then


	if [ ! -d "$ProjectDir/04-ANCOM" ]; then
		mkdir "$ProjectDir/04-ANCOM"
	fi

	# Filter a Category by a particular variable, commented out for now

	# if [ ! -e "$ProjectDir/04-ANCOM/$filter-table.qza" ]
	# 	qiime feature-table filter-samples \
	# 		--i-table "$ProjectDir/02-dada2/out-table.qza" \
	# 		--m-metadata-file "$ProjectDir/00-Metadata/$Project.metadata.tsv" \
	# 		--p-where "$Category='$filter'" \
	# 		--o-filtered-table "$ProjectDir/04-ANCOM/$filter-table.qza"
	# fi

	# Collapse at various levels and analyse with ANCOM
	Count="6"
	while [ $Count -gt "1" ]; do
		if [ ! -e "$ProjectDir/03-Taxonomy/$divprotarget.L$Count.qza" ]; then
			echo -e "$(date)" | tee -a $Progress
			echo -e "collapsing reads at L$Count" | tee -a $Progress
			qiime taxa collapse \
				--i-table "$ProjectDir/02-dada2/out-table.qza" \
				--i-taxonomy "$ProjectDir/03-Taxonomy/$divprotarget-taxa.qza" \
				--p-level $Count \
				--o-collapsed-table "$ProjectDir/03-Taxonomy/$divprotarget.L$Count.qza"
		fi

		     # Add pseudocount for expression/abundance comparsion (removes zeros)
		if [ ! -e "$ProjectDir/04-ANCOM/$divprotarget.L$Count.pseudo-table.qza" ]; then
			echo -e "$(date)" | tee -a $Progress
			echo -e "Adding pseudocount to reads for L$Count" | tee -a $Progress
			qiime composition add-pseudocount \
				--i-table "$ProjectDir/03-Taxonomy/$divprotarget.L$Count.qza" \
				--o-composition-table "$ProjectDir/04-ANCOM/$divprotarget.L$Count.pseudo-table.qza"
		fi

		while read Category; do
			# Composition comparison at specified level with ANCOM
			if [ ! -e "$ProjectDir/04-ANCOM/ancom-L$Count-$Category.qzv" ]; then
				echo -e "$(date)" | tee -a $Progress
				echo -e "Running ANCOM for L$Count for $Category" | tee -a $Progress
				qiime composition ancom \
					--i-table "$ProjectDir/04-ANCOM/$divprotarget.L$Count.pseudo-table.qza" \
					--m-metadata-file "$ProjectDir/00-Metadata/$Project.metadata.tsv" \
					--m-metadata-column $Category \
					--o-visualization "$ProjectDir/04-ANCOM/ancom-L$Count-$Category.qzv"
			fi
		done < "$ProjectDir/00-Metadata/Groups.txt"
		Count=$((Count-1))
	done

	# Collapse at various levels and analyse with ANCOM
	Count="6"
	while [ $Count -gt "1" ]; do
		if [ ! -e "$ProjectDir/03-Taxonomy/$divprotarget-filtered.L$Count.qza" ]; then
			echo -e "$(date)" | tee -a $Progress
			echo -e "collapsing reads at L$Count" | tee -a $Progress
			qiime taxa collapse \
				--i-table "$ProjectDir/02-dada2/out-table-filtered.qza" \
				--i-taxonomy "$ProjectDir/03-Taxonomy/$divprotarget-taxa.qza" \
				--p-level $Count \
				--o-collapsed-table "$ProjectDir/03-Taxonomy/$divprotarget-filtered.L$Count.qza"
		fi

		     # Add pseudocount for expression/abundance comparsion (removes zeros)
		if [ ! -e "$ProjectDir/04-ANCOM/$divprotarget.L$Count-filtered.pseudo-table.qza" ]; then
			echo -e "$(date)" | tee -a $Progress
			echo -e "Adding pseudocount to reads for L$Count" | tee -a $Progress
			qiime composition add-pseudocount \
				--i-table "$ProjectDir/03-Taxonomy/$divprotarget-filtered.L$Count.qza" \
				--o-composition-table "$ProjectDir/04-ANCOM/$divprotarget.L$Count-filtered.pseudo-table.qza"
		fi

		while read Category; do
			# Composition comparison at specified level with ANCOM
			if [ ! -e "$ProjectDir/04-ANCOM/ancom-L$Count-filtered-$Category.qzv" ]; then
				echo -e "$(date)" | tee -a $Progress
				echo -e "Running ANCOM for L$Count for $Category" | tee -a $Progress
				qiime composition ancom \
					--i-table "$ProjectDir/04-ANCOM/$divprotarget.L$Count-filtered.pseudo-table.qza" \
					--m-metadata-file "$ProjectDir/00-Metadata/$Project.metadata.tsv" \
					--m-metadata-column $Category \
					--o-visualization "$ProjectDir/04-ANCOM/ancom-L$Count-filtered-$Category.qzv"
			fi
		done < "$ProjectDir/00-Metadata/Groups.txt"
		Count=$((Count-1))
	done



	basename -a -s '.qza' $ProjectDir/04-ANCOM/*qza | while read i; do
		if [ ! -d "$ProjectDir/04-ANCOM/$i" ]; then
			unzip -q -d "$ProjectDir/04-ANCOM/$i" "$ProjectDir/03-Taxonomy/$i.qza"
		fi
	done

	basename -a -s '.qzv' $ProjectDir/04-ANCOM/*qzv | while read i; do
		if [ ! -d "$ProjectDir/04-ANCOM/$i" ]; then
			unzip -q -d "$ProjectDir/04-ANCOM/$i" "$ProjectDir/04-ANCOM/$i.qzv"
		fi
	done
fi

#Generate a tree for phylogenetic diversity analyses

if [ ! -d "$ProjectDir/05-Phylogeny" ]; then
	mkdir "$ProjectDir/05-Phylogeny"
fi

if [ ! -e "$ProjectDir/05-Phylogeny/aligned-rep-seqs.qza" ]; then
	echo -e "$(date)" | tee -a $Progress
	echo -e "Producing phylogenetic tree" | tee -a $Progress
	qiime phylogeny align-to-tree-mafft-fasttree \
		--p-n-threads 0 \
		--i-sequences "$ProjectDir/02-dada2/rep-seqs.qza" \
		--o-alignment "$ProjectDir/05-Phylogeny/aligned-rep-seqs.qza" \
		--o-masked-alignment "$ProjectDir/05-Phylogeny/masked-aligned-rep-seqs.qza" \
		--o-tree "$ProjectDir/05-Phylogeny/unrooted-tree.qza" \
		--o-rooted-tree "$ProjectDir/05-Phylogeny/rooted-tree.qza"
fi

if [ ! -e "$ProjectDir/05-Phylogeny/aligned-rep-seqs.qza" ]; then
	echo -e "$(date)" | tee -a $Progress
	echo -e "Producing phylogenetic tree" | tee -a $Progress
	qiime phylogeny align-to-tree-mafft-fasttree \
		--p-n-threads 0 \
		--i-sequences "$ProjectDir/02-dada2/rep-seqs-filtered.qza" \
		--o-alignment "$ProjectDir/05-Phylogeny/aligned-rep-seqs-filtered.qza" \
		--o-masked-alignment "$ProjectDir/05-Phylogeny/masked-aligned-rep-seqs-filtered.qza" \
		--o-tree "$ProjectDir/05-Phylogeny/unrooted-tree-filtered.qza" \
		--o-rooted-tree "$ProjectDir/05-Phylogeny/rooted-tree-filtered.qza"
fi


#Alpha and beta diversity analysis

#NEED FORMULA FOR THIS
sampleDepth="1000"

## Output artifacts:
if [ ! -e "$ProjectDir/00-Metadata/$Project.alpha-metrics.txt" ]; then
	cat << EOT >> "$ProjectDir/00-Metadata/$Project.alpha-metrics.txt"
evenness_vector
faith_pd_vector
shannon_vector
observed_otus_vector
EOT
fi

if [ $Comparisons -gt "0" ]; then
if [ ! -e "$ProjectDir/00-Metadata/$Project.beta-metrics.txt" ]; then
	cat << EOT >> "$ProjectDir/00-Metadata/$Project.beta-metrics.txt"
bray_curtis_distance_matrix
unweighted_unifrac_distance_matrix
weighted_unifrac_distance_matrix
jaccard_distance_matrix
EOT
fi
fi

if [ ! -d "$ProjectDir/06-DiversityMetrics-$sampleDepth-unfiltered" ] || [ $(ls "$ProjectDir/06-DiversityMetrics-$sampleDepth-unfiltered/" | wc -l) -lt "17" ]; then
	echo -e "$(date)" | tee -a $Progress
	echo -e "Producing diversity metrics from unfiltered table" | tee -a $Progress
	qiime diversity core-metrics-phylogenetic \
		--p-n-jobs $CORES \
		--i-phylogeny "$ProjectDir/05-Phylogeny/rooted-tree.qza" \
		--i-table "$ProjectDir/02-dada2/out-table.qza" \
		--p-sampling-depth $sampleDepth \
		--m-metadata-file "$ProjectDir/00-Metadata/$Project.metadata.tsv" \
		--output-dir "$ProjectDir/06-DiversityMetrics-$sampleDepth-unfiltered"
fi

while read i; do
	if [ ! -e "$ProjectDir/06-DiversityMetrics-$sampleDepth-unfiltered/$i.qzv" ]; then
		echo -e "$(date)" | tee -a $Progress
		echo -e "Producing $i visualization" | tee -a $Progress
		qiime diversity alpha-group-significance \
			--i-alpha-diversity "$ProjectDir/06-DiversityMetrics-$sampleDepth-unfiltered/$i.qza" \
			--m-metadata-file "$ProjectDir/00-Metadata/$Project.metadata.tsv" \
			--o-visualization "$ProjectDir/06-DiversityMetrics-$sampleDepth-unfiltered/$i.qzv"
	fi
done < "$ProjectDir/00-Metadata/$Project.alpha-metrics.txt"

if [ $Comparisons -gt "0" ]; then
	while read Category; do
		while read i; do
			if [ ! -d "$ProjectDir/06-DiversityMetrics-$sampleDepth-unfiltered/$Category.$i.qzv" ]; then
				echo -e "$(date)" | tee -a $Progress
				echo -e "Producing $i visualization" | tee -a $Progress
				qiime diversity beta-group-significance \
					--i-distance-matrix "$ProjectDir/06-DiversityMetrics-$sampleDepth-unfiltered/$i.qza" \
					--m-metadata-file "$ProjectDir/00-Metadata/$Project.metadata.tsv" \
					--m-metadata-column "$Category" \
					--p-pairwise \
					--p-permutations 999 \
					--o-visualization "$ProjectDir/06-DiversityMetrics-$sampleDepth-unfiltered/$Category.$i.qzv" \
					--verbose
			fi
		done < "$ProjectDir/00-Metadata/$Project.beta-metrics.txt"
	done < "$ProjectDir/00-Metadata/Groups.txt"
fi

basename -a -s '.qzv' $ProjectDir/06-DiversityMetrics-$sampleDepth-unfiltered/*qzv | while read i; do
	if [ ! -d "$ProjectDir/06-DiversityMetrics-$sampleDepth-unfiltered/$i" ]; then
		unzip -q -d "$ProjectDir/06-DiversityMetrics-$sampleDepth-unfiltered/$i" "$ProjectDir/06-DiversityMetrics-$sampleDepth-unfiltered/$i.qzv"
	fi
done


if [ ! -d "$ProjectDir/06-DiversityMetrics-$sampleDepth" ] || [ $(ls "$ProjectDir/06-DiversityMetrics-$sampleDepth/" | wc -l) -lt "17" ]; then
	echo -e "$(date)" | tee -a $Progress
	echo -e "Producing diversity metrics" | tee -a $Progress
	qiime diversity core-metrics-phylogenetic \
		--p-n-jobs $CORES \
		--i-phylogeny "$ProjectDir/05-Phylogeny/rooted-tree-filtered.qza" \
		--i-table "$ProjectDir/02-dada2/out-table-filtered.qza" \
		--p-sampling-depth $sampleDepth \
		--m-metadata-file "$ProjectDir/00-Metadata/$Project.metadata.tsv" \
		--output-dir "$ProjectDir/06-DiversityMetrics-$sampleDepth"
fi

while read i; do
	if [ ! -e "$ProjectDir/06-DiversityMetrics-$sampleDepth/$i.qzv" ]; then
		echo -e "$(date)" | tee -a $Progress
		echo -e "Producing $i visualization" | tee -a $Progress
		qiime diversity alpha-group-significance \
			--i-alpha-diversity "$ProjectDir/06-DiversityMetrics-$sampleDepth/$i.qza" \
			--m-metadata-file "$ProjectDir/00-Metadata/$Project.metadata.tsv" \
			--o-visualization "$ProjectDir/06-DiversityMetrics-$sampleDepth/$i.qzv"
	fi
done < "$ProjectDir/00-Metadata/$Project.alpha-metrics.txt"

if [ $Comparisons -gt "0" ]; then
	while read Category; do
		while read i; do
			if [ ! -d "$ProjectDir/06-DiversityMetrics-$sampleDepth/$Category.$i.qzv" ]; then
				echo -e "$(date)" | tee -a $Progress
				echo -e "Producing $i visualization" | tee -a $Progress
				qiime diversity beta-group-significance \
					--i-distance-matrix "$ProjectDir/06-DiversityMetrics-$sampleDepth/$i.qza" \
					--m-metadata-file "$ProjectDir/00-Metadata/$Project.metadata.tsv" \
					--m-metadata-column "$Category" \
					--p-pairwise \
					--p-permutations 999 \
					--o-visualization "$ProjectDir/06-DiversityMetrics-$sampleDepth/$Category.$i.qzv" \
					--verbose
			fi
		done < "$ProjectDir/00-Metadata/$Project.beta-metrics.txt"
	done < "$ProjectDir/00-Metadata/Groups.txt"
fi

basename -a -s '.qzv' $ProjectDir/06-DiversityMetrics-$sampleDepth/*qzv | while read i; do
	if [ ! -d "$ProjectDir/06-DiversityMetrics-$sampleDepth/$i" ]; then
		unzip -q -d "$ProjectDir/06-DiversityMetrics-$sampleDepth/$i" "$ProjectDir/06-DiversityMetrics-$sampleDepth/$i.qzv"
	fi
done


conda deactivate
