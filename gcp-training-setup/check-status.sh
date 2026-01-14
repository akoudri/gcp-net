#!/bin/bash
#===============================================================================
# VÉRIFICATION DU STATUS - FORMATION GCP NETWORKING
#===============================================================================
# Ce script affiche un résumé de l'état du projet de formation.
#===============================================================================

#-------------------------------------------------------------------------------
# COULEURS
#-------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

#-------------------------------------------------------------------------------
# CONFIGURATION
#-------------------------------------------------------------------------------
CONFIG_FILE="./config.env"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

if [ -z "$PROJECT_ID" ]; then
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
fi

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Erreur: Aucun projet configuré${NC}"
    exit 1
fi

#-------------------------------------------------------------------------------
# AFFICHAGE
#-------------------------------------------------------------------------------
clear
echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║              STATUS DU PROJET DE FORMATION GCP NETWORKING                  ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${BOLD}Projet:${NC} $PROJECT_ID"
echo -e "${BOLD}Date:${NC}   $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

#-------------------------------------------------------------------------------
# RESSOURCES COMPUTE
#-------------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}RESSOURCES COMPUTE${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

VM_COUNT=$(gcloud compute instances list --format="value(name)" 2>/dev/null | wc -l)
VM_RUNNING=$(gcloud compute instances list --filter="status=RUNNING" --format="value(name)" 2>/dev/null | wc -l)
DISK_COUNT=$(gcloud compute disks list --format="value(name)" 2>/dev/null | wc -l)
TEMPLATE_COUNT=$(gcloud compute instance-templates list --format="value(name)" 2>/dev/null | wc -l)

echo -e "  VMs totales:        ${BOLD}$VM_COUNT${NC} (${GREEN}$VM_RUNNING en cours${NC})"
echo -e "  Disques:            ${BOLD}$DISK_COUNT${NC}"
echo -e "  Instance Templates: ${BOLD}$TEMPLATE_COUNT${NC}"

#-------------------------------------------------------------------------------
# RESSOURCES RÉSEAU
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}RESSOURCES RÉSEAU${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

VPC_COUNT=$(gcloud compute networks list --format="value(name)" 2>/dev/null | wc -l)
SUBNET_COUNT=$(gcloud compute networks subnets list --format="value(name)" 2>/dev/null | wc -l)
FW_COUNT=$(gcloud compute firewall-rules list --format="value(name)" 2>/dev/null | wc -l)
ROUTE_COUNT=$(gcloud compute routes list --format="value(name)" 2>/dev/null | wc -l)
ROUTER_COUNT=$(gcloud compute routers list --format="value(name)" 2>/dev/null | wc -l)
ADDRESS_COUNT=$(gcloud compute addresses list --format="value(name)" 2>/dev/null | wc -l)

echo -e "  VPCs:               ${BOLD}$VPC_COUNT${NC}"
echo -e "  Sous-réseaux:       ${BOLD}$SUBNET_COUNT${NC}"
echo -e "  Règles pare-feu:    ${BOLD}$FW_COUNT${NC}"
echo -e "  Routes:             ${BOLD}$ROUTE_COUNT${NC}"
echo -e "  Cloud Routers:      ${BOLD}$ROUTER_COUNT${NC}"
echo -e "  Adresses IP:        ${BOLD}$ADDRESS_COUNT${NC}"

#-------------------------------------------------------------------------------
# LOAD BALANCING
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}LOAD BALANCING${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FWD_GLOBAL=$(gcloud compute forwarding-rules list --global --format="value(name)" 2>/dev/null | wc -l)
FWD_REGIONAL=$(gcloud compute forwarding-rules list --filter="region:*" --format="value(name)" 2>/dev/null | wc -l)
BACKEND_COUNT=$(gcloud compute backend-services list --format="value(name)" 2>/dev/null | wc -l)
HC_COUNT=$(gcloud compute health-checks list --format="value(name)" 2>/dev/null | wc -l)
URLMAP_COUNT=$(gcloud compute url-maps list --format="value(name)" 2>/dev/null | wc -l)

echo -e "  Forwarding Rules:   ${BOLD}$((FWD_GLOBAL + FWD_REGIONAL))${NC} (Global: $FWD_GLOBAL, Regional: $FWD_REGIONAL)"
echo -e "  Backend Services:   ${BOLD}$BACKEND_COUNT${NC}"
echo -e "  Health Checks:      ${BOLD}$HC_COUNT${NC}"
echo -e "  URL Maps:           ${BOLD}$URLMAP_COUNT${NC}"

#-------------------------------------------------------------------------------
# VPN & HYBRID
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}VPN & CONNECTIVITÉ HYBRIDE${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

VPN_GW_COUNT=$(gcloud compute vpn-gateways list --format="value(name)" 2>/dev/null | wc -l)
VPN_TUNNEL_COUNT=$(gcloud compute vpn-tunnels list --format="value(name)" 2>/dev/null | wc -l)
EXT_VPN_COUNT=$(gcloud compute external-vpn-gateways list --format="value(name)" 2>/dev/null | wc -l)

echo -e "  VPN Gateways:       ${BOLD}$VPN_GW_COUNT${NC}"
echo -e "  VPN Tunnels:        ${BOLD}$VPN_TUNNEL_COUNT${NC}"
echo -e "  External VPN GW:    ${BOLD}$EXT_VPN_COUNT${NC}"

#-------------------------------------------------------------------------------
# DNS
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}CLOUD DNS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

DNS_ZONE_COUNT=$(gcloud dns managed-zones list --format="value(name)" 2>/dev/null | wc -l)

echo -e "  Zones DNS:          ${BOLD}$DNS_ZONE_COUNT${NC}"

#-------------------------------------------------------------------------------
# SÉCURITÉ
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}SÉCURITÉ${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ARMOR_COUNT=$(gcloud compute security-policies list --format="value(name)" 2>/dev/null | wc -l)

echo -e "  Security Policies:  ${BOLD}$ARMOR_COUNT${NC}"

#-------------------------------------------------------------------------------
# STORAGE & BIGQUERY
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}STORAGE & BIGQUERY${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

BUCKET_COUNT=$(gsutil ls 2>/dev/null | wc -l)
BQ_DATASET_COUNT=$(bq ls --format=prettyjson 2>/dev/null | grep "datasetId" | wc -l)

echo -e "  Buckets GCS:        ${BOLD}$BUCKET_COUNT${NC}"
echo -e "  Datasets BigQuery:  ${BOLD}$BQ_DATASET_COUNT${NC}"

#-------------------------------------------------------------------------------
# UTILISATEURS
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}UTILISATEURS (hors service accounts)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

USERS=$(gcloud projects get-iam-policy $PROJECT_ID \
    --flatten="bindings[].members" \
    --filter="bindings.members:user:" \
    --format="value(bindings.members)" 2>/dev/null | sort -u | grep "^user:" | sed 's/user:/  - /')

USER_COUNT=$(echo "$USERS" | grep -c "^  -" || echo "0")

echo -e "  Nombre d'utilisateurs: ${BOLD}$USER_COUNT${NC}"
if [ -n "$USERS" ] && [ "$USER_COUNT" -gt 0 ]; then
    echo "$USERS"
fi

#-------------------------------------------------------------------------------
# RÉSUMÉ DES COÛTS POTENTIELS
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}⚠️  RESSOURCES FACTURABLES ACTIVES${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

WARNINGS=0

if [ "$VM_RUNNING" -gt 0 ]; then
    echo -e "  ${YELLOW}⚠${NC}  $VM_RUNNING VM(s) en cours d'exécution"
    WARNINGS=$((WARNINGS + 1))
fi

if [ "$((FWD_GLOBAL + FWD_REGIONAL))" -gt 0 ]; then
    echo -e "  ${YELLOW}⚠${NC}  $((FWD_GLOBAL + FWD_REGIONAL)) Forwarding Rule(s) active(s) (~\$18/mois chacune)"
    WARNINGS=$((WARNINGS + 1))
fi

if [ "$VPN_GW_COUNT" -gt 0 ]; then
    echo -e "  ${YELLOW}⚠${NC}  $VPN_GW_COUNT VPN Gateway(s) active(s)"
    WARNINGS=$((WARNINGS + 1))
fi

if [ "$ROUTER_COUNT" -gt 0 ]; then
    echo -e "  ${YELLOW}⚠${NC}  $ROUTER_COUNT Cloud Router(s) (NAT potentiel)"
    WARNINGS=$((WARNINGS + 1))
fi

if [ "$WARNINGS" -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC}  Aucune ressource coûteuse active détectée"
fi

#-------------------------------------------------------------------------------
# CONSEIL
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}ACTIONS RECOMMANDÉES${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Pour nettoyer les ressources:"
echo "    ./cleanup-resources.sh --dry-run    # Voir ce qui serait supprimé"
echo "    ./cleanup-resources.sh              # Nettoyer (avec confirmation)"
echo ""
echo "  Pour voir les coûts actuels:"
echo "    https://console.cloud.google.com/billing"
echo ""
