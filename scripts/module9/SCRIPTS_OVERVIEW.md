# Module 9 Scripts - Complete Overview

## Summary

Created **39 executable bash scripts** for Module 9 (DDoS Protection and Cloud Armor) covering all exercises from the lab documentation.

## Script Inventory

### Infrastructure Setup (Lab 9.2) - 5 scripts

| Script | Purpose | Resources Created |
|--------|---------|-------------------|
| `lab9.2_ex1_create-infrastructure.sh` | Create VPC and firewall rules | VPC, subnet, 3 firewall rules |
| `lab9.2_ex2_create-instance-template.sh` | Create instance template and group | Instance template, managed instance group |
| `lab9.2_ex3_create-health-check-backend.sh` | Configure backend service | Health check, backend service |
| `lab9.2_ex4_create-urlmap-frontend.sh` | Create load balancer frontend | URL map, IP address, forwarding rule |
| `lab9.2_ex5_test-load-balancer.sh` | Test load balancer | N/A (testing only) |

### Basic Cloud Armor Policy (Lab 9.3) - 4 scripts

| Script | Purpose | Actions |
|--------|---------|---------|
| `lab9.3_ex1_create-security-policy.sh` | Create security policy | Creates policy-web-app |
| `lab9.3_ex2_configure-default-rule.sh` | Review default rule | Shows default rule configuration |
| `lab9.3_ex3_attach-policy.sh` | Attach to backend | Links policy to backend-web |
| `lab9.3_ex4_test-policy-active.sh` | Verify activation | Tests policy is working |

### IP and Geolocation Filtering (Lab 9.4) - 4 scripts

| Script | Purpose | Rule Priority |
|--------|---------|---------------|
| `lab9.4_ex1_block-ip-range.sh` | Block your IP (test) | 100 (temporary) |
| `lab9.4_ex2_block-malicious-ranges.sh` | Block RFC 5737 test ranges | 100 |
| `lab9.4_ex3_geolocation-allow.sh` | Allow only FR/BE/CH/CA | 200 |
| `lab9.4_ex4_geolocation-block.sh` | Block specific countries | 200 |

### Advanced CEL Expressions (Lab 9.5) - 5 scripts

| Script | Purpose | Rule Priority |
|--------|---------|---------------|
| `lab9.5_ex2_filter-by-path.sh` | Block /admin path | 300 |
| `lab9.5_ex3_filter-by-method.sh` | Block DELETE/PUT on /api | 310 |
| `lab9.5_ex4_filter-by-header.sh` | Filter by User-Agent and API key | 320, 330 |
| `lab9.5_ex5_geolocation-and-path.sh` | Admin only from France | 300 (update) |
| `lab9.5_ex6_filter-by-query.sh` | Block suspicious query strings | 340 |

### WAF Rules - OWASP (Lab 9.6) - 5 scripts

| Script | Purpose | Rule Priority |
|--------|---------|---------------|
| `lab9.6_ex2_enable-sqli-protection.sh` | SQL Injection protection (preview) | 1000 |
| `lab9.6_ex3_enable-xss-protection.sh` | XSS protection (preview) | 1100 |
| `lab9.6_ex4_test-waf-rules.sh` | Test WAF detection | N/A (testing) |
| `lab9.6_ex5_adjust-sensitivity.sh` | Adjust sensitivity and exclusions | 1000 (update) |
| `lab9.6_ex6_enable-enforce-mode.sh` | Enable enforce mode | 1000, 1100 (update) |

### Rate Limiting (Lab 9.7) - 5 scripts

| Script | Purpose | Rule Priority |
|--------|---------|---------------|
| `lab9.7_ex2_configure-throttling.sh` | Throttle 60 req/min per IP | 500 |
| `lab9.7_ex3_test-throttling.sh` | Test throttling (65 requests) | N/A (testing) |
| `lab9.7_ex4_configure-rate-based-ban.sh` | Ban if >100 req/min | 510 |
| `lab9.7_ex5_rate-limit-endpoint.sh` | Limit /api/login endpoint | 520 |
| `lab9.7_ex6_rate-limit-by-header.sh` | Rate limit by API key | 530 |

### Preview Mode and Logs (Lab 9.8) - 3 scripts

| Script | Purpose | Actions |
|--------|---------|---------|
| `lab9.8_ex1_enable-preview-mode.sh` | Enable preview mode | Updates rules to preview |
| `lab9.8_ex2_generate-test-traffic.sh` | Generate malicious traffic | Sends SQLi/XSS/LFI requests |
| `lab9.8_ex3_analyze-logs.sh` | Analyze Cloud Armor logs | Queries Cloud Logging |

### Threat Intelligence (Lab 9.9) - 4 scripts

| Script | Purpose | Rule Priority |
|--------|---------|---------------|
| `lab9.9_ex2_allow-google-crawlers.sh` | Allow Googlebot | 10 |
| `lab9.9_ex3_block-tor-nodes.sh` | Block Tor exit nodes | 150 |
| `lab9.9_ex4_block-malicious-ips.sh` | Block known malicious IPs | 160 |
| `lab9.9_ex5_force-cdn-traffic.sh` | Force CDN (Cloudflare/Fastly) | 20 |

### Edge Security (Lab 9.10) - 2 scripts

| Script | Purpose | Resources |
|--------|---------|-----------|
| `lab9.10_ex2_create-edge-policy.sh` | Create edge security policy | Edge policy with 2 rules |
| `lab9.10_ex3_attach-edge-policy.sh` | Attach edge policy and enable CDN | Updates backend-web |

### Complete Scenario (Lab 9.11) - 1 script

| Script | Purpose | Rules Created |
|--------|---------|---------------|
| `lab9.11_deploy-complete-policy.sh` | Deploy comprehensive policy | 11 rules (P10-P1500) |

### Cleanup - 1 script

| Script | Purpose | Actions |
|--------|---------|---------|
| `cleanup-module9.sh` | Remove all Module 9 resources | Deletes all created resources |

## Rule Priority Hierarchy

Complete policy rule structure:

```
Priority  10: Allow Googlebot (explicit allow)
Priority  20: Force CDN traffic (optional)
Priority 100: Block blacklisted IP ranges
Priority 150: Block Tor exit nodes
Priority 160: Block malicious IPs (Threat Intel)
Priority 200: Geolocation filtering
Priority 300: Block /admin path
Priority 310: Block DELETE/PUT on /api
Priority 320: Filter invalid User-Agents
Priority 330: Require API key for /api
Priority 340: Block suspicious query strings
Priority 500: Throttle 100 req/min per IP
Priority 510: Rate-based ban for login
Priority 520: Limit /api/login to 5 req/min
Priority 530: Rate limit by API key header
Priority 1000: WAF - SQL Injection
Priority 1100: WAF - XSS
Priority 1200: WAF - LFI
Priority 1300: WAF - RFI
Priority 1400: WAF - RCE
Priority 1500: WAF - Scanner Detection
Priority 2147483647: Default rule (allow/deny)
```

## Resources Created

### Core Infrastructure
- 1 VPC (vpc-armor-lab)
- 1 Subnet (subnet-web)
- 3 Firewall rules
- 1 Instance template (web-template)
- 1 Managed instance group (2-5 instances)

### Load Balancer
- 1 Health check
- 1 Backend service
- 1 URL map
- 1 Global IP address
- 1 Target HTTP proxy
- 1 Forwarding rule

### Cloud Armor
- 1-3 Security policies (policy-web-app, policy-complete, edge-policy)
- Up to 20+ security rules

### Estimated Costs
- Load Balancer: ~$18/month base + data processing
- Compute instances: ~$25/month (2x e2-small)
- Cloud Armor: ~$5/policy + $0.75/million requests
- **Total for full day testing: ~$10-20**

## Key Features

### Script Design
- Proper bash headers with `#!/bin/bash`
- Error handling with `set -e`
- Progress indicators with echo statements
- Variable definitions for flexibility
- Verification commands after resource creation
- Interactive prompts for destructive operations

### Following Module 2 Patterns
- Same header format and style
- Consistent variable naming
- Similar error handling approach
- Matching documentation style
- Comparable verification steps

### Educational Value
- Clear descriptions in comments
- Verification commands included
- Test scripts for hands-on learning
- Progressive complexity
- Production-ready examples

## Usage Examples

### Sequential Lab Execution
```bash
cd /home/ali/Training/gcp-net/scripts/module9

# Complete Lab 9.2 (infrastructure)
for script in lab9.2_ex*.sh; do ./"$script"; done

# Complete Lab 9.3 (basic policy)
for script in lab9.3_ex*.sh; do ./"$script"; done

# Complete Lab 9.6 (WAF)
for script in lab9.6_ex*.sh; do ./"$script"; done
```

### Quick Production Setup
```bash
# 1. Infrastructure
./lab9.2_ex1_create-infrastructure.sh
./lab9.2_ex2_create-instance-template.sh
./lab9.2_ex3_create-health-check-backend.sh
./lab9.2_ex4_create-urlmap-frontend.sh

# 2. Wait for backends to be healthy
sleep 60

# 3. Complete security policy
./lab9.11_deploy-complete-policy.sh
```

### Cleanup
```bash
./cleanup-module9.sh
```

## Testing & Validation

All scripts include:
1. Resource creation confirmation
2. gcloud describe/list commands for verification
3. Test commands where applicable
4. Clear success/failure indicators

## Documentation

- Individual script comments in French (matching lab guide)
- README.md with comprehensive usage guide
- SCRIPTS_OVERVIEW.md (this file) with complete reference
- Inline comments explaining complex commands

## Alignment with Lab Guide

Scripts cover:
- ✓ All 11 labs from Module 9
- ✓ All exercises with bash code
- ✓ Conceptual exercises documented in comments
- ✓ Complete cleanup script
- ✓ Following naming convention: `labX.Y_exN_description.sh`
- ✓ Proper headers with `#!/bin/bash`, description, and `set -e`
- ✓ Echo statements for progress indication
- ✓ Executable permissions (chmod +x)

## File Locations

```
/home/ali/Training/gcp-net/scripts/module9/
├── README.md                                    (Usage guide)
├── SCRIPTS_OVERVIEW.md                          (This file)
├── cleanup-module9.sh                           (Cleanup script)
├── lab9.2_ex1_create-infrastructure.sh          (Lab 9.2 - Ex 1)
├── lab9.2_ex2_create-instance-template.sh       (Lab 9.2 - Ex 2)
├── lab9.2_ex3_create-health-check-backend.sh    (Lab 9.2 - Ex 3)
├── lab9.2_ex4_create-urlmap-frontend.sh         (Lab 9.2 - Ex 4)
├── lab9.2_ex5_test-load-balancer.sh             (Lab 9.2 - Ex 5)
├── lab9.3_ex1_create-security-policy.sh         (Lab 9.3 - Ex 1)
├── lab9.3_ex2_configure-default-rule.sh         (Lab 9.3 - Ex 2)
├── lab9.3_ex3_attach-policy.sh                  (Lab 9.3 - Ex 3)
├── lab9.3_ex4_test-policy-active.sh             (Lab 9.3 - Ex 5)
├── lab9.4_ex1_block-ip-range.sh                 (Lab 9.4 - Ex 1)
├── lab9.4_ex2_block-malicious-ranges.sh         (Lab 9.4 - Ex 2)
├── lab9.4_ex3_geolocation-allow.sh              (Lab 9.4 - Ex 3)
├── lab9.4_ex4_geolocation-block.sh              (Lab 9.4 - Ex 4)
├── lab9.5_ex2_filter-by-path.sh                 (Lab 9.5 - Ex 2)
├── lab9.5_ex3_filter-by-method.sh               (Lab 9.5 - Ex 3)
├── lab9.5_ex4_filter-by-header.sh               (Lab 9.5 - Ex 4)
├── lab9.5_ex5_geolocation-and-path.sh           (Lab 9.5 - Ex 5)
├── lab9.5_ex6_filter-by-query.sh                (Lab 9.5 - Ex 6)
├── lab9.6_ex2_enable-sqli-protection.sh         (Lab 9.6 - Ex 2)
├── lab9.6_ex3_enable-xss-protection.sh          (Lab 9.6 - Ex 3)
├── lab9.6_ex4_test-waf-rules.sh                 (Lab 9.6 - Ex 4)
├── lab9.6_ex5_adjust-sensitivity.sh             (Lab 9.6 - Ex 5)
├── lab9.6_ex6_enable-enforce-mode.sh            (Lab 9.6 - Ex 6)
├── lab9.7_ex2_configure-throttling.sh           (Lab 9.7 - Ex 2)
├── lab9.7_ex3_test-throttling.sh                (Lab 9.7 - Ex 3)
├── lab9.7_ex4_configure-rate-based-ban.sh       (Lab 9.7 - Ex 4)
├── lab9.7_ex5_rate-limit-endpoint.sh            (Lab 9.7 - Ex 5)
├── lab9.7_ex6_rate-limit-by-header.sh           (Lab 9.7 - Ex 6)
├── lab9.8_ex1_enable-preview-mode.sh            (Lab 9.8 - Ex 1)
├── lab9.8_ex2_generate-test-traffic.sh          (Lab 9.8 - Ex 2)
├── lab9.8_ex3_analyze-logs.sh                   (Lab 9.8 - Ex 3)
├── lab9.9_ex2_allow-google-crawlers.sh          (Lab 9.9 - Ex 2)
├── lab9.9_ex3_block-tor-nodes.sh                (Lab 9.9 - Ex 3)
├── lab9.9_ex4_block-malicious-ips.sh            (Lab 9.9 - Ex 4)
├── lab9.9_ex5_force-cdn-traffic.sh              (Lab 9.9 - Ex 5)
├── lab9.10_ex2_create-edge-policy.sh            (Lab 9.10 - Ex 2)
├── lab9.10_ex3_attach-edge-policy.sh            (Lab 9.10 - Ex 3)
└── lab9.11_deploy-complete-policy.sh            (Lab 9.11)
```

## Next Steps

To use these scripts:

1. **Review the lab guide**: `/home/ali/Training/gcp-net/module9_labs.md`
2. **Read the README**: `/home/ali/Training/gcp-net/scripts/module9/README.md`
3. **Execute in order**: Start with Lab 9.2 infrastructure setup
4. **Experiment**: Modify rules to test different scenarios
5. **Clean up**: Always run `cleanup-module9.sh` when done

## Notes

- Lab 9.1 exercises are conceptual (no bash scripts) - covered in comments
- Exercise numbering follows the lab guide exactly
- Some exercises were merged into logical script units
- All bash code blocks from the lab guide are included
- Scripts follow the same quality and structure as Module 2 scripts
