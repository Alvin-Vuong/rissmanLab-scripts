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
top_path="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific"

# Move into subject directory and grab seed folders
cd "${top_path}/100307"
seed_dirs=$(ls -d From*)

# Loop through all seeds
for j in $seed_dirs
do
  # Move into seed folder
  echo "Seed: $j"
  cd $j
  
  # Compress all target files
  gzip -f seeds_to_*

  # Move back to subject directory
  cd "${top_path}/100307"
done
