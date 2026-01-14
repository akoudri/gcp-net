# Module 1 - TCP/IP Fundamentals Scripts

This directory contains executable bash scripts for Module 1 lab exercises, covering TCP/IP fundamentals and local network diagnostics.

## Overview

Module 1 focuses on understanding networking fundamentals through hands-on local diagnostics. Unlike other modules, these labs don't create GCP resources but use local networking tools to explore how protocols work.

## Prerequisites

### Required Tools
- Linux system (Ubuntu 22.04+ recommended) or WSL2
- `iproute2` (ip command) - usually pre-installed
- `net-tools` (ifconfig, arp, route) - optional, for legacy commands
- Basic networking tools (ping, traceroute, dig)

### Optional Tools (for specific labs)
- **Wireshark** - For Labs 1.2, 1.3, 1.5, 1.6, 1.8 (packet capture analysis)
- **netcat (nc)** - For Lab 1.5.2 (TCP/UDP comparison)
- **lsof** - For Lab 1.5.4 (process/port identification)
- **mtr** - For Lab 1.4.4 (continuous traceroute)

### Installation Commands
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install net-tools netcat lsof mtr wireshark

# Enable non-root Wireshark capture (run once)
sudo usermod -aG wireshark $USER
# Then log out and back in
```

## Script Organization

### Lab 1.1: Network Interface Exploration (Layer 2-3)
- `lab1.1_ex1_list-interfaces.sh` - List all network interfaces
- `lab1.1_ex2_examine-ip-config.sh` - Examine IP configuration
- `lab1.1_ex3_identify-gateway.sh` - Identify default gateway

### Lab 1.2: ARP and Address Resolution (Layer 2)
- `lab1.2_ex1_view-arp-table.sh` - View ARP table
- `lab1.2_ex2_observe-arp-wireshark.sh` - Observe ARP with Wireshark
- `lab1.2_ex3_arp-external-ip.sh` - ARP behavior for external IPs

### Lab 1.3: Ethernet Frames and IP Packets (Layer 2-3)
- `lab1.3_ex1_capture-icmp.sh` - Capture and analyze ICMP frames
- `lab1.3_ex2_ip-fragmentation.sh` - Observe IP fragmentation
- `lab1.3_ex3_ttl-decrementation.sh` - Understand TTL expiration

### Lab 1.4: Traceroute - Packet Path Analysis (Layer 3)
- `lab1.4_ex1_traceroute-basic.sh` - Basic traceroute usage
- `lab1.4_ex2_traceroute-wireshark.sh` - Observe traceroute internals
- `lab1.4_ex3_compare-paths.sh` - Compare routes to different destinations
- `lab1.4_ex4_mtr-continuous.sh` - Continuous traceroute with statistics

### Lab 1.5: TCP vs UDP in Practice (Layer 4)
- `lab1.5_ex1_tcp-handshake.sh` - Observe TCP 3-way handshake
- `lab1.5_ex2_tcp-vs-udp.sh` - Compare TCP and UDP with netcat
- `lab1.5_ex3_observe-connections.sh` - View connections with ss/netstat
- `lab1.5_ex4_identify-processes.sh` - Identify processes using ports

### Lab 1.6: DNS - Name Resolution (Layer 7)
- `lab1.6_ex1_dns-basic.sh` - Basic DNS resolution
- `lab1.6_ex2_dns-record-types.sh` - Explore DNS record types (A, AAAA, MX, NS, etc.)
- `lab1.6_ex3_dns-trace.sh` - Trace complete DNS resolution
- `lab1.6_ex4_dns-wireshark.sh` - Observe DNS in Wireshark
- `lab1.6_ex5_test-dns-servers.sh` - Compare different DNS servers

### Lab 1.8: Full HTTP Analysis (Synthesis)
- `lab1.8_full-http-analysis.sh` - Complete HTTP request analysis (all layers)

### Cleanup
- `cleanup-module1.sh` - Clean up local resources and caches

## Usage

### Running Individual Labs

```bash
# Navigate to the scripts directory
cd /home/ali/Training/gcp-net/scripts/module1

# Run any lab script
./lab1.1_ex1_list-interfaces.sh
./lab1.2_ex1_view-arp-table.sh
./lab1.6_ex1_dns-basic.sh
```

### Labs Requiring Wireshark

Some labs require Wireshark for packet capture analysis. The scripts will prompt you to:
1. Open Wireshark
2. Select your network interface
3. Apply the suggested filter
4. Start capturing
5. Press Enter in the terminal to continue

**Example:**
```bash
./lab1.2_ex2_observe-arp-wireshark.sh
# Follow on-screen instructions to set up Wireshark
```

### Labs Requiring Multiple Terminals

Lab 1.5.2 (TCP vs UDP comparison) requires opening multiple terminals:
```bash
# Terminal 1 - Run the script for instructions
./lab1.5_ex2_tcp-vs-udp.sh

# Terminal 2 - Start server (as instructed)
nc -l -p 12345

# Terminal 3 - Connect client (as instructed)
nc localhost 12345
```

### Labs Requiring sudo

Some labs need root privileges for:
- Flushing ARP cache
- Flushing DNS cache
- Capturing packets with certain tools
- Using lsof

The scripts will prompt for sudo when needed.

## Script Features

All scripts include:
- ✅ Proper bash headers (`#!/bin/bash`)
- ✅ Error handling (`set -e`)
- ✅ Descriptive echo statements for progress
- ✅ Educational comments and questions
- ✅ Clear instructions for Wireshark integration
- ✅ Prerequisite checks (tool availability)

## Learning Objectives by Lab

| Lab | Focus | Key Concepts |
|-----|-------|--------------|
| 1.1 | Interface Discovery | MAC addresses, IP addresses, network interfaces |
| 1.2 | ARP Protocol | MAC-IP resolution, ARP cache, broadcast |
| 1.3 | Frame Analysis | Ethernet frames, IP headers, encapsulation, fragmentation |
| 1.4 | Path Tracing | TTL, ICMP, routing paths, network hops |
| 1.5 | Transport Layer | TCP handshake, UDP, connection states, ports |
| 1.6 | DNS | Name resolution, DNS hierarchy, record types |
| 1.8 | Full Stack | End-to-end request analysis across all layers |

## Cleanup

After completing the labs:
```bash
./cleanup-module1.sh
```

This will:
- Stop any running test servers (netcat, Python HTTP server)
- Flush ARP and DNS caches
- Kill background processes from labs

**Note:** Module 1 doesn't create GCP resources, so there are no cloud resources to delete.

## Troubleshooting

### Common Issues

**"Command not found" errors:**
```bash
# Install missing tools
sudo apt install net-tools netcat lsof mtr
```

**"Permission denied" when flushing caches:**
```bash
# Run the command with sudo
sudo ./lab1.2_ex2_observe-arp-wireshark.sh
```

**Wireshark doesn't show packets:**
- Ensure you selected the correct interface (usually eth0, ens33, or wlan0)
- Check that you're in the `wireshark` group: `groups`
- Restart your session after adding to wireshark group

**DNS cache flush fails:**
```bash
# Your system might not use systemd-resolved
# Try manually:
sudo systemctl restart NetworkManager
```

## Notes on Module 1

- **No GCP resources created** - All labs are local network diagnostics
- **Wireshark is essential** - Many labs require packet capture analysis
- **Lab 1.7 (Packet Tracer)** - Not scripted as it's a GUI simulation tool
- **Interactive learning** - Scripts guide you but require Wireshark analysis
- **Safe to run** - All commands are read-only or temporary (caches)

## Next Steps

After completing Module 1, proceed to Module 2 which introduces GCP VPC networking:
```bash
cd ../module2
ls -la
```

## Reference Documentation

For detailed theory and questions, refer to:
- `/home/ali/Training/gcp-net/module1_labs.md` - Complete lab documentation in French

## Support

For issues or questions:
1. Check the module1_labs.md documentation
2. Review the script comments and educational notes
3. Verify all prerequisites are installed
4. Ensure you have necessary permissions (sudo for some operations)
