#!/bin/bash
# Lab 8.10 - Exercice 8.10.1 : Checklist de sécurité pare-feu
# Objectif : Auditer la configuration de sécurité réseau

set -e

echo "=== Lab 8.10 - Exercice 1 : Audit de sécurité pare-feu ==="
echo ""

# Audit des règles sans description
echo ">>> Règles sans description..."
echo ""
gcloud compute firewall-rules list \
    --format="table(name,description)" \
    --filter="description=''" || echo "Toutes les règles ont une description ✓"

echo ""

# Audit des règles autorisant tout depuis Internet
echo ">>> Règles autorisant 0.0.0.0/0..."
echo ""
gcloud compute firewall-rules list \
    --filter="sourceRanges:0.0.0.0/0" \
    --format="table(name,sourceRanges,allowed,targetTags,targetServiceAccounts)"

echo ""

# Audit des règles utilisant des tags
echo ">>> Règles utilisant des tags (plutôt que Service Accounts)..."
echo ""
gcloud compute firewall-rules list \
    --filter="targetTags:* OR sourceTags:*" \
    --format="table(name,targetTags,sourceTags)" || echo "Aucune règle avec tags"

echo ""

# Règles sans logging
echo ">>> Règles sans logging activé..."
echo ""
gcloud compute firewall-rules list \
    --filter="logConfig.enable:false OR -logConfig.enable:*" \
    --format="table(name,network,logConfig.enable)"

echo ""

echo "=== Checklist de sécurité pare-feu ==="
echo ""
echo "☐ Supprimer les règles default-allow-* du VPC default"
echo "☐ Utiliser des priorités cohérentes:"
echo "   - deny: 100-500 (priorité haute)"
echo "   - allow: 1000+ (priorité normale)"
echo "☐ Préférer Service Accounts aux tags en production"
echo "☐ Activer le logging sur les règles critiques"
echo "☐ Documenter chaque règle avec une description claire"
echo "☐ Réviser régulièrement les règles (trimestriel)"
echo "☐ Utiliser des Network Firewall Policies pour les règles globales"
echo "☐ Implémenter deny-all par défaut, puis autoriser explicitement"
echo ""

echo "Questions à considérer :"
echo "1. Combien de règles autorisant 0.0.0.0/0 sont justifiées ?"
echo "2. Quelles règles devraient avoir le logging activé en priorité ?"
echo "3. Comment mettre en place un processus de revue régulière des règles ?"
