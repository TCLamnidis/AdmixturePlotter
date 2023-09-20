#!/usr/bin/env bash

###################################################################
## Compiling ADMIXTURE run CV errors and Q matrices for plotting ##
###################################################################

fn0="/PATH/TO/ADMIXTURE/OUTPUT" # This should be a directory with one folder per K (which itself contains one folder per replicate and one Logs folder with the slurm logs).
cd ${fn0}
mkdir -p ${fn0}/Plotting


## Set ADMIXTURE IndFile (Eigenstrat), ADMIXTURE input .bed file and minimum and maximum K values.
IndFile="/PATH/TO/YOUR/PLINK/DATA/Data.ind" # An Eigenstrat .ind version of the data you converted to plink
bedFile="/PATH/TO/YOUR/PLINK/DATA/Data.pruned.bed" # The input .bed file you ran ADMIXTURE on.
Kmin=2 #The minimum number of Ks you ran
Kmax=17 #The maximum number of Ks you ran


## Compile CV Errors
touch CVErrors.txt
for i in $(seq ${Kmax} -1 ${Kmin}); do #seq doesn’t like backwards counting on the clusters, so giving the increment of "-1" fixes the problem.
  (echo $i; grep CV $i/Logs/* | cut -f 4 -d " ") | paste  -d " " - CVErrors.txt > temp_CVErrors
  mv temp_CVErrors CVErrors.txt
done
while read r; do echo ${r% } >>temp_CVErrors; done <CVErrors.txt
mv temp_CVErrors CVErrors.txt
mv CVErrors.txt Plotting/CVErrors.txt


## Compile list of replicates with highest Likelihood
for i in $(seq ${Kmin} ${Kmax}); do grep -H ^Logli $i/Logs/*.log | sort -nrk2 | head -n1; done >Plotting/best_runs.txt


## Compile Q matrices and add ind/pop labels
unset runs
for i in $(seq ${Kmin} ${Kmax}); do
  X=$(grep "K${i}\_" Plotting/best_runs.txt | cut -d "K" -f2 | cut -d ":" -f1 )
  K=$(echo ${X} | cut -f1 -d "_"); Rep=$(echo ${X} | cut -d "_" -f 2)
  runs+="$K/${Rep%.log}/$(basename ${bedFile} .bed).$K.Q "
done
paste -d " " ${runs} >Plotting/temp_data.txt


## Create compiled Q matrix header.
for i in $(seq ${Kmin} ${Kmax}); do
  for x in $(seq 1 ${i}); do
    echo -n "${i}:${x}" >>Plotting/temp_header.txt
    echo -n " " >>Plotting/temp_header.txt
  done
done


## Remove trailing space from header.
echo "" >> Plotting/temp_header.txt
while read r; do echo ${r% } > Plotting/temp_header.txt; done <Plotting/temp_header.txt


## Create individual and Pop list
echo "Ind Pop" >Plotting/temp_pop_labels.txt; awk '{print $1,$3}' $IndFile >>Plotting/temp_pop_labels.txt


## Put together header, data and Pop labels to create compiled data table
cd ${fn0}/Plotting
cat temp_header.txt temp_data.txt >temp_compound.data.txt
paste -d " " temp_pop_labels.txt temp_compound.data.txt  >compound.labelled.QperK.txt 

## Clean up
rm temp_*
