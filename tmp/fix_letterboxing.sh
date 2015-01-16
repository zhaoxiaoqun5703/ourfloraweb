# list=`find $1 -type d`
# find . -type f \( -name "*-fixed.jpg" \) | while read file ; do
#   rm "$file"
# done

find . -type f \( -name "*.png" -o -name "*.jpg" \) | while read file ; do
  convert "$file" -bordercolor Black -border 500x500 "$file.tmp";
  result=$( (convert "$file.tmp" -bordercolor black -fuzz 92% -trim +repage "$file.tmp") 2>&1)
  if [ "$result" = "" ]; then
    echo "Success removing letterboxing!";
    mv "$file.tmp" "$file"
  else
    echo "Failed on $file";
    rm "$file.tmp"
  fi
done