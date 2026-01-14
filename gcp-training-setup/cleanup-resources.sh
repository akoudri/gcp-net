#!/bin/bash
#===============================================================================
# SCRIPT DE NETTOYAGE DES RESSOURCES - FORMATION GCP NETWORKING
#===============================================================================
# Ce script supprime toutes les ressources créées pendant les labs
# pour éviter les coûts inutiles.
#
# Usage:
#   ./cleanup-resources.sh                    # Nettoyage interactif
#   ./cleanup-resources.sh --force            # Nettoyage sans confirmation
#   ./cleanup-resources.sh --dry-run          # Afficher ce qui serait supprimé
#   ./cleanup-resources.sh --prefix=test-     # Nettoyer uniquement les ressources avec ce préfixe
#===============================================================================

set -e

#-------------------------------------------------------------------------------
# COULEURS ET CONFIGURATION
#-------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

FORCE_MODE=false
DRY_RUN=false
PREFIX_FILTER=""

#-------------------------------------------------------------------------------
# PARSING DES ARGUMENTS
#-------------------------------------------------------------------------------
for arg in "$@"; do
    case $arg in
        --force)
            FORCE_MODE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --prefix=*)
            PREFIX_FILTER="${arg#*=}"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --force      Supprimer sans confirmation"
            echo "  --dry-run    Afficher ce qui serait supprimé sans supprimer"
            echo "  --prefix=X   Supprimer uniquement les ressources commençant par X"
            echo "  --help       Afficher cette aide"
            exit 0
            ;;
    esac
done

#-------------------------------------------------------------------------------
# FONCTIONS UTILITAIRES
#-------------------------------------------------------------------------------
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_delete() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${CYAN}[DRY-RUN]${NC} Serait supprimé: $1"
    else
        echo -e "${RED}[DELETE]${NC} $1"
    fi
}

delete_resource() {
    local cmd="$1"
    local resource="$2"
    
    log_delete "$resource"
    
    if [ "$DRY_RUN" = false ]; then
        eval "$cmd" 2>/dev/null || true
    fi
}

should_delete() {
    local name="$1"
    
    # Si pas de filtre, tout supprimer
    if [ -z "$PREFIX_FILTER" ]; then
        return 0
    fi
    
    # Vérifier si le nom commence par le préfixe
    if [[ "$name" == "$PREFIX_FILTER"* ]]; then
        return 0
    fi
    
    return 1
}

#-------------------------------------------------------------------------------
# CHARGEMENT DE LA CONFIGURATION
#-------------------------------------------------------------------------------
CONFIG_FILE="./config.env"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Utiliser le projet courant si non défini
if [ -z "$PROJECT_ID" ]; then
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
fi

if [ -z "$PROJECT_ID" ]; then
    log_error "Aucun projet défini. Utilisez: gcloud config set project PROJECT_ID"
    exit 1
fi

if [ -z "$REGION" ]; then
    REGION="europe-west1"
fi

ZONE="${REGION}-b"

#-------------------------------------------------------------------------------
# AFFICHAGE DE L'EN-TÊTE
#-------------------------------------------------------------------------------
echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║           NETTOYAGE DES RESSOURCES - FORMATION GCP NETWORKING              ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "  Projet: $PROJECT_ID"
echo "  Région: $REGION"
echo "  Mode:   $([ "$DRY_RUN" = true ] && echo "DRY-RUN (simulation)" || echo "RÉEL")"
if [ -n "$PREFIX_FILTER" ]; then
    echo "  Filtre: $PREFIX_FILTER*"
fi
echo ""

#-------------------------------------------------------------------------------
# CONFIRMATION
#-------------------------------------------------------------------------------
if [ "$FORCE_MODE" = false ] && [ "$DRY_RUN" = false ]; then
    echo -e "${RED}⚠️  ATTENTION: Cette opération va SUPPRIMER des ressources!${NC}"
    echo ""
    read -p "Êtes-vous sûr de vouloir continuer? (oui/non): " CONFIRM
    if [ "$CONFIRM" != "oui" ]; then
        log_warning "Nettoyage annulé."
        exit 0
    fi
fi

#-------------------------------------------------------------------------------
# COLLECTE DES RESSOURCES
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Analyse des ressources à supprimer..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

#-------------------------------------------------------------------------------
# ÉTAPE 1: PACKET MIRRORING
#-------------------------------------------------------------------------------
log_info "Recherche des Packet Mirrorings..."
MIRRORINGS=$(gcloud compute packet-mirrorings list --format="value(name,region)" 2>/dev/null || true)
if [ -n "$MIRRORINGS" ]; then
    while IFS= read -r line; do
        NAME=$(echo $line | awk '{print $1}')
        REGION_PM=$(echo $line | awk '{print $2}')
        if should_delete "$NAME"; then
            delete_resource "gcloud compute packet-mirrorings delete $NAME --region=$REGION_PM --quiet" "Packet Mirroring: $NAME"
        fi
    done <<< "$MIRRORINGS"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 2: CONNECTIVITY TESTS
#-------------------------------------------------------------------------------
log_info "Recherche des Connectivity Tests..."
TESTS=$(gcloud network-management connectivity-tests list --format="value(name)" 2>/dev/null || true)
if [ -n "$TESTS" ]; then
    while IFS= read -r NAME; do
        if should_delete "$NAME"; then
            delete_resource "gcloud network-management connectivity-tests delete $NAME --quiet" "Connectivity Test: $NAME"
        fi
    done <<< "$TESTS"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 3: LOAD BALANCERS (ordre de suppression important)
#-------------------------------------------------------------------------------
log_info "Recherche des Load Balancers..."

# Global Forwarding Rules
GLOBAL_FWD=$(gcloud compute forwarding-rules list --global --format="value(name)" 2>/dev/null || true)
if [ -n "$GLOBAL_FWD" ]; then
    while IFS= read -r NAME; do
        if should_delete "$NAME"; then
            delete_resource "gcloud compute forwarding-rules delete $NAME --global --quiet" "Global Forwarding Rule: $NAME"
        fi
    done <<< "$GLOBAL_FWD"
fi

# Regional Forwarding Rules
REGIONAL_FWD=$(gcloud compute forwarding-rules list --filter="region:*" --format="value(name,region)" 2>/dev/null || true)
if [ -n "$REGIONAL_FWD" ]; then
    while IFS= read -r line; do
        NAME=$(echo $line | awk '{print $1}')
        REGION_FWD=$(echo $line | awk '{print $2}')
        if should_delete "$NAME"; then
            delete_resource "gcloud compute forwarding-rules delete $NAME --region=$REGION_FWD --quiet" "Forwarding Rule: $NAME"
        fi
    done <<< "$REGIONAL_FWD"
fi

# Target HTTP(S) Proxies
for PROXY_TYPE in target-http-proxies target-https-proxies; do
    PROXIES=$(gcloud compute $PROXY_TYPE list --format="value(name)" 2>/dev/null || true)
    if [ -n "$PROXIES" ]; then
        while IFS= read -r NAME; do
            if should_delete "$NAME"; then
                delete_resource "gcloud compute $PROXY_TYPE delete $NAME --quiet" "Target Proxy: $NAME"
            fi
        done <<< "$PROXIES"
    fi
done

# URL Maps
URL_MAPS=$(gcloud compute url-maps list --format="value(name)" 2>/dev/null || true)
if [ -n "$URL_MAPS" ]; then
    while IFS= read -r NAME; do
        if should_delete "$NAME"; then
            delete_resource "gcloud compute url-maps delete $NAME --quiet" "URL Map: $NAME"
        fi
    done <<< "$URL_MAPS"
fi

# Backend Services
BACKEND_SERVICES=$(gcloud compute backend-services list --format="value(name,region)" 2>/dev/null || true)
if [ -n "$BACKEND_SERVICES" ]; then
    while IFS= read -r line; do
        NAME=$(echo $line | awk '{print $1}')
        REGION_BS=$(echo $line | awk '{print $2}')
        if should_delete "$NAME"; then
            if [ -z "$REGION_BS" ]; then
                delete_resource "gcloud compute backend-services delete $NAME --global --quiet" "Backend Service (global): $NAME"
            else
                delete_resource "gcloud compute backend-services delete $NAME --region=$REGION_BS --quiet" "Backend Service: $NAME"
            fi
        fi
    done <<< "$BACKEND_SERVICES"
fi

# Backend Buckets
BACKEND_BUCKETS=$(gcloud compute backend-buckets list --format="value(name)" 2>/dev/null || true)
if [ -n "$BACKEND_BUCKETS" ]; then
    while IFS= read -r NAME; do
        if should_delete "$NAME"; then
            delete_resource "gcloud compute backend-buckets delete $NAME --quiet" "Backend Bucket: $NAME"
        fi
    done <<< "$BACKEND_BUCKETS"
fi

# Health Checks
HEALTH_CHECKS=$(gcloud compute health-checks list --format="value(name)" 2>/dev/null || true)
if [ -n "$HEALTH_CHECKS" ]; then
    while IFS= read -r NAME; do
        if should_delete "$NAME"; then
            delete_resource "gcloud compute health-checks delete $NAME --quiet" "Health Check: $NAME"
        fi
    done <<< "$HEALTH_CHECKS"
fi

# NEGs
NEGS=$(gcloud compute network-endpoint-groups list --format="value(name,zone)" 2>/dev/null || true)
if [ -n "$NEGS" ]; then
    while IFS= read -r line; do
        NAME=$(echo $line | awk '{print $1}')
        ZONE_NEG=$(echo $line | awk '{print $2}')
        if should_delete "$NAME"; then
            delete_resource "gcloud compute network-endpoint-groups delete $NAME --zone=$ZONE_NEG --quiet" "NEG: $NAME"
        fi
    done <<< "$NEGS"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 4: CLOUD ARMOR
#-------------------------------------------------------------------------------
log_info "Recherche des Security Policies..."
POLICIES=$(gcloud compute security-policies list --format="value(name)" 2>/dev/null || true)
if [ -n "$POLICIES" ]; then
    while IFS= read -r NAME; do
        if should_delete "$NAME"; then
            delete_resource "gcloud compute security-policies delete $NAME --quiet" "Security Policy: $NAME"
        fi
    done <<< "$POLICIES"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 5: VPN
#-------------------------------------------------------------------------------
log_info "Recherche des VPN Tunnels..."
VPN_TUNNELS=$(gcloud compute vpn-tunnels list --format="value(name,region)" 2>/dev/null || true)
if [ -n "$VPN_TUNNELS" ]; then
    while IFS= read -r line; do
        NAME=$(echo $line | awk '{print $1}')
        REGION_VPN=$(echo $line | awk '{print $2}')
        if should_delete "$NAME"; then
            delete_resource "gcloud compute vpn-tunnels delete $NAME --region=$REGION_VPN --quiet" "VPN Tunnel: $NAME"
        fi
    done <<< "$VPN_TUNNELS"
fi

log_info "Recherche des VPN Gateways..."
VPN_GWS=$(gcloud compute vpn-gateways list --format="value(name,region)" 2>/dev/null || true)
if [ -n "$VPN_GWS" ]; then
    while IFS= read -r line; do
        NAME=$(echo $line | awk '{print $1}')
        REGION_VPN=$(echo $line | awk '{print $2}')
        if should_delete "$NAME"; then
            delete_resource "gcloud compute vpn-gateways delete $NAME --region=$REGION_VPN --quiet" "VPN Gateway: $NAME"
        fi
    done <<< "$VPN_GWS"
fi

log_info "Recherche des External VPN Gateways..."
EXT_VPN_GWS=$(gcloud compute external-vpn-gateways list --format="value(name)" 2>/dev/null || true)
if [ -n "$EXT_VPN_GWS" ]; then
    while IFS= read -r NAME; do
        if should_delete "$NAME"; then
            delete_resource "gcloud compute external-vpn-gateways delete $NAME --quiet" "External VPN Gateway: $NAME"
        fi
    done <<< "$EXT_VPN_GWS"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 6: CLOUD ROUTERS
#-------------------------------------------------------------------------------
log_info "Recherche des Cloud Routers..."
ROUTERS=$(gcloud compute routers list --format="value(name,region)" 2>/dev/null || true)
if [ -n "$ROUTERS" ]; then
    while IFS= read -r line; do
        NAME=$(echo $line | awk '{print $1}')
        REGION_RTR=$(echo $line | awk '{print $2}')
        if should_delete "$NAME"; then
            delete_resource "gcloud compute routers delete $NAME --region=$REGION_RTR --quiet" "Cloud Router: $NAME"
        fi
    done <<< "$ROUTERS"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 7: CLOUD DNS
#-------------------------------------------------------------------------------
log_info "Recherche des DNS Zones..."
DNS_ZONES=$(gcloud dns managed-zones list --format="value(name)" 2>/dev/null || true)
if [ -n "$DNS_ZONES" ]; then
    while IFS= read -r NAME; do
        if should_delete "$NAME"; then
            # Supprimer d'abord les record sets (sauf NS et SOA)
            RECORDS=$(gcloud dns record-sets list --zone=$NAME --format="value(name,type)" 2>/dev/null | grep -v -E "(NS|SOA)$" || true)
            if [ -n "$RECORDS" ]; then
                while IFS= read -r rec; do
                    REC_NAME=$(echo $rec | awk '{print $1}')
                    REC_TYPE=$(echo $rec | awk '{print $2}')
                    if [ "$DRY_RUN" = false ]; then
                        gcloud dns record-sets delete $REC_NAME --zone=$NAME --type=$REC_TYPE --quiet 2>/dev/null || true
                    fi
                done <<< "$RECORDS"
            fi
            delete_resource "gcloud dns managed-zones delete $NAME --quiet" "DNS Zone: $NAME"
        fi
    done <<< "$DNS_ZONES"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 8: INSTANCES ET INSTANCE GROUPS
#-------------------------------------------------------------------------------
log_info "Recherche des Instance Groups Managed..."
MIGS=$(gcloud compute instance-groups managed list --format="value(name,zone)" 2>/dev/null || true)
if [ -n "$MIGS" ]; then
    while IFS= read -r line; do
        NAME=$(echo $line | awk '{print $1}')
        ZONE_MIG=$(echo $line | awk '{print $2}')
        if should_delete "$NAME"; then
            delete_resource "gcloud compute instance-groups managed delete $NAME --zone=$ZONE_MIG --quiet" "Managed Instance Group: $NAME"
        fi
    done <<< "$MIGS"
fi

log_info "Recherche des Instance Groups Unmanaged..."
UIGS=$(gcloud compute instance-groups unmanaged list --format="value(name,zone)" 2>/dev/null || true)
if [ -n "$UIGS" ]; then
    while IFS= read -r line; do
        NAME=$(echo $line | awk '{print $1}')
        ZONE_UIG=$(echo $line | awk '{print $2}')
        if should_delete "$NAME"; then
            delete_resource "gcloud compute instance-groups unmanaged delete $NAME --zone=$ZONE_UIG --quiet" "Unmanaged Instance Group: $NAME"
        fi
    done <<< "$UIGS"
fi

log_info "Recherche des Instance Templates..."
TEMPLATES=$(gcloud compute instance-templates list --format="value(name)" 2>/dev/null || true)
if [ -n "$TEMPLATES" ]; then
    while IFS= read -r NAME; do
        if should_delete "$NAME"; then
            delete_resource "gcloud compute instance-templates delete $NAME --quiet" "Instance Template: $NAME"
        fi
    done <<< "$TEMPLATES"
fi

log_info "Recherche des VMs..."
VMS=$(gcloud compute instances list --format="value(name,zone)" 2>/dev/null || true)
if [ -n "$VMS" ]; then
    while IFS= read -r line; do
        NAME=$(echo $line | awk '{print $1}')
        ZONE_VM=$(echo $line | awk '{print $2}')
        if should_delete "$NAME"; then
            delete_resource "gcloud compute instances delete $NAME --zone=$ZONE_VM --quiet" "VM: $NAME"
        fi
    done <<< "$VMS"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 9: DISQUES
#-------------------------------------------------------------------------------
log_info "Recherche des Disques..."
DISKS=$(gcloud compute disks list --format="value(name,zone)" 2>/dev/null || true)
if [ -n "$DISKS" ]; then
    while IFS= read -r line; do
        NAME=$(echo $line | awk '{print $1}')
        ZONE_DISK=$(echo $line | awk '{print $2}')
        if should_delete "$NAME"; then
            delete_resource "gcloud compute disks delete $NAME --zone=$ZONE_DISK --quiet" "Disk: $NAME"
        fi
    done <<< "$DISKS"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 10: ADRESSES IP
#-------------------------------------------------------------------------------
log_info "Recherche des adresses IP..."
ADDRESSES=$(gcloud compute addresses list --format="value(name,region)" 2>/dev/null || true)
if [ -n "$ADDRESSES" ]; then
    while IFS= read -r line; do
        NAME=$(echo $line | awk '{print $1}')
        REGION_ADDR=$(echo $line | awk '{print $2}')
        if should_delete "$NAME"; then
            if [ -z "$REGION_ADDR" ]; then
                delete_resource "gcloud compute addresses delete $NAME --global --quiet" "Global Address: $NAME"
            else
                delete_resource "gcloud compute addresses delete $NAME --region=$REGION_ADDR --quiet" "Address: $NAME"
            fi
        fi
    done <<< "$ADDRESSES"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 11: FIREWALL RULES
#-------------------------------------------------------------------------------
log_info "Recherche des règles de pare-feu..."
FIREWALLS=$(gcloud compute firewall-rules list --format="value(name)" 2>/dev/null || true)
if [ -n "$FIREWALLS" ]; then
    while IFS= read -r NAME; do
        # Ne pas supprimer les règles par défaut
        if [[ "$NAME" != "default-"* ]] && should_delete "$NAME"; then
            delete_resource "gcloud compute firewall-rules delete $NAME --quiet" "Firewall Rule: $NAME"
        fi
    done <<< "$FIREWALLS"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 12: ROUTES
#-------------------------------------------------------------------------------
log_info "Recherche des routes personnalisées..."
ROUTES=$(gcloud compute routes list --format="value(name)" 2>/dev/null || true)
if [ -n "$ROUTES" ]; then
    while IFS= read -r NAME; do
        # Ne pas supprimer les routes par défaut
        if [[ "$NAME" != "default-route-"* ]] && should_delete "$NAME"; then
            delete_resource "gcloud compute routes delete $NAME --quiet" "Route: $NAME"
        fi
    done <<< "$ROUTES"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 13: SUBNETS
#-------------------------------------------------------------------------------
log_info "Recherche des sous-réseaux..."
SUBNETS=$(gcloud compute networks subnets list --format="value(name,region)" 2>/dev/null || true)
if [ -n "$SUBNETS" ]; then
    while IFS= read -r line; do
        NAME=$(echo $line | awk '{print $1}')
        REGION_SUB=$(echo $line | awk '{print $2}')
        if should_delete "$NAME"; then
            delete_resource "gcloud compute networks subnets delete $NAME --region=$REGION_SUB --quiet" "Subnet: $NAME"
        fi
    done <<< "$SUBNETS"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 14: VPC NETWORKS
#-------------------------------------------------------------------------------
log_info "Recherche des VPCs..."
VPCS=$(gcloud compute networks list --format="value(name)" 2>/dev/null || true)
if [ -n "$VPCS" ]; then
    while IFS= read -r NAME; do
        # Ne pas supprimer le VPC default
        if [ "$NAME" != "default" ] && should_delete "$NAME"; then
            delete_resource "gcloud compute networks delete $NAME --quiet" "VPC: $NAME"
        fi
    done <<< "$VPCS"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 15: STORAGE BUCKETS (optionnel)
#-------------------------------------------------------------------------------
log_info "Recherche des buckets Storage..."
BUCKETS=$(gsutil ls 2>/dev/null | grep "gs://" | sed 's/gs:\/\///' | sed 's/\///' || true)
if [ -n "$BUCKETS" ]; then
    while IFS= read -r NAME; do
        # Ne pas supprimer le bucket de données de formation
        if [[ "$NAME" != *"-training-data" ]] && should_delete "$NAME"; then
            delete_resource "gsutil rm -r gs://$NAME" "Bucket: $NAME"
        fi
    done <<< "$BUCKETS"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 16: BIGQUERY DATASETS (optionnel)
#-------------------------------------------------------------------------------
log_info "Recherche des datasets BigQuery..."
DATASETS=$(bq ls --format=prettyjson 2>/dev/null | grep "datasetId" | sed 's/.*: "\(.*\)".*/\1/' || true)
if [ -n "$DATASETS" ]; then
    while IFS= read -r NAME; do
        if should_delete "$NAME"; then
            delete_resource "bq rm -r -f $PROJECT_ID:$NAME" "BigQuery Dataset: $NAME"
        fi
    done <<< "$DATASETS"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 17: LOGGING SINKS
#-------------------------------------------------------------------------------
log_info "Recherche des sinks de logs..."
SINKS=$(gcloud logging sinks list --format="value(name)" 2>/dev/null || true)
if [ -n "$SINKS" ]; then
    while IFS= read -r NAME; do
        if [[ "$NAME" != "_Default" ]] && [[ "$NAME" != "_Required" ]] && should_delete "$NAME"; then
            delete_resource "gcloud logging sinks delete $NAME --quiet" "Logging Sink: $NAME"
        fi
    done <<< "$SINKS"
fi

#-------------------------------------------------------------------------------
# RÉSUMÉ
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$DRY_RUN" = true ]; then
    log_warning "Mode DRY-RUN: Aucune ressource n'a été supprimée."
    echo "Pour supprimer réellement, relancez sans --dry-run"
else
    log_success "Nettoyage terminé!"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
