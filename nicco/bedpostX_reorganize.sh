#!/bin/bash
#####################################################################################
# bedpostX_reorganize.sh
#
# This script reorganizes the files required for missing subjects' bedpost analyses.
# The files are dumped at:
# ~/Nicco/NIQ/EXPANSION/Bedpost_Analysis/{SubjectID}
# 
# This script should be run before 'bedpostX_rerun.sh'.
#
# Uses subject IDs from the following file:
# ~/Nicco/NIQ/HCP_Scripts/missing_bedpostX.txt
#
# Based on the code at:
# ~/Nicco/NIQ/HCP_Scripts/organize_for_bedpost_expansion.sh
#
#####################################################################################

# Set paths
top_dir="/space/raid6/data/rissman/Nicco/HCP_ALL"
bedpost_dir="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Bedpost_Analysis"
txt_dir="/space/raid6/data/rissman/Nicco/NIQ/HCP_Scripts"

# Get missing .bedpostX subjects
cd $txt_dir

# Read in subjects and loop through them line-by-line
while read line
do
  # Get subject folder (Make if doesn't exist)
  subject_folder="${bedpost_dir}/${line}"
  mkdir $subject_folder

  # Output
  echo "Moving Around Files Necessary For Subject ${line}"

  # Set retrieve paths
  DWI="$top_dir/DTI/${line}.nii.gz"
  bvec="$top_dir/bvecs/${line}"
  bval="$top_dir/bvals/${line}"
  no_dif_brain_mask="$top_dir/nodif_brain_mask/${line}.nii.gz"
  grad_dev="$top_dir/grad_dev/${line}.nii.gz"

  # Set save paths
  DWI_save="$subject_folder/data.nii.gz"
  bvec_save="$subject_folder/bvecs"
  bval_save="$subject_folder/bvals"
  no_dif_brain_mask_save="$subject_folder/nodif_brain_mask.nii.gz"
  grad_dev_save="$subject_folder/grad_dev.nii.gz"

  # Copy files
  cp $DWI $DWI_save
  cp $bvec $bvec_save
  cp $bval $bval_save
  cp $no_dif_brain_mask $no_dif_brain_mask_save
  cp $grad_dev $grad_dev_save

done < missing_bedpostX.txt
