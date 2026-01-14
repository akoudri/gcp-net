# Module 6 - Cloud DNS Scripts

This directory contains all the bash scripts for Module 6 (Cloud DNS) labs.

## Summary

**Total Scripts Created: 60**
- 59 lab exercise scripts
- 1 cleanup script

## Lab Structure

### Lab 6.1: Zones privées - Configuration de base (7 scripts)
- ex1: Create infrastructure (VPC, subnet, firewall)
- ex2: Configure Cloud NAT
- ex3: Create VMs (vm1, vm2, db)
- ex4: Create DNS private zone
- ex5: Add DNS records (A, CNAME)
- ex6: Transaction method
- ex7: Test DNS resolution

### Lab 6.2: DNS interne automatique GCP (4 scripts)
- ex1: Discover automatic DNS
- ex2: Check project DNS config
- ex3: Understand DNS formats
- ex4: Enable zonal DNS

### Lab 6.3: Zones publiques et enregistrements (7 scripts)
- ex1: Create public zone
- ex2: Add common records (A, AAAA, CNAME, MX)
- ex3: Add TXT records (SPF, verification)
- ex4: Add SRV record
- ex5: Add CAA record
- ex6: List and export records
- ex7: Modify and delete records

### Lab 6.4: Forwarding DNS vers on-premise (7 scripts)
- ex1: Create on-premise subnet
- ex2: Configure Cloud NAT for forwarding
- ex3: Create DNS server (dnsmasq)
- ex4: Test DNS server
- ex5: Create forwarding zone
- ex6: Test forwarding from client
- ex7: Observe DNS flow

### Lab 6.5: Inbound Forwarding (6 scripts)
- ex1: Create inbound policy
- ex2: Identify forwarding addresses
- ex3: Configure Cloud NAT
- ex4: Create on-premise client
- ex5: Test inbound forwarding
- ex6: Configure client DNS

### Lab 6.6: Peering DNS entre VPC (6 scripts)
- ex1: Create Hub VPC
- ex2: Create Hub DNS zone
- ex3: Create Spoke VPC
- ex4: Create DNS peering
- ex5: Test DNS peering
- ex6: Understand limits

### Lab 6.7: Politiques DNS et Logging (5 scripts)
- ex1: Create DNS policy with logging
- ex2: Generate DNS traffic
- ex3: View DNS logs
- ex4: Analyze logs in detail
- ex5: Create metrics and alerts

### Lab 6.8: DNSSEC - Sécurisation du DNS (5 scripts)
- ex1: Understand DNSSEC
- ex2: Enable DNSSEC
- ex3: Get DNSSEC info
- ex4: Verify DNSSEC
- ex5: Manage keys

### Lab 6.9: Split-horizon DNS (5 scripts)
- ex1: Create backend VM with public IP
- ex2: Create public split zone
- ex3: Create private split zone
- ex4: Test split-horizon
- ex5: Understand priority

### Lab 6.10: Routing Policies (6 scripts)
- ex1: Understand routing policies
- ex2: Routing geolocation
- ex3: Weighted round robin
- ex4: Simulate WRR distribution
- ex5: Geolocation with health checks
- ex6: Manage routing policies

### Lab 6.11: Scénario intégrateur (1 script)
- Deploy full hybrid DNS architecture

### Cleanup (1 script)
- cleanup-module6.sh: Remove all Module 6 resources

## Usage

Each script follows the naming convention:
```
labX.Y_exN_description.sh
```

Where:
- X.Y = Lab number (e.g., 6.1, 6.2)
- N = Exercise number
- description = Brief description

All scripts are executable and include:
- Proper bash header with `#!/bin/bash`
- Description and objective
- `set -e` for error handling
- Echo statements showing progress
- Error checking where appropriate

## Execution Order

For best results, execute scripts in order:

1. Start with Lab 6.1 to create base infrastructure
2. Follow with Labs 6.2-6.10 as needed
3. Lab 6.11 is a complete integrated scenario (can be run independently)
4. Use cleanup-module6.sh to remove all resources

## Notes

- All scripts use the `europe-west1` region by default
- VMs are created without external IPs (using Cloud NAT)
- IAP is used for SSH access
- Scripts follow the same quality standards as Module 2

## Resources Created

The scripts create the following types of resources:
- VPCs and subnets
- VMs (Compute Engine instances)
- Cloud NAT and Cloud Routers
- DNS zones (private and public)
- DNS records (A, AAAA, CNAME, MX, TXT, SRV, CAA)
- DNS policies
- Firewall rules
- Health checks
- Logging metrics

## Cleanup

To remove all resources created in Module 6:

```bash
./cleanup-module6.sh
```

This will prompt for confirmation before deleting all resources.
