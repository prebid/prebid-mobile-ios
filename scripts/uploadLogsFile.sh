#!/usr/bin/env bash 

LOGS_FILE=$(find $HOME -type f -name prebid-mobile-sdk.txt)
OUTPUT_DIR=/tmp/app_logs
mkdir -p $OUTPUT_DIR
cp $LOGS_FILE $OUTPUT_DIR
