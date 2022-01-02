#!/bin/bash
FILES="src/*"

update() {
    sum1=`ls -lR ./src | sha1sum`
}

scan () {
    echo "$ SCANNING"
    for f in $FILES
    do
      echo "Processing $f"
      ./anti "$f"
      echo
    done
}

compare () {
    update
    if [[ $sum1 != $sum2 ]]; 
    then 
      echo ">> FIM: CHANGE DETECTED"
      echo
      scan
      echo ">> FIM: Monitoring '$FILES' ..."
      sum2=$sum1; 
    fi
}

echo ">> FIM: Initialize"
echo
scan

update
sum2=$sum1

echo ">> FIM: Monitoring '$FILES' ..."

while true; do
    compare
    sleep 1s
done