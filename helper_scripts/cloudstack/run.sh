#!/bin/bash

# We work from here
cd /data/git/$HOSTNAME/cloudstack.

# Run mgt
mvn -pl :cloud-client-ui jetty:run
