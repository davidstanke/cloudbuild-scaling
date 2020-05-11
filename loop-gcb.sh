#!/bin/bash 
set +eEx o pipefail

NUMBUILDS=${1-2} # number of builds to queue per project; default to 2
PROJECT_LABEL=${2} # label of the projects we're building in
NUM_PROJECTS=${3} # number of projects

PROJECT_ID=$(gcloud config get-value "project")

# initialize a log file
rm -f buildlog
touch buildlog

for (( j=0; j<$NUM_PROJECTS; j++)); do
    THIS_PROJECT="$PROJECT_ID-$PROJECT_LABEL-$j"
    echo "Starting builds in project $THIS_PROJECT..."
    echo "------------------"
    for (( i = 1; i <= $NUMBUILDS; i++ )); do
        gcloud builds submit --no-source --substitutions=_BUILD_ITER=${i} --project-id=$THIS_PROJECT >>./buildlog 2>&1 & disown; 
        echo "Submitted build: ${j}.${i}";
    done
done    

working=1
while [ $working -gt 0 ]; do
  echo "Checking build status..."
  queued=$(gcloud builds list --limit=300 | grep QUEUED | wc -l)
  working=$(gcloud builds list --limit=300 | grep WORKING | wc -l)
  echo "Queued:  $queued"
  echo "Running: $working"
  echo
done