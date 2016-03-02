#!/bin/sh
###################################################################################
# probtrackx_max.sh
#
# This script runs probtrack jobs for incomplete subjects' seeds on the grid
# and stores the results in:
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
# **NOTE: This version loads the FUNC SGE with as many jobs as possible until
#         the specified job limit has been reached. Then sleeps for 15 minutes
#         before submitting more jobs. (Constant FUNC load).
#
# Bug: At subject # input, you can input a partial match of the first subject
#      and it will return the line number: 1.  Need regex for non-partial matches.
###################################################################################

# Set maximum server load
maxLoad=100

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
f=0

# Ask for Petersen or Gordon
echo -n "Enter 'P' for Petersen or 'G' for Gordon parcellation: "
read type

# Ask for starting subject # and # of subjects to run
echo -n "Enter starting subject #: "
read start
echo -n "Enter # of subjects to run: "
read amt

# Petersen
if [ "$type" = "P" ]
then
  echo "Type: Petersen"
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
    echo "Moving to Subject #$jumper, ID: $j Petersen seeds"
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
        echo "Relaunching Subject #$jumper, ID: $j, Petersen Seed $ps on the grid..."
        
        # Set variables
        seed="${mask_path}/${j}_Petersen_${ps}.nii.gz"
        target_list="${targets_path}/${j}_From_${ps}.txt"
      
        # Check if FUNC SGE is overloaded
        while [ $( sge qstat | awk '(NR>2){print $1}' | wc -l ) -ge $maxLoad ]
        do
	  echo "Server is overloaded. Sleeping 15 minutes..."
	  sleep 15m
        done

        # Send probtrack job to grid
        sge qsub probtrackx2  -x $seed  -l --onewaycondition --omatrix1 -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s "${BEDPOST_FOLDER}/merged" -m "${BEDPOST_FOLDER}/nodif_brain_mask.nii.gz"  --dir="${top_path}/Probtrack_Subject_Specific/${j}/From_${ps}" --targetmasks=$target_list --s2tastext --os2t

      fi
      cd "${save_top_path}/${j}"
    done
    # Move back to subjects directory
    cd $save_top_path
  done

# Gordon
elif [ "$type" = "G" ]
then
  echo "Type: Gordon"
  c=0

  # Grab subjects used from Petersen workflow and loop over them
  file="/space/raid6/data/rissman/Nicco/NIQ/HCP_Scripts/subjsUsed.txt"
  while IFS= read line
  do

    echo "$line"
    c=$(( c + 1 ))

    if [ $c -lt $start ]
    then
      continue
    fi

    BEDPOST_FOLDER="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Bedpost_Analysis/${line}.bedpostX"
    
    # Move into subject folder (Gordon seeds directory)
    echo "Moving to Subject #$c, ID: $line Gordon seeds"
    cd $line
    
    # Check if Gordon folder exists, if not, create it
    if [ $(ls -d1 Gordon | wc -l) -eq 1 ]
    then
      cd Gordon
    else
      mkdir Gordon
      cd Gordon
    fi
    
    # Grab finished Gordon seeds
    gordon_seeds=$(ls -d F*)
  
    # Loop through potential seeds
    for ((ps = 1; ps <= 333; ps++))
    do
      # Loop through finished seeds
      foundP=0
      for p in $gordon_seeds
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
        echo "Relaunching Subject #$c, ID: $line, Gordon Seed $ps on the grid..."
        
        # Set variables
        seed="${mask_path}/${line}_Gordon_${ps}.nii.gz"
        target_list="${targets_path}/${line}_Gordon_From_${ps}.txt"
      
        # Check if FUNC SGE is overloaded
        while [ $( sge qstat | awk '(NR>2){print $1}' | wc -l ) -ge $maxLoad ]
        do
          echo "Server is overloaded. Sleeping 15 minutes..."
          sleep 15m
        done

        # Send probtrack job to grid
        sge qsub probtrackx2  -x $seed  -l --onewaycondition --omatrix1 -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s "${BEDPOST_FOLDER}/merged" -m "${BEDPOST_FOLDER}/nodif_brain_mask.nii.gz"  --dir="${top_path}/Probtrack_Subject_Specific/${line}/Gordon/From_${ps}" --targetmasks=$target_list --s2tastext --os2t

      fi
      cd "${save_top_path}/${line}/Gordon"
    done

    # Move back to subjects directory
    cd $save_top_path

  done <"$file"



# Code here is for Gordon regular workflow

  # Loop through all subjects
  #for j in $subj_dirs
  #do 

    # Only do ith to jth (j = i + N) subjects
    #jumper=$(( jumper + 1 ))
    #if [ $jumper -lt $start ]
    #then
    #  continue
    #fi

    # Only do N subjects
    #subjNum=$(( subjNum + 1 ))
    #if [ $subjNum -eq $(( amt + 1 )) ]
    #then
    #  break
    #fi

    # Check if subject is missing .bedpostX (from .txt list)
    #if grep -Fxq "$j" $missing_bedpostX_path
    #then
    #  echo "Subject $j is missing .bedpostX"
    #  continue
    #fi

    #BEDPOST_FOLDER="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Bedpost_Analysis/${j}.bedpostX"
    
    # Move into subject folder (Gordon seeds directory)
    #echo "Moving to Subject #$jumper, ID: $j Gordon seeds"
    #cd $j
    
    # Check if Gordon folder exists, if not, create it
    #if [ $(ls -d1 Gordon | wc -l) -eq 1 ]
    #then
    #  cd Gordon
    #else
    #  mkdir Gordon
    #  cd Gordon
    #fi
    
    # Grab finished Gordon seeds
    #gordon_seeds=$(ls -d F*)
  
    # Loop through potential seeds
    #for ((ps = 1; ps <= 333; ps++))
    #do
      # Loop through finished seeds
    #  foundP=0
    #  for p in $gordon_seeds
    #  do
	# Check if seed folder exists
    #    if [ "$ps" = "${p:5}" ]
    #    then
	  # Check if fdt_paths exists
    #      echo "Checking seed: $ps"
    #      cd "From_${ps}"
    #      if [ $(ls -d1 fdt_paths.* | wc -l) -eq 1 ]
    #      then
    #        foundP=1
    #        break
    #      fi
    #      break
    #    fi
    #  done
      
      # Seed not found among finished seeds
    #  if [ $foundP -eq 0 ]
    #  then
        # Resubmit this seed to the grid
    #    echo "Relaunching Subject #$jumper, ID: $j, Gordon Seed $ps on the grid..."
        
        # Set variables
    #    seed="${mask_path}/${j}_Gordon_${ps}.nii.gz"
    #    target_list="${targets_path}/${j}_Gordon_From_${ps}.txt"
      
        # Check if FUNC SGE is overloaded
    #    while [ $( sge qstat | awk '(NR>2){print $1}' | wc -l ) -ge $maxLoad ]
    #    do
    #      echo "Server is overloaded. Sleeping 15 minutes..."
    #      sleep 15m
    #    done

        # Send probtrack job to grid
    #    sge qsub probtrackx2  -x $seed  -l --onewaycondition --omatrix1 -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s "${BEDPOST_FOLDER}/merged" -m "${BEDPOST_FOLDER}/nodif_brain_mask.nii.gz"  --dir="${top_path}/Probtrack_Subject_Specific/${j}/Gordon/From_${ps}" --targetmasks=$target_list --s2tastext --os2t

    #  fi
    #  cd "${save_top_path}/${j}/Gordon"
    #done
    # Move back to subjects directory
    #cd $save_top_path
  #done

# Invalid type entered
else
  echo "Invalid Type!"
fi
