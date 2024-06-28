#!/bin/bash

# Script version
SCRIPT_VERSION="1.3"

cat << "EOF"
                                  %#########
                         #############################
                   ########################################
                ##############################################
            &#####################%        %######################
          #################                         #################
        ###############                                 ###############
      #############                                        ##############
    #############                                             ############
   ############                                                 ############
  ###########                     ##########                     ###########
 ###########                    ##############                     ###########
###########                     ##############                      ##########
##########                      ##############                       ##########
##########                        ##########                         ##########
#########&                                                           ##########
#########                                                            #########
#########&                   #######      #######                    ##########
##########                &#########################                 ##########
##########              ##############% ##############              ##########
%##########          &##############      ###############           ##########
 ###########       ###############           ##############%       ###########
  ###########&       ##########                ###############       ########
   ############         #####                     ##############%       ####
     ############                                   ###############
      ##############                                   ##############%
        ###############                                  ###############
          #################&                                ##############%
             #########################&&&#############        ###############
                ########################################%        ############
                    #######################################        ########
                         #############################                ##
EOF
echo "									 YAQAS"
echo "                   Yet Another Quilibrium Auto-install Script"
echo "					              Version $SCRIPT_VERSION"
echo "							https://Quilibrium.wiki"
echo ""

# Function to check for newer script version
check_for_updates() {
    LATEST_VERSION=$(curl -s https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/deploy.sh?token=$(date +%s) | grep 'SCRIPT_VERSION="' | head -1 | cut -d'"' -f2)
    if [ "$SCRIPT_VERSION" != "$LATEST_VERSION" ]; then
        echo "A newer version of this script is available (v$LATEST_VERSION)."
        read -p "Do you want to download the newer version? (y/n): " RESPONSE
        if [ "$RESPONSE" == "y" ] || [ "$RESPONSE" == "Y" ]; then
            curl -o deploy.sh https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/deploy.sh?token=$(date +%s)
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

QUIL_DIR="$HOME/quil"
CLIENT_DIR="$QUIL_DIR/client"
TOOLS_DIR="$QUIL_DIR/tools"
CPU_LIMIT=""
TOOLS_URLS=(
    "https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/update.sh"
    "https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/clean.sh"
    "https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/backup.sh"
    "https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/claim.sh"
    "https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/check.sh"
)
ARCHITECTURE=$(uname -m)
ARCHITECTURE=${ARCHITECTURE/x86_64/linux-amd64} # Map x86_64 to linux-amd64
ARCHITECTURE=${ARCHITECTURE/aarch64/linux-arm64} # Map aarch64 to linux-arm64
LOG_FILE="$HOME/quil/tools/YAQAS.log"
CHAT_ID_FILE="$HOME/quil/tools/chat_id.txt"
NODE_IP=$(curl -s -4 icanhazip.com)

# Function to check if a port is in use
check_port_in_use() {
    local port=$1
    if lsof -i -P -n | grep -q ":$port "; then
        return 0
    else
        return 1
    fi
}

# Function to open a port in the firewall (if present AND enabled)
open_firewall_port() {
    local port=$1
    local protocol=$2
    if command -v ufw > /dev/null; then
        if $SUDO ufw status | grep -q "Status: active"; then
            $SUDO ufw allow $port/$protocol > /dev/null 2>&1
        fi
    fi

    if command -v firewall-cmd > /dev/null; then
        if $SUDO firewall-cmd --state | grep -q "running"; then
            $SUDO firewall-cmd --permanent --add-port=$port/$protocol > /dev/null 2>&1
            $SUDO firewall-cmd --reload > /dev/null 2>&1
        fi
    fi
}

# Function to close a port in the firewall (if present AND enabled)
close_firewall_port() {
    local port=$1
    local protocol=$2
    if command -v ufw > /dev/null; then
        if $SUDO ufw status | grep -q "Status: active"; then
            $SUDO ufw delete allow $port/$protocol > /dev/null 2>&1
        fi
    fi

    if command -v firewall-cmd > /dev/null; then
        if $SUDO firewall-cmd --state | grep -q "running"; then
            $SUDO firewall-cmd --permanent --remove-port=$port/$protocol > /dev/null 2>&1
            $SUDO firewall-cmd --reload > /dev/null 2>&1
        fi
    fi
}

# Function to read user input with validation
read_input() {
    local prompt=$1
    local default=$2
    local input
    while true; do
        read -p "$prompt" input
        input=${input:-$default}
        if [[ $input =~ ^[yYnN]$ ]]; then
            echo $input
            return
        else
            echo "❌ Invalid input. Please enter 'y' or 'n'."
        fi
    done
}

# Function to handle SIGINT (Ctrl+C) to allow copy/paste
trap_ctrl_c() {
    echo ""
}

trap trap_ctrl_c SIGINT

# Function to Enable Automatic Updates
enable_auto_updates() {
    AUTO_UPDATES=$(read_input "❓ Do you want to enable automatic updates? (y/n): " "n")
    if [ "$AUTO_UPDATES" == "y" ] || [ "$AUTO_UPDATES" == "Y" ]; then
        RANDOM_MINUTE=$((RANDOM % 60))
        (crontab -l 2>/dev/null; echo "$RANDOM_MINUTE */2 * * * bash -lc \"$HOME/quil/tools/update.sh\"") | crontab -
        echo "⏳ Scheduled automatic updates occur every 2 hours at a random minute ($RANDOM_MINUTE) to distribute the load on the official repository."
    fi
}

configure_automatic_updates() {
    if crontab -l | grep -q 'update.sh'; then
        read -p "Automatic updates are currently enabled. Do you want to disable them? (y/n): " disable_updates
        if [ "$disable_updates" == "y" ] || [ "$disable_updates" == "Y" ]; then
            crontab -l | grep -v 'update.sh' | crontab -
            echo "Automatic updates have been disabled."
        fi
    else
        enable_auto_updates
    fi
}

# Function to Enable Node Monitoring
enable_node_monitoring() {
    NODE_MONITORING=$(read_input "❓ Do you want to enable node monitoring? (y/n): " "n")
    if [ "$NODE_MONITORING" == "y" ] || [ "$NODE_MONITORING" == "Y" ]; then
        RANDOM_MINUTE=$((RANDOM % 60))
        (crontab -l 2>/dev/null; echo "$RANDOM_MINUTE * * * * bash -lc \"$HOME/quil/tools/check.sh\"") | crontab -
        echo "⏳ Scheduled node monitoring occurs every hour at a random minute ($RANDOM_MINUTE) to distribute the load on the official bootstrap peers."
    fi
}

configure_node_monitoring() {
    if crontab -l | grep -q 'check.sh'; then
        read -p "Node monitoring is currently enabled. Do you want to disable it? (y/n): " disable_monitoring
        if [ "$disable_monitoring" == "y" ] || [ "$disable_monitoring" == "Y" ]; then
            crontab -l | grep -v 'check.sh' | crontab -
            echo "Node monitoring has been disabled."
        fi
    else
        enable_node_monitoring
    fi
}

# Function to Enable Telegram Notifications
enable_telegram_notifications() {
    TELEGRAM_NOTIFICATIONS=$(read_input "❓ Do you want to enable Telegram notifications? (y/n): " "n")
    if [ "$TELEGRAM_NOTIFICATIONS" == "y" ] || [ "$TELEGRAM_NOTIFICATIONS" == "Y" ]; then

        # Function to send a notification
        send_notification() {
            MESSAGE=$1
            if [ -f "$CHAT_ID_FILE" ]; then
                CHAT_ID=$(cat "$CHAT_ID_FILE")
                curl -s -X POST "https://telegram.quilibrium.wiki/sendMessage" -d chat_id=$CHAT_ID -d text="$MESSAGE" > /dev/null 2>&1
            else
                echo "$(date): Chat ID file not found. Notification not sent." | tee -a $LOG_FILE
            fi
        }

        # Prompt user for chat ID if not already stored
        if [ ! -f "$CHAT_ID_FILE" ]; then
            echo ""
            echo "⏩ Open the Telegram app and search for the \"@QuilibriumWikiBot\" bot or use this direct link: https://t.me/QuilibriumWikiBot"
            echo "⏩ Start a conversation with the bot and use the \"/start\" command to get your Chat ID."
            echo ""
            read -p "Please enter your Telegram Chat ID: " CHAT_ID
            echo "$CHAT_ID" > "$CHAT_ID_FILE"
            echo "Chat ID stored in $CHAT_ID_FILE"
            send_notification "$(date): Node $NODE_IP: Bot setup complete. Node notifications will be sent to this chat."
        fi
    fi
}

configure_telegram_notifications() {

    if [ -f "$CHAT_ID_FILE" ]; then
        read -p "Telegram notifications are currently enabled. Do you want to disable them? (y/n): " disable_notifications
        if [ "$disable_notifications" == "y" ] || [ "$disable_notifications" == "Y" ]; then
            rm -f "$CHAT_ID_FILE"
            echo "Telegram notifications have been disabled."
        fi
    else
        enable_telegram_notifications
    fi
}

# Function to display the menu and handle user selection
display_menu_blank() {
    echo "Please choose an option:"
    select opt in "Deploy new node" "Restore node from backup" "Exit"; do
        case $REPLY in
            1) return 1 ;;
            2) return 2 ;;
            3) exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
    done
}

display_menu_existing() {
    echo "Please choose an option:"
    select opt in "Reconfigure node" "Backup keys" "Update node to latest version" "Claim rewards" "Clean store, in case your disk is running full" "Check if your node is running correctly" "Configure Automatic Updates" "Configure Node Monitoring" "Configure Telegram Notifications" "Exit this menu"; do
        case $REPLY in
            1) echo "Reconfiguring node..."; return 1 ;;
            2) echo "Backing up keys..."; bash "$TOOLS_DIR/backup.sh"; exit 0 ;;
            3) echo "Updating node..."; bash "$TOOLS_DIR/update.sh"; exit 0 ;;
            4) echo "Claiming rewards..."; bash "$TOOLS_DIR/claim.sh"; exit 0 ;;
            5) echo "Cleaning store..."; bash "$TOOLS_DIR/clean.sh"; exit 0 ;;
			6) echo "Checking node..."; bash "$TOOLS_DIR/check.sh"; exit 0 ;;
            7) echo "Configuring automatic updates..."; configure_automatic_updates ;;
            8) echo "Configuring node monitoring..."; configure_node_monitoring ;;
            9) echo "Configuring Telegram notifications..."; configure_telegram_notifications ;;
            10) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
    done
}

# Function to serve a temporary web page for file upload
serve_web_page() {
    local port=$1
    local tmp_dir=$(mktemp -d)
    local upload_dir="$tmp_dir/upload"
    mkdir -p "$upload_dir"

    cat << EOF > "$tmp_dir/index.html"
<html>
  <body>
    <h2>Upload Backup</h2>
	<p>The zip file should *only* contain your keys.yml and config.yml files, nothing else!</p>
    <form action="upload" method="post" enctype="multipart/form-data">
      <input type="file" name="file" accept=".zip" />
      <input type="submit" value="Upload" />
    </form>
  </body>
</html>
EOF

    cat << EOF > "$tmp_dir/upload_server.py"
import os
from http.server import SimpleHTTPRequestHandler, HTTPServer
import urllib.parse

UPLOAD_DIR = "$upload_dir"

class CustomHTTPRequestHandler(SimpleHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        boundary = self.headers['Content-Type'].split("=")[1].encode()
        body = self.rfile.read(content_length)
        parts = body.split(b"--" + boundary)
        for part in parts:
            if b"Content-Disposition: form-data;" in part:
                header, file_data = part.split(b"\r\n\r\n", 1)
                if b"filename=" in header:
                    file_name = header.split(b"filename=")[1].split(b"\r\n")[0].strip(b'"')
                    if file_name.decode().endswith('.zip'):
                        with open(os.path.join(UPLOAD_DIR, file_name.decode()), 'wb') as f:
                            f.write(file_data.rstrip(b"\r\n--"))
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(b'File uploaded successfully')

    def do_GET(self):
        if self.path == '/':
            self.path = '/index.html'
        return super().do_GET()

if __name__ == '__main__':
    port = $port
    os.chdir('$tmp_dir')
    server = HTTPServer(('0.0.0.0', port), CustomHTTPRequestHandler)
    with open('$tmp_dir/upload_server.pid', 'w') as f:
        f.write(str(os.getpid()))
    server.serve_forever()
EOF

    nohup python3 "$tmp_dir/upload_server.py" > "$tmp_dir/server.log" 2>&1 &
    echo $! > "$tmp_dir/upload_server.pid"
    echo "$tmp_dir"
}

# Function to read the password with asterisks
read_password() {
    local prompt=$1
    local password=""
    local char

    echo -n "$prompt"
    while IFS= read -r -s -n1 char; do
        if [[ $char == $'\0' ]]; then
            break
        elif [[ $char == $'\177' ]]; then
            if [ -n "$password" ]; then
                password="${password%?}"
                echo -ne "\b \b"
            fi
        else
            password+="$char"
            echo -n '*'
        fi
    done
    echo
    echo "$password"
}

# Check for existing Quilibrium node install and if so offer reconfiguration options
if [ -d "$HOME/quil" ]; then
    if [ -f "/etc/systemd/system/quil.service" ]; then
        echo "✅ Existing Quilibrium node detected."

        # Display the menu
        display_menu_existing
        if [ $? -ne 1 ]; then
            exit 0
        fi

        # Get the current CUSTOM_PORT, gRPC, and REST settings from the config.yml
        CURRENT_PORT=$(grep -oP 'listenMultiaddr: /ip4/0.0.0.0/udp/\K\d+' "$HOME/quil/.config/config.yml")
        GRPC_PORT=$(grep -oP 'listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/\K\d+' "$HOME/quil/.config/config.yml")
        REST_PORT=$(grep -oP 'listenRESTMultiaddr: /ip4/127.0.0.1/tcp/\K\d+' "$HOME/quil/.config/config.yml")

        echo "Current CUSTOM_PORT is $CURRENT_PORT"
        [ -n "$GRPC_PORT" ] && echo "Current gRPC port is $GRPC_PORT" || echo "gRPC is disabled"
        [ -n "$REST_PORT" ] && echo "Current REST port is $REST_PORT" || echo "REST is disabled"

        RESTART_REQUIRED=false
        CUSTOM_PORT_CHANGED=false

        # Offer reconfiguration options
        RECONFIG_PORT=$(read_input "❓ Do you want to reconfigure the CUSTOM_PORT? (y/n): " "n")
        if [ "$RECONFIG_PORT" == "y" ] || [ "$RECONFIG_PORT" == "Y" ]; then
            CUSTOM_PORT=8336
            while true; do
                read -p "⏩ Enter the custom port number (1025-65535): " INPUT_PORT
                if [[ $INPUT_PORT -ge 1025 && $INPUT_PORT -le 65535 ]]; then
                    if check_port_in_use $INPUT_PORT; then
                        echo "❌ Port $INPUT_PORT is already in use. Please choose another port."
                    else
                        CUSTOM_PORT=$INPUT_PORT
                        CUSTOM_PORT_CHANGED=true
                        break
                    fi
                else
                    echo "❌ Invalid port number. Please enter a number between 1025 and 65535."
                fi
            done
            if [ ! -z "$CURRENT_PORT" ] && [ "$CUSTOM_PORT_CHANGED" == true ]; then
                close_firewall_port $CURRENT_PORT "udp"
                open_firewall_port $CUSTOM_PORT "udp"
                RESTART_REQUIRED=true
            fi
        fi

        GRPC_RECONFIG=false
        GRPC_RECONFIG_CHOICE=$(read_input "❓ gRPC is currently $( [ -n "$GRPC_PORT" ] && echo "enabled on port $GRPC_PORT" || echo "disabled" ). Do you want to $( [ -n "$GRPC_PORT" ] && echo "reconfigure it?" || echo "enable it?" ) (y/n): " "n")
        if [ "$GRPC_RECONFIG_CHOICE" == "y" ] || [ "$GRPC_RECONFIG_CHOICE" == "Y" ]; then
            GRPC_RECONFIG=true
        fi

        if [ "$GRPC_RECONFIG" == true ]; then
            while true; do
                read -p "⏩ Enter the gRPC port number (1025-65535, default 8337): " INPUT_GRPC_PORT
                if [[ $INPUT_GRPC_PORT -ge 1025 && $INPUT_GRPC_PORT -le 65535 && $INPUT_GRPC_PORT != $CUSTOM_PORT ]]; then
                    if check_port_in_use $INPUT_GRPC_PORT; then
                        echo "❌ Port $INPUT_GRPC_PORT is already in use. Please choose another port."
                    else
                        GRPC_PORT=$INPUT_GRPC_PORT
                        RESTART_REQUIRED=true
                        break
                    fi
                else
                    echo "❌ Invalid port number or port number conflicts with the application port. Please enter another port."
                fi
            done
        fi

        REST_RECONFIG=false
        REST_RECONFIG_CHOICE=$(read_input "❓ REST is currently $( [ -n "$REST_PORT" ] && echo "enabled on port $REST_PORT" || echo "disabled" ). Do you want to $( [ -n "$REST_PORT" ] && echo "reconfigure it?" || echo "enable it?" ) (y/n): " "n")
        if [ "$REST_RECONFIG_CHOICE" == "y" ] || [ "$REST_RECONFIG_CHOICE" == "Y" ]; then
            REST_RECONFIG=true
        fi

        if [ "$REST_RECONFIG" == true ]; then
            while true; do
                read -p "⏩ Enter the REST port number (1025-65535, default 8338): " INPUT_REST_PORT
                if [[ $INPUT_REST_PORT -ge 1025 && $INPUT_REST_PORT -le 65535 && $INPUT_REST_PORT != $CUSTOM_PORT && $INPUT_REST_PORT != $GRPC_PORT ]]; then
                    if check_port_in_use $INPUT_REST_PORT; then
                        echo "❌ Port $INPUT_REST_PORT is already in use. Please choose another port."
                    else
                        REST_PORT=$INPUT_REST_PORT
                        RESTART_REQUIRED=true
                        break
                    fi
                else
                    echo "❌ Invalid port number or port number conflicts with the application or gRPC port. Please enter another port."
                fi
            done
        fi

        CPU_RECONFIG_CHOICE=$(read_input "❓ Do you want to change the CPU usage limit? (y/n): " "n")
        if [ "$CPU_RECONFIG_CHOICE" == "y" ] || [ "$CPU_RECONFIG_CHOICE" == "Y" ]; then
            read -p "⏩ Enter the CPU limit as a percentage (0-100): " CPU_PERCENT
            if [[ $CPU_PERCENT -ge 0 && $CPU_PERCENT -le 100 ]]; then
                TOTAL_CORES=$(nproc)
                CPU_QUOTA=$((CPU_PERCENT * TOTAL_CORES))
                CPU_LIMIT="CPUQuota=${CPU_QUOTA}%"
                RESTART_REQUIRED=true
            else
                echo "❌ Invalid percentage. Continuing without CPU limit change."
            fi
        fi

        if [ "$CUSTOM_PORT_CHANGED" == true ] || [ "$GRPC_RECONFIG" == true ] || [ "$REST_RECONFIG" == true ] || [ "$CPU_RECONFIG_CHOICE" == "y" ]; then
            echo "Applying new settings..."

            # Update config.yml with the custom port, gRPC port, and REST port if necessary
            if [ "$CUSTOM_PORT_CHANGED" == true ]; then
                echo "Updating config.yml with custom port $CUSTOM_PORT..."
                sed -i "s|/ip4/0.0.0.0/udp/$CURRENT_PORT/quic|/ip4/0.0.0.0/udp/$CUSTOM_PORT/quic|g" "$HOME/quil/.config/config.yml"
            fi

            if [ "$GRPC_RECONFIG" == true ]; then
                echo "Updating config.yml with gRPC port $GRPC_PORT..."
                if grep -q 'listenGrpcMultiaddr:' "$HOME/quil/.config/config.yml"; then
                    sed -i "s|listenGrpcMultiaddr: .*$|listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/$GRPC_PORT|" "$HOME/quil/.config/config.yml"
                else
                    echo "listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/$GRPC_PORT" >> "$HOME/quil/.config/config.yml"
                fi
            fi

            if [ "$REST_RECONFIG" == true ]; then
                echo "Updating config.yml with REST port $REST_PORT..."
                if grep -q 'listenRESTMultiaddr:' "$HOME/quil/.config/config.yml"; then
                    sed -i "s|listenRESTMultiaddr: .*$|listenRESTMultiaddr: /ip4/127.0.0.1/tcp/$REST_PORT|" "$HOME/quil/.config/config.yml"
                else
                    echo "listenRESTMultiaddr: /ip4/127.0.0.1/tcp/$REST_PORT" >> "$HOME/quil/.config/config.yml"
                fi
            fi

            # Update systemd service file if CPU limit is changed
            if [ "$CPU_RECONFIG_CHOICE" == "y" ]; then
                echo "Updating systemd service file with new CPU limit..."
                
                SERVICE_FILE="/etc/systemd/system/quil.service"
                if grep -q 'CPUQuota=' "$SERVICE_FILE"; then
                    # If CPUQuota= is present, update value
                    $SUDO sed -i "s|CPUQuota=.*$|CPUQuota=${CPU_QUOTA}us|" "$SERVICE_FILE"
                else
                    # If CPUQuota= is not present, add CPUQuota in [Service] block.
                    $SUDO sed -i "/\[Service\]/a CPUQuota=${CPU_QUOTA}us" "$SERVICE_FILE"
                fi
                
                $SUDO systemctl daemon-reload
            fi
        fi

        if [ "$RESTART_REQUIRED" == true ]; then
            echo ""
            echo "⏳ Restarting node with new configurations..."
            $SUDO systemctl restart quil.service
            echo "✨ Reconfiguration complete! Your Quilibrium node is now up and running with the new settings!"
        else
            echo ""
            echo "✨ No changes made. Your Quilibrium node continues to run with the current settings."
        fi
        exit 0
    else
        echo "❌ The directory $HOME/quil already exists but the quil.service file is missing. This is an unsupported configuration. To avoid overwriting existing files, the installation will now exit."
        exit 1
    fi
fi

# If neither the directory nor the service file exists, assume there is no existing node installed.

# Display the menu for new deployment or restore from backup
display_menu_blank
CHOICE=$?
if [ $CHOICE -eq 2 ]; then
    echo "✨ Restoring node from backup..."
   
    # Find a free port above 1024
    while true; do
        WEB_PORT=$((RANDOM % 64511 + 1024))
        if ! check_port_in_use $WEB_PORT; then
            break
        fi
    done
    
    echo "⏳ Serving temporary web page..."
    open_firewall_port $WEB_PORT "tcp"
    
    TMP_DIR=$(serve_web_page $WEB_PORT)
    SERVER_PID=$(cat "$TMP_DIR/upload_server.pid")
    WAN_IP=$(curl -s -4 icanhazip.com)
    
    echo "⏩ Temporary web server started. Please upload your backup zip file."
    echo "Visit: http://$WAN_IP:$WEB_PORT"
    read -p "Press [Enter] once the file is uploaded..."
    
    BACKUP_PASSWORD=$(read_password "⏩ If applicable, please enter the password for the backup zip file: ")
    
    UPLOADED_FILE=$(find "$TMP_DIR/upload" -name "*.zip" -print -quit)
    
    # Close the temporary web server
    kill $SERVER_PID
    
    # Close the temporary firewall port
    close_firewall_port $WEB_PORT "tcp"
    
    # Clean up zipfile
    if [ ! -z "$UPLOADED_FILE" ]; then
        unzip -P "$BACKUP_PASSWORD" "$UPLOADED_FILE" -d /tmp || { echo "❌ Failed to unzip the backup file. Exiting."; exit 1; }
    else
        echo "❌ No backup file found. Exiting."
        exit 1
    fi
    
    if [ ! -f /tmp/config.yml ] || [ ! -f /tmp/keys.yml ]; then
        echo "❌ Keys.yml or Config.yml missing in zipfile. Exiting."
        exit 1
    fi
    
    # Extract the CUSTOM_PORT from config.yml and open it in the firewall if necessary
    CUSTOM_PORT=$(grep -oP 'listenMultiaddr: /ip4/0.0.0.0/udp/\K\d+' /tmp/config.yml)
    if [ ! -z "$CUSTOM_PORT" ]; then
        open_firewall_port $CUSTOM_PORT "udp"
    fi
    
    echo "🔄 Continuing with new node deployment..."

fi

echo ""
echo "‍✈️ Step 1: Installing prerequisites..."
$SUDO apt-get update > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to update package list. Exiting."
    exit 1
fi

$SUDO apt-get install -y jq cron wget unzip zip openssh-client sshpass lsof base58 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to install prerequisites. Exiting."
    exit 1
fi

echo "✅ All prerequisites installed successfully!"

echo ""
echo "❓ Step 2: Check user preferences..."
echo ""
echo "❕ Note: Limiting CPU usage reduces rewards, but might be necessary on some VPS hosts to avoid being banned for CPU abuse."

# Ask the user if they want to limit CPU usage
LIMIT_CPU=$(read_input "❓ Do you want to limit CPU usage? (y/n): " "n")
if [ "$LIMIT_CPU" == "y" ] || [ "$LIMIT_CPU" == "Y" ]; then
    read -p "⏩ Enter the CPU limit as a percentage (0-100): " CPU_PERCENT
    if [[ $CPU_PERCENT -ge 0 && $CPU_PERCENT -le 100 ]]; then
        TOTAL_CORES=$(nproc)
        CPU_QUOTA=$((CPU_PERCENT * TOTAL_CORES))
        CPU_LIMIT="CPUQuota=${CPU_QUOTA}%"
    else
        echo "❌ Invalid percentage. Continuing without CPU limit."
    fi
fi

# Calculate GOMAXPROCS based on the system's RAM
calculate_gomaxprocs() {
    local ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    local cpu_cores=$(nproc)
    local gomaxprocs=$((ram_gb / 2))
    if [ $gomaxprocs -gt $cpu_cores ]; then
        gomaxprocs=$cpu_cores
    fi
    gomaxprocs=$((gomaxprocs + 1))
    echo $gomaxprocs
}

GOMAXPROCS=$(calculate_gomaxprocs)

echo "✅ GOMAXPROCS has been set to $GOMAXPROCS based on your server's resources."

if [ "$CHOICE" -eq 1 ]; then
# Variables to track if custom ports or services are enabled
CUSTOM_PORT_ENABLED=false
GRPC_ENABLED=false
REST_ENABLED=false

# Ask the user for a custom port and check if it is in use
CUSTOM_PORT=8336
CUSTOM_PORT_CHOICE=$(read_input "❓ Do you want to use a custom port? (y/n): " "n")
if [ "$CUSTOM_PORT_CHOICE" == "y" ] || [ "$CUSTOM_PORT_CHOICE" == "Y" ]; then
    CUSTOM_PORT_ENABLED=true
    while true; do
        read -p "⏩ Enter the custom port number (1025-65535): " INPUT_PORT
        if [[ $INPUT_PORT -ge 1025 && $INPUT_PORT -le 65535 ]]; then
            if check_port_in_use $INPUT_PORT; then
                echo "❌ Port $INPUT_PORT is already in use. Please choose another port."
            else
                CUSTOM_PORT=$INPUT_PORT
                break
            fi
        else
            echo "❌ Invalid port number. Please enter a number between 1025 and 65535."
        fi
    done
fi
open_firewall_port $CUSTOM_PORT "udp"

# Ask the user if they want to enable the gRPC interface
ENABLE_GRPC=false
GRPC_PORT=8337
ENABLE_GRPC_CHOICE=$(read_input "❓ Do you want to enable the gRPC interface? (y/n): " "n")
if [ "$ENABLE_GRPC_CHOICE" == "y" ] || [ "$ENABLE_GRPC_CHOICE" == "Y" ]; then
    ENABLE_GRPC=true
    GRPC_ENABLED=true
    while true; do
        read -p "⏩ Enter the gRPC port number (1025-65535, default 8337): " INPUT_GRPC_PORT
        if [[ $INPUT_GRPC_PORT -ge 1025 && $INPUT_GRPC_PORT -le 65535 && $INPUT_GRPC_PORT != $CUSTOM_PORT ]]; then
            if check_port_in_use $INPUT_GRPC_PORT; then
                echo "❌ Port $INPUT_GRPC_PORT is already in use. Please choose another port."
            else
                GRPC_PORT=$INPUT_GRPC_PORT
                break
            fi
        else
            echo "❌ Invalid port number or port number conflicts with the application port. Please enter another port."
        fi
    done
fi

# Ask the user if they want to enable the REST interface
ENABLE_REST=false
REST_PORT=8338
ENABLE_REST_CHOICE=$(read_input "❓ Do you want to enable the REST interface? (y/n): " "n")
if [ "$ENABLE_REST_CHOICE" == "y" ] || [ "$ENABLE_REST_CHOICE" == "Y" ]; then
    ENABLE_REST=true
    REST_ENABLED=true
    while true; do
        read -p "⏩ Enter the REST port number (1025-65535, default 8338): " INPUT_REST_PORT
        if [[ $INPUT_REST_PORT -ge 1025 && $INPUT_REST_PORT -le 65535 && $INPUT_REST_PORT != $CUSTOM_PORT && $INPUT_REST_PORT != $GRPC_PORT ]]; then
            if check_port_in_use $INPUT_REST_PORT ]; then
                echo "❌ Port $INPUT_REST_PORT is already in use. Please choose another port."
            else
                REST_PORT=$INPUT_REST_PORT
                break
            fi
        else
            echo "❌ Invalid port number or port number conflicts with the application or gRPC port. Please enter another port."
        fi
    done
fi
fi

echo ""
echo "⏳ Step 3: Downloading latest Quilibrium release..."

mkdir -p "$QUIL_DIR"
cd "$QUIL_DIR" || { echo "Failed to change directory"; exit 1; }

# Get the latest version from the releases URL
LATEST_VERSION=$(curl -s https://releases.quilibrium.com/release | grep -oP 'node-\K[0-9.]+(?=-linux-amd64)' | sort -V | tail -1)

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

# Download qclient
mkdir -p "$CLIENT_DIR"
cd "$CLIENT_DIR" || { echo "Failed to change directory"; exit 1; }
QCLIENT_VERSION=$(curl -s https://releases.quilibrium.com/qclient-release | grep -oP 'qclient-\K[0-9.]+(?=-linux-amd64)' | sort -V | tail -1)
QCLIENT_FILE="qclient-$QCLIENT_VERSION-$ARCHITECTURE"
curl -O "$BASE_URL/$QCLIENT_FILE"

# Set execute permissions for qclient
chmod +x "$QCLIENT_FILE"

# grpcurl binaries - hardcoded because I got lazy
URL_AMD64="https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_linux_amd64.deb"
URL_ARM64="https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_linux_arm64.deb"

# Download and install the appropriate .deb file
if [ "$ARCHITECTURE" == "linux-amd64" ]; then
    wget -O grpcurl.deb "$URL_AMD64"
elif [ "$ARCHITECTURE" == "linux-arm64" ]; then
    wget -O grpcurl.deb "$URL_ARM64"
else
    echo "Unsupported architecture: $ARCHITECTURE"
    exit 1
fi

# Install the downloaded .deb file
$SUDO dpkg -i grpcurl.deb

# Clean up
rm grpcurl.deb

# Create symlink to maintain backwards compatibility with older YAQAS deployments
mkdir -p $HOME/go/bin
ln -s /usr/bin/grpcurl $HOME/go/bin/grpcurl

echo ""
echo "⚡ Step 4: Creating directories..."
# Create folders
mkdir -p "$QUIL_DIR" || { echo "Failed to create directory"; exit 1; }
mkdir -p "$TOOLS_DIR" || { echo "Failed to create tools directory"; exit 1; }
cd "$QUIL_DIR" || { echo "Failed to change directory"; exit 1; }

# Restore backup files
if [ "$CHOICE" -eq 2 ]; then
    mkdir -p "$HOME/quil/.config" || { echo "Failed to create config directory"; exit 1; }
    mv /tmp/config.yml /tmp/keys.yml "$HOME/quil/.config"
fi

echo ""
echo "⚡ Step 5: Download YAQAS tools..."
for url in "${TOOLS_URLS[@]}"; do
    filename=$(basename $url)
    if wget -O "$TOOLS_DIR/$filename" "$url" > /dev/null 2>&1; then
        chmod +x "$TOOLS_DIR/$filename"
        echo "Downloaded and set executable permission for $filename"
    else
        echo "❌ Failed to download $filename from $url"
        echo "Exiting due to download failure."
        exit 1
    fi
done
if [ ! -f "$LOG_FILE" ]; then
  touch "$LOG_FILE"
fi

echo ""
echo "⚡ Step 6: Creating systemd service..."
# Create systemd service
cat << EOF | $SUDO tee /etc/systemd/system/quil.service > /dev/null
[Unit]
Description=Quilibrium Node
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/quil
ExecStart=$HOME/quil/$FILENAME
Restart=always
RestartSec=3
TimeoutStopSec=3
KillMode=control-group
$CPU_LIMIT
Environment="GOMAXPROCS=$GOMAXPROCS"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
$SUDO systemctl daemon-reload

echo ""
echo "⚡ Step 7: Updating sysctl settings..."
# Check if bbr is available
if sysctl net.ipv4.tcp_available_congestion_control | grep -q "bbr"; then
    echo 'net.core.default_qdisc = fq' | $SUDO tee -a /etc/sysctl.conf > /dev/null
    echo 'net.ipv4.tcp_congestion_control = bbr' | $SUDO tee -a /etc/sysctl.conf > /dev/null
    echo "BBR congestion control is available and has been enabled for extra performance."
else
    echo "BBR congestion control is not available. Skipping setting net.core.default_qdisc and net.ipv4.tcp_congestion_control."
fi
# Set UDP buffers
echo 'net.core.rmem_max=26214400' | $SUDO tee -a /etc/sysctl.conf > /dev/null
echo 'net.core.rmem_default=26214400' | $SUDO tee -a /etc/sysctl.conf > /dev/null
echo 'net.core.wmem_max=26214400' | $SUDO tee -a /etc/sysctl.conf > /dev/null
echo 'net.core.wmem_default=26214400' | $SUDO tee -a /etc/sysctl.conf > /dev/null

$SUDO sysctl -p > /dev/null

echo ""
echo "⚡ Step 8: Enabling and starting the service..."
# Enable and start the service
$SUDO systemctl enable quil.service > /dev/null
$SUDO systemctl start quil.service
while [ ! -f "$HOME/quil/.config/config.yml" ]; do
    for s in / - \\ \|; do
        printf "\r$s"
        sleep 0.1
    done
done

if [ "$CUSTOM_PORT_ENABLED" == true ] || [ "$GRPC_ENABLED" == true ] || [ "$REST_ENABLED" == true ]; then
    echo ""
    echo "⚡ Step 9: Updating config.yml with custom port, gRPC port, and REST port"
    # Update the config.yml with the custom port, gRPC port, and REST port
    $SUDO systemctl stop quil.service

    if [ "$CUSTOM_PORT" != "8336" ]; then
        echo "Updating config.yml with custom port $CUSTOM_PORT..."
        sed -i "s|/ip4/0.0.0.0/udp/8336/quic|/ip4/0.0.0.0/udp/$CUSTOM_PORT/quic|g" "$HOME/quil/.config/config.yml"
    fi

    if [ "$ENABLE_GRPC" == true ]; then
        echo "Updating config.yml with gRPC port $GRPC_PORT..."
        if grep -q 'listenGrpcMultiaddr:' "$HOME/quil/.config/config.yml"; then
            sed -i "s|listenGrpcMultiaddr: .*$|listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/$GRPC_PORT|" "$HOME/quil/.config/config.yml"
        else
            echo "listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/$GRPC_PORT" >> "$HOME/quil/.config/config.yml"
        fi
    fi

    if [ "$ENABLE_REST" == true ]; then
        echo "Updating config.yml with REST port $REST_PORT..."
        if grep -q 'listenRESTMultiaddr:' "$HOME/quil/.config/config.yml"; then
            sed -i "s|listenRESTMultiaddr: .*$|listenRESTMultiaddr: /ip4/127.0.0.1/tcp/$REST_PORT|" "$HOME/quil/.config/config.yml"
        else
            echo "listenRESTMultiaddr: /ip4/127.0.0.1/tcp/$REST_PORT" >> "$HOME/quil/.config/config.yml"
        fi
    fi

    echo ""
    echo "⏳ Step 10: Re-starting node..."
    # Start node
    $SUDO systemctl start quil.service
fi

# Setup Automatic Updates, if requested.
echo ""
enable_auto_updates

# Setup Node Monitoring, if requested.
echo ""
echo "✨ YAQAS can monitor your node and restart it if it's not running properly."
echo "It does so by querying the official bootstrap nodes once an hour to check if they can see your node."
enable_node_monitoring

# Setup Telegram Notifications, if requested.
echo ""
echo "❕ The Quilibrium project is under active development. As such, code updates can contain breaking changes."
echo "❕ It is highly recommended to enable Telegram notifications so you can keep an eye on your node."
enable_telegram_notifications

echo ""
echo "✨ *** Congratulations! Your Quilibrium node is now up and running! ***"
PEER_ID=$($HOME/quil/$FILENAME -peer-id | grep -oP 'Peer ID: \K.*')
echo "✌ Your Peer ID is: $PEER_ID"
echo ""
echo "❔ You can check your node's status by running the following command: $SUDO service quil status"
echo "✔ Your node will automatically start if your server (re)boots"
echo ""
echo "✋ To stop your node, run the following command: $SUDO service quil stop"
echo ""
echo "❕ To view the logs of your node, run the following command: $SUDO journalctl -u quil -f"
echo "❕ During the initial start, the node will first generate multiple metrics. This process will take up to 30 minutes."
exec bash
