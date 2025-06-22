#!/bin/bash

rm netwok_*.txt

cat << "EOF"
   _  __   ____ ______  _      __  ____    __ __
  / |/ /  / __//_  __/ | | /| / / / __ \  / //_/
 /    /  / _/   / /    | |/ |/ / / /_/ / / ,<   
/_/|_/  /___/  /_/     |__/|__/  \____/ /_/|_|  

          Cook The Netwok
  https://github.com/heshanthenura/netwok
EOF

filename="netwok_$(date +%Y-%m-%d_%H-%M-%S).txt"
echo -e "\nCreating file: $filename"
touch "$filename"
echo "log available: $(pwd)/$filename"
echo ""

diagnose_report() {
    os_type=$(uname)

    echo "system identity" | tee -a "$filename"
    echo "" | tee -a "$filename"

    echo "hostname: $(hostname)" | tee -a "$filename"
    echo "os: $os_type" | tee -a "$filename"
    echo "kernel: $(uname -r)" | tee -a "$filename"
    echo "uptime: $(uptime)" | tee -a "$filename"
    echo "date: $(date)" | tee -a "$filename"
    echo "current user: $(whoami)" | tee -a "$filename"

    echo "" | tee -a "$filename"
    echo "interface details" | tee -a "$filename"
    echo "" | tee -a "$filename"

    ### 1. Network interfaces
    echo "network interfaces:" | tee -a "$filename"
    if [[ "$os_type" == "Linux" ]]; then
        ip -br link show | sed 's/^/    /' | tee -a "$filename"
    elif [[ "$os_type" == "Darwin" ]]; then
        ifconfig -l | tr ' ' '\n' | sed 's/^/    /' | tee -a "$filename"
    fi

    ### 2. IP addresses
    echo "" | tee -a "$filename"
    echo "ip addresses:" | tee -a "$filename"
    if [[ "$os_type" == "Linux" ]]; then
        ip -o addr show | awk '
        {
            iface = $2;
            if ($3 == "inet") {
                printf "    %s (IPv4): %s\n", iface, $4
            } else if ($3 == "inet6") {
                printf "    %s (IPv6): %s\n", iface, $4
            }
        }' | tee -a "$filename"
    elif [[ "$os_type" == "Darwin" ]]; then
        for iface in $(ifconfig -l); do
            ipv4=$(ipconfig getifaddr $iface 2>/dev/null)
            ipv6=$(ifconfig $iface | awk '/inet6/ && !/fe80/ {print $2}' | head -n1)
            [[ $ipv4 ]] && echo "    $iface (IPv4): $ipv4" | tee -a "$filename"
            [[ $ipv6 ]] && echo "    $iface (IPv6): $ipv6" | tee -a "$filename"
        done
    fi

    ### 3. TX/RX statistics
    echo "" | tee -a "$filename"
    echo "tx/rx statistics & errors:" | tee -a "$filename"
    if [[ "$os_type" == "Linux" ]]; then
        for iface in /sys/class/net/*; do
            iface=$(basename "$iface")
            echo "    $iface:" | tee -a "$filename"
            rx_bytes=$(cat /sys/class/net/$iface/statistics/rx_bytes)
            tx_bytes=$(cat /sys/class/net/$iface/statistics/tx_bytes)
            rx_errors=$(cat /sys/class/net/$iface/statistics/rx_errors)
            tx_errors=$(cat /sys/class/net/$iface/statistics/tx_errors)
            echo "        RX Bytes  : $rx_bytes" | tee -a "$filename"
            echo "        TX Bytes  : $tx_bytes" | tee -a "$filename"
            echo "        RX Errors : $rx_errors" | tee -a "$filename"
            echo "        TX Errors : $tx_errors" | tee -a "$filename"
        done
    elif [[ "$os_type" == "Darwin" ]]; then
        netstat -ib | awk 'NR==1 || $1 ~ /^[a-z0-9]+$/ { print }' | sed 's/^/    /' | tee -a "$filename"
    fi

    ### 4. Interface speed & MTU
    echo "" | tee -a "$filename"
    echo "interface speed & MTU:" | tee -a "$filename"
    if [[ "$os_type" == "Linux" ]]; then
        for iface in /sys/class/net/*; do
            iface=$(basename "$iface")
            echo "    $iface:" | tee -a "$filename"
            mtu=$(cat /sys/class/net/$iface/mtu)
            if [ -f /sys/class/net/$iface/speed ]; then
                speed=$(cat /sys/class/net/$iface/speed 2>/dev/null)
                [[ "$speed" == "-1" || -z "$speed" ]] && speed="Unknown/Not Reported" || speed="${speed} Mbps"
            else
                speed="Not Available"
            fi
            echo "        MTU   : $mtu" | tee -a "$filename"
            echo "        Speed : $speed" | tee -a "$filename"
        done
    elif [[ "$os_type" == "Darwin" ]]; then
        for iface in $(ifconfig -l); do
            echo "    $iface:" | tee -a "$filename"
            mtu=$(ifconfig $iface | awk '/mtu/ {print $NF}')
            echo "        MTU   : $mtu" | tee -a "$filename"
            echo "        Speed : Not Available (macOS limitation)" | tee -a "$filename"
        done
    fi

    ### 5. Default interface & IP
    echo "" | tee -a "$filename"
    echo "default interface & IP address:" | tee -a "$filename"
    if [[ "$os_type" == "Linux" ]]; then
        default_iface=$(ip route | awk '/default/ {print $5}')
        ip_addr=$(ip -o -4 addr show dev "$default_iface" | awk '{print $4}')
    elif [[ "$os_type" == "Darwin" ]]; then
        default_iface=$(route -n get default | awk '/interface:/ {print $2}')
        ip_addr=$(ipconfig getifaddr "$default_iface" 2>/dev/null)
    fi
    echo "    Interface : $default_iface" | tee -a "$filename"
    echo "    IPv4 Addr : $ip_addr" | tee -a "$filename"
}

diagnose_report
