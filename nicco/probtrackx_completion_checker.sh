#!/bin/sh
###################################################################################
# probtrackx_completion_checker.sh
#
# This script checks if probtrack jobs for subjects are complete.
# It checks the following folders:
#
# ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/{SubjectID}/From_{Seed#}/
# (^ For Petersen ROIs)
#
# ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/{SubjectID}/Gordon/From_{Seed#}/
# (^ For Gordon ROIs)
#
# This checks both Gordon and Petersen seeds to see if they are complete.
# Alter the code if you want only one type to be checked.
# 
# Also able to alter i and N values.
# N: number of subjects to check
# i: starting subject index
#
# *(Currently set to check only Petersen seeds)*
# *(Currently set to check only 10 subjects)*
# *(Currently set to start at 11th subject)*
#
# Note on FUNC efficiency:
#   Sleeping for 2 minutes per 5 subjects is not slow enough for the SGE.
#
# Bug: At subject # input, you can input a partial match of the first subject
#      and it will return the line number: 1.  Need regex for non-partial matches.
###################################################################################

# Set paths
top_path="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION"
mask_path="/space/raid6/data/rissman/Nicco/NIQ/masks/Subject_Specific"
targets_path="/space/raid6/data/rissman/Nicco/NIQ/Reference"

ref_dir="/space/raid6/data/rissman/Nicco/HCP_ALL/Move2Func"

save_top_path="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific"

# Get all candidate subject folders
cd $save_top_path
subj_dirs=$(ls -d [0-9]*)

# Initialize counters
subjNum=0
jumper=0
numNeeds=0
f=0

# Loop through all subjects
for j in $subj_dirs
do
  # Only do ith to jth (j = i + N) subjects
  jumper=$(( jumper + 1 ))
  if [ $jumper -lt 11 ] # [ $jumper -lt i ]
  then
    continue
  fi

  # Only do N subjects
  subjNum=$(( subjNum + 1 ))
  if [ $subjNum -eq 11 ] # [ $subjNum -eq N+1 ]
  then
    break
  fi

  BEDPOST_FOLDER="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Bedpost_Analysis/${j}.bedpostX"
  
  # Move into subject folder (Petersen seeds directory)
  echo "Moving to Subject $j Petersen seeds"
  cd $j

  # Grab finished Petersen seeds
  petersen_seeds=$(ls -d F*)
  
  # Loop through potential seeds
  for ((ps = 1; ps <= 264; ps++))
  do
    # Loop through finished seeds
    foundP=0
    for p in $petersen_seeds
    do
      # Check if seed folder exists
      if [ "$ps" = "${p:5}" ]
      then
	# Check if fdt_paths exists
	echo "Checking seed: $ps"
	cd "From_${ps}"
        if [ $(ls -d1 fdt_paths.* | wc -l) -eq 1 ]
        then
	  foundP=1
	  break
	fi
	break
      fi
    done
      
    # Seed not found among finished seeds
    if [ $foundP -eq 0 ]
    then
      # Output not finished
      echo "Subject $j, Petersen Seed $ps not finished..."
    fi
    cd "${save_top_path}/${j}"
  done
  
  # Move into subject's Gordon seeds directory
#  echo "Moving to Subject $j Gordon seeds"
#  cd "${save_top_path}/${j}/Gordon"

  # Grab finished Gordon seeds
#  gordon_seeds=$(ls -d F*)

  # Loop through potential seeds
#  for ((gs = 1; gs <= 333; gs++))
#  do
    # Loop through finished seeds
#    foundG=0
#    for g in $gordon_seeds
#    do
      # Check if seed folder exists
#      if [ "$gs" = "${g:5}" ]
#      then
	# Check if fdt_paths exists
#        echo "Checking seed: $gs"
#        cd "From_${gs}"
#        if [ $(ls -d1 fdt_paths.* | wc -l) -eq 1 ]
#        then
#          foundG=1
#          break
#        fi
#        break
#      fi
#    done
      
    # Seed not found among finished seeds
#    if [ $foundG -eq 0 ]
#    then
      # Output not finished
#      echo "Subject $j, Gordon Seed $gs not finished..."
#    fi
#    cd "${save_top_path}/${j}"
#  done

  # Move back to subjects directory
  cd $save_top_path
done
