ARG IMAGE=containers.intersystems.com/intersystems/irishealth:2020.1.3.521.0
FROM $IMAGE

USER root
#WORKDIR /opt/irisapp
#RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp
RUN apt-get update \
    && apt-get -y install xinetd vim

USER ${ISC_PACKAGE_MGRUSER}

# copy files
#COPY  Installer.cls .
#COPY src src
#COPY  module.xml .  
#COPY iris.script /tmp/iris.script

# run iris and script
#RUN iris start IRIS \
#	&& iris session IRIS < /tmp/iris.script \
#    && iris stop IRIS quietly
