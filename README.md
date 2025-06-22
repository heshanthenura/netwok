<p align="center"><img src="logo.png"></p>

**NETWOK** is an all-in-one, Bash-based network automation toolkit designed for network engineers, system administrators, and IT professionals. It simplifies and automates a wide range of networking tasks. From diagnostics and configuration to device discovery, security auditing, and reporting, all through a single, easy-to-use CLI interface.

## Features

### 1. Diagnose Report

1. #### System Identity
   - Hostname  
   - Operating system type and version  
   - Kernel version  
   - System uptime  
   - Current date and time  
   - Current logged-in user  

2. #### Interface Details
   - List of network interfaces available on the system  
   - IP addresses assigned to each interface (IPv4 and IPv6)  

3. #### TX/RX Statistics & Errors
   - Bytes transmitted and received per interface  
   - Transmission and reception error counts per interface  

4. #### Interface Speed & MTU
   - Maximum Transmission Unit (MTU) for each interface  
   - Interface link speed (Mbps), where available  

5. #### Default Interface & IP Address
   - Network interface used as the default route  
   - IP address assigned to that default interface  

6. #### Routing & Gateway
   - Default gateway IP address  
   - Full routing table including routes and metric values  
   - Explanation about routing metric priority  

7. #### DNS Configuration & Resolution
   - DNS servers configured in `/etc/resolv.conf`  
   - Test resolving a domain using system DNS  
   - Test resolving a domain using alternative public DNS servers (Cloudflare, Google)  

8. #### Connectivity Tests
   - Ping tests to default gateway  
   - Ping tests to public DNS servers  
   - Ping tests to a public domain (google.com)  
   - Traceroute to a public domain to check path and latency  

9. #### Internet Presence
   - Public IP address (retrieved from an external service)  
   - Local IP address of the default interface  
   - Basic NAT detection by comparing public and local IP addresses  

10. #### Open Listening Ports
    - List of open/listening TCP and UDP ports  
    - Associated process names and PIDs  

11. #### Firewall Status (Optional - to be added)
    - IPTables or nftables rules (Linux)  
    - UFW status (if applicable)  
    - Default INPUT policy 