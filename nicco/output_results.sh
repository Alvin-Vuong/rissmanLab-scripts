#!/bin/sh

# Sorted output

# Prompt for search term
echo -n "Enter search term (use regex): "
read search

FILES=$search.txt

# Init arrays and counter
FILENAMES[0]=""
VALUES[0]=""
ABSVALUES[0]=""
i=0

# Fill arrays
for f in $FILES
do
  # Store each filename in an array
  FILENAMES[$i]=$f

  # Store file's r-value in an array
  VALUES[$i]=$(awk 'NR==2' $f)

  # Store absolute value of r in an array
  ABSVALUES[$i]=$(echo ${VALUES[i]} | tr -d -)

  # Increment counter
  i=$((i+1))
done

# Sort arrays
curr=0
i=0
for f in $FILES
do
  currABS=${ABSVALUES[i]}
  currVAL=${VALUES[i]}
  currFILE=${FILENAMES[i]}
  for (( j = 0; j < i; j++ ))
  do
    #TF=$(echo "$currABS < ${ABSVALUES[j]}" | bc)
    TF=$(echo "$currVAL < ${VALUES[j]}" | bc)
    if [ $TF -eq 1 ]
    then
      for (( k = i-1; k > j-1; k-- ))
      do
	ABSVALUES[$((k+1))]=${ABSVALUES[k]}
	VALUES[$((k+1))]=${VALUES[k]}
	FILENAMES[$((k+1))]=${FILENAMES[k]}
      done
      ABSVALUES[$j]=$currABS
      VALUES[$j]=$currVAL
      FILENAMES[$j]=$currFILE
      break
    fi
  done
  i=$((i+1))
done

# Output result
i=0
for f in $FILES
do
  echo -e "${VALUES[i]} \t ${FILENAMES[i]}"
  i=$((i+1))
done
