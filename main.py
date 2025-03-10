import argparse
from utils import get_ips
parser = argparse.ArgumentParser(add_help=False)


parser.add_argument('-h','--help', action='store_true', help='Display custom help')
parser.add_argument('-dd', '--dhcp_discover', action='store_true', help='Discover DHCP Server')
parser.add_argument("-p", "--ping", nargs="+", metavar="ARGS", help="Ping target with optional parameters")
parser.add_argument("-hd", "--host_discover", nargs="+", metavar="ARGS", help="Detect hosts in network")
parser.add_argument("-ipd", "--ip_details",action="store_true", help="Get IP Details")
parser.add_argument("-at", "--arp_table",action="store_true", help="ARP Table")

args = parser.parse_args()

if args.help:
    print("-------------------------")
    print("NETWOK - Cook The Network")
    print("-------------------------")
    print("Heshan Thenura Kariyawasam")
    print("https://github.com/heshanthenura")
    print()
    print("Usage:")
    print("  -dd, --dhcp_discover                                Perform DHCP Discover")
    print("  -da, --deauth_attack                                Perform Deauthentication Attack")
    print("  -p, --ping --host=<IP> [n=<No. Of Packets>] [t=<Timeout secs>]")
    exit()

if args.dhcp_discover:
    print("Performing DHCP Discover...")

elif args.ping:
    ping_data = {}
    print(args.ping)
    for arg in args.ping:
        if "=" in arg:
            key, value = arg.split("=", 1)
            ping_data[key] = value
        else:
            ping_data["--host"] = arg 

    if "--host" not in ping_data:
        print("Error: '--host' (host) is required for --ping")
    else:
        print("Ping Parameters:")
        print(f"  Host: {ping_data['--host']}")
        print(f"  Packets: {ping_data.get('n', 'Not specified')}")
        print(f"  Timeout: {ping_data.get('t', 'Not specified')}")

elif args.host_discover:
    print(args.host_discover)

elif args.ip_details:
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
    print(args.arp_table)