#!/bin/bash
# Runs on every container start (postStartCommand) since VS Code overrides the
# Dockerfile ENTRYPOINT/CMD to keep the container alive for attaching - IRIS
# must be started explicitly here instead of relying on entrypoint.sh.
set -e

DATA_DIR=/workspace/vista/data

# Ensure directories and merge.cpf exist - do not depend on postCreateCommand
# having run first, since Codespaces can run postStartCommand before it.
mkdir -p "$DATA_DIR/merge" "$DATA_DIR/dat/vista" "$DATA_DIR/iris_conf.d"
if [ ! -f "$DATA_DIR/merge/merge.cpf" ] && [ -f /workspace/vista/merge.cpf ]; then
    echo "[start-iris] Generating merge.cpf..."
    sed "s#/dur/#$DATA_DIR/#g" /workspace/vista/merge.cpf > "$DATA_DIR/merge/merge.cpf"
fi

echo "[start-iris] Fixing ownership of $DATA_DIR for IRIS (51773:51773)..."
chown -R 51773:51773 "$DATA_DIR"
chmod -R 775 "$DATA_DIR"

start_iris() {
    su irisowner -c "iris start IRIS" || echo "[start-iris] IRIS may already be running"
}

echo "[start-iris] Starting IRIS instance..."
start_iris

# IRIS's own internal startup can briefly run privileged steps and hand
# ownership back to irisowner when done. If that gets interrupted (e.g. a
# Codespaces disconnect), the instance is left "indeterminate"/inaccessible.
# Detect that and self-heal by force-stopping, re-chowning, and retrying once.
STATUS=$(su irisowner -c "iris list IRIS" 2>/dev/null)
if echo "$STATUS" | grep -qiE "indeterminate|inaccessible"; then
    echo "[start-iris] Detected indeterminate/inaccessible IRIS state - recovering..."
    su irisowner -c "iris stop IRIS force quietly" 2>/dev/null || true
    chown -R 51773:51773 "$DATA_DIR"
    chmod -R 775 "$DATA_DIR"
    start_iris
fi

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

# The VISTA namespace/database is created by merging merge.cpf - normally done
# automatically by the base image's own entrypoint on first boot, which devcontainers
# bypasses, so it must be applied and activated manually here.
MERGE_MARKER="$DATA_DIR/.vistajs-merged"
if [ ! -f "$MERGE_MARKER" ]; then
    echo "[start-iris] Merging VISTA namespace/database config from merge.cpf..."
    su irisowner -c "iris merge IRIS $DATA_DIR/merge/merge.cpf"

    echo "[start-iris] Restarting IRIS to activate merged config..."
    su irisowner -c "iris stop IRIS quietly" || true
    su irisowner -c "iris start IRIS"

    attempt=0
    while [ $attempt -lt $max_attempts ]; do
        if su irisowner -c "iris session IRIS -c 'q'" >/dev/null 2>&1; then
            break
        fi
        sleep 2
        attempt=$((attempt + 1))
    done

    touch "$MERGE_MARKER"
else
    echo "[start-iris] merge.cpf already applied - skipping"
fi

# Only run the routine load / user creation once per durable data volume
MARKER="$DATA_DIR/.vistajs-initialized"
if [ ! -f "$MARKER" ]; then
    ROUTINE_LOAD_OK=1
    USER_CREATE_OK=1

    echo "[start-iris] First run - loading XUSRB1 and SMEINT routines..."
    su irisowner -c "iris session IRIS < /opt/vistajs/xusrb1fix.script" || { echo "[start-iris] Warning: routine load had issues"; ROUTINE_LOAD_OK=0; }

    echo "[start-iris] Creating initial user..."
    su irisowner -c "iris session IRIS < /opt/vistajs/CreateUser.script" || { echo "[start-iris] Warning: user creation had issues"; USER_CREATE_OK=0; }

    if [ "$ROUTINE_LOAD_OK" -eq 1 ] && [ "$USER_CREATE_OK" -eq 1 ]; then
        touch "$MARKER"
    else
        echo "[start-iris] Not marking as initialized due to errors above - will retry on next start"
    fi
else
    echo "[start-iris] Already initialized - skipping routine load and user creation"
fi

echo "[start-iris] Starting xinetd..."
if ! pgrep -x xinetd >/dev/null 2>&1; then
    # setsid/nohup fully detach xinetd so it survives after this script exits
    # (a plain "&" background job can be killed when postStartCommand's shell exits)
    nohup setsid /xinetd.sh < /dev/null > /var/log/xinetd-start.log 2>&1 &
    disown
    sleep 1
    if pgrep -x xinetd >/dev/null 2>&1; then
        echo "[start-iris] xinetd started"
    else
        echo "[start-iris] WARNING: xinetd did not start - see /var/log/xinetd-start.log"
        cat /var/log/xinetd-start.log 2>/dev/null
    fi
else
    echo "[start-iris] xinetd already running"
fi

echo "[start-iris] Done. IRIS Management Portal: http://localhost:52773/csp/sys/UtilHome.csp"
