#!/bin/bash
###########################################################################
# reslice_gordon.sh
#
# This script reslices the Gordon masks per subject to the correct size.
# Overwrites the old compressed files in the masks folder.
#
# Code based on 'reslice_Petersen.sh' located at:
#
# ~/Nicco/NIQ/HCP_Scripts/
#
###########################################################################

# Set paths
orig_masks="/space/raid6/data/rissman/Nicco/NIQ/masks/Subject_Specific/"
IDENTITY="/space/raid/fmri/fsl-5.0.7-centos6_64/etc/flirtsch/ident.mat"
ref_dir="/space/raid6/data/rissman/Nicco/HCP_ALL/Move2Func"

# Grab all subjects
cd $ref_dir
all_dirs=$(ls -d [0-9]*/)

# Move into masks directory
cd $orig_masks

# Loop over subjects
for s in $all_dirs
do
  echo "Reslicing Subject $s..."

  # Loop over masks (specifically Gordon ones)
  # Let OS scheduler handle jobs
  #counter=1
  #for j in $(ls ${s: 0: -1}_Gordon_*)
  for ((j = 1; j <= 333; j++))
  do
  (
    echo "Mask ${j}..."

    # Reslice mask
    FIXED="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Bedpost_Analysis/100408/data.nii.gz"
    INPUT="${s: 0: -1}_Gordon_${j}.nii.gz"
    OUTPUT_NAME="${INPUT}"

    flirt -applyxfm -init $IDENTITY -in $INPUT -out $OUTPUT_NAME -ref $FIXED ) &
    
    # Run jobs in background 10 at a time
    if (( $j % 10 == 0 ))
    then
      wait
    fi

  done
  wait
done
