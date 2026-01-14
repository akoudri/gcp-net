#!/bin/bash
#===============================================================================
# GESTION DES APPRENANTS - FORMATION GCP NETWORKING
#===============================================================================
# Ce script permet d'ajouter ou supprimer des apprenants du projet.
#
# Usage:
#   ./manage-trainees.sh add email@example.com
#   ./manage-trainees.sh remove email@example.com
#   ./manage-trainees.sh list
#===============================================================================

set -e

#-------------------------------------------------------------------------------
# COULEURS
#-------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

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
    log_error "Projet non défini. Configurez PROJECT_ID dans config.env"
    exit 1
fi

#-------------------------------------------------------------------------------
# FONCTIONS
#-------------------------------------------------------------------------------
add_trainee() {
    local EMAIL=$1
    
    if [ -z "$EMAIL" ]; then
        log_error "Email requis. Usage: $0 add email@example.com"
        exit 1
    fi
    
    log_info "Ajout de $EMAIL au projet $PROJECT_ID..."
    
    # Rôle trainee personnalisé
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="user:$EMAIL" \
        --role="projects/$PROJECT_ID/roles/trainee" \
        --quiet 2>/dev/null || log_warning "Rôle trainee non trouvé, utilisation de Editor"
    
    # Viewer
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="user:$EMAIL" \
        --role="roles/viewer" \
        --quiet
    
    # Service Usage
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="user:$EMAIL" \
        --role="roles/serviceusage.serviceUsageConsumer" \
        --quiet
    
    log_success "$EMAIL ajouté avec succès!"
    echo ""
    echo "L'apprenant peut maintenant accéder au projet via:"
    echo "  - Console: https://console.cloud.google.com/home/dashboard?project=$PROJECT_ID"
    echo "  - CLI: gcloud config set project $PROJECT_ID"
}

remove_trainee() {
    local EMAIL=$1
    
    if [ -z "$EMAIL" ]; then
        log_error "Email requis. Usage: $0 remove email@example.com"
        exit 1
    fi
    
    log_info "Suppression de $EMAIL du projet $PROJECT_ID..."
    
    # Supprimer tous les rôles
    ROLES=$(gcloud projects get-iam-policy $PROJECT_ID \
        --flatten="bindings[].members" \
        --filter="bindings.members:user:$EMAIL" \
        --format="value(bindings.role)")
    
    for role in $ROLES; do
        log_info "Suppression du rôle $role..."
        gcloud projects remove-iam-policy-binding $PROJECT_ID \
            --member="user:$EMAIL" \
            --role="$role" \
            --quiet 2>/dev/null || true
    done
    
    log_success "$EMAIL supprimé du projet!"
}

list_trainees() {
    log_info "Liste des utilisateurs du projet $PROJECT_ID:"
    echo ""
    
    gcloud projects get-iam-policy $PROJECT_ID \
        --flatten="bindings[].members" \
        --filter="bindings.members:user:" \
        --format="table(bindings.members.split(':').slice(1).join(':'):label=EMAIL,bindings.role:label=ROLE)" \
        | grep -v "serviceAccount" | sort -u
}

show_usage() {
    echo "Usage: $0 <commande> [arguments]"
    echo ""
    echo "Commandes:"
    echo "  add <email>      Ajouter un apprenant"
    echo "  remove <email>   Supprimer un apprenant"
    echo "  list             Lister les apprenants"
    echo ""
    echo "Exemples:"
    echo "  $0 add etudiant@gmail.com"
    echo "  $0 remove etudiant@gmail.com"
    echo "  $0 list"
}

#-------------------------------------------------------------------------------
# MAIN
#-------------------------------------------------------------------------------
case "$1" in
    add)
        add_trainee "$2"
        ;;
    remove)
        remove_trainee "$2"
        ;;
    list)
        list_trainees
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
