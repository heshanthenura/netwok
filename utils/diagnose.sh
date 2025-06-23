#!/bin/bash

filename="$1"
[ -z "$filename" ] && echo "Filename not provided!" && exit 1

diagnose_report() {


    os_type=$(uname)

    # * system identity
    echo "system identity" | tee -a "$filename"
    echo "" | tee -a "$filename"

    echo "hostname: $(hostname)" | tee -a "$filename"
    echo "os: $os_type" | tee -a "$filename"
    echo "kernel: $(uname -r)" | tee -a "$filename"
    echo "uptime: $(uptime)" | tee -a "$filename"
    echo "date: $(date)" | tee -a "$filename"
    echo "current user: $(whoami)" | tee -a "$filename"

    # * interface details
    echo "" | tee -a "$filename"
    echo "interface details" | tee -a "$filename"
    echo "" | tee -a "$filename"

    # network interfaces
    echo "network interfaces:" | tee -a "$filename"
    if [[ "$os_type" == "Linux" ]]; then
        ip -br link show | sed 's/^/    /' | tee -a "$filename"
    elif [[ "$os_type" == "Darwin" ]]; then
        ifconfig -l | tr ' ' '\n' | sed 's/^/    /' | tee -a "$filename"
    fi

    # ip addresses
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

    # TX/RX statistics
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

    # Interface speed & MTU
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

    # default interface & IP
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

    # * Routing & Gateway
    echo "" | tee -a "$filename"
    echo "routing & gateway" | tee -a "$filename"
    echo "" | tee -a "$filename"

    # Default Gateway
    echo "default gateway:" | tee -a "$filename"
    if [[ "$os_type" == "Linux" ]]; then
        gateway=$(ip route | awk '/default/ {print $3}')
        echo "    Gateway   : $gateway" | tee -a "$filename"
    elif [[ "$os_type" == "Darwin" ]]; then
        gateway=$(route -n get default | awk '/gateway:/ {print $2}')
        echo "    Gateway   : $gateway" | tee -a "$filename"
    fi

    # Full Routing Table
    echo "" | tee -a "$filename"
    echo "full route table (with metric values):" | tee -a "$filename"
    if [[ "$os_type" == "Linux" ]]; then
        echo "" | tee -a "$filename"
        ip route show table main | sed 's/^/    /' | tee -a "$filename"
    elif [[ "$os_type" == "Darwin" ]]; then
        echo "" | tee -a "$filename"
        netstat -rn | sed 's/^/    /' | tee -a "$filename"
    fi

    # Explanation note for metric
    echo "" | tee -a "$filename"
    echo "note: lower metric = higher priority (used for load balancing decisions)" | tee -a "$filename"

    # *  DNS Configuration & Resolution
    echo "" | tee -a "$filename"
    echo "DNS Configuration & Resolution" | tee -a "$filename"
    echo "" | tee -a "$filename"

    # Configured DNS servers
    echo "Configured DNS servers:" | tee -a "$filename"
    if [[ "$os_type" == "Linux" || "$os_type" == "Darwin" ]]; then
        grep -E "^nameserver" /etc/resolv.conf | sed 's/^/    /' | tee -a "$filename"
    else
        echo "    Unsupported OS for DNS config display" | tee -a "$filename"
    fi

    test_domain="google.com"
    
    # resolve test
    echo "" | tee -a "$filename"
    echo "Can resolve domain '$test_domain' with system DNS?" | tee -a "$filename"
    if nslookup "$test_domain" >/dev/null 2>&1; then
        nslookup "$test_domain" | head -10 | sed 's/^/    /' | tee -a "$filename"
    else
        echo "    Failed to resolve $test_domain using system DNS" | tee -a "$filename"
    fi

    # Test with alternative resolvers
    for resolver in 1.1.1.1 8.8.8.8; do
        echo "" | tee -a "$filename"
        echo "Test resolving '$test_domain' via DNS server $resolver:" | tee -a "$filename"
        if nslookup "$test_domain" "$resolver" >/dev/null 2>&1; then
            nslookup "$test_domain" "$resolver" | head -10 | sed 's/^/    /' | tee -a "$filename"
        else
            echo "    Failed to resolve $test_domain via $resolver" | tee -a "$filename"
        fi
    done

    # * Connectivity Tests
    echo "" | tee -a "$filename"
    echo "Connectivity Tests" | tee -a "$filename"
    echo "" | tee -a "$filename"

    # Detect OS for traceroute command
    if [[ "$os_type" == "Darwin" ]]; then
        traceroute_cmd="traceroute"
        ping_cmd="ping -c 4"
    else
        traceroute_cmd="traceroute"
        ping_cmd="ping -c 4"
    fi

    # Ping default gateway
    echo "Ping default gateway ($gateway):" | tee -a "$filename"
    if ping -c 4 "$gateway" >/dev/null 2>&1; then
        ping -c 4 "$gateway" | sed 's/^/    /' | tee -a "$filename"
    else
        echo "    Failed to reach gateway $gateway" | tee -a "$filename"
    fi

    # Ping public DNS servers
    for dns_ip in 8.8.8.8 1.1.1.1; do
        echo "" | tee -a "$filename"
        echo "Ping public DNS server ($dns_ip):" | tee -a "$filename"
        if ping -c 4 "$dns_ip" >/dev/null 2>&1; then
            ping -c 4 "$dns_ip" | sed 's/^/    /' | tee -a "$filename"
        else
            echo "    Failed to reach DNS server $dns_ip" | tee -a "$filename"
        fi
    done

    # Ping public domain (google.com)
    public_domain="google.com"
    echo "" | tee -a "$filename"
    echo "Ping public domain ($public_domain):" | tee -a "$filename"
    if ping -c 4 "$public_domain" >/dev/null 2>&1; then
        ping -c 4 "$public_domain" | sed 's/^/    /' | tee -a "$filename"
    else
        echo "    Failed to reach $public_domain" | tee -a "$filename"
    fi

    # Traceroute to external host
    echo "" | tee -a "$filename"
    echo "Traceroute to $public_domain:" | tee -a "$filename"
    if $traceroute_cmd "$public_domain" >/dev/null 2>&1; then
        $traceroute_cmd "$public_domain" | sed 's/^/    /' | tee -a "$filename"
    else
        echo "    Traceroute failed to $public_domain" | tee -a "$filename"
    fi

    # * Internet Presence
    echo "" | tee -a "$filename"
    echo "Internet Presence" | tee -a "$filename"

    # Get public IP using an external service
    public_ip=$(curl -s https://ipinfo.io/ip)
    if [[ -z "$public_ip" ]]; then
        echo "Public IP: Unable to retrieve" | tee -a "$filename"
    else
        echo "Public IP: $public_ip" | tee -a "$filename"
    fi

    # Get local IP of default interface (already stored in $ip_addr)
    echo "Local IP (default interface): $ip_addr" | tee -a "$filename"

    # Basic NAT detection
    if [[ "$public_ip" != "$ip_addr" ]]; then
        echo "NAT detected: YES (public and local IPs differ)" | tee -a "$filename"
    else
        echo "NAT detected: NO (public and local IPs are the same)" | tee -a "$filename"
    fi

    # * Open listening TCP & UDP ports with processes
    echo "" | tee -a "$filename"
    echo "Open listening TCP & UDP ports with processes:" | tee -a "$filename"
    if [[ "$(uname)" == "Linux" ]]; then
        ss -tulnp 2>/dev/null | awk '
        NR>1 {
            proto=$1;
            state=$2;
            local=$5;
            pid_proc=$7;
            if (state == "LISTEN" || proto == "udp") {
                printf "    %-4s %-22s %s\n", proto, local, pid_proc
            }
        }' | tee -a "$filename"
    elif [[ "$(uname)" == "Darwin" ]]; then
        netstat -anv -p tcp -p udp | awk '
        /LISTEN/ || /udp/ {
            print "    "$0
        }' | tee -a "$filename"
    else
        echo "Unsupported OS for open ports listing" | tee -a "$filename"
    fi

    # * Firewall & Security Info
    echo "" | tee -a "$filename"
    echo "Firewall & Security Info" | tee -a "$filename"
    echo "" | tee -a "$filename"

    # iptables rules 
    if [[ "$os_type" == "Linux" ]]; then
        echo "iptables rules:" | tee -a "$filename"
        if command -v iptables >/dev/null 2>&1; then
            sudo iptables -L -v -n | tee -a "$filename"
        else
            echo "    iptables not installed" | tee -a "$filename"
        fi

        echo "" | tee -a "$filename"
        echo "nftables rules:" | tee -a "$filename"
        if command -v nft >/dev/null 2>&1; then
            sudo nft list ruleset | tee -a "$filename"
        else
            echo "    nftables not installed or not in use" | tee -a "$filename"
        fi

        echo "" | tee -a "$filename"
        echo "UFW status:" | tee -a "$filename"
        if command -v ufw >/dev/null 2>&1; then
            sudo ufw status verbose | tee -a "$filename"
        else
            echo "    UFW not installed" | tee -a "$filename"
        fi

        echo "" | tee -a "$filename"
        echo "Default INPUT policy:" | tee -a "$filename"
        # Get default INPUT policy from iptables
        default_input=$(sudo iptables -L INPUT --line-numbers | grep "Chain INPUT" -A 1 | head -2 | tail -1 | awk '{print $1}')
        if [[ -z "$default_input" ]]; then
            echo "    Unable to determine default INPUT policy" | tee -a "$filename"
        else
            echo "    $default_input" | tee -a "$filename"
        fi

    elif [[ "$os_type" == "Darwin" ]]; then
        echo "macOS uses pf firewall; listing pf rules:" | tee -a "$filename"
        sudo pfctl -sr | tee -a "$filename"
        echo "" | tee -a "$filename"
        echo "pf status:" | tee -a "$filename"
        sudo pfctl -s info | tee -a "$filename"
    else
        echo "Unsupported OS for firewall info" | tee -a "$filename"
    fi


}

diagnose_report