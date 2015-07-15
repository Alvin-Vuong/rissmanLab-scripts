#!/bin/sh
#########################################################################
# MNI2MPRAGE_Gordon.sh
#
# This script realigns the Gordon masks from MNI-space to MPRAGE-space
# for each subject.
# Saves realigned masks as:
#
# ~/Nicco/masks/Subject_Specific/{SubjectID}_Gordon_{ROI}.nii.gz
#
# Code is based on 'MNI2MPRAGE.sh' located at:
#
# ~/Nicco/NIQ/HCP_Scripts/
#
#########################################################################

# Set paths
top_path="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION"
mask_path="/space/raid6/data/rissman/Nicco/NIQ/masks"
targets_path="/space/raid6/data/rissman/Nicco/NIQ/Reference"
structural_path="/space/raid6/data/rissman/Nicco/HCP_ALL/Structural"
MNI_2mm="/space/raid6/data/rissman/Nicco/MNI/MNI152_T1_2mm_brain.nii.gz"
Gordon_Dir="/space/raid6/data/rissman/Nicco/MNI/Gordon/"
xfm_dir="/space/raid6/data/rissman/Nicco/NIQ/xfms"
save_path="/space/raid6/data/rissman/Nicco/NIQ/masks/Subject_Specific/"

ref_dir="/space/raid6/data/rissman/Nicco/HCP_ALL/Move2Func"

# Move into subject directory
cd $ref_dir

# Loop through subjects
for j in $(ls -d [0-9]*/)
do
  echo "Realigning Subject ${j}..."

  # Loop through masks (Let OS scheduler handle jobs)
  for ((s = 1; s <= 333; s++))
  do
  (
    # Realign mask
    echo "Mask ${s}..."
    
    flirt -in "${Gordon_Dir}/Gordon_${s}.nii" -ref "${structural_path}/${j: 0: -1}_bet.nii.gz" -applyxfm -init "${xfm_dir}/MPRAGE${j: 0: -1}2MNIinv" -out "${save_path}${j: 0: -1}_Gordon_${s}.nii.gz" ) &
  
    # Run jobs in background 10 at a time
    if (( $s % 10 == 0 ))
    then
      wait
    fi

  done
  wait
done
