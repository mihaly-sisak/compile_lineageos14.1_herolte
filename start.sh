#!/bin/bash

set -eoux pipefail

podman build \
    --build-arg USER_ID=$(id -u) \
    --build-arg GROUP_ID=$(id -g) \
    -t lineageos-build-ubuntu22 .

podman run --rm --userns=keep-id \
    -v ~/android/lineage:/android/lineage \
    lineageos-build-ubuntu22
