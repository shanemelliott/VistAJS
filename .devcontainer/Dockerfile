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
COPY .devcontainer/entrypoint.sh /opt/vistajs/post-init.sh

# Normalize line endings (source files may have CRLF from Windows git checkouts,
# which breaks shell shebangs and xinetd's config parser)
RUN sed -i 's/\r$//' /xinetd.sh /opt/vistajs/post-init.sh /opt/vistajs/xusrb1fix.script /opt/vistajs/CreateUser.script \
    /etc/xinetd.d/stg_rpc /etc/xinetd.d/stg_vlk \
    && chmod +x /xinetd.sh /opt/vistajs/post-init.sh

EXPOSE 52773 1972 9093 9096

# Do not override the base image's own ENTRYPOINT - it handles CPF merging,
# database mounting, and starting IRIS itself (using ISC_CPF_MERGE_FILE and
# ISC_DATA_DIRECTORY, set in devcontainer.json). The "-a" flag tells it to run
# our script as the final action once IRIS is up, matching how the original
# docker-compose.yml used "command: --check-caps false -a /xinetd.sh".
USER ${ISC_PACKAGE_MGRUSER}
CMD ["--check-caps", "false", "-a", "/opt/vistajs/post-init.sh"]
