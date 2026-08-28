#!/bin/bash
set -e

echo "VistA Dev Container Post-Create Setup"
echo "======================================"

# VistA download configuration
VISTA_URL="foia-vista.worldvista.org/DBA_VistA_FOIA_System_Files/DBA_VISTA_FOIA_2022"
VISTA_ZIP="DBA_VISTA_FOIA_20221004.zip"
DAT_FILE="/workspace/vista/data/dat/vista/IRIS.DAT"

# Create necessary directories
mkdir -p /workspace/vista/data/merge
mkdir -p /workspace/vista/data/dat/vista
mkdir -p /workspace/vista/data/iris_conf.d

# Set ownership to IRIS user (51773) - required for IRIS to write to mounted volumes
echo "Setting directory permissions for IRIS user..."
chown -R 51773:51773 /workspace/vista/data
chmod -R 775 /workspace/vista/data

# Copy config file if it exists
if [ -f "/workspace/vista/merge.cpf" ]; then
    echo "Copying merge.cpf to data directory..."
    cp /workspace/vista/merge.cpf /workspace/vista/data/merge/merge.cpf
fi

# Check for VistA DAT file and download if needed
if [ ! -f "$DAT_FILE" ]; then
    echo ""
    echo "IRIS.DAT not found - downloading VistA..."
    echo "URL: https://$VISTA_URL/$VISTA_ZIP"
    echo ""
    
    if wget -q --show-progress -P /workspace/vista/data/dat/vista "https://$VISTA_URL/$VISTA_ZIP"; then
        echo "Download complete - extracting..."
        unzip /workspace/vista/data/dat/vista/$VISTA_ZIP -d /workspace/vista/data/dat/vista
        rm /workspace/vista/data/dat/vista/$VISTA_ZIP
        
        if [ -f "$DAT_FILE" ]; then
            echo "IRIS.DAT extracted successfully"
            chmod 644 "$DAT_FILE"
        else
            echo "ERROR: IRIS.DAT not found after extraction"
            exit 1
        fi
    else
        echo "ERROR: Failed to download VistA from:"
        echo "  https://$VISTA_URL/$VISTA_ZIP"
        echo ""
        echo "MANUAL OPTION: Download manually and place at:"
        echo "  vista/data/dat/vista/IRIS.DAT"
        echo ""
        exit 1
    fi
else
    echo "IRIS.DAT found - using existing database"
fi

# Setup bashrc
if [ -f "/workspace/vista/bashrc" ]; then
    echo "Setting up shell aliases..."
    cat /workspace/vista/bashrc >> ~/.bashrc
fi

# Install Node dependencies
echo "Installing Node dependencies..."
cd /workspace
npm install --silent

echo ""
echo "Setup complete! VistA IRIS container is initializing..."
echo "Access IRIS at: http://localhost:52773/csp/sys/UtilHome.csp"
echo ""
echo "Local ports:"
echo "  52773 - IRIS Management Portal"
echo "  1972  - SuperServer (RPC)"
echo "  9093  - XWB"
echo "  9096  - WebSocket"
echo ""
