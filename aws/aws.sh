#!/bin/bash

getAccountId()
{
  aws sts get-caller-identity --output text | awk '{print $1}'
}

usage()
{
  echo ""
  echo "Usage: $0 <options>"
  echo "  -a returns aws account id"
  echo "  -h print this help message"
  echo ""
}

while getopts "ha" opt
do
  case "$opt" in
     (h) usage; exit 0;;
     (a) getAccountId;exit 0;;
     (*) usage; exit 0;;
  esac
done

exit 0