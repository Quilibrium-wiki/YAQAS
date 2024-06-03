#!/bin/bash

# Script version
SCRIPT_VERSION="1.0"

echo ""
echo "  ad8888888888ba"
echo " dP'         \`\"8b,"
echo " 8  ,aaa,       \"Y888a     ,aaaa,     ,aaa,  ,aa,"
echo " 8  8' \`8           \"88baadP\"\"\"\"YbaaadP\"\"\"\"YbdP\"\"Yb"
echo " 8  8   8              \"\"\"        \"\"\"      \"\"    8b"
echo " 8  8, ,8         ,aaaaaaaaaaaaaaaaaaaaaaaaddddd88P"
echo " 8  \`\"\"\"'       ,d8\"\""
echo " Yb,         ,ad8\"  Quilibrium Key Backup Script - Version $SCRIPT_VERSION"
echo "  \"Y8888888888P\"        https://Quilibrium.wiki"
echo ""
echo "This script generates a password-protected zip file of your Quilibrium keys and temporarily runs a web server,"
echo "allowing you to download the file to your local machine"
echo ""

# Function to check for newer script version
check_for_updates() {
    LATEST_VERSION=$(curl -s https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/backup.sh | grep 'SCRIPT_VERSION="' | head -1 | cut -d'"' -f2)
    if [ "$SCRIPT_VERSION" != "$LATEST_VERSION" ]; then
        echo "A newer version of this script is available (v$LATEST_VERSION)."
        read -p "Do you want to download the newer version? (y/n): " RESPONSE
        if [ "$RESPONSE" == "y" ] || [ "$RESPONSE" == "Y" ]; then
            curl -o backup.sh https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/backup.sh
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

# Define file paths
CONFIG_FILE="$HOME/quil/.config/config.yml"
KEYS_FILE="$HOME/quil/.config/keys.yml"
ZIP_FILE="$HOME/quil-backup.zip"

# Check if zip is installed, and install it if it's not
if ! command -v zip &> /dev/null; then
  echo "zip could not be found, installing it..."
  $SUDO apt-get update && $SUDO apt-get install -y zip > /dev/null 2>&1
fi

# Prompt for the password securely and show asterisks
echo -n "Enter password to protect the zip file: "
stty -echo
trap 'stty echo' EXIT
PASSWORD=""
while IFS= read -r -s -n1 char; do
  if [[ $char == $'\0' ]]; then
    break
  fi
  if [[ $char == $'\177' ]]; then
    if [[ -n $PASSWORD ]]; then
      PASSWORD=${PASSWORD%?}
      echo -ne "\b \b"
    fi
  else
    PASSWORD+="$char"
    echo -n '*'
  fi
done
stty echo
trap - EXIT
echo

# Create the zip file with password protection, without directory paths
zip -j -P "$PASSWORD" "$ZIP_FILE" "$CONFIG_FILE" "$KEYS_FILE" > /dev/null 2>&1

# Check if the zip was created successfully
if [[ $? -ne 0 ]]; then
  echo "❌ Failed to create the zip file."
  exit 1
fi

echo "✨ Zip file created successfully: $ZIP_FILE"

# Get the external IP address
IP_ADDRESS=$(curl -s -4 icanhazip.com)

# Function to find an available port
find_available_port() {
  while true; do
    PORT=$(shuf -i 1025-65535 -n 1)
    if ! lsof -i:$PORT > /dev/null; then
      echo $PORT
      return
    fi
  done
}

# Find a random available port above 1024
PORT=$(find_available_port)

# Variables to track if we opened the port
UFW_OPENED=false
FIREWALL_CMD_OPENED=false

# Check if the firewall is blocking the port and open it if necessary
if command -v ufw > /dev/null 2>&1; then
  # Check if ufw is enabled
  if $SUDO ufw status | grep -q "Status: active"; then
    # Check if the port is allowed
    if ! $SUDO ufw status | grep -q "$PORT/tcp"; then
      echo "Opening port $PORT in the firewall..."
      $SUDO ufw allow $PORT/tcp > /dev/null 2>&1
      UFW_OPENED=true
    fi
  fi
elif command -v firewall-cmd > /dev/null 2>&1; then
  # Check if firewalld is running
  if $SUDO firewall-cmd --state | grep -q "running"; then
    # Check if the port is allowed
    if ! $SUDO firewall-cmd --list-ports | grep -q "$PORT/tcp"; then
      echo "Opening port $PORT in the firewall..."
      $SUDO firewall-cmd --add-port=$PORT/tcp --permanent > /dev/null 2>&1
      $SUDO firewall-cmd --reload > /dev/null 2>&1
      FIREWALL_CMD_OPENED=true
    fi
  fi
else
  echo "No recognized firewall management tool found."
fi

# Function to clean up and exit
cleanup() {
  echo "Stopping the web server and cleaning up..."
  kill $SERVER_PID

  # Close the port if it was opened by this script
  if $UFW_OPENED; then
    echo "Closing port $PORT in the firewall..."
    $SUDO ufw delete allow $PORT/tcp > /dev/null 2>&1
  fi

  if $FIREWALL_CMD_OPENED; then
    echo "Closing port $PORT in the firewall..."
    $SUDO firewall-cmd --remove-port=$PORT/tcp --permanent > /dev/null 2>&1
    $SUDO firewall-cmd --reload > /dev/null 2>&1
  fi

  # Delete the zip file
  rm "$ZIP_FILE"
  echo "Zip file deleted: $ZIP_FILE"
  exit 0
}

# Trap SIGINT (Ctrl+C) and call cleanup function
trap "echo 'Press [Enter] to stop the web server and delete the zip file...'; trap - SIGINT" SIGINT

# Start a temporary web server
echo "Starting temporary web server on port $PORT..."
cd $HOME
python3 -m http.server $PORT > /dev/null 2>&1 &
SERVER_PID=$!

# Inform the user how to download the file
DOWNLOAD_URL="http://$IP_ADDRESS:$PORT/quil-backup.zip"
echo "⏩ You can download the zip file from: $DOWNLOAD_URL"

# Provide instructions for copying the URL
echo "Copy the URL above. Press [Enter] to stop the web server and delete the zip file..."

# Wait for the user to press Enter
read -p ""

# Call cleanup function
cleanup
