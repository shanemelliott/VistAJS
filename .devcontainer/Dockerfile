ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2025.3
FROM $IMAGE

USER root

RUN apt-get update \
    && apt-get -y install xinetd vim git curl wget unzip bash-completion \
    && rm -rf /var/lib/apt/lists/*

# Copy VistA configuration and initialization files
COPY vista/stg_rpc /etc/xinetd.d/stg_rpc
COPY vista/stg_vlk /etc/xinetd.d/stg_vlk
COPY vista/smeint.xml /opt/vistajs/smeint.xml
COPY vista/xusrb1.xml /opt/vistajs/xusrb1.xml
COPY vista/xinetd.sh /xinetd.sh
COPY vista/xusrb1fix.script /opt/vistajs/xusrb1fix.script
COPY vista/CreateUser.script /opt/vistajs/CreateUser.script
COPY .devcontainer/entrypoint.sh /entrypoint.sh

# Normalize line endings (source files may have CRLF from Windows git checkouts,
# which breaks shell shebangs with "cannot execute: required file not found")
RUN sed -i 's/\r$//' /xinetd.sh /entrypoint.sh /opt/vistajs/xusrb1fix.script /opt/vistajs/CreateUser.script \
    && chmod +x /xinetd.sh /entrypoint.sh

USER ${ISC_PACKAGE_MGRUSER}

EXPOSE 52773 1972 9093 9096

ENTRYPOINT ["/entrypoint.sh"]
