#!/bin/bash

###################################################################
#Script Name	: accept-pending-computers.sh
#Description	: Accept Pending Computers in Landscape
#Email       	: fabien.roffet@gmail.com
#Date 		: 28.05.2023
###################################################################

pending=$(landscape-api get-pending-computers | grep id | awk '{print $2}' | tr -d "," )

for name in $pending; do
    echo "Accepting computer: $name"
    landscape-api accept-pending-computers "$name" --access-group dcn
done
