#!/bin/bash

export PROJECT_ID=$(gcloud config get-value "project")

PROJECTS_TO_DELETE=$(gcloud projects list --filter="PROJECT_ID='$PROJECT_ID-p*'" --format="value(PROJECT_ID)" | tr '\n' ' ')

echo $PROJECTS_TO_DELETE

for p in $PROJECTS_TO_DELETE; do
    gcloud projects delete $p --quiet
done