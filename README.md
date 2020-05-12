# cloudbuild-scaling
Demonstrate Cloud Build scalability by triggering multiple parallel builds

These scripts will create a set of GCP projects across which we can parallelize multiple Cloud Build builds.

## To start:
Start in a GCP project. This will be the parent project for the child projects in which the builds will run. 

> _The parent project's Project ID cannot exceed 24 characters in length._

> _The parent project must have billing enabled._

Run `./setup.sh <NUMBER>` where <NUMBER> is the number of child projects you wish to create.

> _This will create <NUMBER> projects prefixed with your parent project ID and containing a unique label (The label is unique per invocation of setup, and consistent across all projects generated within one invocation.)_

## To run builds:
The setup script will output a command that looks like this: `./loop-gcb.sh 10 xyz 2` (where xyz is the label for this collection of projects). Run this command and replace "10" with the number of builds per sub-project.

## TODO
Document how to aggregate logs from all the child projects and display build counts in a graph.

## Clean up:
Run `./teardown.sh`

## Troubleshooting
To find orphaned projects: `gcloud projects list --filter="PROJECT_ID:stanke-gcb*"`