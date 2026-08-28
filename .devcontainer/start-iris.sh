#!/bin/bash
# Runs on every container start (postStartCommand) since VS Code overrides the
# Dockerfile ENTRYPOINT/CMD to keep the container alive for attaching - IRIS
# must be started explicitly here instead of relying on entrypoint.sh.
set -e

IRIS_UID=$(id -u irisowner)
IRIS_GID=$(id -g irisowner)

echo "[start-iris] Fixing ownership of /vistadata for irisowner ($IRIS_UID:$IRIS_GID)..."
chown -R "$IRIS_UID:$IRIS_GID" /vistadata
chmod -R 775 /vistadata

echo "[start-iris] Starting IRIS instance..."
su irisowner -c "iris start IRIS" || echo "[start-iris] IRIS may already be running"

echo "[start-iris] Waiting for IRIS to accept sessions..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if su irisowner -c "iris session IRIS -c 'q'" >/dev/null 2>&1; then
        echo "[start-iris] IRIS is ready"
        break
    fi
    sleep 2
    attempt=$((attempt + 1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "[start-iris] ERROR: IRIS did not become ready in time"
    exit 1
fi

# Only run the routine load / user creation once per durable data volume
MARKER=/vistadata/.vistajs-initialized
if [ ! -f "$MARKER" ]; then
    echo "[start-iris] First run - loading XUSRB1 and SMEINT routines..."
    su irisowner -c "iris session IRIS < /tmp/xusrb1fix.script" || echo "[start-iris] Warning: routine load had issues"

    echo "[start-iris] Creating initial user..."
    su irisowner -c "iris session IRIS < /tmp/CreateUser.script" || echo "[start-iris] Warning: user creation had issues"

    touch "$MARKER"
else
    echo "[start-iris] Already initialized - skipping routine load and user creation"
fi

echo "[start-iris] Starting xinetd..."
if ! pgrep -x xinetd >/dev/null 2>&1; then
    /xinetd.sh &
else
    echo "[start-iris] xinetd already running"
fi

echo "[start-iris] Done. IRIS Management Portal: http://localhost:52773/csp/sys/UtilHome.csp"
