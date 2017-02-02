#!/bin/bash
docker build $1 -t="ricmathie/python_java:2.7_8" python_java
docker build $1 -t="ricmathie/storm" storm
docker build $1 -t="ricmathie/storm-python" storm-python
docker build $1 -t="ricmathie/storm-nimbus" storm-nimbus
docker build $1 -t="ricmathie/storm-supervisor" storm-supervisor
docker build $1 -t="ricmathie/storm-ui" storm-ui

# you mustbe logged in TODO move to autobuild
docker push ricmathie/python_java:2.7_8
docker push ricmathie/storm
docker push ricmathie/storm-python
docker push ricmathie/storm-nimbus
docker push ricmathie/storm-ui
docker push ricmathie/storm-supervisor

