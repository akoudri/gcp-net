#!/bin/bash
# Nettoyage complet des ressources du Module 8
# Objectif : Supprimer toutes les ressources créées dans les labs de sécurité

set -e

echo "=== Nettoyage des ressources du Module 8 ==="
echo ""
echo "⚠️  ATTENTION : Ce script va supprimer toutes les ressources créées."
echo ""
read -p "Voulez-vous continuer ? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Nettoyage annulé."
    exit 0
fi

export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo ""
echo "=== Suppression Cloud IDS (si existant) ==="
# Supprimer le packet mirroring
gcloud compute packet-mirrorings delete mirror-to-ids --region=$REGION --quiet 2>/dev/null || true

# Supprimer l'endpoint IDS
gcloud ids endpoints delete ids-endpoint-lab --zone=$ZONE --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des VMs ==="
for VM in vm-web vm-api vm-db vm-web-sa vm-api-sa vm-db-sa vm-web-secure vm-api-secure vm-db-secure; do
    gcloud compute instances delete $VM --zone=$ZONE --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des Service Accounts ==="
for SA in sa-web sa-api sa-db sa-web-secure sa-api-secure sa-db-secure; do
    gcloud iam service-accounts delete ${SA}@${PROJECT_ID}.iam.gserviceaccount.com --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des Network Firewall Policies ==="

# Supprimer les associations d'abord
for POLICY in global-security-policy secure-global-policy; do
    # Lister et supprimer les associations
    ASSOCIATIONS=$(gcloud compute network-firewall-policies describe $POLICY --global --format="value(associations[].name)" 2>/dev/null || true)
    for ASSOC in $ASSOCIATIONS; do
        gcloud compute network-firewall-policies associations delete $ASSOC \
            --firewall-policy=$POLICY --global-firewall-policy --quiet 2>/dev/null || true
    done

    # Supprimer la politique
    gcloud compute network-firewall-policies delete $POLICY --global --quiet 2>/dev/null || true
done

# Politique régionale
ASSOCIATIONS=$(gcloud compute network-firewall-policies describe europe-policy --region=$REGION --format="value(associations[].name)" 2>/dev/null || true)
for ASSOC in $ASSOCIATIONS; do
    gcloud compute network-firewall-policies associations delete $ASSOC \
        --firewall-policy=europe-policy --firewall-policy-region=$REGION --quiet 2>/dev/null || true
done
gcloud compute network-firewall-policies delete europe-policy --region=$REGION --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des règles de pare-feu ==="
for VPC in vpc-security-lab vpc-secure; do
    RULES=$(gcloud compute firewall-rules list --filter="network:$VPC" --format="get(name)" 2>/dev/null || true)
    for RULE in $RULES; do
        gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null || true
    done
done

echo ""
echo "=== Suppression des Cloud NAT ==="
for ROUTER in router-nat-security router-nat-firewall; do
    NATS=$(gcloud compute routers nats list --router=$ROUTER --region=$REGION --format="get(name)" 2>/dev/null || true)
    for NAT in $NATS; do
        gcloud compute routers nats delete $NAT --router=$ROUTER --region=$REGION --quiet 2>/dev/null || true
    done
done

echo ""
echo "=== Suppression des Cloud Routers ==="
for ROUTER in router-nat-security router-nat-firewall; do
    gcloud compute routers delete $ROUTER --region=$REGION --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des sous-réseaux ==="
for SUBNET in subnet-frontend subnet-backend subnet-dmz; do
    gcloud compute networks subnets delete $SUBNET --region=$REGION --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des VPCs ==="
for VPC in vpc-security-lab vpc-secure; do
    gcloud compute networks delete $VPC --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des rôles personnalisés ==="
gcloud iam roles delete NetworkViewerCustom --project=$PROJECT_ID --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des métriques de logging ==="
gcloud logging metrics delete firewall-denied-count --quiet 2>/dev/null || true
gcloud logging metrics delete iap-denied-access --quiet 2>/dev/null || true

echo ""
echo "=== Nettoyage terminé ==="
echo ""
echo "Vérification des ressources restantes :"
echo ""

echo ">>> VPCs restants :"
gcloud compute networks list | grep -E "(vpc-security-lab|vpc-secure)" || echo "Aucun VPC de lab restant ✓"

echo ""
echo ">>> VMs restantes :"
gcloud compute instances list | grep -E "(vm-web|vm-api|vm-db)" || echo "Aucune VM de lab restante ✓"

echo ""
echo ">>> Service Accounts restants :"
gcloud iam service-accounts list | grep -E "(sa-web|sa-api|sa-db)" || echo "Aucun SA de lab restant ✓"

echo ""
echo "Nettoyage du Module 8 terminé avec succès !"
