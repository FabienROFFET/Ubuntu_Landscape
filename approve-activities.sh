#!/bin/bash

###################################################################
#Script Name	: approve-activities.sh
#Description	: Aprouved Activities in Landscape
#Email       	: fabien.roffet@gmail.com
#Date 		: 28.05.2023
###################################################################

activity_ids=$(landscape-api get-activities --status pending | grep -oP '(?<=ID: )\d+')

# Approve each activity
if [ -z "$activity_ids" ]; then
  echo "No pending activities to approve."
else
  for id in $activity_ids; do
    landscape-api approve-activities $id
    echo "Approved activity ID: $id"
  done
fi
