#!/bin/sh
#####################################################################################
# bedpostX_checker.sh
#
# This script checks if subjects' .bedpostX folders exist, and if not, outputs
# the subject ID into a text file located at:
#
# ~/Nicco/NIQ/HCP_Scripts/missing_bedpostX.txt
#
#####################################################################################

# Set paths
ref_dir="/space/raid6/data/rissman/Nicco/HCP_ALL/Move2Func"
save_dir="/space/raid6/data/rissman/Nicco/NIQ/HCP_Scripts"
bedpost_dir="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Bedpost_Analysis"

# Create .txt file for output. Overwrite if exists.
cd $save_dir
rm missing_bedpostX.txt
touch missing_bedpostX.txt

# Get all candidate subject folders
cd $ref_dir
subj_dirs=$(ls -d [0-9]*)

# Move to bedpost directory
cd $bedpost_dir

# Loop through all subjects
for j in $subj_dirs
do
  # Check if subject's .bedpostX exists
  if [ $(ls -d1 ${j}.bedpostX | wc -l) -eq 1 ]
  then
    # Found, go to next subject
    echo "$j"
    continue
  else
    # Missing, output to text file
    echo "Missing $j"
    echo -e "$j" >> ${save_dir}/missing_bedpostX.txt
    continue
  fi

done
