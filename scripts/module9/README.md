# Module 9 - DDoS Protection and Cloud Armor Scripts

This directory contains 39 bash scripts for Module 9 labs covering Cloud Armor and DDoS protection.

## Prerequisites

- GCP project with billing enabled
- Appropriate IAM permissions:
  - `roles/compute.securityAdmin`
  - `roles/compute.loadBalancerAdmin`
- gcloud CLI configured

## Script Organization

### Lab 9.2: Deploy Application Load Balancer (5 scripts)

Infrastructure setup required for Cloud Armor:

1. `lab9.2_ex1_create-infrastructure.sh` - Create VPC and firewall rules
2. `lab9.2_ex2_create-instance-template.sh` - Create instance template and managed instance group
3. `lab9.2_ex3_create-health-check-backend.sh` - Configure health checks and backend service
4. `lab9.2_ex4_create-urlmap-frontend.sh` - Create URL map and load balancer frontend
5. `lab9.2_ex5_test-load-balancer.sh` - Test the load balancer functionality

### Lab 9.3: Create Basic Cloud Armor Policy (4 scripts)

1. `lab9.3_ex1_create-security-policy.sh` - Create Cloud Armor security policy
2. `lab9.3_ex2_configure-default-rule.sh` - Configure default rule behavior
3. `lab9.3_ex3_attach-policy.sh` - Attach policy to backend service
4. `lab9.3_ex4_test-policy-active.sh` - Verify policy is active

### Lab 9.4: IP and Geolocation Filtering (4 scripts)

1. `lab9.4_ex1_block-ip-range.sh` - Block specific IP ranges (test with your IP)
2. `lab9.4_ex2_block-malicious-ranges.sh` - Block multiple malicious IP ranges
3. `lab9.4_ex3_geolocation-allow.sh` - Allow only specific countries
4. `lab9.4_ex4_geolocation-block.sh` - Block specific countries

### Lab 9.5: Advanced CEL Expressions (5 scripts)

1. `lab9.5_ex2_filter-by-path.sh` - Block access to /admin path
2. `lab9.5_ex3_filter-by-method.sh` - Block DELETE/PUT methods on /api
3. `lab9.5_ex4_filter-by-header.sh` - Filter by User-Agent and require API key
4. `lab9.5_ex5_geolocation-and-path.sh` - Combine geolocation with path filtering
5. `lab9.5_ex6_filter-by-query.sh` - Block suspicious query strings

### Lab 9.6: Preconfigured WAF Rules (OWASP) (5 scripts)

1. `lab9.6_ex2_enable-sqli-protection.sh` - Enable SQL Injection protection (preview mode)
2. `lab9.6_ex3_enable-xss-protection.sh` - Enable XSS protection (preview mode)
3. `lab9.6_ex4_test-waf-rules.sh` - Test WAF rule detection
4. `lab9.6_ex5_adjust-sensitivity.sh` - Adjust sensitivity and exclude rules
5. `lab9.6_ex6_enable-enforce-mode.sh` - Enable enforce mode (actual blocking)

### Lab 9.7: Rate Limiting and Throttling (5 scripts)

1. `lab9.7_ex2_configure-throttling.sh` - Configure basic throttling (60 req/min)
2. `lab9.7_ex3_test-throttling.sh` - Test throttling with 65 requests
3. `lab9.7_ex4_configure-rate-based-ban.sh` - Configure rate-based ban (100 req/min)
4. `lab9.7_ex5_rate-limit-endpoint.sh` - Rate limit specific endpoint (/api/login)
5. `lab9.7_ex6_rate-limit-by-header.sh` - Rate limit by API key header

### Lab 9.8: Preview Mode and Log Analysis (3 scripts)

1. `lab9.8_ex1_enable-preview-mode.sh` - Enable preview mode for testing
2. `lab9.8_ex2_generate-test-traffic.sh` - Generate malicious test traffic
3. `lab9.8_ex3_analyze-logs.sh` - Analyze Cloud Armor logs

### Lab 9.9: Named IP Lists and Threat Intelligence (4 scripts)

1. `lab9.9_ex2_allow-google-crawlers.sh` - Allow Googlebot crawlers
2. `lab9.9_ex3_block-tor-nodes.sh` - Block Tor exit nodes
3. `lab9.9_ex4_block-malicious-ips.sh` - Block known malicious IPs
4. `lab9.9_ex5_force-cdn-traffic.sh` - Force traffic through CDN (Cloudflare/Fastly)

### Lab 9.10: Edge Security Policies (2 scripts)

1. `lab9.10_ex2_create-edge-policy.sh` - Create edge security policy
2. `lab9.10_ex3_attach-edge-policy.sh` - Attach edge policy and enable Cloud CDN

### Lab 9.11: Complete Protection Scenario (1 script)

1. `lab9.11_deploy-complete-policy.sh` - Deploy comprehensive security policy

### Cleanup (1 script)

- `cleanup-module9.sh` - Remove all Module 9 resources

## Usage

### Quick Start (Sequential Execution)

```bash
cd /home/ali/Training/gcp-net/scripts/module9

# 1. Deploy infrastructure (Lab 9.2)
./lab9.2_ex1_create-infrastructure.sh
./lab9.2_ex2_create-instance-template.sh
./lab9.2_ex3_create-health-check-backend.sh
./lab9.2_ex4_create-urlmap-frontend.sh
./lab9.2_ex5_test-load-balancer.sh

# 2. Create basic Cloud Armor policy (Lab 9.3)
./lab9.3_ex1_create-security-policy.sh
./lab9.3_ex3_attach-policy.sh
./lab9.3_ex4_test-policy-active.sh

# 3. Add filtering rules (Labs 9.4-9.5)
./lab9.4_ex2_block-malicious-ranges.sh
./lab9.5_ex2_filter-by-path.sh

# 4. Enable WAF protection (Lab 9.6)
./lab9.6_ex2_enable-sqli-protection.sh
./lab9.6_ex3_enable-xss-protection.sh
./lab9.6_ex4_test-waf-rules.sh

# 5. Configure rate limiting (Lab 9.7)
./lab9.7_ex2_configure-throttling.sh

# 6. Add threat intelligence (Lab 9.9)
./lab9.9_ex3_block-tor-nodes.sh
./lab9.9_ex4_block-malicious-ips.sh
```

### Alternative: Deploy Complete Policy

Instead of executing individual labs, deploy the complete policy:

```bash
cd /home/ali/Training/gcp-net/scripts/module9

# 1. Deploy infrastructure
./lab9.2_ex1_create-infrastructure.sh
./lab9.2_ex2_create-instance-template.sh
./lab9.2_ex3_create-health-check-backend.sh
./lab9.2_ex4_create-urlmap-frontend.sh

# 2. Deploy complete security policy
./lab9.11_deploy-complete-policy.sh
```

### Cleanup

To remove all resources:

```bash
cd /home/ali/Training/gcp-net/scripts/module9
./cleanup-module9.sh
```

## Important Notes

### Resource Order

Cloud Armor requires an Application Load Balancer. Always deploy Lab 9.2 infrastructure first before creating security policies.

### Preview Mode

Many scripts use preview mode to test rules without blocking:
- Preview mode logs detections but doesn't block
- Use this to identify false positives
- Activate enforce mode only after validation

### Rule Priorities

Rules are evaluated in priority order (lowest number first):
- 10-99: Explicit allow rules (e.g., Googlebot)
- 100-199: IP blocklists
- 200-299: Geolocation rules
- 300-399: Path/access rules
- 500-599: Rate limiting
- 1000-1999: WAF rules
- 2147483647: Default rule

### Testing Considerations

- Some scripts include interactive prompts for safety
- Test scripts may temporarily block your IP
- WAF test scripts generate intentionally malicious traffic
- Rate limiting tests require rapid requests

### Costs

Running these labs incurs GCP costs:
- Load Balancer forwarding rules
- Compute instances (e2-small x2+)
- Cloud Armor policy and rules
- Data egress

Estimated cost: ~$10-20 for a full day of testing.

## Troubleshooting

### Load Balancer not responding

```bash
# Check backend health
gcloud compute backend-services get-health backend-web --global

# Wait for backends to become healthy (can take 2-5 minutes)
```

### Rules not applying

- Rules can take 10-30 seconds to propagate
- Check rule preview mode status
- Verify rule priority order

### 403 errors when testing

- Check if your IP is blocked by a rule
- Review rule expressions for typos
- Use Cloud Console Logs Explorer to see which rule matched

## References

- [Cloud Armor Documentation](https://cloud.google.com/armor/docs)
- [CEL Expression Language](https://cloud.google.com/armor/docs/rules-language-reference)
- [Preconfigured WAF Rules](https://cloud.google.com/armor/docs/waf-rules)
- Module 9 Lab Guide: `/home/ali/Training/gcp-net/module9_labs.md`
