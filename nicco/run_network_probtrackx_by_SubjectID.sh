#!/bin/sh
############################################################################
# This script runs probtrack jobs for selected subjects' seeds on the grid
# and stores the results in:
#
# ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/{SubjectID}/From_{Seed#}/
#
# This is the newer version of the code and uses a user input prompt to 
# ask for the starting subject ID, and automates the process of finding 
# the line number of the subject. This version has not been tested.
#
# See run_network_probtrackx_by_CharIndex.sh for the older version.
#
############################################################################

# Set paths
top_path="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION"
mask_path="/space/raid6/data/rissman/Nicco/NIQ/masks/Subject_Specific"
targets_path="/space/raid6/data/rissman/Nicco/NIQ/Reference"

ref_dir="/space/raid6/data/rissman/Nicco/HCP_ALL/Move2Func"

# Get all subject folders
cd $ref_dir
subj_dirs=$(ls -d [0-9]*/)

# Ask to run on all subjects
echo "Run on all subjects? [y/n]"
read run_all

if [ $run_all == 'y' ]
then
  # Loop through all subjects
  for j in $subj_dirs
  do

    BEDPOST_FOLDER="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Bedpost_Analysis/${j: 0: -1}.bedpostX"
	
    # Loop through seeds
    for ((f = 1; f <= 264; f++))
    do
      
      # Set variables
      seed="${mask_path}/${j: 0: -1}_Petersen_${f}.nii.gz"
      target_list="${targets_path}/${j: 0: -1}_From_${f}.txt"
      
      # Send probtrack job to grid
      echo "Launching Subject ${j} With Seed ${f} to the grid!"
      
      sge qsub probtrackx2  -x $seed  -l --onewaycondition --omatrix1 -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s "${BEDPOST_FOLDER}/merged" -m "${BEDPOST_FOLDER}/nodif_brain_mask.nii.gz"  --dir="${top_path}/Probtrack_Subject_Specific/${j: 0: -1}/From_${f}" --targetmasks=$target_list --s2tastext --os2t
      
      # Every 5 jobs, sleep 2 mins
      if [ $(($f % 5)) == 0 ]
      then
	echo "Sleeping for 2 minutes to prevent grid clogging"
	sleep 2m
      fi
    done
  done
  
elif [ $run_all == 'n' ]
then
  # Select certain subjects (ask for starting subject ID)
  ls -d1 [0-9]* > subjs.txt
  selected=''
  while [ $selected == '' ]
  do
    echo "Type the subject ID that you want to run, followed by [ENTER]:"
    read subject
    
    # Retrieve line number of subject
    let selected=awk 'match($0,subject){ print NR; exit }'
    if [ $selected == '' ]
    then
      echo "Subject not found."
    fi
  done
  
  # Use line # of subject * 8 - 8 to get the starting index...
  let selected=$selected * 8 - 8
  array=("${subj_dirs[@]:$selected}")
  
  # Loop through selected subjects
  for j in $array
  do
      
    BEDPOST_FOLDER="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Bedpost_Analysis/${j: 0: -1}.bedpostX"
	
    # Loop through seeds
    for ((f = 1; f <= 264; f++))
    do
	
      # Set variables
      seed="${mask_path}/${j: 0: -1}_Petersen_${f}.nii.gz"
      target_list="${targets_path}/${j: 0: -1}_From_${f}.txt"
      
      # Send probtrack job to grid
      echo "Launching Subject ${j} With Seed ${f} to the grid!"
      
      sge qsub probtrackx2  -x $seed  -l --onewaycondition --omatrix1 -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s "${BEDPOST_FOLDER}/merged" -m "${BEDPOST_FOLDER}/nodif_brain_mask.nii.gz"  --dir="${top_path}/Probtrack_Subject_Specific/${j: 0: -1}/From_${f}" --targetmasks=$target_list --s2tastext --os2t
	    
      # Every 5 jobs, sleep 2 mins
      if [ $(($f % 5)) == 0 ]
      then
	echo "Sleeping for 2 minutes to prevent grid clogging"
	sleep 2m
      fi
    done
  done
  
else
  echo "Input was invalid."
fi
