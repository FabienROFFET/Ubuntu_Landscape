#!/bin/bash

# Get the list of duplicate computer names
duplicates=$(landscape-api get-computers | grep title | awk '{print $2}' | sort | uniq -d)

# Loop through each duplicate computer name and remove it
for name in $duplicates; do
    name=$(echo "$name" | tr -d "'" | tr -d ",")
    echo "Removing duplicate computer: $name"

   # computer_id=$(landscape-api get-computers --query $name | grep -w ".id" | grep -Eo '[0-9]{1,4}' | head -n -1)
    computer_id=$(landscape-api get-computers --query $name | grep -w ".id" | grep -Eo '[0-9]{1,4}' )

    for cid in `echo $computer_id` ;do
    	landscape-api remove-computers "$cid"
    done
done
