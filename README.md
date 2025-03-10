# NETWOK
## Cook The Network

Netwok is a powerful and lightweight network security tool built with Python and Scapy. It provides various features to analyze, manipulate, and secure networks, making it useful for cybersecurity enthusiasts, ethical hackers, and network engineers.

## Installation:
```bash
git clone https://github.com/yourusername/netwok.git  
cd netwok  
pip install -r requirements.txt  
```

## Usage:

- ### IP Details
This will print
- Local IP
- Subnet Mask
- Public IP
- CIDR Notation
- Network Address
- Broadcast Address
- First Usable IP
- Last Usable IP
- Total Usable Hosts

```bash
python main.py -ipd
```
```bash
python main.py --ip_details
```

- ### ARP Table
This will print ARP Table

```bash
python main.py -at <ip>/<CIDR>

example
python main.py -at 192.168.1.101/24
```
```bash
python main.py --arp_table <ip>/<CIDR>

example
python main.py --arp_table 192.168.1.101/24
```


## Contributions & Collaboration
Contributions and collaborations are always welcome! If you have ideas, improvements, or bug fixes, feel free to fork the repository, submit a pull request, or open an issue. Let's build something amazing together!