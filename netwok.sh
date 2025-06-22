#!/bin/bash


#remove this line
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
echo "Creating file: $filename"
touch "$filename"
echo "log available: $(pwd)/$filename"
echo ""

echo "System Identity " | tee -a "$filename"
echo "" | tee -a "$filename"

host_name=$(hostname)
echo "hostname: $host_name" | tee -a "$filename"

os="$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')"
echo "os: $os" | tee -a "$filename"

kernel="kernel: $(uname -r)"
echo "$kernel" | tee -a "$filename"

uptime=$(uptime)
echo "uptime: $uptime" | tee -a "$filename"

date=$(date)
echo "date: $date" | tee -a "$filename"

whoami=$(whoami)
echo "current user: $whoami" | tee -a "$filename"