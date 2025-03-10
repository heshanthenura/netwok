import argparse
from utils import get_ips,get_arp_table
parser = argparse.ArgumentParser(add_help=False)


parser.add_argument('-h','--help', action='store_true', help='Display custom help')
parser.add_argument("-ipd", "--ip_details",action="store_true", help="Get IP Details")
parser.add_argument("-at", "--arp_table", nargs="+", metavar="ARGS", help="ARP Table")
parser.add_argument('-dd', '--dhcp_discover', action='store_true', help='Discover DHCP Server')
parser.add_argument("-p", "--ping", nargs="+", metavar="ARGS", help="Ping target with optional parameters")
parser.add_argument("-hd", "--host_discover", nargs="+", metavar="ARGS", help="Detect hosts in network")

args = parser.parse_args()

if args.help:
    print("-------------------------")
    print("NETWOK - Cook The Network")
    print("-------------------------")
    print("Heshan Thenura Kariyawasam")
    print("https://github.com/heshanthenura/netwok")
    print()
    print("Usage:")
    print("  -ipd, --ip_details                                Details About IP Address")
    print("  -at,  --arp_table <IP>/<CIDR>                     ARP Table")
    exit()

if args.ip_details:
    local_ip, subnet_mask, ip_range, public_ip, cidr = get_ips()
    print(f"Local IP       : {local_ip}")
    print(f"Subnet Mask    : {subnet_mask}")
    print(f"Public IP      : {public_ip}")
    print(f"CIDR Notation  : {cidr}")
    if isinstance(ip_range, dict):
        print("\nIP Range Details:")
        print(f"  Network Address  : {ip_range['Network Address']}")
        print(f"  Broadcast Address: {ip_range['Broadcast Address']}")
        print(f"  First Usable IP  : {ip_range['First Usable IP']}")
        print(f"  Last Usable IP   : {ip_range['Last Usable IP']}")
        print(f"  Total Usable Hosts: {ip_range['Total Hosts']}")
    else:
        print(f"IP Range: {ip_range}")

elif args.arp_table:
    arp_table = get_arp_table(args.arp_table[0])  
    for entry in arp_table:
        print(f"IP Address: {entry['IP']} | MAC Address: {entry['MAC']}")