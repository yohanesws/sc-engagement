#!/bin/sh

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
SOURCES_DIR=/tmp/scripts/sources/


function copy {
  mkdir -p $(dirname $2)
  cp -p $1 $2
}

function link {
  mkdir -p $(dirname $2)
  ln -s $1 $2
}

copy ${ADDED_DIR}/launch.sh $HAZELCAST_HOME/bin/
copy ${ADDED_DIR}/hazelcast.xml $HAZELCAST_HOME/bin/hazelcast.xml
copy ${ADDED_DIR}/log4j.properties $HAZELCAST_HOME/lib/log4j.properties

chown -R jboss:jboss $HAZELCAST_HOME
chmod -R 755 $HAZELCAST_HOME
chmod -R 755 /usr/local/dynamic-resources/

# Necessary to permit running under a random uid
chmod -R a+rwX $HAZELCAST_HOME
