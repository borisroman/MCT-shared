#!/bin/bash

# We work from here
cd /data/git/$HOSTNAME/cloudstack

# Compile ACS
mvn clean install -P developer,systemvm -DskipTests -T 2C

# Run mgt
mvnDebug -pl :cloud-client-ui jetty:run

