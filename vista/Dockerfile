#ARG IMAGE=containers.intersystems.com/intersystems/irishealth:2020.1.3.521.0
ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2022.1.0.209.0
FROM $IMAGE

USER root

# RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp
RUN apt-get update \
     && apt-get -y install xinetd vim
COPY stg_rpc /etc/xinetd.d/stg_rpc
COPY stg_vlk /etc/xinetd.d/stg_vlk
COPY xusrb1.xml /tmp/xusrb1.xml
COPY xinetd.sh /xinetd.sh
COPY xusrb1fix.script /tmp/xusrb1fix.script
COPY xusrb1fix.sh /tmp/xusrb1fix.sh
RUN chmod +x /tmp/xusrb1fix.sh
USER ${ISC_PACKAGE_MGRUSER}

