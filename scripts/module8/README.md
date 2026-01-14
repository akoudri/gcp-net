# Module 8 - Network Security Scripts

This directory contains all bash scripts for Module 8 labs on Network Security (Contrôle d'Accès et Sécurité Réseau).

## Overview

34 executable scripts covering:
- IAM Network Roles and Permissions
- VPC Firewall Rules (Tags and Service Accounts)
- Network Firewall Policies (Global and Regional)
- Hierarchical Firewall Policies
- Firewall Logging and Analysis
- IAP (Identity-Aware Proxy)
- Cloud IDS (Intrusion Detection System)
- Security Best Practices and Auditing
- Complete Secure Architecture Deployment

## Lab Structure

### Lab 8.1 - IAM Network Roles
- `lab8.1_ex1_discover-network-roles.sh` - Discover available network IAM roles
- `lab8.1_ex3_compare-permissions.sh` - Compare permissive vs. correct configurations
- `lab8.1_ex4_create-custom-role.sh` - Create custom IAM role with limited permissions

### Lab 8.2 - VPC Firewall Rules Fundamentals
- `lab8.2_ex1_create-infrastructure.sh` - Create VPC and subnets
- `lab8.2_ex2_configure-cloud-nat.sh` - Configure Cloud NAT for egress
- `lab8.2_ex3_create-vms.sh` - Create VMs with network tags
- `lab8.2_ex4_understand-default-rules.sh` - Understand implicit firewall rules
- `lab8.2_ex5_create-firewall-rules.sh` - Create ingress firewall rules
- `lab8.2_ex6_add-deny-rules.sh` - Add explicit deny rules
- `lab8.2_ex7_test-firewall-rules.sh` - Test firewall rules connectivity

### Lab 8.3 - Network Tags vs Service Accounts
- `lab8.3_ex2_create-service-accounts.sh` - Create service accounts per tier
- `lab8.3_ex3_configure-cloud-nat-firewall.sh` - Configure Cloud NAT
- `lab8.3_ex4_create-vms-with-sa.sh` - Create VMs with service accounts
- `lab8.3_ex5_create-sa-firewall-rules.sh` - Create SA-based firewall rules

### Lab 8.4 - Network Firewall Policies
- `lab8.4_ex2_create-global-policy.sh` - Create global network firewall policy
- `lab8.4_ex3_associate-policy.sh` - Associate policy to VPC
- `lab8.4_ex4_create-regional-policy.sh` - Create regional policy
- `lab8.4_ex5_test-evaluation-order.sh` - Test rule evaluation order

### Lab 8.5 - Hierarchical Firewall Policies
- `lab8.5_ex3_simulate-hierarchical.sh` - Simulate hierarchical policies at project level

### Lab 8.6 - Firewall Logging and Analysis
- `lab8.6_ex1_enable-logging.sh` - Enable logging on firewall rules
- `lab8.6_ex2_generate-traffic.sh` - Generate traffic for logs
- `lab8.6_ex3_view-logs.sh` - View firewall logs in Cloud Logging
- `lab8.6_ex5_advanced-analysis.sh` - Advanced log analysis and metrics

### Lab 8.7 - IAP (Identity-Aware Proxy)
- `lab8.7_ex1_verify-iap-config.sh` - Verify IAP firewall configuration
- `lab8.7_ex2_configure-iam.sh` - Configure IAM permissions for IAP
- `lab8.7_ex3_test-ssh-via-iap.sh` - Test SSH connection via IAP
- `lab8.7_ex5_audit-iap-connections.sh` - Audit IAP access logs

### Lab 8.8 - Cloud IDS (Intrusion Detection)
- `lab8.8_ex1_create-ids-endpoint.sh` - Create Cloud IDS endpoint (COSTLY!)
- `lab8.8_ex5_cleanup-ids.sh` - Clean up Cloud IDS resources

### Lab 8.10 - Security Best Practices
- `lab8.10_ex1_security-audit.sh` - Audit firewall security
- `lab8.10_ex2_architecture-audit.sh` - Audit network architecture
- `lab8.10_ex4_security-audit-script.sh` - Complete security audit script

### Lab 8.11 - Secure Architecture Integration
- `lab8.11_deploy-secure-architecture.sh` - Deploy complete secure architecture

### Cleanup
- `cleanup-module8.sh` - Clean up all Module 8 resources

## Usage

### Sequential Execution
For a complete lab experience, execute scripts in order:

```bash
cd /home/ali/Training/gcp-net/scripts/module8

# Lab 8.1 - IAM
./lab8.1_ex1_discover-network-roles.sh
./lab8.1_ex3_compare-permissions.sh
./lab8.1_ex4_create-custom-role.sh

# Lab 8.2 - VPC Firewall Rules
./lab8.2_ex1_create-infrastructure.sh
./lab8.2_ex2_configure-cloud-nat.sh
./lab8.2_ex3_create-vms.sh
./lab8.2_ex4_understand-default-rules.sh
./lab8.2_ex5_create-firewall-rules.sh
./lab8.2_ex6_add-deny-rules.sh
./lab8.2_ex7_test-firewall-rules.sh

# Lab 8.3 - Service Accounts
./lab8.3_ex2_create-service-accounts.sh
./lab8.3_ex3_configure-cloud-nat-firewall.sh
./lab8.3_ex4_create-vms-with-sa.sh
./lab8.3_ex5_create-sa-firewall-rules.sh

# Continue with other labs...
```

### Cleanup
After completing the labs:

```bash
./cleanup-module8.sh
```

## Important Notes

### Prerequisites
- GCP project with billing enabled
- Required IAM roles:
  - `roles/compute.networkAdmin`
  - `roles/compute.securityAdmin`
  - `roles/iam.serviceAccountAdmin`
- Organization access required for Lab 8.5 (hierarchical policies)

### Cost Warnings
- **Lab 8.8 (Cloud IDS)**: ~$1.50/hour - Always clean up immediately after testing
- VMs use `e2-micro` and `e2-small` to minimize costs
- Cloud NAT incurs charges for NAT gateway and data processing

### Resource Naming
Scripts follow the naming convention from CLAUDE.md:
- VPCs: `vpc-security-lab`, `vpc-secure`
- VMs: `vm-{role}-{lab}` (e.g., `vm-web-sa`)
- Service Accounts: `sa-{tier}` (e.g., `sa-web`)

### Key Features
- All scripts have `set -e` for error handling
- Progress messages with echo statements
- Educational questions at the end of each script
- Proper descriptions in headers
- Logging enabled where appropriate
- Service Account-based rules for production security

### Dependencies
Some labs depend on previous labs:
- Lab 8.3 requires Lab 8.2 (infrastructure)
- Lab 8.6 (logging) requires Lab 8.3 (SA-based VMs)
- Lab 8.7 (IAP) can use VMs from Lab 8.3

### Region and Zone
Default configuration:
- Region: `europe-west1`
- Zone: `europe-west1-b`

Modify these variables in scripts if needed.

## Troubleshooting

### Common Issues

1. **VPC already exists**: Run cleanup script first
2. **Permission denied**: Verify IAM roles
3. **Quota exceeded**: Check and request quota increase
4. **Cloud IDS timeout**: Wait 15-30 minutes for endpoint creation

### Verification Commands

```bash
# List VPCs
gcloud compute networks list

# List firewall rules
gcloud compute firewall-rules list --filter="network:vpc-security-lab"

# List VMs
gcloud compute instances list

# List Service Accounts
gcloud iam service-accounts list

# View logs
gcloud logging read 'resource.type="gce_subnetwork"' --limit=10
```

## Architecture Diagram

```
Module 8 Labs - Security Architecture
┌────────────────────────────────────────────────────────────────┐
│                    Global Network Policy                        │
│  - Deny dangerous ports (Telnet, RDP, SMB)                     │
│  - Allow Health Checks                                          │
│  - Allow IAP                                                    │
└────────────────────────────────────────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────────┐
│            VPC (vpc-security-lab / vpc-secure)                │
│                            │                                  │
│  ┌─────────────────┐      │      ┌─────────────────┐         │
│  │  subnet-dmz     │      │      │  subnet-backend │         │
│  │  10.0.1.0/24    │      │      │  10.0.2.0/24    │         │
│  │                 │      │      │                 │         │
│  │  vm-web (SA)    │──────┼─────►│  vm-api (SA)    │         │
│  │  :80/:443       │   :8080     │  :8080          │         │
│  │                 │      │      │       │         │         │
│  └─────────────────┘      │      │       ▼ :5432   │         │
│                           │      │  vm-db (SA)     │         │
│                           │      │                 │         │
│  VPC Flow Logs: ✓         │      │  Private Google │         │
│  Cloud NAT: ✓             │      │  Access: ✓      │         │
│  IAP Access: ✓            │      │  No public IPs  │         │
└───────────────────────────┼─────────────────────────────────┘
                            │
                     Internet (egress via NAT)
```

## Learning Objectives

By completing these labs, you will learn:
- IAM network roles and least privilege principle
- VPC firewall rules (tags vs. service accounts)
- Network Firewall Policies (global and regional)
- Hierarchical firewall policy concepts
- Firewall logging and analysis
- Bastionless access with IAP
- Intrusion detection with Cloud IDS
- Security audit and best practices
- Complete secure architecture design

## Additional Resources

- [GCP VPC Firewall Rules Documentation](https://cloud.google.com/vpc/docs/firewalls)
- [Network Firewall Policies](https://cloud.google.com/vpc/docs/network-firewall-policies)
- [Identity-Aware Proxy](https://cloud.google.com/iap/docs)
- [Cloud IDS Documentation](https://cloud.google.com/ids/docs)
- [VPC Security Best Practices](https://cloud.google.com/vpc/docs/best-practices)
