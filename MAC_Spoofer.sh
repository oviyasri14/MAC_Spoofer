#!/bin/bash


# 🎨 Print ASCII MAC Banner + Penguin
echo "  __  __    _    ____   "
echo " |  \/  |  / \  |  __|  "
echo " | |\/| | / _ \ | |     "
echo " | |  | |/ ___ \| |__   "
echo " |_|  |_/_/   \_\____|  MAC"
echo

echo -e "\e[1;34m"
echo "        .--."
echo "       |o_o |    Linux 🐧"
echo "       |:_/ |"
echo "      //   \\ \\"
echo "     (|     | )"
echo "    / \\_   _/\\ "
echo "    \\___)=(___/"
echo -e "\e[0m"

echo -e "\e[1m➤ MAC Spoofer Script by oviya\e[0m"
echo -e "➤ License: MIT"
echo -e "➤ Description: Change MAC addresses for all interfaces except loopback"
echo    "--------------------------------------------------------"

# ----------------------------
# Root privilege check
# ----------------------------
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;31m❌ This script must be run as root.\e[0m"
    exit 1
fi

# ----------------------------
# Regex pattern to validate MAC format
# ----------------------------
mac_regex='^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$'

# ----------------------------
# MAC generator function
# ----------------------------
generate_mac() {
    hexchars="0123456789ABCDEF"
    echo "02:${hexchars:$((RANDOM % 16)):1}${hexchars:$((RANDOM % 16)):1}:\
${hexchars:$((RANDOM % 16)):1}${hexchars:$((RANDOM % 16)):1}:\
${hexchars:$((RANDOM % 16)):1}${hexchars:$((RANDOM % 16)):1}:\
${hexchars:$((RANDOM % 16)):1}${hexchars:$((RANDOM % 16)):1}:\
${hexchars:$((RANDOM % 16)):1}${hexchars:$((RANDOM % 16)):1}"
}

# ----------------------------
# Interface Loop
# ----------------------------
for interface in $(ls /sys/class/net); do

    # Skip loopback interface
    if [ "$interface" == "lo" ]; then
        echo -e "\e[1;33m⏩ Skipping loopback interface: $interface\e[0m"
        continue
    fi

    echo -e "\n\e[1;36m🔧 Changing MAC Address for: $interface\e[0m"
    current_mac=$(cat /sys/class/net/$interface/address)
    echo -e "\e[1;37m📎 Current MAC Address: $current_mac\e[0m"

    # Ask user for method
    echo -e "\nChoose an option:"
    echo "  [1] Auto-generate MAC address"
    echo "  [2] Enter MAC address manually"
    read -p "  ➤ Enter your choice [1/2]: " choice

    if [ "$choice" == "1" ]; then
        new_mac=$(generate_mac)
        echo -e "🎲 Auto-generated MAC: \e[1;32m$new_mac\e[0m"
    elif [ "$choice" == "2" ]; then
        read -p "🎯 Enter new MAC address (format: XX:XX:XX:XX:XX:XX): " new_mac
        if [[ ! $new_mac =~ $mac_regex ]]; then
            echo -e "\e[1;31m❌ Invalid MAC address format. Skipping $interface.\e[0m"
            continue
        fi
    else
        echo -e "\e[1;31m❌ Invalid option. Skipping $interface.\e[0m"
        continue
    fi

    # Apply MAC address
    ip link set dev "$interface" down
    if ip link set dev "$interface" address "$new_mac"; then
        ip link set dev "$interface" up
        updated_mac=$(cat /sys/class/net/$interface/address)
        echo -e "\e[1;32m✅ New MAC address for $interface: $updated_mac\e[0m"
    else
        echo -e "\e[1;31m❌ Failed to change MAC address for $interface.\e[0m"
        ip link set dev "$interface" up
    fi
done
