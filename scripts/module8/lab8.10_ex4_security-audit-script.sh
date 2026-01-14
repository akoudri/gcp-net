#!/bin/bash
# Lab 8.10 - Exercice 8.10.4 : Script d'audit de sécurité complet
# Objectif : Exécuter un audit complet de la sécurité réseau

set -e

echo "=========================================="
echo "  AUDIT DE SÉCURITÉ RÉSEAU GCP"
echo "=========================================="
echo ""

# 1. Règles de pare-feu ouvertes à Internet
echo "=== 1. Règles de pare-feu ouvertes à Internet ==="
gcloud compute firewall-rules list \
    --filter="sourceRanges:0.0.0.0/0 AND direction:INGRESS" \
    --format="table(name,network,allowed,priority)"

echo ""

# 2. VMs avec IP publique
echo "=== 2. VMs avec IP publique ==="
gcloud compute instances list \
    --filter="networkInterfaces[0].accessConfigs[0].natIP:*" \
    --format="table(name,zone,networkInterfaces[0].accessConfigs[0].natIP)"

echo ""

# 3. Sous-réseaux sans VPC Flow Logs
echo "=== 3. Sous-réseaux sans VPC Flow Logs ==="
gcloud compute networks subnets list \
    --filter="enableFlowLogs:false OR enableFlowLogs:null" \
    --format="table(name,region,enableFlowLogs)"

echo ""

# 4. Règles de pare-feu utilisant des tags
echo "=== 4. Règles de pare-feu utilisant des tags ==="
gcloud compute firewall-rules list \
    --filter="targetTags:* OR sourceTags:*" \
    --format="table(name,targetTags,sourceTags)"

echo ""

# 5. Règles sans logging
echo "=== 5. Règles sans logging ==="
gcloud compute firewall-rules list \
    --filter="logConfig.enable:false OR -logConfig.enable:*" \
    --format="table(name,network,logConfig.enable)"

echo ""

# 6. Service Accounts utilisés par les VMs
echo "=== 6. Service Accounts utilisés par les VMs ==="
gcloud compute instances list \
    --format="table(name,zone,serviceAccounts[0].email)"

echo ""

# 7. Règles ALLOW sans restrictions de source
echo "=== 7. Règles ALLOW sans restrictions de source ==="
gcloud compute firewall-rules list \
    --filter="sourceRanges:0.0.0.0/0 AND allowed:* AND -targetTags:* AND -targetServiceAccounts:*" \
    --format="table(name,network,allowed)"

echo ""

# 8. Sous-réseaux sans Private Google Access
echo "=== 8. Sous-réseaux sans Private Google Access ==="
gcloud compute networks subnets list \
    --filter="privateIpGoogleAccess:false OR -privateIpGoogleAccess:*" \
    --format="table(name,region,privateIpGoogleAccess)"

echo ""

# Résumé
echo "=========================================="
echo "  RÉSUMÉ DE L'AUDIT"
echo "=========================================="
echo ""

OPEN_RULES=$(gcloud compute firewall-rules list --filter="sourceRanges:0.0.0.0/0 AND direction:INGRESS" --format="value(name)" | wc -l)
VMS_WITH_PUBLIC_IP=$(gcloud compute instances list --filter="networkInterfaces[0].accessConfigs[0].natIP:*" --format="value(name)" | wc -l)
SUBNETS_NO_FLOW_LOGS=$(gcloud compute networks subnets list --filter="enableFlowLogs:false OR enableFlowLogs:null" --format="value(name)" | wc -l)
RULES_WITH_TAGS=$(gcloud compute firewall-rules list --filter="targetTags:* OR sourceTags:*" --format="value(name)" | wc -l)
RULES_NO_LOGGING=$(gcloud compute firewall-rules list --filter="logConfig.enable:false OR -logConfig.enable:*" --format="value(name)" | wc -l)

echo "Règles ouvertes à Internet : $OPEN_RULES"
echo "VMs avec IP publique : $VMS_WITH_PUBLIC_IP"
echo "Sous-réseaux sans Flow Logs : $SUBNETS_NO_FLOW_LOGS"
echo "Règles utilisant des tags : $RULES_WITH_TAGS"
echo "Règles sans logging : $RULES_NO_LOGGING"
echo ""

# Recommandations
echo "=========================================="
echo "  RECOMMANDATIONS"
echo "=========================================="
echo ""

if [ $OPEN_RULES -gt 2 ]; then
    echo "⚠️  Trop de règles ouvertes à Internet ($OPEN_RULES)"
    echo "   → Restreindre les sources aux plages IP nécessaires"
fi

if [ $VMS_WITH_PUBLIC_IP -gt 1 ]; then
    echo "⚠️  Plusieurs VMs ont des IP publiques ($VMS_WITH_PUBLIC_IP)"
    echo "   → Utiliser IAP et Cloud NAT à la place"
fi

if [ $SUBNETS_NO_FLOW_LOGS -gt 0 ]; then
    echo "⚠️  Certains sous-réseaux n'ont pas Flow Logs activé"
    echo "   → Activer Flow Logs pour la visibilité"
fi

if [ $RULES_WITH_TAGS -gt 0 ]; then
    echo "⚠️  Certaines règles utilisent des tags"
    echo "   → Migrer vers Service Accounts en production"
fi

if [ $RULES_NO_LOGGING -gt 5 ]; then
    echo "⚠️  Beaucoup de règles sans logging ($RULES_NO_LOGGING)"
    echo "   → Activer le logging sur les règles critiques"
fi

echo ""
echo "=========================================="
echo "  FIN DE L'AUDIT"
echo "=========================================="
