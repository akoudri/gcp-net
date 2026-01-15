#!/bin/bash

for i in $(gcloud compute networks list | awk '!/NAME/{ print $1 }'); do ./clean_resources.sh $i; done