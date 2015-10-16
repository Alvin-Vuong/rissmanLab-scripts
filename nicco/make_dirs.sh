# Quick script to create empty subject folders necessary for probtrackx_max.sh

save_top_path="/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific"
targets_path="/space/raid6/data/rissman/Nicco/HCP_ALL/DTI"

cd $targets_path
subjs=$(ls [0-9]*)

cd $save_top_path

start=262
count=0

for j in $subjs
do
  count=$(( count + 1 ))
  if [ $count -lt $start ]
  then
    continue
  fi

  mkdir ${j:0:6}
done