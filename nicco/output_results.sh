FILES=*.txt
for f in $FILES
do
  echo "$f"
  cat $f
done
