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

# Get to-be-moved subjects
cd $list_dir

# Read in subjects and loop through them line-by-line
while read line
do
  # Get subject folders
  subject_probtrack="${probtrack_dir}/${line}"
  subject_bedpost="${bedpost_dir}/${line}"

  # Remove subject folders
  rm -rf ${subject_probtrack}
  rm -rf ${subject_bedpost}
  rm -rf ${subject_bedpost}.bedpostX

done < toRemove.txt

