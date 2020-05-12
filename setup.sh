#!/bin/bash
set -eEox pipefail

export PROJECT_ID=$(gcloud config get-value "project")
echo "Base project: $PROJECT_ID"

BILLING_ACCOUNT=$(gcloud beta billing projects describe $PROJECT_ID --format="value(billingAccountName)")

# ensure cloud build API is enabled in parent project
gcloud services enable cloudbuild.googleapis.com -q

# number of child projects to create [specify as first param]; default 1
PROJECTS=${1-1}

# generate a short unique tag to use on all child projects
export PROJECT_LABEL=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 3 | head -n 1)
echo "Label for new projects: $PROJECT_LABEL"

for((i=0;i<$PROJECTS;i++)); do
    export PROJECT_NEW="$PROJECT_ID-p-$PROJECT_LABEL-$i"

    echo "creating project: $PROJECT_NEW" 
    FOLDER_ID=$(gcloud projects describe $PROJECT_ID --format="value(parent.id)")
    
    # TODO: run these in parallel (invoke async and poll for completion)
    if test -z "$FOLDER_ID"; then 
        gcloud projects create $PROJECT_NEW
    else
        gcloud projects create $PROJECT_NEW --folder $FOLDER_ID
    fi
    gcloud beta billing projects link $PROJECT_NEW --billing-account $BILLING_ACCOUNT
    gcloud services enable cloudbuild.googleapis.com --project=$PROJECT_NEW
done

echo "----------------------"
echo "----------------------"
echo " "
echo "${PROJECTS} projects have been created."
echo "To invoke builds, use command: './loop-gcb.sh 10 $PROJECT_LABEL $PROJECTS'"
echo "(replace 10 with desired builds per project)"