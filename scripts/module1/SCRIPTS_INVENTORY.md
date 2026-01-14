# Module 1 Scripts - Complete Inventory

## Summary

**Total Scripts Created:** 24
- Lab Scripts: 23
- Cleanup Scripts: 1

All scripts extracted from `/home/ali/Training/gcp-net/module1_labs.md`

## Script Mapping to Lab Exercises

### Lab 1.1: Exploration des interfaces réseau

| Script | Lab Section | Description |
|--------|-------------|-------------|
| `lab1.1_ex1_list-interfaces.sh` | Exercise 1.1.1 | List network interfaces (ip link, ifconfig) |
| `lab1.1_ex2_examine-ip-config.sh` | Exercise 1.1.2 | Examine IP configuration (IPv4/IPv6) |
| `lab1.1_ex3_identify-gateway.sh` | Exercise 1.1.3 | Identify default gateway and routing table |

**Key Commands:** `ip link`, `ifconfig`, `ip addr`, `ip route`, `route -n`

---

### Lab 1.2: La table ARP et la résolution d'adresses

| Script | Lab Section | Description |
|--------|-------------|-------------|
| `lab1.2_ex1_view-arp-table.sh` | Exercise 1.2.1 | View ARP table and neighbor cache |
| `lab1.2_ex2_observe-arp-wireshark.sh` | Exercise 1.2.2 | Observe ARP requests/responses with Wireshark |
| `lab1.2_ex3_arp-external-ip.sh` | Exercise 1.2.3 | ARP behavior for external IP addresses |

**Key Commands:** `ip neigh`, `arp -a`, `ping`
**Tools Required:** Wireshark (for ex2 and ex3)

---

### Lab 1.3: Analyse de trames Ethernet et paquets IP

| Script | Lab Section | Description |
|--------|-------------|-------------|
| `lab1.3_ex1_capture-icmp.sh` | Exercise 1.3.1 | Capture and analyze ICMP frames (Layer 2/3) |
| `lab1.3_ex2_ip-fragmentation.sh` | Exercise 1.3.2 | Observe IP packet fragmentation (MTU) |
| `lab1.3_ex3_ttl-decrementation.sh` | Exercise 1.3.3 | Understand TTL and its decrementation |

**Key Commands:** `ping`
**Tools Required:** Wireshark
**Concepts:** Ethernet frames, IP headers, ICMP, fragmentation, TTL

---

### Lab 1.4: Traceroute - Comprendre le chemin des paquets

| Script | Lab Section | Description |
|--------|-------------|-------------|
| `lab1.4_ex1_traceroute-basic.sh` | Exercise 1.4.1 | Basic traceroute usage and interpretation |
| `lab1.4_ex2_traceroute-wireshark.sh` | Exercise 1.4.2 | Observe traceroute mechanism in Wireshark |
| `lab1.4_ex3_compare-paths.sh` | Exercise 1.4.3 | Compare network paths to different destinations |
| `lab1.4_ex4_mtr-continuous.sh` | Exercise 1.4.4 (Bonus) | Continuous traceroute with MTR |

**Key Commands:** `traceroute`, `mtr`
**Tools Required:** Wireshark (for ex2), mtr (for ex4)
**Concepts:** TTL exploitation, ICMP Time Exceeded, network hops

---

### Lab 1.5: TCP vs UDP en pratique

| Script | Lab Section | Description |
|--------|-------------|-------------|
| `lab1.5_ex1_tcp-handshake.sh` | Exercise 1.5.1 | Observe TCP 3-way handshake |
| `lab1.5_ex2_tcp-vs-udp.sh` | Exercise 1.5.2 | Compare TCP and UDP with netcat |
| `lab1.5_ex3_observe-connections.sh` | Exercise 1.5.3 | Observe connections with ss/netstat |
| `lab1.5_ex4_identify-processes.sh` | Exercise 1.5.4 | Identify processes using lsof |

**Key Commands:** `curl`, `nc`, `ss`, `netstat`, `lsof`, `python3 -m http.server`
**Tools Required:** Wireshark (for ex1, ex2), netcat (for ex2), lsof (for ex4)
**Concepts:** TCP handshake, connection states, ports, UDP datagram

---

### Lab 1.6: DNS - La résolution de noms

| Script | Lab Section | Description |
|--------|-------------|-------------|
| `lab1.6_ex1_dns-basic.sh` | Exercise 1.6.1 | Basic DNS resolution with dig/nslookup |
| `lab1.6_ex2_dns-record-types.sh` | Exercise 1.6.2 | Explore DNS record types (A, AAAA, MX, NS, TXT, CNAME) |
| `lab1.6_ex3_dns-trace.sh` | Exercise 1.6.3 | Trace complete DNS resolution from root |
| `lab1.6_ex4_dns-wireshark.sh` | Exercise 1.6.4 | Observe DNS queries in Wireshark |
| `lab1.6_ex5_test-dns-servers.sh` | Exercise 1.6.5 | Compare different DNS servers (Google, Cloudflare, Quad9) |

**Key Commands:** `dig`, `nslookup`, `systemd-resolve --flush-caches`
**Tools Required:** Wireshark (for ex4)
**Concepts:** DNS hierarchy, record types, resolution process, DNS servers

---

### Lab 1.7: Simulation réseau avec Packet Tracer

**No scripts created** - This lab uses Cisco Packet Tracer GUI simulation tool

Packet Tracer exercises include:
- Exercise 1.7.1: Basic 2-network topology
- Exercise 1.7.2: Observe encapsulation
- Exercise 1.7.3: Add DNS and HTTP server
- Exercise 1.7.4: Multi-router topology

**Tool Required:** Cisco Packet Tracer (free via Cisco Networking Academy)

---

### Lab 1.8: Synthèse - Analyse d'une requête HTTP complète

| Script | Lab Section | Description |
|--------|-------------|-------------|
| `lab1.8_full-http-analysis.sh` | Lab 1.8 | Complete end-to-end HTTP request analysis (all layers) |

**Key Commands:** `curl`, `ip neigh flush`, `systemd-resolve --flush-caches`
**Tools Required:** Wireshark
**Concepts:** Full OSI stack, DNS → ARP → TCP → HTTP sequence

---

### Cleanup

| Script | Purpose | Description |
|--------|---------|-------------|
| `cleanup-module1.sh` | Resource cleanup | Stop test servers, flush caches, kill background processes |

**Actions Performed:**
- Kill netcat servers
- Kill Python HTTP servers
- Flush ARP cache
- Flush DNS cache

---

## Script Statistics

### Lines of Code
```
total: ~2,400 lines across 24 scripts
average: ~100 lines per script
```

### Complexity Distribution
- **Simple (< 50 lines):** 8 scripts (diagnostic commands)
- **Medium (50-100 lines):** 10 scripts (with Wireshark integration)
- **Complex (> 100 lines):** 6 scripts (interactive, educational content)

### Sudo Requirements
Scripts requiring sudo privileges:
- `lab1.2_ex2_observe-arp-wireshark.sh` (flush ARP)
- `lab1.2_ex3_arp-external-ip.sh` (flush ARP)
- `lab1.3_ex3_ttl-decrementation.sh` (low TTL ping)
- `lab1.4_ex4_mtr-continuous.sh` (mtr)
- `lab1.5_ex4_identify-processes.sh` (lsof)
- `lab1.6_ex4_dns-wireshark.sh` (flush DNS)
- `lab1.8_full-http-analysis.sh` (flush ARP/DNS)
- `cleanup-module1.sh` (flush caches)

### External Tools Used
- **Always Required:** ip, ping, traceroute, dig/nslookup, curl
- **Optional Legacy:** ifconfig, arp, route, netstat
- **Recommended:** Wireshark (15 scripts reference it)
- **Bonus Tools:** netcat (1 script), lsof (1 script), mtr (1 script)

---

## Quality Features

All scripts include:
- ✅ Shebang (`#!/bin/bash`)
- ✅ Header comment with lab number, exercise, objective
- ✅ Error handling (`set -e`)
- ✅ Descriptive echo statements
- ✅ Educational questions and guidance
- ✅ Clear instructions for Wireshark integration
- ✅ Prerequisite checks where applicable
- ✅ Informative output formatting
- ✅ Safety measures (confirmation prompts, error handling)

---

## Usage Patterns

### Sequential Learning
```bash
# Complete Lab 1.1
./lab1.1_ex1_list-interfaces.sh
./lab1.1_ex2_examine-ip-config.sh
./lab1.1_ex3_identify-gateway.sh

# Complete Lab 1.2
./lab1.2_ex1_view-arp-table.sh
./lab1.2_ex2_observe-arp-wireshark.sh
./lab1.2_ex3_arp-external-ip.sh

# ... continue through labs ...

# Final synthesis
./lab1.8_full-http-analysis.sh

# Cleanup
./cleanup-module1.sh
```

### Focused Practice
```bash
# Practice ARP only
./lab1.2_ex1_view-arp-table.sh
./lab1.2_ex2_observe-arp-wireshark.sh
./lab1.2_ex3_arp-external-ip.sh

# Practice DNS only
./lab1.6_ex1_dns-basic.sh
./lab1.6_ex2_dns-record-types.sh
./lab1.6_ex3_dns-trace.sh
./lab1.6_ex4_dns-wireshark.sh
./lab1.6_ex5_test-dns-servers.sh
```

---

## Educational Approach

Scripts follow a pedagogical structure:
1. **Context Setting** - Explain what will be done
2. **Prerequisites Check** - Verify tools are available
3. **Instructions** - Guide for Wireshark setup if needed
4. **Execution** - Run the diagnostic commands
5. **Analysis Guide** - What to look for in the output
6. **Reflection Questions** - Encourage deeper understanding
7. **Key Concepts** - Summarize learning points

---

## Differences from Module 2

| Aspect | Module 1 | Module 2 |
|--------|----------|----------|
| **Platform** | Local machine | Google Cloud Platform |
| **Resources** | No cloud resources | VPCs, subnets, VMs, firewalls |
| **Tools** | ping, dig, Wireshark | gcloud CLI |
| **Cleanup** | Kill processes, flush caches | Delete GCP resources |
| **Cost** | Free (local only) | GCP costs apply |
| **Focus** | Understanding protocols | Implementing cloud networks |

---

## Verification

To verify all scripts are present and executable:
```bash
ls -la /home/ali/Training/gcp-net/scripts/module1/

# Should show 24 executable .sh files
# All should have -rwxrwxr-x permissions
```

To test a script:
```bash
./lab1.1_ex1_list-interfaces.sh
```

---

## Maintenance Notes

- Scripts are self-contained and don't depend on each other
- No persistent state between script runs (except network caches)
- Safe to run multiple times
- No modification of system configuration (only temporary operations)
- All changes (cache flushes) are standard networking operations

---

Generated: 2026-01-14
Source: /home/ali/Training/gcp-net/module1_labs.md
Scripts: /home/ali/Training/gcp-net/scripts/module1/
