#!/bin/bash

# Step 1: Initialize variables
source variables.sh

artifact="${ARTIFACTS[0]}"
mkdir -p ./artifacts

# Step 2: Download the executables
echo "Downloading ${artifact}..."
curl -L -o "./artifacts/${artifact}" "${ARTIFACT_URL}/${artifact}"
chmod +x "./artifacts/${artifact}"

