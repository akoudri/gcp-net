#!/bin/bash
#===============================================================================
# SCRIPT DE CONFIGURATION - PROJET DE FORMATION GCP NETWORKING
#===============================================================================
# Ce script configure un projet GCP sécurisé pour former des apprenants
# sans risque de facturation excessive.
#
# Auteur: Formation GCP Networking
# Version: 1.0
#===============================================================================

set -e  # Arrêter en cas d'erreur

#-------------------------------------------------------------------------------
# COULEURS POUR L'AFFICHAGE
#-------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 n'est pas installé. Veuillez l'installer avant de continuer."
        exit 1
    fi
}

#-------------------------------------------------------------------------------
# VÉRIFICATIONS PRÉALABLES
#-------------------------------------------------------------------------------
echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║        CONFIGURATION DU PROJET DE FORMATION GCP NETWORKING                 ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

log_info "Vérification des prérequis..."

# Vérifier que gcloud est installé
check_command gcloud

# Vérifier l'authentification
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1 > /dev/null 2>&1; then
    log_error "Vous n'êtes pas authentifié. Exécutez: gcloud auth login"
    exit 1
fi

CURRENT_USER=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1)
log_success "Connecté en tant que: $CURRENT_USER"

#-------------------------------------------------------------------------------
# CHARGEMENT DE LA CONFIGURATION
#-------------------------------------------------------------------------------
CONFIG_FILE="./config.env"

if [ ! -f "$CONFIG_FILE" ]; then
    log_error "Fichier de configuration $CONFIG_FILE non trouvé!"
    log_info "Créez le fichier config.env à partir de config.env.template"
    exit 1
fi

source "$CONFIG_FILE"

# Validation des variables obligatoires
REQUIRED_VARS=("PROJECT_ID" "BILLING_ACCOUNT_ID" "REGION" "BUDGET_AMOUNT" "ALERT_EMAIL")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        log_error "Variable $var non définie dans $CONFIG_FILE"
        exit 1
    fi
done

log_success "Configuration chargée depuis $CONFIG_FILE"
echo ""
echo "  Project ID:      $PROJECT_ID"
echo "  Billing Account: $BILLING_ACCOUNT_ID"
echo "  Région:          $REGION"
echo "  Budget:          ${BUDGET_AMOUNT}€"
echo "  Email alertes:   $ALERT_EMAIL"
echo ""

#-------------------------------------------------------------------------------
# CONFIRMATION
#-------------------------------------------------------------------------------
read -p "Voulez-vous continuer avec cette configuration? (oui/non): " CONFIRM
if [ "$CONFIRM" != "oui" ]; then
    log_warning "Configuration annulée."
    exit 0
fi

#-------------------------------------------------------------------------------
# ÉTAPE 1: CRÉATION DU PROJET
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 1: Création du projet"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Vérifier si le projet existe déjà
if gcloud projects describe $PROJECT_ID &> /dev/null; then
    log_warning "Le projet $PROJECT_ID existe déjà."
    read -p "Voulez-vous continuer avec ce projet existant? (oui/non): " USE_EXISTING
    if [ "$USE_EXISTING" != "oui" ]; then
        exit 0
    fi
else
    log_info "Création du projet $PROJECT_ID..."
    gcloud projects create $PROJECT_ID \
        --name="Formation GCP Networking" \
        --labels=environment=training,purpose=education
    log_success "Projet créé: $PROJECT_ID"
fi

# Définir le projet par défaut
gcloud config set project $PROJECT_ID

#-------------------------------------------------------------------------------
# ÉTAPE 2: LIAISON À LA FACTURATION
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 2: Configuration de la facturation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log_info "Liaison du projet au compte de facturation..."
gcloud billing projects link $PROJECT_ID \
    --billing-account=$BILLING_ACCOUNT_ID

log_success "Facturation configurée"

#-------------------------------------------------------------------------------
# ÉTAPE 3: ACTIVATION DES APIs
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 3: Activation des APIs nécessaires"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

APIS=(
    # Compute & Networking
    "compute.googleapis.com"
    "networkmanagement.googleapis.com"
    "networkconnectivity.googleapis.com"
    "servicenetworking.googleapis.com"
    "dns.googleapis.com"
    "vpcaccess.googleapis.com"
    
    # Security
    #"cloudarmor.googleapis.com"
    "ids.googleapis.com"
    "certificatemanager.googleapis.com"
    
    # Monitoring & Logging
    "logging.googleapis.com"
    "monitoring.googleapis.com"
    "cloudtrace.googleapis.com"
    
    # IAM & Admin
    "iam.googleapis.com"
    "cloudresourcemanager.googleapis.com"
    "cloudbilling.googleapis.com"
    
    # Storage & BigQuery (pour les labs)
    "storage.googleapis.com"
    "bigquery.googleapis.com"
    
    # Cloud Functions & Run (pour certains labs)
    "cloudfunctions.googleapis.com"
    "run.googleapis.com"
    
    # Recommender (pour Firewall Insights)
    "recommender.googleapis.com"
)

log_info "Activation de ${#APIS[@]} APIs..."
for api in "${APIS[@]}"; do
    echo -n "  Activation de $api... "
    gcloud services enable $api --quiet
    echo "✓"
done

log_success "Toutes les APIs sont activées"

#-------------------------------------------------------------------------------
# ÉTAPE 4: CRÉATION DU RÔLE PERSONNALISÉ POUR LES APPRENANTS
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 4: Création du rôle personnalisé 'Trainee'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Créer le fichier YAML du rôle personnalisé
cat > /tmp/trainee-role.yaml << 'EOF'
title: "GCP Networking Trainee"
description: "Rôle limité pour les apprenants de la formation GCP Networking"
stage: "GA"
includedPermissions:
# ===== COMPUTE ENGINE =====
# Instances
- compute.instances.create
- compute.instances.delete
- compute.instances.get
- compute.instances.list
- compute.instances.setMetadata
- compute.instances.setTags
- compute.instances.start
- compute.instances.stop
- compute.instances.use
- compute.instances.setServiceAccount
- compute.instances.osLogin
# Disks
- compute.disks.create
- compute.disks.delete
- compute.disks.get
- compute.disks.list
- compute.disks.use
# Instance Groups
- compute.instanceGroups.create
- compute.instanceGroups.delete
- compute.instanceGroups.get
- compute.instanceGroups.list
- compute.instanceGroups.update
- compute.instanceGroups.use
- compute.instanceGroupManagers.create
- compute.instanceGroupManagers.delete
- compute.instanceGroupManagers.get
- compute.instanceGroupManagers.list
- compute.instanceGroupManagers.update
- compute.instanceGroupManagers.use
# Instance Templates
- compute.instanceTemplates.create
- compute.instanceTemplates.delete
- compute.instanceTemplates.get
- compute.instanceTemplates.list
- compute.instanceTemplates.useReadOnly

# ===== NETWORKING =====
# VPC
- compute.networks.create
- compute.networks.delete
- compute.networks.get
- compute.networks.list
- compute.networks.update
- compute.networks.updatePolicy
- compute.networks.use
# Subnets
- compute.subnetworks.create
- compute.subnetworks.delete
- compute.subnetworks.get
- compute.subnetworks.list
- compute.subnetworks.update
- compute.subnetworks.use
- compute.subnetworks.useExternalIp
# Firewall
- compute.firewalls.create
- compute.firewalls.delete
- compute.firewalls.get
- compute.firewalls.list
- compute.firewalls.update
# Routes
- compute.routes.create
- compute.routes.delete
- compute.routes.get
- compute.routes.list
# Routers (Cloud NAT, VPN)
- compute.routers.create
- compute.routers.delete
- compute.routers.get
- compute.routers.list
- compute.routers.update
- compute.routers.use
# External IPs
- compute.addresses.create
- compute.addresses.delete
- compute.addresses.get
- compute.addresses.list
- compute.addresses.use
- compute.globalAddresses.create
- compute.globalAddresses.delete
- compute.globalAddresses.get
- compute.globalAddresses.list
- compute.globalAddresses.use

# ===== VPN =====
- compute.vpnGateways.create
- compute.vpnGateways.delete
- compute.vpnGateways.get
- compute.vpnGateways.list
- compute.vpnGateways.use
- compute.vpnTunnels.create
- compute.vpnTunnels.delete
- compute.vpnTunnels.get
- compute.vpnTunnels.list
- compute.externalVpnGateways.create
- compute.externalVpnGateways.delete
- compute.externalVpnGateways.get
- compute.externalVpnGateways.list
- compute.externalVpnGateways.use

# ===== LOAD BALANCING =====
# Health Checks
- compute.healthChecks.create
- compute.healthChecks.delete
- compute.healthChecks.get
- compute.healthChecks.list
- compute.healthChecks.update
- compute.healthChecks.use
- compute.regionHealthChecks.create
- compute.regionHealthChecks.delete
- compute.regionHealthChecks.get
- compute.regionHealthChecks.list
- compute.regionHealthChecks.update
- compute.regionHealthChecks.use
# Backend Services
- compute.backendServices.create
- compute.backendServices.delete
- compute.backendServices.get
- compute.backendServices.list
- compute.backendServices.update
- compute.backendServices.use
- compute.regionBackendServices.create
- compute.regionBackendServices.delete
- compute.regionBackendServices.get
- compute.regionBackendServices.list
- compute.regionBackendServices.update
- compute.regionBackendServices.use
# Backend Buckets
- compute.backendBuckets.create
- compute.backendBuckets.delete
- compute.backendBuckets.get
- compute.backendBuckets.list
- compute.backendBuckets.update
- compute.backendBuckets.use
# URL Maps
- compute.urlMaps.create
- compute.urlMaps.delete
- compute.urlMaps.get
- compute.urlMaps.list
- compute.urlMaps.update
- compute.urlMaps.use
- compute.regionUrlMaps.create
- compute.regionUrlMaps.delete
- compute.regionUrlMaps.get
- compute.regionUrlMaps.list
- compute.regionUrlMaps.update
- compute.regionUrlMaps.use
# Target Proxies
- compute.targetHttpProxies.create
- compute.targetHttpProxies.delete
- compute.targetHttpProxies.get
- compute.targetHttpProxies.list
- compute.targetHttpProxies.use
- compute.targetHttpsProxies.create
- compute.targetHttpsProxies.delete
- compute.targetHttpsProxies.get
- compute.targetHttpsProxies.list
- compute.targetHttpsProxies.use
- compute.regionTargetHttpProxies.create
- compute.regionTargetHttpProxies.delete
- compute.regionTargetHttpProxies.get
- compute.regionTargetHttpProxies.list
- compute.regionTargetHttpProxies.use
- compute.regionTargetHttpsProxies.create
- compute.regionTargetHttpsProxies.delete
- compute.regionTargetHttpsProxies.get
- compute.regionTargetHttpsProxies.list
- compute.regionTargetHttpsProxies.use
# Forwarding Rules
- compute.forwardingRules.create
- compute.forwardingRules.delete
- compute.forwardingRules.get
- compute.forwardingRules.list
- compute.forwardingRules.update
- compute.forwardingRules.use
- compute.globalForwardingRules.create
- compute.globalForwardingRules.delete
- compute.globalForwardingRules.get
- compute.globalForwardingRules.list
- compute.globalForwardingRules.update
# NEGs
- compute.networkEndpointGroups.create
- compute.networkEndpointGroups.delete
- compute.networkEndpointGroups.get
- compute.networkEndpointGroups.list
- compute.networkEndpointGroups.use
- compute.networkEndpointGroups.attachNetworkEndpoints
- compute.networkEndpointGroups.detachNetworkEndpoints
- compute.globalNetworkEndpointGroups.create
- compute.globalNetworkEndpointGroups.delete
- compute.globalNetworkEndpointGroups.get
- compute.globalNetworkEndpointGroups.list
- compute.globalNetworkEndpointGroups.use
- compute.regionNetworkEndpointGroups.create
- compute.regionNetworkEndpointGroups.delete
- compute.regionNetworkEndpointGroups.get
- compute.regionNetworkEndpointGroups.list
- compute.regionNetworkEndpointGroups.use

# ===== CLOUD ARMOR =====
- compute.securityPolicies.create
- compute.securityPolicies.delete
- compute.securityPolicies.get
- compute.securityPolicies.list
- compute.securityPolicies.update
- compute.securityPolicies.use

# ===== SSL CERTIFICATES =====
- compute.sslCertificates.create
- compute.sslCertificates.delete
- compute.sslCertificates.get
- compute.sslCertificates.list
- compute.regionSslCertificates.create
- compute.regionSslCertificates.delete
- compute.regionSslCertificates.get
- compute.regionSslCertificates.list

# ===== CLOUD DNS =====
- dns.managedZones.create
- dns.managedZones.delete
- dns.managedZones.get
- dns.managedZones.list
- dns.managedZones.update
- dns.resourceRecordSets.create
- dns.resourceRecordSets.delete
- dns.resourceRecordSets.get
- dns.resourceRecordSets.list
- dns.resourceRecordSets.update
- dns.policies.create
- dns.policies.delete
- dns.policies.get
- dns.policies.list
- dns.policies.update

# ===== PACKET MIRRORING =====
- compute.packetMirrorings.create
- compute.packetMirrorings.delete
- compute.packetMirrorings.get
- compute.packetMirrorings.list
- compute.packetMirrorings.update

# ===== NETWORK INTELLIGENCE CENTER =====
- networkmanagement.connectivitytests.create
- networkmanagement.connectivitytests.delete
- networkmanagement.connectivitytests.get
- networkmanagement.connectivitytests.list
- networkmanagement.connectivitytests.rerun
- recommender.computeFirewallInsights.get
- recommender.computeFirewallInsights.list

# ===== MONITORING & LOGGING =====
- logging.logEntries.list
- logging.logs.list
- logging.logServices.list
- logging.sinks.create
- logging.sinks.delete
- logging.sinks.get
- logging.sinks.list
- logging.sinks.update
- monitoring.alertPolicies.create
- monitoring.alertPolicies.delete
- monitoring.alertPolicies.get
- monitoring.alertPolicies.list
- monitoring.alertPolicies.update
- monitoring.dashboards.create
- monitoring.dashboards.delete
- monitoring.dashboards.get
- monitoring.dashboards.list
- monitoring.dashboards.update
- monitoring.groups.create
- monitoring.groups.delete
- monitoring.groups.get
- monitoring.groups.list
- monitoring.groups.update
- monitoring.metricDescriptors.get
- monitoring.metricDescriptors.list
- monitoring.monitoredResourceDescriptors.get
- monitoring.monitoredResourceDescriptors.list
- monitoring.notificationChannels.create
- monitoring.notificationChannels.delete
- monitoring.notificationChannels.get
- monitoring.notificationChannels.list
- monitoring.notificationChannels.update
- monitoring.timeSeries.list

# ===== STORAGE (pour Backend Buckets et logs) =====
- storage.buckets.create
- storage.buckets.delete
- storage.buckets.get
- storage.buckets.list
- storage.buckets.update
- storage.objects.create
- storage.objects.delete
- storage.objects.get
- storage.objects.list
- storage.objects.update

# ===== BIGQUERY (pour Flow Logs export) =====
- bigquery.datasets.create
- bigquery.datasets.delete
- bigquery.datasets.get
- bigquery.tables.create
- bigquery.tables.delete
- bigquery.tables.get
- bigquery.tables.getData
- bigquery.tables.list
- bigquery.jobs.create
- bigquery.jobs.get
- bigquery.jobs.list

# ===== SERVICE ACCOUNTS =====
- iam.serviceAccounts.actAs
- iam.serviceAccounts.get
- iam.serviceAccounts.list

# ===== GÉNÉRAL =====
- compute.zones.get
- compute.zones.list
- compute.regions.get
- compute.regions.list
- compute.projects.get
- compute.machineTypes.get
- compute.machineTypes.list
- compute.images.get
- compute.images.list
- compute.images.useReadOnly
- resourcemanager.projects.get
EOF

# Vérifier si le rôle existe déjà
if gcloud iam roles describe trainee --project=$PROJECT_ID &> /dev/null; then
    log_warning "Le rôle 'trainee' existe déjà. Mise à jour..."
    gcloud iam roles update trainee \
        --project=$PROJECT_ID \
        --file=/tmp/trainee-role.yaml \
        --quiet
else
    log_info "Création du rôle 'trainee'..."
    gcloud iam roles create trainee \
        --project=$PROJECT_ID \
        --file=/tmp/trainee-role.yaml \
        --quiet
fi

log_success "Rôle 'trainee' configuré"

#-------------------------------------------------------------------------------
# ÉTAPE 5: AJOUT DES APPRENANTS
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 5: Ajout des apprenants"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FAILED_TRAINEES=()
if [ -n "$TRAINEES" ]; then
    IFS=',' read -ra TRAINEE_ARRAY <<< "$TRAINEES"
    for trainee in "${TRAINEE_ARRAY[@]}"; do
        trainee=$(echo "$trainee" | xargs)  # Trim whitespace
        if [ -n "$trainee" ]; then
            log_info "Ajout de $trainee..."

            # Rôle personnalisé trainee
            ADD_RESULT=$(gcloud projects add-iam-policy-binding $PROJECT_ID \
                --member="user:$trainee" \
                --role="projects/$PROJECT_ID/roles/trainee" \
                --quiet 2>&1) || true
            if echo "$ADD_RESULT" | grep -qi "FAILED_PRECONDITION\|allowedPolicyMemberDomains\|not belong to a permitted"; then
                log_error "  Impossible d'ajouter $trainee (domaine non autorisé par la politique d'organisation)"
                FAILED_TRAINEES+=("$trainee")
                continue
            fi

            # Viewer pour voir le projet
            gcloud projects add-iam-policy-binding $PROJECT_ID \
                --member="user:$trainee" \
                --role="roles/viewer" \
                --quiet 2>/dev/null || true

            # Service Usage Consumer pour utiliser les APIs
            gcloud projects add-iam-policy-binding $PROJECT_ID \
                --member="user:$trainee" \
                --role="roles/serviceusage.serviceUsageConsumer" \
                --quiet 2>/dev/null || true

            log_success "  $trainee ajouté"
        fi
    done
else
    log_warning "Aucun apprenant défini dans TRAINEES. Vous pourrez les ajouter plus tard."
fi

# Avertissement si des apprenants n'ont pas pu être ajoutés
if [ ${#FAILED_TRAINEES[@]} -gt 0 ]; then
    echo ""
    log_warning "Certains apprenants n'ont pas pu être ajoutés à cause de la politique d'organisation."
    log_warning "La contrainte 'iam.allowedPolicyMemberDomains' restreint les domaines autorisés."
    echo ""
    echo "  Pour résoudre ce problème, un admin de l'organisation doit:"
    echo "  1. Aller dans la Console GCP → IAM et admin → Règles d'administration"
    echo "  2. Chercher 'Domain restricted sharing' (iam.allowedPolicyMemberDomains)"
    echo "  3. Ajouter les domaines nécessaires ou désactiver la contrainte pour ce projet"
    echo ""
    echo "  Ou exécuter (nécessite les droits orgpolicy.policies.update):"
    echo "    gcloud org-policies set-policy domain-policy.yaml"
    echo ""
fi

#-------------------------------------------------------------------------------
# ÉTAPE 6: CONFIGURATION DES BUDGETS ET ALERTES
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 6: Configuration des budgets et alertes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log_info "Création du budget avec alertes..."

# Créer le fichier de configuration du budget
cat > /tmp/budget.json << EOF
{
  "displayName": "Budget Formation GCP Networking",
  "budgetFilter": {
    "projects": ["projects/$PROJECT_ID"]
  },
  "amount": {
    "specifiedAmount": {
      "currencyCode": "EUR",
      "units": "$BUDGET_AMOUNT"
    }
  },
  "thresholdRules": [
    {
      "thresholdPercent": 0.25,
      "spendBasis": "CURRENT_SPEND"
    },
    {
      "thresholdPercent": 0.50,
      "spendBasis": "CURRENT_SPEND"
    },
    {
      "thresholdPercent": 0.75,
      "spendBasis": "CURRENT_SPEND"
    },
    {
      "thresholdPercent": 0.90,
      "spendBasis": "CURRENT_SPEND"
    },
    {
      "thresholdPercent": 1.0,
      "spendBasis": "CURRENT_SPEND"
    }
  ],
  "notificationsRule": {
    "monitoringNotificationChannels": [],
    "enableProjectLevelRecipients": true
  }
}
EOF

# Note: La création de budget via CLI nécessite gcloud beta
# Alternative: utiliser la console ou l'API REST

log_warning "Pour créer le budget, allez dans la Console GCP:"
echo "  1. Navigation → Facturation → Budgets et alertes"
echo "  2. Créer un budget"
echo "  3. Projet: $PROJECT_ID"
echo "  4. Montant: ${BUDGET_AMOUNT}€"
echo "  5. Alertes: 25%, 50%, 75%, 90%, 100%"
echo "  6. Email: $ALERT_EMAIL"
echo ""

#-------------------------------------------------------------------------------
# ÉTAPE 7: CONFIGURATION DES QUOTAS
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 7: Configuration des quotas recommandés"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

log_warning "Les quotas doivent être ajustés manuellement dans la Console GCP:"
echo ""
echo "  Navigation → IAM et admin → Quotas"
echo ""
echo "  Quotas recommandés pour la formation:"
echo "  ┌────────────────────────────────────┬─────────────────┐"
echo "  │ Quota                              │ Valeur suggérée │"
echo "  ├────────────────────────────────────┼─────────────────┤"
echo "  │ CPUs (par région)                  │ 24              │"
echo "  │ In-use IP addresses (par région)  │ 10              │"
echo "  │ VPC networks                       │ 10              │"
echo "  │ Subnetworks (par région)          │ 30              │"
echo "  │ Firewall rules                    │ 100             │"
echo "  │ Routes                            │ 100             │"
echo "  │ Forwarding rules                  │ 20              │"
echo "  │ Backend services                  │ 20              │"
echo "  │ Health checks                     │ 30              │"
echo "  │ Cloud Routers (par région)        │ 10              │"
echo "  │ VPN tunnels (par région)          │ 10              │"
echo "  └────────────────────────────────────┴─────────────────┘"
echo ""

#-------------------------------------------------------------------------------
# ÉTAPE 8: CRÉATION DU SERVICE ACCOUNT POUR LE NETTOYAGE
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 8: Création du Service Account pour le nettoyage automatique"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

SA_NAME="cleanup-automation"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Vérifier si le SA existe
if gcloud iam service-accounts describe $SA_EMAIL &> /dev/null; then
    log_warning "Le Service Account $SA_NAME existe déjà."
else
    log_info "Création du Service Account $SA_NAME..."
    gcloud iam service-accounts create $SA_NAME \
        --display-name="Cleanup Automation" \
        --description="Service account pour le nettoyage automatique des ressources"
    
    # Donner les droits nécessaires
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SA_EMAIL" \
        --role="roles/compute.admin" \
        --quiet
    
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SA_EMAIL" \
        --role="roles/dns.admin" \
        --quiet
    
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SA_EMAIL" \
        --role="roles/storage.admin" \
        --quiet
    
    log_success "Service Account créé: $SA_EMAIL"
fi

#-------------------------------------------------------------------------------
# ÉTAPE 9: CRÉATION DES RESSOURCES DE BASE
#-------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ÉTAPE 9: Création des ressources de base"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Bucket pour les scripts et données partagées
BUCKET_NAME="${PROJECT_ID}-training-data"
if gsutil ls -b gs://$BUCKET_NAME &> /dev/null; then
    log_warning "Le bucket $BUCKET_NAME existe déjà."
else
    log_info "Création du bucket $BUCKET_NAME..."
    gsutil mb -l $REGION gs://$BUCKET_NAME
    log_success "Bucket créé: gs://$BUCKET_NAME"
fi

# Rendre le bucket accessible aux apprenants (peut échouer si politique de domaine restrictive)
log_info "Configuration des accès au bucket..."
BUCKET_IAM_RESULT=$(gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME 2>&1) || true
if echo "$BUCKET_IAM_RESULT" | grep -qi "not belong to a permitted\|PreconditionException"; then
    log_warning "Impossible de rendre le bucket public (politique d'organisation restrictive)"
    log_info "Les apprenants auront accès via leur rôle 'trainee'"
fi

#-------------------------------------------------------------------------------
# RÉSUMÉ FINAL
#-------------------------------------------------------------------------------
echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                    CONFIGURATION TERMINÉE AVEC SUCCÈS!                     ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "  📁 Projet:           $PROJECT_ID"
echo "  🌍 Région:           $REGION"
echo "  💰 Budget:           ${BUDGET_AMOUNT}€"
echo "  📧 Alertes:          $ALERT_EMAIL"
echo "  🪣 Bucket:           gs://$BUCKET_NAME"
echo ""
echo "  👥 Apprenants configurés:"
if [ -n "$TRAINEES" ]; then
    IFS=',' read -ra TRAINEE_ARRAY <<< "$TRAINEES"
    for trainee in "${TRAINEE_ARRAY[@]}"; do
        trainee=$(echo "$trainee" | xargs)
        # Vérifier si cet apprenant a échoué
        is_failed=false
        for failed in "${FAILED_TRAINEES[@]}"; do
            if [ "$trainee" = "$failed" ]; then
                is_failed=true
                break
            fi
        done
        if [ "$is_failed" = true ]; then
            echo "     - $trainee ❌ (non ajouté - domaine non autorisé)"
        else
            echo "     - $trainee ✓"
        fi
    done
else
    echo "     (aucun - à ajouter manuellement)"
fi
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  PROCHAINES ÉTAPES:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1. Configurer le budget dans la Console GCP"
echo "  2. Ajuster les quotas si nécessaire"
echo "  3. Envoyer les instructions aux apprenants (voir INSTRUCTIONS_APPRENANTS.md)"
echo "  4. Planifier le nettoyage automatique (voir cleanup-resources.sh)"
echo ""
echo "  URL de la console: https://console.cloud.google.com/home/dashboard?project=$PROJECT_ID"
echo ""
log_success "Setup terminé!"
