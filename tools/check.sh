#!/bin/bash

# Script version
SCRIPT_VERSION="1.0"

cat << "EOF"
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣷⣶⣴⣾⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣀⣤⣤⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⣤⣤⣄⠀⠀⠀⠀
⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀
⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀
⢀⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠈⢻⣿⣿⣿⣿⣿⣿⣿
⢿⣿⣿⣿⣿⣿⣿⣿⡿⠻⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿
⢈⣿⣿⣿⣿⣿⣿⣯⡀⠀⠈⠻⣿⣿⣿⠟⠁⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⡁
⣾⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠈⠛⠁⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁
⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀
⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀
⠀⠀⠀⠀⠉⠛⠛⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠛⠛⠉⠁⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⠿⢿⡻⠿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF

echo ""
echo "Quilibrium Checker Script - Version $SCRIPT_VERSION"
echo "***** https://Quilibrium.wiki *****"
echo ""
echo "This script will check if your node is running properly."
echo "It does so by querying the official bootstrap nodes once an hour to check if they can see your node."
echo "Make sure your node has been running for at least 30 minutes before running this script, or you will get false negatives."
echo ""
echo "Note: There is no need to run this script manually. You can configure YAQAS to run this script background automatically."
echo "Simply restart the deployment script (deploy.sh), select option 2 and enable node monitoring."
echo ""

# Function to check for newer script version
check_for_updates() {
    LATEST_VERSION=$(curl -s https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/check.sh | grep 'SCRIPT_VERSION="' | head -1 | cut -d'"' -f2)
    if [ "$SCRIPT_VERSION" != "$LATEST_VERSION" ]; then
        echo "A newer version of this script is available (v$LATEST_VERSION)."
        read -p "Do you want to download the newer version? (y/n): " RESPONSE
        if [ "$RESPONSE" == "y" ] || [ "$RESPONSE" == "Y" ]; then
            curl -o check.sh https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/check.sh
            echo "New version downloaded. Please run the script again."
            exit 0
        fi
    fi
}

# Check for updates
check_for_updates

# Check if the script is run as root
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

LOG_FILE="$HOME/quil/tools/YAQAS.log"
CHAT_ID_FILE="$HOME/quil/tools/chat_id.txt"

# Function to restart the quil service
restart_service() {
  $SUDO systemctl restart quil
  NODE_IP=$(curl -s -4 icanhazip.com)
  echo "$(date): Quil service restarted" | tee -a $LOG_FILE
  send_notification "$(date) - Node $NODE_IP: Quil service restarted"
}

# Function to send a notification
send_notification() {
  MESSAGE=$1
  if [ -f "$CHAT_ID_FILE" ]; then
    CHAT_ID=$(cat "$CHAT_ID_FILE")
    curl -s -X POST "https://telegram.quilibrium.wiki/sendMessage" -d chat_id=$CHAT_ID -d text="$MESSAGE"
  else
    echo "$(date): Chat ID file not found. Notification not sent." | tee -a $LOG_FILE
  fi
}

# Download the config file
curl -s https://source.quilibrium.com/quilibrium/ceremonyclient/-/raw/main/node/config/config.go?ref_type=heads -o config.go

# Extract lines with BootstrapPeers containing 'quilibrium.com' and extract the ID
peer_ids=$(grep -oP '"/dns/[^"]*quilibrium\.com[^"]*p2p/\K[^"]+' config.go)

# Remove the go file, we don't need it anymore
rm config.go

# Convert each peer ID using 'base58 -d | base64'
declare -A peer_id_map
for peer_id in $peer_ids; do
  converted_id=$(echo "$peer_id" | base58 -d | base64)
  peer_id_map["$converted_id"]="$peer_id"
done

# Extract GRPC port from the config.yml file
GRPC_PORT=$(grep -oP 'listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/\K\d+' "$HOME/quil/.config/config.yml")

# Check if we are connected to at least one of these peers
network_info=$(grpcurl -plaintext 127.0.0.1:"$GRPC_PORT" quilibrium.node.node.pb.NodeService.GetNetworkInfo)

# Retrieve the node's IPv4 address
NODE_IP=$(curl -s -4 icanhazip.com)

# Check connection status and inform the user
connected=false
for converted_id in "${!peer_id_map[@]}"; do
  if echo "$network_info" | grep -q "$converted_id"; then
    connected=true
    echo "$(date): Connected to official bootstrap peer with ID: ${peer_id_map[$converted_id]}" | tee -a $LOG_FILE
  fi
done

if ! $connected; then
  if [ -t 0 ]; then
    # Running interactively
    echo "$(date): Not connected to any official bootstrap peer" | tee -a $LOG_FILE
    while true; do
      read -p "Your node is orphaned, restarting your node might fix this. Do you want to restart your node? (y/n): " yn
      case $yn in
          [Yy]* ) restart_service; break;;
          [Nn]* ) echo "Quil service not restarted." | tee -a $LOG_FILE
                  break;;
          * ) echo "Please answer yes or no.";;
      esac
    done
  else
    # Running as cron job
    send_notification "$(date) - Node $NODE_IP: Not connected to any official bootstrap peer. Restarting node..."
	restart_service
  fi
fi
