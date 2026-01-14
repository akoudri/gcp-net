#!/bin/bash
# Lab 8.4 - Exercice 8.4.5 : Tester l'ordre d'évaluation
# Objectif : Comprendre la priorité entre Network Policies et VPC Rules

set -e

echo "=== Lab 8.4 - Exercice 5 : Tester l'ordre d'évaluation ==="
echo ""

export VPC_NAME="vpc-security-lab"

echo "VPC : $VPC_NAME"
echo ""

echo "=== Ordre d'évaluation des règles ==="
echo ""
echo "1. Hierarchical Firewall Policies (organisation/dossier)"
echo "2. Global Network Firewall Policies"
echo "3. Regional Network Firewall Policies"
echo "4. VPC Firewall Rules"
echo ""

# Créer une règle conflictuelle pour observer l'ordre
echo ">>> Test : Créer une VPC rule qui autorise Telnet..."
echo ""
echo "La règle 'deny Telnet' de la politique globale (priorité 100)"
echo "devrait bloquer même si une VPC rule l'autorise."
echo ""

gcloud compute firewall-rules create ${VPC_NAME}-test-allow-telnet \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:23 \
    --source-ranges=10.0.0.0/8 \
    --priority=1000

echo ""
echo "Règle de test créée !"
echo ""

echo "=== Analyse ==="
echo ""
echo "Résultat attendu :"
echo "- Le trafic Telnet (port 23) sera BLOQUÉ"
echo "- La Network Firewall Policy (deny, priorité 100) prime"
echo "- La VPC Rule (allow, priorité 1000) ne sera jamais évaluée"
echo ""
echo "Raison : Les Network Firewall Policies sont évaluées AVANT les VPC Rules"
echo ""

# Lister toutes les règles
echo "=== Règles configurées ==="
echo ""
echo "Network Firewall Policy (global-security-policy) :"
gcloud compute network-firewall-policies rules list \
    --firewall-policy=global-security-policy \
    --global-firewall-policy \
    --filter="priority=100"

echo ""
echo "VPC Firewall Rules :"
gcloud compute firewall-rules list \
    --filter="network:$VPC_NAME AND name:test-allow-telnet"

echo ""

# Nettoyer la règle de test
echo ">>> Nettoyage de la règle de test..."
gcloud compute firewall-rules delete ${VPC_NAME}-test-allow-telnet --quiet

echo ""
echo "Règle de test supprimée."
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi l'ordre d'évaluation est-il important ?"
echo "2. Comment utiliser cet ordre pour implémenter une sécurité en couches ?"
echo "3. Que se passe-t-il si plusieurs règles matchent au même niveau ?"
