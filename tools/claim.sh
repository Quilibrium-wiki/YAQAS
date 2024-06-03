#!/bin/bash

# Script version
SCRIPT_VERSION="1.0"

cat << "EOF"
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⣦⣤⣤⣤⣿⣿⣶⣤⣤⣶⣿⡿⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣶⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠧⣜⢿⣿⠉⢻⣿⢿⣿⣿⡇⢠⣭⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⢿⣿⡄⣺⣿⣤⣿⣿⣿⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣻⣿⣿⣛⣿⣿⣾⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣟⣿⣿⣟⣻⣿⣿⣾⣿⣿⣃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣿⢿⠿⠟⠿⣿⢿⡉⠉⢽⡗⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠞⠋⢉⠟⠀⠀⠀⠀⠀⠈⠀⠙⢄⠀⠉⢿⣇⠏⡵⢦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡶⣿⣦⠖⠀⠀⠀⠀⠀⢰⣶⣤⡄⠀⠀⠀⠀⠀⠀⠉⠺⢷⠎⣸⣻⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⣴⣾⣷⣿⡟⠁⠀⢀⣴⣾⣯⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⡡⢊⡼⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣴⢏⢗⢸⠟⠃⠀⠀⢠⣾⣿⣿⡿⢿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠸⡗⣩⠞⡔⣹⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣠⠞⣷⢸⡸⠈⠀⠀⠀⠀⢸⣿⣿⡏⠀⣸⣿⣿⡏⠙⢿⡿⠛⠀⠀⠀⠀⠀⠀⠀⠀⠨⠵⣪⠜⡡⣻⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢀⡾⢡⣶⡟⠋⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣶⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠚⣡⢞⡕⢡⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀
⠀⡞⠀⠈⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⣿⣿⣿⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⡵⢋⠔⡿⢡⣿⡀⠀⠀⠀⠀⠀⠀⠀
⣼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⣣⠞⣴⣻⣿⡇⠀⠀⠀⠀⠀⠀⠀
⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣴⣧⡀⠀⣿⣿⣿⠀⠹⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡔⣡⣾⢟⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀
⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣷⣤⣿⣿⣿⣀⣠⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣬⣾⢟⣵⣿⡿⣻⡇⠀⠀⠀⠀⠀⠀⠀
⢳⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⢞⣥⣿⣿⢟⡕⣹⠁⠀⠀⠀⠀⠀⠀⠀
⠈⣆⢻⣠⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⣿⣿⣿⠛⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⢟⡻⢟⣽⡿⣋⢴⡟⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠸⡌⢿⣧⡄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣇⡠⠊⡠⢊⠔⡻⢫⠞⣡⣿⣤⣤⣤⣀⠀⠀⠀⠀⠀
⠀⠀⠹⣄⠛⣷⣷⣤⣄⠀⠀⠀⠀⠀⢀⣄⡴⣢⢖⡰⢂⠔⣠⠖⣰⣦⢆⣴⣲⣿⢞⣶⠞⡴⢡⢞⠔⣡⣏⣾⣿⣿⣿⣿⣿⣿⣿⣶⣤⣄
⠀⠀⠀⠈⠳⣌⠙⢿⣿⢸⣿⣷⣶⣿⣿⡾⡿⣵⢋⠔⠵⢊⡵⢮⠟⡵⣯⢞⡵⣣⡿⢃⠞⡴⡱⢋⣾⣟⣯⣭⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿
⠀⠀⠀⠀⠀⠿⢷⣦⣭⣭⣭⣥⣭⣤⣤⣤⣤⣤⣤⣤⣶⣞⡒⠒⠲⠃⠌⣹⢿⡿⣷⣣⣞⣴⣟⣛⣒⣺⣿⣿⣿⣟⣷⣶⣶⠦⠤⠉⠀⠀
⠀⠀⠀⠀⠀⠀⠈⠉⠹⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣤⣤⣤⣼⣿⡟⠛⠛⠳⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⡭⠿⠿⢿⣿⣶⣶⣞⣃⣀⣀⣀⡚⠛⠛⠛⠉⠉⠉⠉⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF
echo ""
echo "Quilibrium Claim Script - Version $SCRIPT_VERSION"
echo "***** https://Quilibrium.wiki *****"
echo ""
echo "This script will assist you with claiming your rewards."
echo ""

# Function to check for newer script version
check_for_updates() {
    LATEST_VERSION=$(curl -s https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/claim.sh | grep 'SCRIPT_VERSION="' | head -1 | cut -d'"' -f2)
    if [ "$SCRIPT_VERSION" != "$LATEST_VERSION" ]; then
        echo "A newer version of this script is available (v$LATEST_VERSION)."
        read -p "Do you want to download the newer version? (y/n): " RESPONSE
        if [ "$RESPONSE" == "y" ] || [ "$RESPONSE" == "Y" ]; then
            curl -o claim.sh https://raw.githubusercontent.com/Quilibrium-wiki/YAQAS/main/tools/claim.sh
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

# Function to handle SIGINT (Ctrl+C) to allow copy/paste
trap_ctrl_c() {
    echo ""
}

echo "Once your QUIL is bridged to wQUIL, it cannot be bridged back until version 2.0 is released."
echo "Claiming will claim the entire balance associated with your node. You cannot do a partial claim."
echo "Additionally, you will need a small amount of Ethereum to cover the gas fees."
echo ""
read -p "❓ Do you want to proceed with claiming your tokens? (y/n): " USER_CONFIRMATION
if [ "$USER_CONFIRMATION" != "y" ] && [ "$USER_CONFIRMATION" != "Y" ]; then
    echo "Operation cancelled by user."
    exit 0
fi


# Variables
QUIL_DIR="$HOME/quil"
ARCHITECTURE=$(uname -m)
ARCHITECTURE=${ARCHITECTURE/x86_64/linux-amd64} # Map x86_64 to linux-amd64
ARCHITECTURE=${ARCHITECTURE/aarch64/linux-arm64} # Map aarch64 to linux-arm64
BINARY_NAME=$(ls "$QUIL_DIR" | grep "$ARCHITECTURE" | grep -v ".dgst")
PEER_ID=$($HOME/quil/$BINARY_NAME -peer-id | grep -oP 'Peer ID: \K.*')

cd "$QUIL_DIR/client" || { echo "Failed to change directory"; exit 1; }

echo ""
echo "1. To claim your rewards, open a webbrowser on your PC and navigate to: https://quilibrium.com/rewards"
echo ""
echo "2. Input your Peer-ID in the left column. Your Peer ID is: $PEER_ID"
echo ""
echo "3. Click on Connect Wallet, select your Wallet and enter your password"
echo ""
echo "4. Click on 'Prove'"
echo ""
echo "   The qclient is already set up and ready to go. There is no need to run the GOEXPERIMENT command."
echo ""

echo "5. Paste the entire 'cross-mint string' below, including ./qclient cross-mint"
read user_command

# Check if the user input starts with "./qclient cross-mint"
if [[ $user_command == ./qclient\ cross-mint* ]]; then
    eval "$user_command"
else
    echo "Error: The command must start with './qclient cross-mint'"
	exit 1
fi

echo ""
echo "6. Copy/paste the response object back in the bottom text field of the reward claim page"
echo ""
echo "7. Approve the claim transaction in your wallet".
echo ""
echo "✨ Once the transaction is confirmed, you will have the corresponding wQUIL available in your wallet."
echo ""
echo "You will likely have to add a custom token from within the wallet (e.g. Metamask) for it to show up."
echo "Use the following token details when doing so:"
echo "Contract address: 0x8143182a775c54578c8b7b3ef77982498866945d"
echo "Token symbol: wQUIL"
echo "Decimals: 8"