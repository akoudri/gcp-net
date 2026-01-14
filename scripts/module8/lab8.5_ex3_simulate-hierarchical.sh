#!/bin/bash
# Lab 8.5 - Exercice 8.5.3 : Simulation au niveau projet
# Objectif : Simuler des politiques hiérarchiques avec des VPC rules

set -e

echo "=== Lab 8.5 - Exercice 3 : Simulation des politiques hiérarchiques ==="
echo ""

export VPC_NAME="vpc-security-lab"

echo "VPC : $VPC_NAME"
echo ""
echo "IMPORTANT : Ce script simule les politiques hiérarchiques au niveau projet"
echo "car la plupart des utilisateurs n'ont pas accès au niveau organisation."
echo ""

# Simuler une politique "organisation" avec priorité très haute
echo ">>> Création de règle simulant la politique org : Deny Telnet..."
gcloud compute firewall-rules create ${VPC_NAME}-org-deny-telnet \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=DENY \
    --rules=tcp:23 \
    --source-ranges=0.0.0.0/0 \
    --priority=100 \
    --description="Simule politique org: deny Telnet"

echo ""

echo ">>> Création de règle simulant la politique org : Deny RDP externe..."
gcloud compute firewall-rules create ${VPC_NAME}-org-deny-rdp-external \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=DENY \
    --rules=tcp:3389 \
    --source-ranges=0.0.0.0/0 \
    --priority=100 \
    --description="Simule politique org: deny RDP externe"

echo ""

# Autoriser RDP interne (priorité plus basse = évalué après)
echo ">>> Création de règle : Autoriser RDP interne..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-rdp-internal \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:3389 \
    --source-ranges=10.0.0.0/8 \
    --priority=1000 \
    --description="Autoriser RDP interne"

echo ""
echo "Règles créées avec succès !"
echo ""

# Afficher les règles
echo "=== Règles de simulation hiérarchique ==="
gcloud compute firewall-rules list \
    --filter="network:$VPC_NAME AND (priority=100 OR priority=1000)" \
    --format="table(name,direction,priority,action,sourceRanges,allowed,denied)" \
    --sort-by=priority

echo ""
echo "=== Analyse du comportement ==="
echo ""
echo "Test 1 : RDP depuis Internet (0.0.0.0/0)"
echo "  - Matche la règle deny à priorité 100"
echo "  - Résultat : BLOQUÉ"
echo ""
echo "Test 2 : RDP depuis réseau interne (10.0.0.0/8)"
echo "  - Ne matche PAS la règle deny (source différente)"
echo "  - Matche la règle allow à priorité 1000"
echo "  - Résultat : AUTORISÉ"
echo ""
echo "Test 3 : Telnet de n'importe où"
echo "  - Matche la règle deny à priorité 100"
echo "  - Résultat : BLOQUÉ (aucune exception possible)"
echo ""

echo "Questions à considérer :"
echo "1. Comment les priorités créent-elles une hiérarchie ?"
echo "2. Pourquoi la règle RDP interne ne s'applique-t-elle qu'au trafic interne ?"
echo "3. Comment implémenter une règle 'GOTO_NEXT' avec les VPC Rules ?"
