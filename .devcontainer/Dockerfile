ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2025.3
FROM $IMAGE

USER root

RUN apt-get update \
    && apt-get -y install xinetd vim git curl wget \
    && rm -rf /var/lib/apt/lists/*

# Copy VistA configuration and initialization files
COPY vista/stg_rpc /etc/xinetd.d/stg_rpc
COPY vista/stg_vlk /etc/xinetd.d/stg_vlk
COPY vista/smeint.xml /tmp/smeint.xml
COPY vista/xusrb1.xml /tmp/xusrb1.xml
COPY vista/xinetd.sh /xinetd.sh
COPY vista/xusrb1fix.script /tmp/xusrb1fix.script
COPY vista/CreateUser.script /tmp/CreateUser.script
COPY .devcontainer/entrypoint.sh /entrypoint.sh

RUN chmod +x /xinetd.sh /entrypoint.sh

# Ensure data directories exist
RUN mkdir -p /vistadata/iris_conf.d /vistadata/merge /vistadata/dat/vista

USER ${ISC_PACKAGE_MGRUSER}

EXPOSE 52773 1972 9093 9096

ENTRYPOINT ["/entrypoint.sh"]
