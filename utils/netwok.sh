#!/bin/bash

filename="$1"
[ -z "$filename" ] && echo "Filename not provided!" && exit 1


show_menu() {
    echo "==================== Menu ==================="
    echo "1) Generate Diagnose Report"
    echo "2) IP Calculator"
    echo "0) Exit"
    echo "============================================="
    echo -n "Enter your choice: "
}



while true; do
    show_menu
    read -r choice
    case $choice in
        1)
            source utils/diagnose.sh "$filename"
            ;;
        2)
            source utils/ipcalc.sh "$filename"
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