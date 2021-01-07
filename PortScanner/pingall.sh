#!/bin/bash

for num in {1..255} 
do
    ping -c 1 -w 1.5 $1.$num >> temp.txt &
done
 
rm log.txt
cat temp.txt | grep "64 bytes from" | cut -d " " -f4 | cut -d ":" -f1 >> log.txt
rm temp.txt