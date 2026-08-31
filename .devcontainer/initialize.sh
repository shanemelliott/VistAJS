#!/bin/bash
# Runs on the HOST before the container is created (devcontainer.json
# "initializeCommand"). This exists so IRIS.DAT and merge.cpf are already in
# place BEFORE the base IRIS image's own entrypoint starts on first boot -
# otherwise IRIS would initialize an empty database while postCreateCommand
# is still downloading the real one (a race we hit repeatedly running this
# from inside the container via postCreateCommand/postStartCommand instead).
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="$REPO_ROOT/vista/data"
VISTA_URL="foia-vista.worldvista.org/DBA_VistA_FOIA_System_Files/DBA_VISTA_FOIA_2022"
VISTA_ZIP="DBA_VISTA_FOIA_20221004.zip"
DAT_FILE="$DATA_DIR/dat/vista/IRIS.DAT"

echo "[initialize] Setting up vista/data directory structure..."
mkdir -p "$DATA_DIR/merge" "$DATA_DIR/dat/vista" "$DATA_DIR/iris_conf.d"

if [ -f "$REPO_ROOT/vista/merge.cpf" ] && [ ! -f "$DATA_DIR/merge/merge.cpf" ]; then
    echo "[initialize] Generating merge.cpf (database path rewritten for the container)..."
    sed 's#/dur/#/workspace/vista/data/#g' "$REPO_ROOT/vista/merge.cpf" > "$DATA_DIR/merge/merge.cpf"
fi

if [ ! -f "$DAT_FILE" ]; then
    if command -v wget >/dev/null 2>&1 && command -v unzip >/dev/null 2>&1; then
        echo "[initialize] IRIS.DAT not found - downloading VistA (this can take a few minutes)..."
        if wget -q --show-progress -P "$DATA_DIR/dat/vista" "https://$VISTA_URL/$VISTA_ZIP"; then
            echo "[initialize] Download complete - extracting..."
            ZIP_PATH="$DATA_DIR/dat/vista/$VISTA_ZIP"
            unzip "$ZIP_PATH" -d "$DATA_DIR/dat/vista" &
            UNZIP_PID=$!
            while kill -0 "$UNZIP_PID" 2>/dev/null; do
                sleep 10
                if [ -f "$DAT_FILE" ]; then
                    echo "  ...extracted $(du -h "$DAT_FILE" | cut -f1) so far"
                fi
            done
            wait "$UNZIP_PID"
            rm -f "$ZIP_PATH"
            if [ -f "$DAT_FILE" ]; then
                echo "[initialize] IRIS.DAT extracted successfully"
            else
                echo "[initialize] ERROR: IRIS.DAT not found after extraction"
            fi
        else
            echo "[initialize] ERROR: Failed to download VistA from https://$VISTA_URL/$VISTA_ZIP"
            echo "[initialize] MANUAL OPTION: place IRIS.DAT at vista/data/dat/vista/IRIS.DAT"
        fi
    else
        echo "[initialize] WARNING: wget/unzip not available on this host - skipping VistA download."
        echo "[initialize] Place IRIS.DAT manually at vista/data/dat/vista/IRIS.DAT before starting the container."
    fi
else
    echo "[initialize] IRIS.DAT found - using existing database"
fi

# Best-effort - matches on Linux hosts (Codespaces) where bind-mount UID maps
# directly into the container. No-op/harmless if it fails (e.g. Windows/NTFS).
chown -R 51773:51773 "$DATA_DIR" 2>/dev/null || true
chmod -R 775 "$DATA_DIR" 2>/dev/null || true

echo "[initialize] Done."
