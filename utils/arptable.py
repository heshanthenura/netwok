from scapy.all import ARP,Ether,srp

def get_arp_table(target_ip):
    arp_request = ARP(pdst=target_ip)
    broadcast = Ether(dst="ff:ff:ff:ff:ff:ff")
    
    arp_request_broadcast = broadcast/arp_request
    
    answered_list = srp(arp_request_broadcast, timeout=2, verbose=False)[0]
    
    arp_table = []
    for element in answered_list:
        arp_entry = {
            'IP': element[1].psrc,
            'MAC': element[1].hwsrc
        }
        arp_table.append(arp_entry)
    
    return arp_table

arp_table = get_arp_table("172.28.0.0/19")  # Scan the local network (adjust the IP range if needed)
for entry in arp_table:
    print(f"IP Address: {entry['IP']} | MAC Address: {entry['MAC']}")