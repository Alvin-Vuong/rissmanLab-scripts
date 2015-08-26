#!/bin/sh
#####################################################################################
# bedpostX_rerun.sh
#
# This script relaunches the bedpost analyses for subjects missing their .bedpostX 
# folders onto the FUNC SGE.
# 
# Uses subject IDs from the following file:
# ~/Nicco/NIQ/HCP_Scripts/missing_bedpostX.txt
#
#####################################################################################

# Set paths
bedpost_dir="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Bedpost_Analysis"
ref_dir="/space/raid6/data/rissman/Nicco/HCP_ALL/Move2Func"
txt_dir="/space/raid6/data/rissman/Nicco/NIQ/HCP_Scripts"

# Get missing .bedpostX subjects
cd $txt_dir
# Read in subjects

# Loop through subjects
for j in #somethingHere
do
  subject_folder="${bedpost_dir}/${j}"

  # Launch bedpostX on grid
  echo "Launching Subject ${j}'s bedpostX. 25s until next submission."
  sge qsub bedpostx $subject_folder -g

  # Sleep
  sleep 25s

done
