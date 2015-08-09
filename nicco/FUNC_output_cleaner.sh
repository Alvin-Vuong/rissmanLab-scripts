#!/bin/sh
#####################################################################################
# FUNC_output_cleaner.sh
#
# This script cleans up the subject folders with any FUNC output-related files.
# These files result from submitting jobs to the FUNC SGE grid.
# This script can be altered to clean more folders.
#
# Currently cleans:
#   ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/{SubjectID}/From_{Seed#}
#####################################################################################

# Set paths
save_top_path="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific"

# Get all candidate subject folders
cd $save_top_path
subj_dirs=$(ls -d [0-9]*)

# Loop through all subjects
for j in $subj_dirs
do
  # Move into subject folder (Petersen seeds directory)
  echo "Moving to Subject $j Petersen seeds"
  cd $j

  # Loop through all seed folders
  for ((ps = 1; ps <= 264; ps++))
  do
    # Output subject ID and seed number
    echo "Cleaning Subject $j, Seed $ps"
    cd "From_${ps}"

    # Remove any FUNC output files
    rm -f avuong.*
    rm -f nicco.*
    rm -f tavakoli.*

    # Move back into subject folder
    cd "${save_top_path}/${j}"
  done
  
  # Move back to subjects directory
  cd $save_top_path
done
