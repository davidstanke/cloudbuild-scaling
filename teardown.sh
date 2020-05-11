#!/bin/bash

export PROJECT_ID=$(gcloud config get-value "project")
PROJECT_LABEL=${1}

echo "deleting projects with label '$PROJECT_LABEL'"
gcloud projects delete "$PROJECT_ID-$PROJECT_LABEL-0" --quiet