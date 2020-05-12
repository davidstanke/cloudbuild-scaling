#!/bin/bash 
set +eExo pipefail

NUMBUILDS=${1-2} # number of builds to queue per project; default to 2
PROJECT_LABEL=${2} # label of the projects we're building in
NUM_PROJECTS=${3} # number of projects

PROJECT_ID=$(gcloud config get-value "project")
LOGS_BUCKET=${PROJECT_ID}-builds

echo "running $NUMBUILDS builds in each of $PROJECT_ID's subprojects with label $PROJECT_LABEL"

# initialize a log file
rm -f buildlog
touch buildlog

for ((j=0; j<=$NUM_PROJECTS-1; j++)); do
    THIS_PROJECT="$PROJECT_ID-p-$PROJECT_LABEL-$j"
    echo " "
    echo "Starting builds in project $THIS_PROJECT"
    echo "------------------"
    for ((i=1; i<=$NUMBUILDS; i++)); do
        gcloud builds submit --no-source --substitutions=_BUILD_ITER="${j}.${i}",_LOGS_BUCKET=${LOGS_BUCKET} --project=$THIS_PROJECT >>./buildlog 2>&1 & disown; 
        echo "Submitted build: ${j}.${i}"
    done
done    
