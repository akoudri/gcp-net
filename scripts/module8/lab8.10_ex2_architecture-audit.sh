#!/bin/bash
# Lab 8.10 - Exercice 8.10.2 : Checklist architecture
# Objectif : Auditer l'architecture réseau de sécurité

set -e

echo "=== Lab 8.10 - Exercice 2 : Audit d'architecture ==="
echo ""

# Audit des VMs avec IP publique
echo ">>> VMs avec IP publique..."
echo ""
gcloud compute instances list \
    --format="table(name,zone,networkInterfaces[0].accessConfigs[0].natIP)" \
    --filter="networkInterfaces[0].accessConfigs[0].natIP:*" || echo "Aucune VM avec IP publique ✓"

echo ""

# Vérifier VPC Flow Logs
echo ">>> Sous-réseaux sans VPC Flow Logs..."
echo ""
gcloud compute networks subnets list \
    --format="table(name,region,enableFlowLogs)"

echo ""

# Vérifier Private Google Access
echo ">>> Sous-réseaux sans Private Google Access..."
echo ""
gcloud compute networks subnets list \
    --format="table(name,region,privateIpGoogleAccess)"

echo ""

# Vérifier Cloud NAT
echo ">>> Configuration Cloud NAT..."
echo ""
for REGION in $(gcloud compute regions list --format="value(name)" | head -5); do
    ROUTERS=$(gcloud compute routers list --regions=$REGION --format="value(name)" 2>/dev/null || true)
    if [ -n "$ROUTERS" ]; then
        echo "Région $REGION :"
        for ROUTER in $ROUTERS; do
            echo "  Router: $ROUTER"
            gcloud compute routers nats list --router=$ROUTER --region=$REGION 2>/dev/null || true
        done
    fi
done

echo ""

echo "=== Checklist d'architecture ==="
echo ""
echo "☐ Segmenter par environnement (prod/dev/staging)"
echo "☐ Segmenter par fonction (frontend/backend/db)"
echo "☐ Utiliser des sous-réseaux privés (pas d'IP publiques)"
echo "☐ Implémenter Private Google Access pour les APIs"
echo "☐ Utiliser Cloud NAT pour l'accès Internet sortant"
echo "☐ Configurer IAP pour l'accès administrateur"
echo "☐ Implémenter VPC Service Controls pour les données sensibles"
echo "☐ Utiliser Shared VPC pour centraliser la gestion"
echo ""

echo "Questions à considérer :"
echo "1. Combien de VMs ont réellement besoin d'une IP publique ?"
echo "2. Quels sous-réseaux nécessitent Private Google Access ?"
echo "3. Comment améliorer la segmentation réseau actuelle ?"
