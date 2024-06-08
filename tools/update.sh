#!/bin/bash

cat << "EOF"
                                        ██████████████    
                                  ██████████        ██    
                              ████████              ██    
                          ██████                  ████    
                        ██████      ████          ██      
                      ████        ████████      ████      
                    ████        ████░░░░████    ████      
          ████████████          ████░░░░████  ████        
        ████    ▒▒██              ████████    ████        
        ██    ▒▒██                  ████    ████          
      ████  ▒▒██          ████            ████            
      ██▒▒  ▒▒██        ████▒▒██          ████            
    ████▒▒▒▒██        ████▒▒██▒▒        ████              
    ████████████    ████▒▒██▒▒        ████                
            ░░    ████▒▒██▒▒        ████                  
      ░░░░        ██▒▒██▒▒        ████                    
    ▒▒▒▒░░        ▒▒██▒▒        ██▒▒██                    
  ░░▒▒▒▒▒▒░░                ████  ▒▒██                    
        ▒▒░░          ░░████▒▒    ▒▒██                    
      ▒▒▒▒▒▒░░    ░░  ▒▒██▒▒      ▒▒██                    
    ▒▒▒▒▒▒▒▒░░░░▒▒░░  ▒▒██▒▒▒▒██████                      
  ░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░▒▒████████                          
  ▒▒      ▒▒▒▒▒▒░░▒▒░░  ████                              
        ▒▒▒▒▒▒  ▒▒▒▒                                      
        ▒▒░░    ▒▒░░                                      
EOF

# Script version
SCRIPT_VERSION="1.2"

echo ""
echo "Quilibrium Update Script - Version $SCRIPT_VERSION"
echo "***** https://Quilibrium.wiki *****"
echo ""
echo "This script will update your node to the latest version."
echo ""

# Function to check for newer script version
check_for_updates() {
    LATEST_VERSION=$(curl -s https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/update.sh | grep 'SCRIPT_VERSION="' | head -1 | cut -d'"' -f2)
    if [ "$SCRIPT_VERSION" != "$LATEST_VERSION" ]; then
        echo "A newer version of this script is available (v$LATEST_VERSION)."
        read -p "Do you want to download the newer version? (y/n): " RESPONSE
        if [ "$RESPONSE" == "y" ] || [ "$RESPONSE" == "Y" ]; then
            curl -o update.sh https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/update.sh
            echo "New version downloaded. Please run the script again."
            exit 0
        fi
    fi
}

QUIL_DIR="$HOME/quil"
ARCHITECTURE=$(uname -m)
ARCHITECTURE=${ARCHITECTURE/x86_64/linux-amd64} # Map x86_64 to linux-amd64
ARCHITECTURE=${ARCHITECTURE/aarch64/linux-arm64} # Map aarch64 to linux-arm64
SERVICE_FILE="/etc/systemd/system/quil.service"
LAST_UPDATE_FILE="$HOME/quil/tools/last_update"
LOG_FILE="$HOME/quil/tools/YAQAS.log"
CHAT_ID_FILE="$HOME/quil/tools/chat_id.txt"

# Redirect stdout and stderr to both console and log file
exec > >(tee -a "$LOG_FILE") 2>&1

send_notification() {
  MESSAGE=$1
  NODE_IP=$(curl -s -4 icanhazip.com)
  FULL_MESSAGE="$(date) - Node $NODE_IP: $MESSAGE"
  if [ -f "$CHAT_ID_FILE" ]; then
    CHAT_ID=$(cat "$CHAT_ID_FILE")
    curl -s -X POST "https://telegram.quilibrium.wiki/sendMessage" -d chat_id=$CHAT_ID -d text="$FULL_MESSAGE"
  else
    echo "$(date): Chat ID file not found. Notification not sent." | tee -a $LOG_FILE
  fi
}

# Check for updates if run interactively
if [ -t 0 ]; then
    check_for_updates

    echo "❕❕❕ Before updating your node, make sure to back up your keys ❕❕❕"
    echo ""
    read -p "❓ Did you make a backup of your keys and want to proceed with updating your node? (y/n): " USER_CONFIRMATION
    if [ "$USER_CONFIRMATION" != "y" ] && [ "$USER_CONFIRMATION" != "Y" ]; then
        echo "Operation cancelled by user."
        exit 0
    fi
fi

# Check if the script is run as root
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Check if the last update file exists, if not create it
if [ ! -f "$LAST_UPDATE_FILE" ]; then
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ" -d '2 hours ago')" > "$LAST_UPDATE_FILE"
fi

read -r LAST_UPDATE < "$LAST_UPDATE_FILE"
CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Check for new commits
NEW_COMMITS=$(curl -s "https://source.quilibrium.com/api/v4/projects/quilibrium%2Fceremonyclient/repository/commits?ref_name=release-cdn&since=$LAST_UPDATE")

if [ "$NEW_COMMITS" == "[]" ]; then
    echo "No new commits since the last update -  Exiting."
    exit 0
fi

# Update the last update time
echo "$CURRENT_TIME" > "$LAST_UPDATE_FILE"

# Stop node
$SUDO systemctl stop quil.service

# Create a temporary directory for cloning the repo
TEMP_DIR=$(mktemp -d)

# Clone the new Git repo into the temporary directory
git clone --branch release-cdn https://source.quilibrium.com/quilibrium/ceremonyclient.git "$TEMP_DIR" || { echo "Failed to clone repository"; rm -rf "$TEMP_DIR"; exit 1; }

# Remove old files except .config and tools folder
cd "$QUIL_DIR" || { echo "Failed to change directory"; exit 1; }
find . -maxdepth 1 ! -name '.config' ! -name 'tools' -exec rm -rf {} + > /dev/null 2>&1

# Move relevant files from the temporary directory to the Quil directory
mv "$TEMP_DIR"/* "$QUIL_DIR"/

# Clean up the temporary directory
rm -rf "$TEMP_DIR"

# Build the client so you can actually claim rewards... would be nice if this was prebuilt.
cd "$QUIL_DIR/client" || { echo "Failed to change directory"; exit 1; }
GOEXPERIMENT=arenas go build -o qclient main.go > /dev/null 2>&1

# Only keep relevant files (yes this is fugly, but hey what can you do...)
cd "$QUIL_DIR" || { echo "Failed to change directory"; exit 1; }
find node -type f -name "*$ARCHITECTURE*" -exec mv {} . \;
find . -maxdepth 1 ! -name "*$ARCHITECTURE*" ! -name 'client' ! -name 'tools' ! -name '.config' -exec rm -rf {} + > /dev/null 2>&1

# Get the binary filename
BINARY_NAME=$(ls "$QUIL_DIR" | grep "$ARCHITECTURE" | grep -v ".dgst")
FILENAME=$(ls node-*-linux-amd64 node-*-linux-arm64 2>/dev/null | head -n 1)
VERSION=$(echo "$FILENAME" | sed -n 's/^node-\([^-]*\)-linux-\(amd64\|arm64\)$/\1/p')

# Set execute permissions
chmod +x "$QUIL_DIR/$BINARY_NAME"

# Update the systemd service file with the new binary name
$SUDO sed -i "s|ExecStart=.*|ExecStart=$QUIL_DIR/$BINARY_NAME|g" $SERVICE_FILE

# Start the node
$SUDO systemctl daemon-reload
$SUDO systemctl start quil.service

send_notification "✔ Your node has been updated to version $VERSION and the service has been restarted"
if [ -t 0 ]; then
    echo "$(date): ✔ Your node has been updated to version $VERSION and the service has been restarted"
fi
