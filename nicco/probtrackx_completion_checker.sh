#!/bin/sh
###################################################################################
# probtrackx_completion_checker.sh
#
# This script checks for incomplete subjects' seeds in the following locations:
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
# Currently altered to run on only select ranges of Petersen seeds.
#
# Bug: At subject # input, you can input a partial match of the first subject
#      and it will return the line number: 1.  Need regex for non-partial matches.
###################################################################################

# Set paths
top_path="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION"
mask_path="/space/raid6/data/rissman/Nicco/NIQ/masks/Subject_Specific"
targets_path="/space/raid6/data/rissman/Nicco/NIQ/Reference"
missing_bedpostX_path="/space/raid6/data/rissman/Nicco/NIQ/HCP_Scripts/missing_bedpostX.txt"
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

# Ask for starting subject # and # of subjects to run
echo -n "Enter starting subject #: "
read start
echo -n "Enter # of subjects to run: "
read amt

# Loop through all subjects
for j in $subj_dirs
do
  # Only do ith to jth (j = i + N) subjects
  jumper=$(( jumper + 1 ))
  if [ $jumper -lt $start ]
  then
    continue
  fi

  # Only do N subjects
  subjNum=$(( subjNum + 1 ))
  if [ $subjNum -eq $(( amt + 1 )) ]
  then
    break
  fi

  # Check if subject is missing .bedpostX (from .txt list)
  if grep -Fxq "$j" $missing_bedpostX_path
  then
    echo "Subject $j is missing .bedpostX"
    continue
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
      # Resubmit this seed to the grid
      echo "Relaunching Subject $j, Petersen Seed $ps on the grid..."
      
      # Set variables
      seed="${mask_path}/${j}_Petersen_${ps}.nii.gz"
      target_list="${targets_path}/${j}_From_${ps}.txt"
      
      # Output number of missing seeds to this point
#      numNeeds=$(( numNeeds + 1 ))
#      echo $numNeeds

    fi
    cd "${save_top_path}/${j}"
  done
  
  # Move to subject's Gordon seeds directory
#  echo "Moving to Subject $j's Gordon seeds"
#  cd Gordon
  
  # Check if all Gordon seed folders exist
#  if [ $(ls -d1 F* | wc -l) -ne 333 ]
#  then
    # Grab finished Gordon seeds
#    gordon_seeds=$(ls -d F*)

    # Loop through potential seeds
#    for ((gs = 1; gs <= 333; gs++))
#    do
      # Loop through finished seeds
#      foundG=0
#      for g in $gordon_seeds
#      do
        # Check if seed is finished
#        if [ "$gs" = "${g:5}" ]
#        then
#          foundG=1
#          break
#        fi
#      done

      # Seed not found among finished seeds
#      if [ $foundG -eq 0 ]
#      then
        # Resubmit this seed onto the grid
#        echo "Relaunching Subject $j, Gordon Seed $gs on the grid..."

      # Set variables
#        seed="${mask_path}/${j}_Gordon_${gs}.nii.gz"
#        target_list="${targets_path}/${j}_Gordon_From_${gs}.txt"
      
      # Send probtrack job to grid
#        sge qsub probtrackx2  -x $seed  -l --onewaycondition --omatrix1 -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s "${BEDPOST_FOLDER}/merged" -m "${BEDPOST_FOLDER}/nodif_brain_mask.nii.gz"  --dir="${top_path}/Probtrack_Subject_Specific/${j}/Gordon/From_${gs}" --targetmasks=$target_list --s2tastext --os2t
        
      # Increment sleep counter
#        f=$(( f + 1))

      # Every 5 jobs, sleep 2 mins
#        if [ $(($f % 5)) == 0 ]
#        then
#          echo "Sleeping for 2 minutes to prevent grid clogging"
#          sleep 2m
#        fi

#       else
      # Seed is already complete
#        echo "Subject $j, Gordon Seed $gs is already complete."
#      fi
#    done
#  fi
  
  # Move back to subjects directory
  cd $save_top_path
done
