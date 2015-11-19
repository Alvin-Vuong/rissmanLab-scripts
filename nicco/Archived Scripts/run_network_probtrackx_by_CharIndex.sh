#!/bin/sh
############################################################################
# This script runs probtrack jobs for selected subjects' seeds on the grid
# and stores the results in:
#
# ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/{SubjectID}/From_{Seed#}/
#
# This is the old version of the code and uses a hardcoded char index value
# in order to select the starting subject ID. This version works so far.
#
# See run_network_probtrackx_by_SubjectID.sh for the newer version.
#
############################################################################

# Set paths
top_path="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION"
mask_path="/space/raid6/data/rissman/Nicco/NIQ/masks/Subject_Specific"
targets_path="/space/raid6/data/rissman/Nicco/NIQ/Reference"

ref_dir="/space/raid6/data/rissman/Nicco/HCP_ALL/Move2Func"

# Get all subjects
cd $ref_dir
all_dirs=$(ls -d [0-9]*/)

# Use this to select certain subjects (number is starting char index)
# Use the following commands to find the line #:
# (Be sure you're in the correct directory:)
#  ~/Nicco/HCP_ALL/Move2Func/ 
#
# ls -d1 [0-9]* > subjs.txt
# awk '/{SubjectID}/{ print NR; exit }' subjs.txt
# 
# This should output a number. Multiply by 8, and subtract by 8. 
# Then change the following line of code to include this value.

array=("${all_dirs[@]:1104}")

# Loop through subjects (all_dirs for all, $array for selected)
#for j in $all_dirs
for j in $array

do

BEDPOST_FOLDER="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Bedpost_Analysis/${j: 0: -1}.bedpostX"

# Loop through seeds
for ((f = 1; f <= 264; f++))

do

# Set variables
seed="${mask_path}/${j: 0: -1}_Petersen_${f}.nii.gz"
target_list="${targets_path}/${j: 0: -1}_From_${f}.txt"

# Send probtrack job to grid
echo "Launching Subject ${j} With Seed ${f} to the grid!"

sge qsub probtrackx2  -x $seed  -l --onewaycondition --omatrix1 -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s "${BEDPOST_FOLDER}/merged" -m "${BEDPOST_FOLDER}/nodif_brain_mask.nii.gz"  --dir="${top_path}/Probtrack_Subject_Specific/${j: 0: -1}/From_${f}" --targetmasks=$target_list --s2tastext --os2t

# Every 5 jobs, sleep 2 mins
if [ $(($f % 5)) == 0 ]; then

echo "Sleeping for 2 minutes to prevent grid Clogging"

sleep 2m

fi

done

done
