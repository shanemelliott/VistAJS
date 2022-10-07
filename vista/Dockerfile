# ARG IMAGE=containers.intersystems.com/intersystems/irishealth:2020.1.3.521.0
ARG IMAGE=intersystemsdc/iris-community
FROM $IMAGE

USER root
# WORKDIR /opt/irisapp
# RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp
RUN apt-get update \
    && apt-get -y install xinetd vim
COPY stg_rpc /etc/xinetd.d/stg_rpc
COPY stg_vlk /etc/xinetd.d/stg_vlk


USER ${ISC_PACKAGE_MGRUSER}

# COPY  module.xml .  
# COPY iris.script /tmp/iris.script

# run iris and script
# RUN iris start IRIS \
#	&& iris session IRIS < /tmp/iris.script \
#    && iris stop IRIS quietly
