#!/bin/sh
#####################################################################################
# bedpostX_rerun.sh
#
# This script relaunches the bedpost analyses for subjects missing their .bedpostX 
# folders onto the FUNC SGE. This will not work if the folder at:
# ~/Nicco/NIQ/EXPANSION/Bedpost_Analysis/{SubjectID}
# is missing the required files for bedpostx. If this the case, there run:
# 'bedpostX_reorganize.sh' on the subject first.
#
# Uses subject IDs from the following file:
# ~/Nicco/NIQ/HCP_Scripts/missing_bedpostX.txt
#
# Based on the code at:
# ~/Nicco/NIQ/HCP_Scripts/run_bedpost.sh
#
#####################################################################################

# Set paths
bedpost_dir="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Bedpost_Analysis"
txt_dir="/space/raid6/data/rissman/Nicco/NIQ/HCP_Scripts"

# Get missing .bedpostX subjects
cd $txt_dir

# Read in subjects and loop through them line-by-line
while read line
do
  # Get subject folder
  subject_folder="${bedpost_dir}/${line}"

  # Launch bedpostX on grid
  echo "Relaunching Subject ${line}'s bedpostX."
  sge qsub bedpostx $subject_folder -g

  # Sleep
  echo "15s until next submission."
  sleep 15s

done < missing_bedpostX.txt
