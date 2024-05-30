#!/bin/bash

###################################################################
#Script Name	: sync-pocket-sequentially.sh
#Description	: Daily Syncro of repos
#Email       	: fabien.roffet@gmail.com
#Date 		: 29.04.2024 : Fix Check and add more series
###################################################################

# Config
SERIES=("bionic" "focal" "jammy" "noble" "focal-esm-infra" "jammy-esm-infra" "focal-esm-apps" "jammy-esm-apps")
POCKET=("release" "updates" "security")
WAIT=30  # in seconds

# Check if previous job finished
check() {
    while true; do
        progress=$(landscape-api get-activities --query type:SyncPocketRequest --limit 1 | grep progress | awk '{print $2}' | tr -d ",")
        if [ "$progress" -eq 100 ]; then
            echo "Job is complete."
            break
        else
            echo "Waiting for current job to reach 100%... Current progress: $progress%"
            sleep $WAIT
        fi
    done
}


# Perform pocket sync job
sync() {
    local series="$1"
    local pocket="$2"
    echo "Synchronizing $pocket for $series"
    landscape-api sync-mirror-pocket "$pocket" "$series" ubuntu >/dev/null 2>&1
    sleep 3
    check
}

# Main script
for series in "${SERIES[@]}"; do
    for pocket in "${POCKET[@]}"; do
        sync "$series" "$pocket"
    done
done

echo "Sync complete"
