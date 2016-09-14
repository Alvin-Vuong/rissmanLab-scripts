#!/bin/sh
###################################################################################
# target_compressor.sh
#
# This script compresses all target files within a subject folder.
# Currently Subject ID is alterable.
#
# TODO: Allow user input of Subject ID.
#       Loop through subject range.
###################################################################################

# Set paths
#top_path="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific"
top_path="/Volumes/RissmanLab_5TB/Nicco/HCP/Alvin/Probtrack"

# Infinite listen
while true
do

  # Move into probtrack directory and grab subject folders
  cd $top_path
  subj_dirs=$(ls -d [0-9]*)

  # Loop through all subjects
  for i in $subj_dirs
  do
    # Move into subject directory and grab seed folders
    echo "Subject: $i"
    cd $i
    seed_dirs=$(ls -d From_*)

    # Loop through all seeds
    for j in $seed_dirs
    do
      # Move into seed folder
      echo "Seed: $j"
      cd $j
  
      # Compress all .nii files
      gzip -f *.nii

      # Move back to subject directory
      cd "${top_path}/${i}"
    done

    # Move back to probtrack directory
    cd $top_path
  done

done
