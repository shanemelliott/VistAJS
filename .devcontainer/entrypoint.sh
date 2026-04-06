#!/bin/bash
set -e

echo "[VistA Init] Checking IRIS readiness..."
max_attempts=30
attempt=0

# Wait for IRIS to be ready
while [ $attempt -lt $max_attempts ]; do
    if iris session IRIS -c 'q' >/dev/null 2>&1; then
        echo "[VistA Init] IRIS is ready"
        break
    fi
    echo "[VistA Init] Waiting for IRIS... ($((attempt + 1))/$max_attempts)"
    sleep 2
    attempt=$((attempt + 1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "[VistA Init] ERROR: IRIS failed to start after $max_attempts attempts"
    exit 1
fi

# Check if database is initialized (look for VISTA namespace)
if ! iris session IRIS -c 'zn "VISTA" q' >/dev/null 2>&1; then
    echo "[VistA Init] VISTA namespace not found - initializing database..."
    
    if [ -f "/vistadata/dat/vista/IRIS.DAT" ]; then
        echo "[VistA Init] IRIS.DAT found - database should be initialized"
    else
        echo "[VistA Init] WARNING: No IRIS.DAT found. Restore it to /vistadata/dat/vista/IRIS.DAT"
    fi
else
    echo "[VistA Init] VISTA namespace exists - loading routines..."
fi

# Load and compile XUSRB1 and SMEINT
echo "[VistA Init] Loading XUSRB1 and SMEINT routines..."
iris session IRIS < /tmp/xusrb1fix.script || echo "[VistA Init] Warning: Routine loading had issues"

echo "[VistA Init] Creating initial user..."
iris session IRIS < /tmp/CreateUser.script || echo "[VistA Init] Warning: User creation had issues"

echo "[VistA Init] Starting xinetd service..."
exec /xinetd.sh
