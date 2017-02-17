#!/bin/bash
Version=$(cat Version)
docker build $1 -t="ricmathie/python_java:$Version" python_java
docker build $1 -t="ricmathie/storm:$Version" storm
docker build $1 -t="ricmathie/storm-nimbus:$Version" storm-nimbus
docker build $1 -t="ricmathie/storm-supervisor:$Version" storm-supervisor
docker build $1 -t="ricmathie/storm-ui:$Version" storm-ui

# you mustbe logged in TODO move to autobuild
docker push ricmathie/python_java:$Version
docker push ricmathie/storm:$Version
docker push ricmathie/storm-nimbus:$Version
docker push ricmathie/storm-ui:$Version
docker push ricmathie/storm-supervisor:$Version

