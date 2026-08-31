#!/bin/bash
set -e

echo "VistA Dev Container Post-Create Setup"
echo "======================================"

# Directory setup, merge.cpf generation, and the IRIS.DAT download all happen
# in .devcontainer/initialize.sh (runs on the host before the container is
# created) so they're already in place before the base IRIS image's own
# entrypoint starts on first boot. This script only handles things that can
# safely run after the container is up.

DAT_FILE="/workspace/vista/data/dat/vista/IRIS.DAT"
if [ -f "$DAT_FILE" ]; then
    echo "IRIS.DAT found"
else
    echo "WARNING: IRIS.DAT not found at $DAT_FILE"
    echo "Check the 'initializeCommand' output for download errors, or place it there manually."
fi

# Generate config.js for the test user created by the container's -a action
# script (see vista/smeint.xml for the Access/Verify codes), pointing at the
# xinetd RPC broker port (see vista/stg_rpc)
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
echo "  19301 - VistA RPC Broker"
echo "  18301 - VistaLink"
echo ""
