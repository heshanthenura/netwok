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
touch "$filename"
echo "log available: $(pwd)/$filename"
echo ""


show_menu() {
    echo "==================== Menu ==================="
    echo "1) Generate Diagnose Report"
    echo "0) Exit"
    echo "============================================="
    echo -n "Enter your choice: "
}



while true; do
    show_menu
    read -r choice
    case $choice in
        1)
            bash utils/diagnose.sh "$filename"
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