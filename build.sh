#!/bin/sh
set -e
mkdir -p build
cobc -x -free -I copy -o build/BILLLOAD src/BILLLOAD.cbl
cobc -x -free -fstatic-call -I copy -o build/BILLCLI \
    src/BILLCLI.cbl src/BILLBIZ.cbl src/BILLFILE.cbl
cobc -x -free -fstatic-call -I copy -o build/BILLWEB \
    src/BILLWEB.cbl src/BILLBIZ.cbl src/BILLFILE.cbl
