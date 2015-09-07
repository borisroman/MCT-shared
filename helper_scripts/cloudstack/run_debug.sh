#!/bin/bash

# We work from here
cd /data/git/$HOSTNAME/cloudstack

# Run mgt
mvnDebug -pl :cloud-client-ui jetty:run

