from scapy.all import IP,ICMP,sr1


icmp_request = IP(dst="8.8.8.8")/ICMP()


response = sr1(icmp_request, timeout=1)


if response:
    print(f"Received response from {response.src}:")
    response.show()  
else:
    print("No response received.")
