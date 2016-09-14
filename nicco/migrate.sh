#!/bin/sh
#####################################################################################
# migrate.sh
#
# Moves all subject data in toRemove.txt off the FUNC and to the disk drive in the lab.
#
#####################################################################################

##### LOCAL SIDE #####

# Set paths
list_dir="/space/raid6/data/rissman/Nicco/NIQ/Save/"
probtrack_dir="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific"
bedpost_dir="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Bedpost_Analysis"

# Read in subjects and loop through them line-by-line
while read line
do
  # Get subject folders and move to drive
  subject_probtrack="${probtrack_dir}/${line}"
  subject_bedpost="${bedpost_dir}/${line}"
  scp -r avuong@dentate.psych.ucla.edu:${subject_probtrack} /Volumes/RissmanLab_5TB/Nicco/HCP/Alvin/Probtrack
  scp -r avuong@dentate.psych.ucla.edu:${subject_bedpost} /Volumes/RissmanLab_5TB/Nicco/HCP/Alvin/Bedpost
  scp -r avuong@dentate.psych.ucla.edu:${subject_bedpost}.bedpostX /Volumes/RissmanLab_5TB/Nicco/HCP/Alvin/Bedpost

  # Remove subject folders

done < toRemove.txt

##### FUNC SIDE #####

# Get to-be-moved subjects
cd $list_dir

# Read in subjects and loop through them line-by-line
while read line
do
  # Remove subject folders
  rm -rf ${subject_probtrack}
  rm -rf ${subject_bedpost}
  rm -rf ${subject_bedpost}.bedpostX

done < toRemove.txt
