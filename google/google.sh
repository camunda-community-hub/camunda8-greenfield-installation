#!/bin/bash

DISKS_FILE=".disks"

deleteDisks()
{
  while read -r LINE; do
    if [ -n "$LINE" ]
    then
      gcloud compute disks delete "$LINE" --zone "$ZONE" --quiet
    fi
  done <$DISKS_FILE
}

usage()
{
  echo ""
  echo "Usage: $0 <options>"
  echo "  -d read a list of google compute disk names from $DISKS_FILE and delete them. This is useful to run after deleting a cluster"
  echo "  -h print this help message"
  echo ""
}

while getopts "hd:" opt
do
  case "$opt" in
     (h) usage; exit 0;;
     (d) ZONE=${OPTARG};deleteDisks;exit 0;;
     (*) usage; exit 0;;
  esac
done

exit 0