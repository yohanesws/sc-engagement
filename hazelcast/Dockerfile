#FROM registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:latest
FROM uklvaddcd05a.uk.standardchartered.com:5000/scb-glbl-docker-jdk:latest
# FROM ibanking-jboss/jdk:1.0

MAINTAINER SCB IBanking<scb-ibanking-feedback@sc.com>

# Environment variables
ENV JBOSS_IMAGE_NAME="scb-hazelcast-tryout" \
    JBOSS_IMAGE_VERSION="1.0" \
    JBOSS_IMAGE_RELEASE="1" \
    JAVA_HOME="/opt/java/jdk-1.8.0" \
    #JAVA_HOME="/usr/lib/jvm/java-1.8.0" \
    JAVA_VENDOR="oracle" \
    JAVA_VERSION="1.8.0" \
    JAVA_VERSION_MAJOR="8" \
    JAVA_VERSION_MINOR="121" \
    JAVA_VERSION_BUILD="14" \
    JAVA_PACKAGE="jdk" \
    HAZELCAST_HOME="/opt/hazelcast" \
    HAZELCAST_LIB="/opt/hazelcast/lib"

# Labels
LABEL name="$JBOSS_IMAGE_NAME" \
      version="$JBOSS_IMAGE_VERSION" \
      release="$JBOSS_IMAGE_RELEASE" \
      architecture="x86_64" \
      com.redhat.component="jboss-base-7-jdk8-docker"

USER root

# Add all required sources to the /tmp/scripts/sources/
# directory
RUN mkdir -p /tmp/scripts

# Add scripts used to configure the image
COPY scripts /tmp/scripts

COPY source/hazelcast-3.8.1.tar.gz /tmp/scripts

RUN mkdir -p $HAZELCAST_HOME && \
  tar -zxvf /tmp/scripts/hazelcast-3.8.1.tar.gz -C $HAZELCAST_HOME --strip 1 && \
  rm -rf  $HAZELCAST_HOME/code-samples &&\
  rm -rf  $HAZELCAST_HOME/demo &&\
  rm -rf  $HAZELCAST_HOME/docs &&\
  rm -rf $HAZELCAST_HOME/bin/hazelcast-full-example.xml &&\
  rm -rf $HAZELCAST_HOME/bin/._* &&\
  rm -rf $HAZELCAST_HOME/lib/._*

RUN mkdir -p $HAZELCAST_HOME/ext/

COPY source/ext/*.jar $HAZELCAST_HOME/ext/

#RUN mkdir -p $HAZELCAST_HOME && curl -jksSL  "http://download.hazelcast.com/download.#jsp?version=hazelcast-3.8.1&type=tar&p="  \
#  | tar -zxvf - -C $HAZELCAST_HOME --strip 1 &&\
#  rm -rf  $HAZELCAST_HOME/code-samples &&\
#  rm -rf  $HAZELCAST_HOME/demo &&\
#  rm -rf  $HAZELCAST_HOME/docs &&\
#  rm -rf $HAZELCAST_HOME/bin/hazelcast-full-example.xml

# Set environment
ENV JAVA_HOME /opt/java/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin

USER root
RUN [ "bash", "-x", "/tmp/scripts/dynamic-resources/install.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/install_scripts.sh" ]

RUN rm -rf /tmp/scripts

USER 185

### Expose port
EXPOSE 5701 37000 37001 37002 37003

# Start the main process
CMD ["/opt/hazelcast/bin/launch.sh"]
