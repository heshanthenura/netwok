#!/bin/bash

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
mkdir logs
touch "logs/$filename"
echo "log available: $(pwd)/logs/$filename"
echo ""

source utils/netwok.sh "$filename"