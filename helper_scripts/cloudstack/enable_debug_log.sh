#!/bin/bash

# We work from here
cd /data/git/$HOSTNAME/cloudstack

# Find and replace all occurences of info and warn to debug.

# Files
tomcat="client/tomcatconf/log4j-cloud.xml.in"
server="server/conf/log4j-cloud.xml.in"

# Replace 

sed -e -i s/"<param name=\"Threshold\" value=\"INFO\"/>"/"<param name=\"Threshold\" value=\"DEBUG\"/>"/g $tomcat
sed -e -i s/"<level value=\"WARN\"/>"/"<level value=\"DEBUG\"/>"/g $tomcat
sed -e -i s/"<level value=\"INFO\"/>"/"<level value=\"DEBUG\"/>"/g $tomcat

sed -e -i s/"<param name=\"Threshold\" value=\"INFO\"/>"/"<param name=\"Threshold\" value=\"DEBUG\"/>"/g $server
sed -e -i s/"<level value=\"WARN\"/>"/"<level value=\"DEBUG\"/>"/g $server
sed -e -i s/"<level value=\"INFO\"/>"/"<level value=\"DEBUG\"/>"/g $server
