import socket
import requests
import netifaces
import ipaddress

def get_ips():
    # Get local IP (LAN)
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(0)
    try:
        s.connect(('10.254.254.254', 1)) 
        local_ip = s.getsockname()[0]
    except Exception:
        local_ip = '127.0.0.1' 
    finally:
        s.close()

    # Get subnet mask
    subnet_mask = "Unknown"
    try:
        interfaces = netifaces.interfaces()
        for interface in interfaces:
            addrs = netifaces.ifaddresses(interface)
            if netifaces.AF_INET in addrs:
                for addr in addrs[netifaces.AF_INET]:
                    if addr['addr'] == local_ip:
                        subnet_mask = addr['netmask']
                        break
    except Exception:
        subnet_mask = "Could not retrieve subnet mask"

    # Get IP range from local IP and subnet mask
    ip_range = "Could not calculate IP range"
    cidr = "Unknown"
    if subnet_mask != "Unknown":
        try:
            network = ipaddress.ip_network(f"{local_ip}/{subnet_mask}", strict=False)
            all_hosts = list(network.hosts())  # Get all usable hosts in the subnet
            first_usable_ip = all_hosts[0] if all_hosts else network.network_address
            last_usable_ip = all_hosts[-1] if all_hosts else network.broadcast_address
            ip_range = {
                "Network Address": network.network_address,
                "Broadcast Address": network.broadcast_address,
                "First Usable IP": first_usable_ip,
                "Last Usable IP": last_usable_ip,
                "Total Hosts": network.num_addresses - 2 if network.num_addresses > 2 else 1
            }
            # Get the CIDR notation (e.g., 192.168.1.100/24)
            cidr = f"{local_ip}/{network.prefixlen}"
        except ValueError:
            ip_range = "Invalid IP or subnet mask"

    # Get public IP (ISP)
    try:
        response = requests.get("https://api64.ipify.org?format=text", timeout=5)
        public_ip = response.text.strip()
    except requests.RequestException:
        public_ip = "Could not retrieve public IP"
    
    return local_ip, subnet_mask, ip_range, public_ip, cidr