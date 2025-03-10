from scapy.all import sniff,ICMP

def packet_callback(packet):
	if packet.haslayer(ICMP) and packet[ICMP].type == 8:
		print("----------------------------------------------------------")
		print()
		print(packet.show())
		print()
		print("----------------------------------------------------------")
sniff(filter="icmp",prn=packet_callback,store=0,iface="wlan0",promisc=True)
