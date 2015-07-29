#!/bin/sh
###################################################################################
# grid_queuer.sh
#
# This script submits jobs to the FUNC grid until the grid's total number of jobs
# is 50,000.  When the total number of jobs on the grid is above 50,000 the script
# sleeps for 5 minutes before checking again.
#
# This script was developed as prevention of overloading the FUNC grid.  All values
# can be changed as needed.
#
###################################################################################

# Get current number of jobs on the grid
sge qstat | awk '(NR>2){print $1,$4}' | sort | uniq | awk '{print $2}' | sort | uniq -c

# Submit a job
sge qsub probtrackx2  -x $seed  -l --onewaycondition --omatrix1 -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd -s "${BEDPOST_FOLDER}/merged" -m "${BEDPOST_FOLDER}/nodif_brain_mask.nii.gz"  --dir="${top_path}/Probtrack_Subject_Specific/${j: 0: -1}/Gordon/From_${f}" --targetmasks=$target_list --s2tastext --os2t
