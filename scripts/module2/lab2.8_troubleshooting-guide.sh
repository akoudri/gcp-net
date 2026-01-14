#!/bin/bash
# Lab 2.8 - Exercice 2.8.2 : Guide de troubleshooting
# Objectif : Fournir des commandes de diagnostic

set -e

cat << 'EOF'
=== Lab 2.8 - Guide de Troubleshooting VPC ===

Scénario A : VM inaccessible en SSH
─────────────────────────────────────
Symptôme : ssh: connect to host X.X.X.X port 22: Connection timed out

Checklist de diagnostic :

1. Vérifier que la VM est en cours d'exécution :
   gcloud compute instances describe <VM_NAME> --zone=<ZONE> \
       --format="get(status)"

2. Vérifier les règles de pare-feu pour SSH :
   gcloud compute firewall-rules list \
       --filter="network=<VPC_NAME> AND allowed[].ports:22"

3. Vérifier les tags de la VM :
   gcloud compute instances describe <VM_NAME> --zone=<ZONE> \
       --format="get(tags.items)"

4. Vérifier les logs de pare-feu (si activés) :
   gcloud logging read \
       'resource.type="gce_subnetwork" AND jsonPayload.rule_details.action="DENY"' \
       --limit=10


Scénario B : Pas de connectivité entre deux VMs
────────────────────────────────────────────────
1. Vérifier que les VMs sont dans le même VPC :
   gcloud compute instances list \
       --format="table(name,zone,networkInterfaces[0].network)"

2. Vérifier les routes :
   gcloud compute routes list --filter="network=<VPC_NAME>"

3. Tester avec Connectivity Tests :
   gcloud network-management connectivity-tests create test-vm-to-vm \
       --source-instance=projects/<PROJECT>/zones/<ZONE>/instances/<VM_A> \
       --destination-instance=projects/<PROJECT>/zones/<ZONE>/instances/<VM_B> \
       --protocol=ICMP

4. Vérifier le résultat :
   gcloud network-management connectivity-tests describe test-vm-to-vm \
       --format="yaml(result)"


Scénario C : VM ne peut pas accéder à Internet
───────────────────────────────────────────────
1. Vérifier si la VM a une IP externe :
   gcloud compute instances describe <VM_NAME> --zone=<ZONE> \
       --format="get(networkInterfaces[0].accessConfigs[0].natIP)"

2. Vérifier la route par défaut :
   gcloud compute routes list \
       --filter="network=<VPC_NAME> AND destRange=0.0.0.0/0"

3. Vérifier les règles de sortie (egress) :
   gcloud compute firewall-rules list \
       --filter="network=<VPC_NAME> AND direction=EGRESS"

4. Vérifier si Cloud NAT est configuré :
   gcloud compute routers list --filter="network=<VPC_NAME>"
   gcloud compute routers nats list --router=<ROUTER_NAME> --region=<REGION>


Outils de diagnostic supplémentaires
─────────────────────────────────────
# Depuis une VM :
ping <IP>                    # Test de connectivité basique
traceroute <IP>              # Tracer le chemin réseau
mtr <IP>                     # Diagnostic continu (ping + traceroute)
dig <HOSTNAME>               # Résolution DNS
tcpdump -i any icmp -n       # Capture de paquets

# Logs VPC Flow (si activés) :
gcloud logging read 'resource.type="gce_subnetwork"' --limit=50

# Network Intelligence Center :
# Console GCP → Network Intelligence Center → Connectivity Tests
EOF
