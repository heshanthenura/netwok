#!/bin/bash

filename="$1"
[ -z "$filename" ] && echo "Filename not provided!" && exit 1

ip_to_int() {
    local IFS=.
    read -r i1 i2 i3 i4 <<< "$1"
    ip_value=$(( i1 * 256**3 + i2 * 256**2 + i3 * 256 + i4 ))
    echo $ip_value
}

int_to_ip() {
    local ui32=$1
    echo "$(( (ui32 >> 24) & 255 )).$(( (ui32 >> 16) & 255 )).$(( (ui32 >> 8) & 255 )).$(( ui32 & 255 ))"
}

get_class() {
    local first_octet=${1%%.*}
    if (( first_octet >= 1 && first_octet <= 126 )); then
        echo "A"
    elif (( first_octet >= 128 && first_octet <= 191 )); then
        echo "B"
    elif (( first_octet >= 192 && first_octet <= 223 )); then
        echo "C"
    elif (( first_octet >= 224 && first_octet <= 239 )); then
        echo "D (Multicast)"
    elif (( first_octet >= 240 && first_octet <= 254 )); then
        echo "E (Experimental)"
    else
        echo "Unknown"
    fi
}

subnet_mask() {
    local bits=$1 mask=0 i bit_position

    for ((i = 0; i < 32; i++)); do
        (( i < bits )) || continue
        bit_position=$(( 31 - i ))
        mask=$(( mask | (2 ** bit_position) ))  
    done

    int_to_ip "$mask"
}

calculate_cidr_info() {
  read -rp "Enter CIDR (e.g. 192.168.1.10/24): " cidr

  if ! [[ $cidr =~ ^([0-9]{1,3}(\.[0-9]{1,3}){3})/([0-9]{1,2})$ ]]; then
    echo "Invalid CIDR format"
    return
  fi

  local ip=${BASH_REMATCH[1]}
  local prefix=${BASH_REMATCH[3]}


  IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
  for oct in $o1 $o2 $o3 $o4; do
    if (( oct < 0 || oct > 255 )); then
      echo "Invalid IP address"
      return
    fi
  done
  if (( prefix < 0 || prefix > 32 )); then
    echo "Invalid subnet mask bits"
    return
  fi

  local class=$(get_class "$ip")
  local netmask=$(subnet_mask "$prefix")

  local ip_int=$(ip_to_int "$ip")
  local mask_int=$(ip_to_int "$netmask")

  local network_int=$(( ip_int & mask_int ))
  local broadcast_int=$(( network_int | (~mask_int & 0xFFFFFFFF) ))

  local first_usable_int=$(( network_int + 1 ))
  local last_usable_int=$(( broadcast_int - 1 ))

  local hostbits=$(( 32 - prefix ))
  local total_addresses=$(( 2 ** hostbits ))
  local usable_addresses=0

  if (( prefix == 31 )); then
    usable_addresses=2
  elif (( prefix == 32 )); then
    usable_addresses=1
  else
    usable_addresses=$(( total_addresses - 2 ))
  fi

  echo "" | tee -a "$filename"
  echo "CIDR Information:" | tee -a "$filename"
  echo "-----------------" | tee -a "$filename"
  echo "IP Address           : $ip" | tee -a "$filename"
  echo "Class                : $class" | tee -a "$filename"
  echo "Subnet Mask          : $netmask" | tee -a "$filename"
  echo "Netbits (Prefix)     : $prefix" | tee -a "$filename"
  echo "Hostbits             : $hostbits" | tee -a "$filename"
  echo "Network Address      : $(int_to_ip $network_int)" | tee -a "$filename"
  echo "Broadcast Address    : $(int_to_ip $broadcast_int)" | tee -a "$filename"
  echo "First Usable IP      : $(int_to_ip $first_usable_int)" | tee -a "$filename"
  echo "Last Usable IP       : $(int_to_ip $last_usable_int)" | tee -a "$filename"
  echo "Total Addresses      : $total_addresses" | tee -a "$filename"
  echo "Usable Addresses     : $usable_addresses" | tee -a "$filename"
  echo "" | tee -a "$filename"
}

show_menu() {
    echo ""
    echo "================ IP Calculator Menu ==============="
    echo "1) CIDR to IP Range & Subnet Info"
    echo "9) Return to Main Menu"
    echo "0) Exit"
    echo "==================================================="
    echo -n "Enter your choice: "
}

while true; do
    show_menu
    read -r choice
    case $choice in
        1)
            calculate_cidr_info
            ;;
        9)
            source utils/netwok.sh "$filename"
            ;;
        0)
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid choice, please try again."
            ;;
    esac
done
