# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GCP Networking Training Program - educational training kit for teaching Google Cloud Platform networking concepts. Documentation is in French, scripts in English/Bash. Contains 11 module-based lab exercises covering VPC, routing, DNS, VPN, load balancing, security, and monitoring.

## Management Scripts

All scripts are located in `gcp-training-setup/`:

```bash
# Initial project setup (creates GCP project, IAM roles, enables APIs, configures budget)
cd gcp-training-setup
cp config.env.template config.env  # Edit with your GCP project details
./setup-training-project.sh

# Learner management
./manage-trainees.sh add email@example.com
./manage-trainees.sh remove email@example.com
./manage-trainees.sh list

# Resource cleanup
./cleanup-resources.sh              # Interactive with confirmation
./cleanup-resources.sh --dry-run    # Preview what would be deleted
./cleanup-resources.sh --force      # No confirmation
./cleanup-resources.sh --prefix=ali-  # Cleanup specific learner's resources

# Status monitoring
./check-status.sh                   # Shows project status, budget, active resources
```

## Architecture

### Training Environment
- **Shared GCP Project**: One project for all learners with custom "Trainee" IAM role
- **Security Model**: Learners can create networking resources but cannot modify IAM, billing, or project settings
- **Budget Controls**: Automatic alerts at 25%, 50%, 75%, 90%, 100% thresholds
- **Resource Naming Convention**: `{resource}-{firstname}-m{module}-l{lab}` (e.g., `vpc-ali-m2-l3`)

### Lab Modules Structure
```
Module 1  : TCP/IP Fundamentals (ping, traceroute, Wireshark, Packet Tracer)
Module 2  : VPC Fundamentals (VPCs, subnets, firewall rules)
Module 3  : Routing and Addressing (Cloud Router, route tables)
Module 4  : VPC Sharing (Shared VPC, VPC Peering)
Module 5  : Private Connectivity (Private Google Access, Private Service Connect)
Module 6  : Cloud DNS (zones, records, forwarding)
Module 7  : Hybrid Connectivity (Cloud VPN, Cloud Interconnect)
Module 8  : Network Security (firewall policies, hierarchical rules)
Module 9  : DDoS Protection and Cloud Armor
Module 10 : Load Balancing (HTTP(S), TCP/UDP, internal)
Module 11 : Monitoring and Logging (VPC Flow Logs, Network Intelligence Center)
```

### Key Configuration (`config.env`)
```bash
PROJECT_ID="formation-gcp-networking-2025"
BILLING_ACCOUNT_ID="XXXXXX-XXXXXX-XXXXXX"
REGION="europe-west1"
BUDGET_AMOUNT="300"
TRAINEES="email1@gmail.com, email2@gmail.com"
AUTO_CLEANUP="true"
```

### GCP APIs Enabled
compute, networkmanagement, dns, logging, monitoring, cloudtrace, storage, bigquery, run, cloudfunctions, servicenetworking, vpcaccess, cloudresourcemanager, iam, billingbudgets, serviceusage, oslogin, iap, cloudarmor

## Resource Deletion Order

Resources have dependencies; delete in this order:
1. Load Balancers (forwarding rules → proxies → url-maps → backend services)
2. VPN (tunnels → gateways)
3. VMs
4. Firewall rules
5. Routes
6. Subnets
7. VPCs
