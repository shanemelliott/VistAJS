#ARG IMAGE=containers.intersystems.com/intersystems/irishealth:2020.1.3.521.0
ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2022.1.0.209.0
FROM $IMAGE

USER root

# RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp
RUN apt-get update \
     && apt-get -y install xinetd vim
COPY stg_rpc /etc/xinetd.d/stg_rpc
COPY stg_vlk /etc/xinetd.d/stg_vlk
COPY xusrb1.xls /tmp/
COPY xinetd.sh /xinetd.sh
# Reference for todo later.
#d $System.OBJ.Load("/home/kazamatzuri/deplgbl.xml")
# D D COMPILE^%RCOMPIL("XUSRB1","INT")
USER ${ISC_PACKAGE_MGRUSER}

# COPY  module.xml .  
# COPY iris.script /tmp/iris.script

# run iris and script
# RUN iris start IRIS \
#	&& iris session IRIS < /tmp/iris.script \
#    && iris stop IRIS quietly
