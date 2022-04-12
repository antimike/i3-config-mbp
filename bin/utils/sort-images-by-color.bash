#!/bin/bash
# From https://legacy.imagemagick.org/discourse-server/viewtopic.php?t=29789

for file in *.png
do
  filename=`convert $file -scale 1x1\! txt:- | tail -n 1 | awk -F\( '{print $2}'|cut -d\) -f1|awk -F\, '{print $1$2$3}'`

  extension=".png"
  while [ -f "$filename$extension" ]
  do
    random=`echo $RANDOM % 10 + 1 | bc`
    filename=$filename$random
  done

  mv $file $filename$extension
done

for file in *.jpg
do
  filename=`convert $file -scale 1x1\! txt:- | tail -n 1 | awk -F\( '{print $2}'|cut -d\) -f1|awk -F\, '{print $1$2$3}'`

  extension=".jpg"
  while [ -f "$filename$extension" ]
  do
    random=`echo $RANDOM % 10 + 1 | bc`
    filename=$filename$random
  done

  mv $file $filename$extension
done
