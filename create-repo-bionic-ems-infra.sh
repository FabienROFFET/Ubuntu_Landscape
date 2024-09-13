#!/bin/bash

# Draft, but it Works
###################################################################
#Script Name	: create-repo-bionic-ems-infra.sh
#Description	: Adding ESM repos in Landscape
#Email       	: fabien.roffet@gmail.com
#Date 		    : 13.09.2024
###################################################################
# Creads : /etc/apt/auth.conf.d/90ubuntu-advantage
# Source : https://support-portal.canonical.com/knowledge-base/How-to-mirror-the-Ubuntu-ESM-repositories-using-Landscape-On-Premises
# URL and MKEY need to change for apps or infra

RELEASE=bionic
POCKETS=security,updates
REALPREFIX=infra
PREFIX=esm-infra
POCKET1=security
POCKET2=updates
GKEY=mirror-key
MKEY=esm-mirror-key
#URL="https://esm.ubuntu.com/infra/ubuntu"
URL="https://bearer:xxxxxxxxxxxxxxxxx@esm.ubuntu.com/infra/ubuntu"

#echo "Remove old $RELEASE"
#landscape-api remove-series $RELEASE-esm-infra ubuntu

if landscape-api get-gpg-keys | grep -q $MKEY; then
    echo "Key found"
else
    echo "Key not found"
    exit 0
fi

echo "Create the serie $RELEASE"
landscape-api create-series \
  --pockets $POCKETS \
  --components main \
  --architectures amd64,i386 \
  --mirror-gpg-key $MKEY \
  --gpg-key $GKEY \
  --mirror-uri $URL \
  --mirror-series $RELEASE-$REALPREFIX $RELEASE-$PREFIX ubuntu

echo "Start Syncronization:" $POCKET1
SYNC=$(landscape-api sync-mirror-pocket $POCKET1 $RELEASE-$PREFIX ubuntu | grep -w 'id' | tr -d ',' | awk '{print $2}' | sed -n 2p)

echo "My ID:" $SYNC

if [[ ! "$SYNC" =~ ^[0-9]+$ ]]; then
    echo "No valid numeric ID found, Error"
    exit 0
else
    echo "ID is: $SYNC"
fi

sleep 2

echo "Check Status"
while true; do
    CHECK=$(landscape-api get-activities --query id:$SYNC)
    if echo "$CHECK" | grep -q "'activity_status': 'failed'"; then
        echo "Activity status is 'failed'. Exiting..."
	landscape-api get-activities --query id:$SYNC
        break
    else
	echo "Activity status is 'good'. Still Checking"
        while true; do
        progress=$(landscape-api get-activities --query id:$SYNC |grep progress | awk '{print $2}' | tr -d ",")
        if [ "$progress" -eq 100 ]; then
            echo "Job is complete."
            break
        else
            echo "Waiting for current job to reach 100%... Current progress: $progress%"
            sleep 15
        fi
    done
	break
    fi
    sleep 2
done

sleep 60

echo "Start Syncronization:" $POCKET2
SYNC=$(landscape-api sync-mirror-pocket $POCKET2 $RELEASE-$PREFIX ubuntu | grep -w 'id' | tr -d ',' | awk '{print $2}' | sed -n 2p)

echo "My ID:" $SYNC

if [[ ! "$SYNC" =~ ^[0-9]+$ ]]; then
    echo "No valid numeric ID found, Error"
    exit 0
else
    echo "ID is: $SYNC"
fi

sleep 2

echo "Check Status"
while true; do
    CHECK=$(landscape-api get-activities --query id:$SYNC)
    if echo "$CHECK" | grep -q "'activity_status': 'failed'"; then
        echo "Activity status is 'failed'. Exiting..."
        landscape-api get-activities --query id:$SYNC
        break
    else
        echo "Activity status is 'good'. Still Checking"
        while true; do
        progress=$(landscape-api get-activities --query id:$SYNC |grep progress | awk '{print $2}' | tr -d ",")
        if [ "$progress" -eq 100 ]; then
            echo "Job is complete."
            break
        else
            echo "Waiting for current job to reach 100%... Current progress: $progress%"
            sleep 15
        fi
    done
	break
    fi
    sleep 2
done

landscape-api list-pocket $POCKET1 $RELEASE-$PREFIX ubuntu | wc -l
landscape-api list-pocket $POCKET2 $RELEASE-$PREFIX ubuntu | wc -l
