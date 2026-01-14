# Module 2 - Scripts Disponibles

## Lab 2.1 : Découverte du VPC default (4 scripts)

- [lab2.1_ex1_explore-default-vpc.sh](lab2.1_ex1_explore-default-vpc.sh) - Explorer le VPC par défaut
- [lab2.1_ex2_audit-firewall-rules.sh](lab2.1_ex2_audit-firewall-rules.sh) - Auditer les règles de pare-feu
- [lab2.1_ex3_create-test-vm.sh](lab2.1_ex3_create-test-vm.sh) - Créer une VM de test
- [lab2.1_ex4_cleanup-default-vpc.sh](lab2.1_ex4_cleanup-default-vpc.sh) - Nettoyer et supprimer le VPC default

## Lab 2.2 : VPC custom multi-régions (7 scripts)

- [lab2.2_ex1_create-custom-vpc.sh](lab2.2_ex1_create-custom-vpc.sh) - Créer un VPC custom
- [lab2.2_ex2_create-subnets.sh](lab2.2_ex2_create-subnets.sh) - Créer les sous-réseaux multi-régions
- [lab2.2_ex3_create-firewall-rules.sh](lab2.2_ex3_create-firewall-rules.sh) - Configurer les règles de pare-feu
- [lab2.2_ex4_configure-cloud-nat.sh](lab2.2_ex4_configure-cloud-nat.sh) - Configurer Cloud NAT
- [lab2.2_ex5_deploy-vms.sh](lab2.2_ex5_deploy-vms.sh) - Déployer les VMs
- [lab2.2_ex6_test-connectivity.sh](lab2.2_ex6_test-connectivity.sh) - Tester la connectivité inter-régions
- [lab2.2_ex7_verify-internal-dns.sh](lab2.2_ex7_verify-internal-dns.sh) - Vérifier le DNS interne

## Lab 2.3 : Planification et extension des sous-réseaux (4 scripts)

- [lab2.3_ex1_design-ip-plan.sh](lab2.3_ex1_design-ip-plan.sh) - Plan d'adressage IP
- [lab2.3_ex2_create-subnet-with-secondary.sh](lab2.3_ex2_create-subnet-with-secondary.sh) - Sous-réseau avec plages secondaires GKE
- [lab2.3_ex3_expand-subnet.sh](lab2.3_ex3_expand-subnet.sh) - Étendre un sous-réseau existant
- [lab2.3_ex4_check-overlaps.sh](lab2.3_ex4_check-overlaps.sh) - Vérifier les chevauchements IP

## Lab 2.4 : VM avec interfaces réseau multiples (6 scripts)

- [lab2.4_ex1_create-two-vpcs.sh](lab2.4_ex1_create-two-vpcs.sh) - Créer deux VPC
- [lab2.4_ex2_create-multi-nic-vm.sh](lab2.4_ex2_create-multi-nic-vm.sh) - Créer la VM multi-NIC (appliance)
- [lab2.4_ex3_create-client-vms.sh](lab2.4_ex3_create-client-vms.sh) - Créer les VMs clientes
- [lab2.4_ex4_configure-appliance-routing.sh](lab2.4_ex4_configure-appliance-routing.sh) - Configurer le routage sur l'appliance
- [lab2.4_ex5_create-custom-routes.sh](lab2.4_ex5_create-custom-routes.sh) - Créer des routes personnalisées
- [lab2.4_ex6_test-multi-nic-connectivity.sh](lab2.4_ex6_test-multi-nic-connectivity.sh) - Tester la connectivité via l'appliance

## Lab 2.5 : Comparaison des Network Tiers (5 scripts)

- [lab2.5_ex1_create-tier-test-vpc.sh](lab2.5_ex1_create-tier-test-vpc.sh) - Créer un VPC de test
- [lab2.5_ex2_create-premium-tier-vm.sh](lab2.5_ex2_create-premium-tier-vm.sh) - Créer une VM avec Premium Tier
- [lab2.5_ex3_create-standard-tier-vm.sh](lab2.5_ex3_create-standard-tier-vm.sh) - Créer une VM avec Standard Tier
- [lab2.5_ex4_compare-network-tiers.sh](lab2.5_ex4_compare-network-tiers.sh) - Comparer les performances
- [lab2.5_ex5_estimate-costs.sh](lab2.5_ex5_estimate-costs.sh) - Estimer les coûts

## Lab 2.6 : Mode de routage dynamique (4 scripts)

- [lab2.6_ex1_create-regional-routing-vpc.sh](lab2.6_ex1_create-regional-routing-vpc.sh) - VPC avec routage régional
- [lab2.6_ex2_create-global-routing-vpc.sh](lab2.6_ex2_create-global-routing-vpc.sh) - VPC avec routage global
- [lab2.6_ex3_simulate-dynamic-routes.sh](lab2.6_ex3_simulate-dynamic-routes.sh) - Simuler des routes dynamiques
- [lab2.6_ex4_change-routing-mode.sh](lab2.6_ex4_change-routing-mode.sh) - Modifier le mode de routage

## Lab 2.7 : Architecture entreprise (1 script)

- [lab2.7_deploy-full-architecture.sh](lab2.7_deploy-full-architecture.sh) - Déploiement complet d'une architecture multi-tiers

## Lab 2.8 : Troubleshooting VPC (2 scripts)

- [lab2.8_connectivity-tests.sh](lab2.8_connectivity-tests.sh) - Utiliser Connectivity Tests
- [lab2.8_troubleshooting-guide.sh](lab2.8_troubleshooting-guide.sh) - Guide de dépannage

## Nettoyage (1 script)

- [cleanup-module2.sh](cleanup-module2.sh) - Supprimer toutes les ressources du Module 2

---

**Total : 34 scripts**

## Utilisation rapide

```bash
# Exécuter un lab complet (exemple : Lab 2.1)
cd scripts/module2
./lab2.1_ex1_explore-default-vpc.sh
./lab2.1_ex2_audit-firewall-rules.sh
./lab2.1_ex3_create-test-vm.sh
./lab2.1_ex4_cleanup-default-vpc.sh

# Nettoyage final
./cleanup-module2.sh
```
