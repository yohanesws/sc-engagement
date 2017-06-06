#!/bin/sh

. /usr/local/dynamic-resources/dynamic_resources.sh

function find_env() {
  var=`printenv "$1"`
  # If environment variable exists
  if [ -n "$var" ]; then
    echo $var
  else
    echo $2
  fi
}

function inject_group() {
  group_name=$(find_env "HZ_GROUP_NAME")
  group_password=$(find_env "HZ_GROUP_PASSWORD")

  if [ -z $group_name ] || [ -z $group_password ]; then
    echo "There is a problem with your group configuration!"
    echo "Current values:"
    echo "HZ_GROUP_NAME: $group_name"
    echo "HZ_GROUP_PASSWORD: $group_password"
    echo "WARNING! The Groups is required"
  else
    group_xml="<group><name>${group_name}</name><password>${group_password}</password></group>"
    sed -i "s|<!-- ##GROUP## -->|$group_xml|" $HAZELCAST_HOME/bin/hazelcast.xml
  fi
}

function inject_join_members() {
  interface=$(find_env "HZ_INTERFACE")
  if ! [ -z "$interface" ]; then
    xml="<interface>${interface}</interface>"
    sed -i "s|<!-- ##INTERFACE## -->|$xml|" $HAZELCAST_HOME/bin/hazelcast.xml
    xmltcp="<tcp-ip enabled=\"true\">"
    sed -i "s|<!-- ##TCP## -->|$xmltcp|" $HAZELCAST_HOME/bin/hazelcast.xml
  fi

  public_address=$(find_env "HZ_PUBLIC_ADDRESS")
  if ! [ -z "$public_address" ]; then
    xml="<public-address>${public_address}</public-address>"
    sed -i "s|<!-- ##PUBLIC_ADDRESS## -->|$xml|" $HAZELCAST_HOME/bin/hazelcast.xml
    xmltcp="<tcp-ip enabled=\"true\">"
    sed -i "s|<!-- ##TCP## -->|$xmltcp|" $HAZELCAST_HOME/bin/hazelcast.xml
  fi

  members_env=$(find_env "HZ_MEMBERS")
  if ! [ -z "$members_env" ]; then
    xmltcp="<tcp-ip enabled=\"true\">"
    sed -i "s|<!-- ##TCP## -->|$xmltcp|" $HAZELCAST_HOME/bin/hazelcast.xml
    xml=""
    IFS=',' read -a members <<< $(find_env "HZ_MEMBERS")
    for member in ${members[@]}; do
      xml="$xml <member>${member}</member>"
    done

    if ! [ -z "$xml" ]; then
      member_xml="<member-list>${xml}</member-list>"
      sed -i "s|<!-- ##MEMBER_LIST## -->|$xml|" $HAZELCAST_HOME/bin/hazelcast.xml
    fi
  fi

  kubernetes_env=$(find_env "HAZELCAST_KUBERNETES_SERVICE_NAME")
  if ! [ -z "$kubernetes_env" ]; then

    xmldiscovery="<property name=\"hazelcast.discovery.enabled\">true</property>"
    sed -i "s|<!-- ##PROPERTY-DISCOVERY## -->|$xmldiscovery|" $HAZELCAST_HOME/bin/hazelcast.xml

    xmltcp="<tcp-ip enabled=\"false\">"
    sed -i "s|<!-- ##TCP## -->|$xmltcp|" $HAZELCAST_HOME/bin/hazelcast.xml

    service_name=$(find_env "HAZELCAST_KUBERNETES_SERVICE_NAME")
    namespace=$(find_env "HAZELCAST_KUBERNETES_NAMESPACE")
    service_domain=$(find_env "HAZELCAST_KUBERNETES_SERVICE_DOMAIN")

    if [ "$namespace" == "" ]; then
      namespace=$( cat /var/run/secrets/kubernetes.io/serviceaccount/namespace )
    fi
    echo "Kubernetes Namespace: $HAZELCAST_KUBERNETES_NAMESPACE"


    if [ "$service_domain" == "" ]; then
      service_domain="cluster.local"
    fi
    echo "Kubernetes Domain: $service_domain"

    HAZELCAST_KUBERNETES_SERVICE_DNS="$service_name.$namespace.svc.$service_domain"
    echo "Service DNS :$HAZELCAST_KUBERNETES_SERVICE_DNS"

    xml="<discovery-strategy enabled=\"true\" class=\"com.hazelcast.kubernetes.HazelcastKubernetesDiscoveryStrategy\">"
    xml="$xml <properties>"

    xml="$xml <property name=\"service-dns\">$HAZELCAST_KUBERNETES_SERVICE_DNS</property>"
    xml="$xml <property name=\"service-dns-timeout\">10</property>"

    # xml="$xml <property name=\"service-name\">$service_name</property>"
    # xml="$xml <property name=\"namespace\">$namespace</property>"

    label_env=$(find_env "HAZELCAST_KUBERNETES_SERVICE_LABEL_NAME")
    if ! [ -z "$label_env" ]; then
      label=$(find_env "HAZELCAST_KUBERNETES_SERVICE_LABEL_NAME")
      value=$(find_env "HAZELCAST_KUBERNETES_SERVICE_LABEL_VALUE")
      xml="$xml <property name=\"service-label-name\">\"$label\"</property>"
      xml="$xml <property name=\"service-label-value\">\"$value\"</property>"
    fi
    xml="$xml </properties></discovery-strategy>"
    sed -i "s|<!-- ##DISCOVERY_STRATEGIES## -->|$xml|" $HAZELCAST_HOME/bin/hazelcast.xml
  fi

}

function expand_catalina_opts() {
    MAX_HEAP=`get_heap_size`
    if [ -n "$MAX_HEAP" ]; then
      export MIN_HEAP_SIZE=$MAX_HEAP
      export MAX_HEAP_SIZE=$MAX_HEAP
    fi
    # ls -ltr /opt
    # ls -ltr $HAZELCAST_HOME
}


function launch_hazelcast() {
  PRG="$0"
  PRGDIR=`dirname "$PRG"`
  if [ $JAVA_HOME ]; then
      echo "JAVA_HOME found at $JAVA_HOME"
      RUN_JAVA=$JAVA_HOME/bin/java
  else
    echo "JAVA_HOME environment variable not available."
    RUN_JAVA=`which java 2>/dev/null`
  fi

  if [ -z $RUN_JAVA ]; then
    echo "JAVA could not be found in your system."
    echo "please install Java 1.6 or higher!!!"
    exit 1
  fi

  if [ "x$MIN_HEAP_SIZE" != "x" ]; then
    JAVA_OPTS="$JAVA_OPTS -Xms${MIN_HEAP_SIZE}"
  fi

  if [ "x$MAX_HEAP_SIZE" != "x" ]; then
    JAVA_OPTS="$JAVA_OPTS -Xmx${MAX_HEAP_SIZE}"
  fi

  JAVA_OPTS="$JAVA_OPTS -Dhazelcast.config=$HAZELCAST_HOME/bin/hazelcast.xml"
  JAVA_OPTS="$JAVA_OPTS -Dlog4j.configuration=file://$HAZELCAST_HOME/lib/log4j.properties"

  echo "Path to Java : $RUN_JAVA"

  #export CLASSPATH="$HAZELCAST_HOME/lib/hazelcast-all-3.8.1.jar"
  CLASSPATH="$HAZELCAST_HOME/lib/hazelcast-all-3.8.1.jar:$HAZELCAST_HOME/lib/log4j-1.2.16.jar:$HAZELCAST_HOME/lib/json-smart-1.1.1.jar:$HAZELCAST_HOME/lib/jsonevent-layout-1.7.jar"
  # CLASSPATH="$CLASSPATH:$HAZELCAST_HOME/lib/commons-lang-2.6.0.redhat-6.jar"
  CLASSPATH="$CLASSPATH:$HAZELCAST_HOME/lib/commons-lang-2.6.0.redhat-6.jar:$HAZELCAST_HOME/ext/*"

  #export CLASSPATH="$HAZELCAST_HOME/lib/hazelcast-all-3.8.1.jar:$HAZELCAST_HOME/lib/log4j-1.2.16.jar"

  echo "########################################"
  echo "# RUN_JAVA=$RUN_JAVA"
  echo "# JAVA_OPTS=$JAVA_OPTS"
  echo "# starting now...."
  echo "########################################"
  $RUN_JAVA -server -cp $CLASSPATH $JAVA_OPTS com.hazelcast.core.server.StartServer
}






expand_catalina_opts
inject_group
inject_join_members
launch_hazelcast

#echo "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION-$JBOSS_IMAGE_RELEASE"

# exec $HAZELCAST_HOME/bin/start.sh
