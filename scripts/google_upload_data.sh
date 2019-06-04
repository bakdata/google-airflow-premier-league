#!/usr/bin/env bash

pushd $( dirname "${BASH_SOURCE[0]}" ) >/dev/null 2>&1

read -p "please enter your project id: " GC_PROJECT_ID

gsutil -m cp ../data/matchweek/* gs://${GC_PROJECT_ID} && \
gsutil -m cp ../data/scorer/* gs://${GC_PROJECT_ID}

popd