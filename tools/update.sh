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
SCRIPT_VERSION="1.5"

echo ""
echo "Quilibrium Update Script - Version $SCRIPT_VERSION"
echo "***** https://Quilibrium.wiki *****"
echo ""
echo "This script will update your node to the latest version."
echo ""

# Function to check for newer script version
check_for_updates() {
    LATEST_VERSION=$(curl -s https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/update.sh?token=$(date +%s) | grep 'SCRIPT_VERSION="' | head -1 | cut -d'"' -f2)
    if [ "$SCRIPT_VERSION" != "$LATEST_VERSION" ]; then
        echo "A newer version of this script is available (v$LATEST_VERSION)."
        read -p "Do you want to download the newer version? (y/n): " RESPONSE
        if [ "$RESPONSE" == "y" ] || [ "$RESPONSE" == "Y" ]; then
            curl -o update.sh https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/update.sh?token=$(date +%s)
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
LOG_FILE="$HOME/quil/tools/YAQAS.log"
CHAT_ID_FILE="$HOME/quil/tools/chat_id.txt"
CLIENT_DIR="$QUIL_DIR/client"

# Redirect stdout and stderr to both console and log file
exec > >(tee -a "$LOG_FILE") 2>&1

send_notification() {
  MESSAGE=$1
  NODE_IP=$(curl -s -4 icanhazip.com)
  FULL_MESSAGE="$(date) - Node $NODE_IP: $MESSAGE"
  if [ -f "$CHAT_ID_FILE" ];then
    CHAT_ID=$(cat "$CHAT_ID_FILE")
    curl -s -X POST "https://telegram.quilibrium.wiki/sendMessage" -d chat_id=$CHAT_ID -d text="$FULL_MESSAGE"
  else
    echo "$(date): Chat ID file not found. Notification not sent." | tee -a $LOG_FILE
  fi
}

# Function to compare versions
version_greater() {
    [ "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1" ]
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

# Get the current local version
if [ -f "$QUIL_DIR/node_version.txt" ]; then
    LOCAL_VERSION=$(cat "$QUIL_DIR/node_version.txt")
else
    LOCAL_VERSION="0.0.0"
fi

# Get the latest version from the releases URL
LATEST_VERSION=$(curl -s https://releases.quilibrium.com/release | grep -oP 'node-\K[0-9.]+(?=-linux-amd64)' | sort -V | tail -1)

# Compare versions
if version_greater "$LATEST_VERSION" "$LOCAL_VERSION"; then
    echo "New version available: $LATEST_VERSION (current version: $LOCAL_VERSION)"
	
	# Stop node
    $SUDO systemctl stop quil.service
	
    # Remove old files except hidden and tools folders
    cd "$QUIL_DIR" || { echo "Failed to change directory"; exit 1; }
    find . -maxdepth 1 ! -name '.*' ! -name 'tools' -exec rm -rf {} + > /dev/null 2>&1

    # Construct the filenames
    BASE_URL="https://releases.quilibrium.com"
    FILENAME="node-$LATEST_VERSION-$ARCHITECTURE"

    # Download binary and digest
    curl -O "$BASE_URL/$FILENAME"
    curl -O "$BASE_URL/$FILENAME.dgst"

    # Download available signature files
    AVAILABLE_SIGS=$(curl -s https://releases.quilibrium.com/release | grep -oP "$FILENAME.dgst.sig.\d+")
    for SIG in $AVAILABLE_SIGS; do
        curl -O "$BASE_URL/$SIG"
    done

    # Set execute permissions
    chmod +x "$FILENAME"

    # Update the systemd service file with the new binary name
    $SUDO sed -i "s|ExecStart=.*|ExecStart=$QUIL_DIR/$FILENAME|g" $SERVICE_FILE

    # Download qclient
    mkdir -p "$CLIENT_DIR"
    cd "$CLIENT_DIR" || { echo "Failed to change directory"; exit 1; }
    QCLIENT_VERSION=$(curl -s https://releases.quilibrium.com/qclient-release | grep -oP 'qclient-\K[0-9.]+(?=-linux-amd64)' | sort -V | tail -1)
    QCLIENT_FILE="qclient-$QCLIENT_VERSION-$ARCHITECTURE"
    curl -O "$BASE_URL/$QCLIENT_FILE"
    curl -O "$BASE_URL/$QCLIENT_FILE.dgst"

    # Download available qclient signature files
    AVAILABLE_CSIGS=$(curl -s https://releases.quilibrium.com/qclient-release  | grep -oP "$QCLIENT_FILE.dgst.sig.\d+")
    for CSIG in $AVAILABLE_CSIGS; do
        curl -O "$BASE_URL/$CSIG"
    done

    # Set execute permissions for qclient
    chmod +x "$QCLIENT_FILE"

    # Start the node
    $SUDO systemctl daemon-reload
    $SUDO systemctl start quil.service

    # Save the new version to local version file
    echo "$LATEST_VERSION" > "$QUIL_DIR/node_version.txt"

    send_notification "✔ Your node has been updated to version $LATEST_VERSION and the service has been restarted"
    if [ -t 0 ]; then
        echo "$(date): ✔ Your node has been updated to version $LATEST_VERSION and the service has been restarted"
    fi
else
    echo "Your node is already up to date (version $LOCAL_VERSION). No update needed."
fi
