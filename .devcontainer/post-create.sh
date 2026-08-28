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

# Copy config file if it exists, rewriting the database path since the
# original merge.cpf targets /dur (docker-compose flow) but the devcontainer uses vista/data
if [ -f "/workspace/vista/merge.cpf" ]; then
    echo "Copying merge.cpf to data directory..."
    sed 's#/dur/#/workspace/vista/data/#g' /workspace/vista/merge.cpf > /workspace/vista/data/merge/merge.cpf
fi

# Check for VistA DAT file and download if needed
if [ ! -f "$DAT_FILE" ]; then
    echo ""
    echo "IRIS.DAT not found - downloading VistA..."
    echo "URL: https://$VISTA_URL/$VISTA_ZIP"
    echo ""
    
    if wget -q --show-progress -P /workspace/vista/data/dat/vista "https://$VISTA_URL/$VISTA_ZIP"; then
        echo "Download complete - extracting (this can take several minutes for the large DAT file)..."

        # unzip gives no progress for a single large file, so poll the growing
        # output file size in the background to show it is still working
        ZIP_PATH="/workspace/vista/data/dat/vista/$VISTA_ZIP"
        unzip "$ZIP_PATH" -d /workspace/vista/data/dat/vista &
        UNZIP_PID=$!
        while kill -0 "$UNZIP_PID" 2>/dev/null; do
            sleep 10
            if [ -f "$DAT_FILE" ]; then
                echo "  ...extracted $(du -h "$DAT_FILE" | cut -f1) so far"
            fi
        done
        wait "$UNZIP_PID"

        rm "$ZIP_PATH"
        
        if [ -f "$DAT_FILE" ]; then
            echo "IRIS.DAT extracted successfully"
            chown 51773:51773 "$DAT_FILE"
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

# Generate config.js for the test user created by start-iris.sh (see vista/smeint.xml
# for the Access/Verify codes), pointing at the xinetd RPC broker port (see vista/stg_rpc)
if [ ! -f "/workspace/config.js" ] && [ -f "/workspace/config.sample.js" ]; then
    echo "Generating config.js with default VistA test user credentials..."
    cat > /workspace/config.js << 'EOF'
module.exports = {
    context: 'SDECRPC',
    host: 'localhost',
    port: 19301,
    accessCode: 'VISTAJS123',
    verifyCode: 'VISTAJS123!!',
    localIP: '',
    localAddress: '',
    samlToken: ''
};
EOF
fi

# Setup shell aliases (devcontainer runs inside the IRIS container already, no docker exec needed).
# IRIS commands must run as irisowner, so wrap with su when the terminal is root.
echo "Setting up shell aliases..."
cat >> ~/.bashrc << 'EOF'

# VistA Shortcuts (devcontainer - runs directly, no docker exec)
[ -f /etc/bash_completion ] && . /etc/bash_completion
alias prog='su irisowner -c "iris session iris -U VISTA"'
alias PROG='su irisowner -c "iris session iris -U VISTA"'
alias vista='su irisowner -c "iris session iris -U VISTA \"^ZU\""'
alias VISTA='su irisowner -c "iris session iris -U VISTA \"^ZU\""'
alias irisowner='su irisowner'
EOF

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
