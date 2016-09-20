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
pass="#####"

# Read in subjects and loop through them line-by-line
while read line
do
  # Get subject folders
  subject_probtrack="${probtrack_dir}/${line}"
  subject_bedpost="${bedpost_dir}/${line}"
  
  # Check if subject folder exists (if done already)
  if [ ! -d "/Volumes/RissmanLab_5TB/Nicco/HCP/Alvin/Probtrack/${line}" ]
  then

    # Transfer to drive
    rm temp
    echo "
    set timeout -1
    spawn scp -r avuong@dentate.psych.ucla.edu:${subject_probtrack} /Volumes/RissmanLab_5TB/Nicco/HCP/Alvin/Probtrack
    expect \"Password: \"
    send \"${pass}\\r\"
    expect \"$ \"
    send \"exit\\r\"
    " > temp
    
    /usr/bin/expect < temp

  fi
  
  if [ ! -d "/Volumes/RissmanLab_5TB/Nicco/HCP/Alvin/Bedpost/${line}" ]
  then
    # Transfer to drive
    rm temp
    echo "
    set timeout -1
    spawn scp -r avuong@dentate.psych.ucla.edu:${subject_bedpost} /Volumes/RissmanLab_5TB/Nicco/HCP/Alvin/Bedpost
    expect \"Password: \"
    send \"${pass}\\r\"
    expect \"$ \"
    send \"exit\\r\"
    " > temp
    
    /usr/bin/expect < temp
  fi

  if [ ! -d "/Volumes/RissmanLab_5TB/Nicco/HCP/Alvin/Bedpost/${line}.bedpostX" ]
  then
    # Transfer to drive
    rm temp
    echo "
    set timeout -1
    spawn scp -r avuong@dentate.psych.ucla.edu:${subject_bedpost}.bedpostX /Volumes/RissmanLab_5TB/Nicco/HCP/Alvin/Bedpost
    expect \"Password: \"
    send \"${pass}\\r\"
    expect \"$ \"
    send \"exit\\r\"
    " > temp
    
    /usr/bin/expect < temp
  fi

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
