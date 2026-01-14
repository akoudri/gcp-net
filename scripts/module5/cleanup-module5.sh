#!/bin/bash
# Nettoyage complet des ressources du Module 5
# Objectif : Supprimer toutes les ressources créées dans les labs du Module 5

set -e

echo "=========================================="
echo " Nettoyage des ressources du Module 5"
echo "=========================================="
echo ""
echo "⚠️  ATTENTION : Ce script va supprimer toutes les ressources créées"
echo "    dans les labs du Module 5 (Private Connectivity)."
echo ""
read -p "Voulez-vous continuer ? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Nettoyage annulé."
    exit 0
fi

export REGION="europe-west1"
export ZONE="${REGION}-b"

echo ""
echo "=== Suppression des VMs ==="
for VM in vm-pga vm-psc vm-sql-client app-vm backend-vm consumer-vm; do
    echo "Suppression de $VM..."
    gcloud compute instances delete $VM --zone=$ZONE --quiet 2>/dev/null || echo "  $VM déjà supprimée ou inexistante"
done

echo ""
echo "=== Suppression des instance groups ==="
gcloud compute instance-groups unmanaged delete backend-group \
    --zone=$ZONE --quiet 2>/dev/null || echo "  backend-group déjà supprimé ou inexistant"

echo ""
echo "=== Suppression des forwarding rules PSC ==="
for FR in psc-endpoint-all-apis psc-to-producer psc-googleapis ilb-producer; do
    echo "Suppression de $FR..."
    gcloud compute forwarding-rules delete $FR --region=$REGION --quiet 2>/dev/null || echo "  $FR déjà supprimée ou inexistante"
done

echo ""
echo "=== Suppression des service attachments ==="
gcloud compute service-attachments delete my-service-attachment \
    --region=$REGION --quiet 2>/dev/null || echo "  Service attachment déjà supprimé ou inexistant"

echo ""
echo "=== Suppression des backend services ==="
gcloud compute backend-services delete backend-service \
    --region=$REGION --quiet 2>/dev/null || echo "  Backend service déjà supprimé ou inexistant"

echo ""
echo "=== Suppression des health checks ==="
gcloud compute health-checks delete hc-backend --quiet 2>/dev/null || echo "  Health check déjà supprimé ou inexistant"

echo ""
echo "=== Suppression des adresses réservées ==="
for ADDR in psc-apis-endpoint psc-consumer-endpoint psc-apis; do
    echo "Suppression de $ADDR (régionale)..."
    gcloud compute addresses delete $ADDR --region=$REGION --quiet 2>/dev/null || echo "  $ADDR déjà supprimée ou inexistante"
done

for ADDR in google-managed-services psa-range; do
    echo "Suppression de $ADDR (globale)..."
    gcloud compute addresses delete $ADDR --global --quiet 2>/dev/null || echo "  $ADDR déjà supprimée ou inexistante"
done

echo ""
echo "=== Suppression des instances Cloud SQL ==="
for SQL in sql-private sql-secure; do
    echo "Suppression de $SQL..."
    gcloud sql instances delete $SQL --quiet 2>/dev/null || echo "  $SQL déjà supprimée ou inexistante"
done

echo ""
echo "=== Suppression des instances Memorystore ==="
echo "Suppression de redis-private..."
gcloud redis instances delete redis-private --region=$REGION --quiet 2>/dev/null || echo "  redis-private déjà supprimée ou inexistante"

echo ""
echo "=== Suppression des zones DNS ==="
for DNSZONE in googleapis-private googleapis-psc service-internal googleapis-hub googleapis-restricted; do
    echo "Suppression de la zone DNS $DNSZONE..."
    # Supprimer les enregistrements d'abord (sauf SOA et NS)
    RECORDS=$(gcloud dns record-sets list --zone=$DNSZONE --format="csv[no-heading](name,type)" 2>/dev/null | grep -v "SOA\|NS" || true)
    if [ ! -z "$RECORDS" ]; then
        echo "$RECORDS" | while IFS=, read -r NAME TYPE; do
            echo "  Suppression de l'enregistrement $NAME ($TYPE)..."
            gcloud dns record-sets delete "$NAME" --zone=$DNSZONE --type=$TYPE --quiet 2>/dev/null || true
        done
    fi
    gcloud dns managed-zones delete $DNSZONE --quiet 2>/dev/null || echo "  $DNSZONE déjà supprimée ou inexistante"
done

echo ""
echo "=== Suppression des Cloud NAT ==="
gcloud compute routers nats delete nat-psa-config --router=router-nat-psa --region=$REGION --quiet 2>/dev/null || echo "  NAT déjà supprimé ou inexistant"

echo ""
echo "=== Suppression des Cloud Routers ==="
gcloud compute routers delete router-nat-psa --region=$REGION --quiet 2>/dev/null || echo "  Router déjà supprimé ou inexistant"

echo ""
echo "=== Suppression des connexions PSA ==="
for VPC in vpc-private-access vpc-hub-secure; do
    echo "Suppression de la connexion PSA pour $VPC..."
    gcloud services vpc-peerings delete \
        --service=servicenetworking.googleapis.com \
        --network=$VPC --quiet 2>/dev/null || echo "  Connexion PSA pour $VPC déjà supprimée ou inexistante"
done

echo ""
echo "=== Suppression des règles de pare-feu ==="
for VPC in vpc-private-access vpc-producer vpc-consumer vpc-hub-secure; do
    echo "Suppression des règles de pare-feu pour $VPC..."
    RULES=$(gcloud compute firewall-rules list --filter="network:$VPC" --format="get(name)" 2>/dev/null || true)
    for RULE in $RULES; do
        echo "  Suppression de $RULE..."
        gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null || true
    done
done

echo ""
echo "=== Suppression des sous-réseaux ==="
for SUBNET in subnet-pga subnet-app subnet-psc subnet-data subnet-producer \
              subnet-psc-nat subnet-consumer; do
    echo "Suppression de $SUBNET..."
    gcloud compute networks subnets delete $SUBNET \
        --region=$REGION --quiet 2>/dev/null || echo "  $SUBNET déjà supprimé ou inexistant"
done

echo ""
echo "=== Suppression des VPCs ==="
for VPC in vpc-private-access vpc-producer vpc-consumer vpc-hub-secure; do
    echo "Suppression de $VPC..."
    gcloud compute networks delete $VPC --quiet 2>/dev/null || echo "  $VPC déjà supprimé ou inexistant"
done

echo ""
echo "=== Suppression des fichiers temporaires ==="
rm -f /tmp/sql-ip.env /tmp/redis-ip.env /tmp/service-attachment-uri.env 2>/dev/null || true

echo ""
echo "=========================================="
echo " Nettoyage terminé !"
echo "=========================================="
echo ""
echo "Vérification des ressources restantes :"
echo ""

echo "=== VPCs restants ==="
gcloud compute networks list --format="table(name,subnetMode)" | grep -E "vpc-private-access|vpc-producer|vpc-consumer|vpc-hub-secure" || echo "Aucun VPC du Module 5"

echo ""
echo "=== VMs restantes ==="
gcloud compute instances list --format="table(name,zone,status)" | grep -E "vm-pga|vm-psc|vm-sql-client|app-vm|backend-vm|consumer-vm" || echo "Aucune VM du Module 5"

echo ""
echo "=== Cloud SQL restant ==="
gcloud sql instances list --format="table(name,region,databaseVersion)" | grep -E "sql-private|sql-secure" || echo "Aucune instance Cloud SQL du Module 5"

echo ""
echo "=== Memorystore restant ==="
gcloud redis instances list --format="table(name,region,tier)" 2>/dev/null | grep "redis-private" || echo "Aucune instance Redis du Module 5"

echo ""
echo "Si des ressources persistent, elles peuvent être en cours de suppression."
echo "Certaines ressources (Cloud SQL, Memorystore) peuvent prendre plusieurs minutes à se supprimer."
echo ""
echo "Pour vérifier l'état complet :"
echo "  gcloud compute networks list"
echo "  gcloud compute instances list"
echo "  gcloud sql instances list"
echo "  gcloud redis instances list"
