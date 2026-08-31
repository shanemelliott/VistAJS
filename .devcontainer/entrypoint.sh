#!/bin/bash
# Passed to the base IRIS image's own entrypoint via CMD's "-a" flag, which
# runs this as the final action once IRIS is fully up (CPF merge, database
# mounting, encryption/WIJ handling, etc. are all handled by the base image's
# own entrypoint - reimplementing that ourselves was the source of most of
# the flakiness we used to hit here). Runs as irisowner (the image's default
# USER), matching the original docker-compose "command: -a /xinetd.sh" setup.
set -e

DATA_DIR=/workspace/vista/data

# Only run the routine load / user creation once per durable data volume
MARKER="$DATA_DIR/.vistajs-initialized"
if [ ! -f "$MARKER" ]; then
    ROUTINE_LOAD_OK=1
    USER_CREATE_OK=1

    echo "[vistajs-init] Loading XUSRB1 and SMEINT routines..."
    iris session IRIS < /opt/vistajs/xusrb1fix.script || { echo "[vistajs-init] Warning: routine load had issues"; ROUTINE_LOAD_OK=0; }

    echo "[vistajs-init] Creating initial user..."
    iris session IRIS < /opt/vistajs/CreateUser.script || { echo "[vistajs-init] Warning: user creation had issues"; USER_CREATE_OK=0; }

    if [ "$ROUTINE_LOAD_OK" -eq 1 ] && [ "$USER_CREATE_OK" -eq 1 ]; then
        # Force a clean checkpoint so the new user/routines are durably
        # flushed to disk rather than only existing in memory
        echo "[vistajs-init] Restarting IRIS to checkpoint newly created user/routines to disk..."
        iris stop IRIS quietly || true
        iris start IRIS
        touch "$MARKER"
    else
        echo "[vistajs-init] Not marking as initialized due to errors above - will retry on next start"
    fi
else
    echo "[vistajs-init] Already initialized - skipping routine load and user creation"
fi

echo "[vistajs-init] Starting xinetd..."
exec /xinetd.sh
