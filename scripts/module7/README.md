# Module 7 - Hybrid Connectivity Scripts

This directory contains executable bash scripts for all Module 7 labs covering Cloud VPN HA, BGP, Network Connectivity Center, and hybrid architectures.

## Prerequisites

- GCP project with billing enabled
- Required APIs: Compute Engine, Network Connectivity
- Required roles: `roles/compute.networkAdmin`, `roles/compute.securityAdmin`
- `gcloud` CLI configured with your project

## Lab Structure

### Lab 7.1: Cloud VPN HA - Complete Configuration

Complete setup of HA VPN with BGP between two VPCs simulating GCP and on-premise environments.

**Scripts:**
- `lab7.1_ex1_create-vpcs.sh` - Create VPC infrastructure (vpc-gcp and vpc-onprem)
- `lab7.1_ex2_configure-cloud-nat.sh` - Configure Cloud NAT for Internet access
- `lab7.1_ex3_deploy-vms.sh` - Deploy test VMs in both VPCs
- `lab7.1_ex4_verify-no-connectivity.sh` - Verify no connectivity before VPN
- `lab7.1_ex5_create-cloud-routers.sh` - Create Cloud Routers with BGP ASNs
- `lab7.1_ex6_create-vpn-gateways.sh` - Create HA VPN gateways
- `lab7.1_ex7_create-vpn-tunnels.sh` - Create 4 VPN tunnels (2 per gateway)
- `lab7.1_ex8_configure-bgp.sh` - Configure BGP interfaces and peers
- `lab7.1_ex9_verify-vpn-bgp.sh` - Verify VPN tunnels and BGP sessions
- `lab7.1_ex10_test-connectivity.sh` - Test connectivity through VPN

**Run in order:**
```bash
cd /home/ali/Training/gcp-net/scripts/module7
./lab7.1_ex1_create-vpcs.sh
./lab7.1_ex5_create-cloud-routers.sh
./lab7.1_ex2_configure-cloud-nat.sh
./lab7.1_ex3_deploy-vms.sh
./lab7.1_ex4_verify-no-connectivity.sh
./lab7.1_ex6_create-vpn-gateways.sh
./lab7.1_ex7_create-vpn-tunnels.sh
./lab7.1_ex8_configure-bgp.sh
./lab7.1_ex9_verify-vpn-bgp.sh
./lab7.1_ex10_test-connectivity.sh
```

### Lab 7.2: BGP with Cloud Router

Explore and configure BGP routing with Cloud Router.

**Scripts:**
- `lab7.2_ex1_explore-bgp-config.sh` - Explore BGP configuration
- `lab7.2_ex2_understand-routes.sh` - Understand BGP route exchange
- `lab7.2_ex3_add-subnet-propagation.sh` - Add subnet and observe propagation
- `lab7.2_ex4_custom-advertisements.sh` - Configure custom route advertisements

**Prerequisites:** Lab 7.1 must be completed first.

### Lab 7.3: Active/Active vs Active/Passive VPN

Compare and configure different VPN modes.

**Scripts:**
- `lab7.3_ex1_verify-active-active.sh` - Verify default Active/Active (ECMP) mode
- `lab7.3_ex2_observe-ecmp.sh` - Observe ECMP load distribution
- `lab7.3_ex3_configure-active-passive.sh` - Configure Active/Passive with MED
- `lab7.3_ex4_verify-active-passive.sh` - Verify Active/Passive configuration
- `lab7.3_ex5_restore-active-active.sh` - Restore Active/Active mode

**Prerequisites:** Lab 7.1 must be completed first.

### Lab 7.4: VPN Failover and High Availability

Test VPN failover mechanisms and measure convergence time.

**Scripts:**
- `lab7.4_ex1_prepare-failover-test.sh` - Prepare failover test
- `lab7.4_ex2_continuous-ping.sh` - Launch continuous ping (keep terminal open)
- `lab7.4_ex3_simulate-failure.sh` - Simulate tunnel failure (run in separate terminal)
- `lab7.4_ex4_observe-convergence.sh` - Observe routing convergence
- `lab7.4_ex5_restore-tunnel.sh` - Restore the deleted tunnel

**Prerequisites:** Lab 7.1 must be completed first.

**Usage for failover test:**
1. Terminal 1: Run `lab7.4_ex2_continuous-ping.sh` (keep running)
2. Terminal 2: Run `lab7.4_ex3_simulate-failure.sh` (observe packet loss in Terminal 1)
3. Terminal 2: Run `lab7.4_ex4_observe-convergence.sh`
4. Terminal 2: Run `lab7.4_ex5_restore-tunnel.sh`

### Lab 7.8: Network Connectivity Center - Hub and Spoke

Configure Network Connectivity Center for transitive connectivity between multiple sites.

**Scripts:**
- `lab7.8_ex1_create-multisite-infrastructure.sh` - Create hub and site VPCs
- `lab7.8_ex2_create-ncc-hub.sh` - Create NCC hub
- `lab7.8_ex3_establish-vpn-to-sites.sh` - Create VPN infrastructure for sites

**Note:** This lab demonstrates the NCC concept. Full VPN tunnel creation would follow Lab 7.1 patterns for each site.

### Lab 7.10: Complete Hybrid Architecture

Deploy a complete multi-site hybrid architecture with VPN and Cloud NAT.

**Scripts:**
- `lab7.10_deploy-full-hybrid-architecture.sh` - Deploy complete architecture

This script creates:
- 1 production VPC on GCP (10.0.1.0/24, 10.0.2.0/24)
- 3 site VPCs (Paris, Lyon, Berlin) simulating on-premise locations
- HA VPN tunnels connecting all sites to production
- BGP routing between all sites
- Cloud NAT for all VPCs
- Test VMs in each location

## Cleanup

To remove all resources created in Module 7:

```bash
./cleanup-module7.sh
```

This script will:
- Delete all VMs
- Delete NCC spokes and hubs
- Delete VPN tunnels and gateways
- Delete Cloud NAT configurations
- Delete Cloud Routers
- Delete firewall rules
- Delete subnets and VPCs

**Warning:** This will permanently delete all resources. You will be prompted for confirmation.

## Important Notes

### Cloud NAT Dependency
- Lab 7.1 Exercise 2 creates Cloud NAT configurations
- Cloud NAT must be created AFTER Cloud Routers (Exercise 5)
- Run Exercise 5 before Exercise 2, or Cloud NAT creation will fail

### Correct Execution Order for Lab 7.1
```bash
# 1. Infrastructure
./lab7.1_ex1_create-vpcs.sh

# 2. Cloud Routers (BEFORE Cloud NAT!)
./lab7.1_ex5_create-cloud-routers.sh

# 3. Cloud NAT (AFTER Cloud Routers!)
./lab7.1_ex2_configure-cloud-nat.sh

# 4. VMs and testing
./lab7.1_ex3_deploy-vms.sh
./lab7.1_ex4_verify-no-connectivity.sh

# 5. VPN setup
./lab7.1_ex6_create-vpn-gateways.sh
./lab7.1_ex7_create-vpn-tunnels.sh
./lab7.1_ex8_configure-bgp.sh

# 6. Verification
./lab7.1_ex9_verify-vpn-bgp.sh
./lab7.1_ex10_test-connectivity.sh
```

### VPN Tunnel Secrets
- Scripts generate random secrets for VPN tunnels
- Secrets are displayed in console output
- Save secrets if you need to recreate tunnels
- Lab 7.4 failover test requires the original secret to restore a tunnel

### BGP Convergence Time
- Allow 30-60 seconds for BGP sessions to establish
- Scripts include automatic wait times where needed
- Typical convergence after failure: 30-60 seconds

### Theoretical Labs (Not Included)
The following labs from module7_labs.md are theoretical and don't have scripts:
- Lab 7.5: Dedicated Interconnect (requires physical colocation)
- Lab 7.6: Partner Interconnect (requires service provider contracts)
- Lab 7.7: Cross-Cloud Interconnect (requires multi-cloud setup)
- Lab 7.9: Solution Comparison (analysis/decision framework)

## Cost Considerations

### Estimated Costs (europe-west1)
- e2-micro VMs: ~$7/month each
- Cloud VPN tunnels: ~$0.05/hour per tunnel (~$36/month per tunnel)
- Cloud NAT: ~$0.045/hour (~$32/month)
- Data egress: Variable based on usage

### Cost Optimization Tips
- Delete resources immediately after completing labs
- Use the cleanup script when finished
- VPN tunnels incur hourly charges even when idle
- Consider running only one lab at a time

## Troubleshooting

### VPN Tunnels Not Establishing
1. Check that both tunnels use the same shared secret
2. Verify BGP ASN configuration (must be different on each side)
3. Check firewall rules allow traffic between VPCs
4. Wait 60 seconds for BGP convergence

### BGP Sessions Not Up
1. Verify tunnel status is "Established"
2. Check BGP interface IP addresses (must be on same /30 subnet)
3. Verify peer ASN numbers match configuration
4. Check Cloud Router status: `gcloud compute routers get-status`

### Cloud NAT Not Working
1. Verify Cloud Router exists before creating NAT
2. Check NAT is configured for correct subnets
3. Verify VM has no external IP address
4. Test with: `curl ifconfig.me` from VM

### Cannot Connect to VMs
- Use IAP tunneling: `--tunnel-through-iap` flag
- Verify firewall rule allows SSH from 35.235.240.0/20
- Ensure VM is running: `gcloud compute instances list`

## Architecture Diagrams

For detailed architecture diagrams and explanations, refer to:
- `/home/ali/Training/gcp-net/module7_labs.md`

## Related Documentation

- [Cloud VPN Documentation](https://cloud.google.com/network-connectivity/docs/vpn)
- [Cloud Router Documentation](https://cloud.google.com/network-connectivity/docs/router)
- [Network Connectivity Center](https://cloud.google.com/network-connectivity/docs/network-connectivity-center)
- [Cloud NAT Documentation](https://cloud.google.com/nat/docs)
