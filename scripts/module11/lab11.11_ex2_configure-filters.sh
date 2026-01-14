#!/bin/bash
# Lab 11.11 - Exercice 11.11.2 : Configurer les filtres
# Objectif : Réduire le volume de logs avec des filtres

set -e

echo "=== Lab 11.11 - Exercice 2 : Configurer les filtres ==="
echo ""

# Variables
export REGION="europe-west1"

echo "Région : $REGION"
echo ""

echo "Filtres disponibles pour réduire le volume de logs :"
echo ""
echo "1. Capturer uniquement le trafic HTTP/HTTPS"
echo "2. Capturer uniquement le trafic externe (non RFC1918)"
echo "3. Capturer tout le trafic (supprimer le filtre)"
echo ""

read -p "Choisissez un filtre (1, 2 ou 3) : " FILTER_CHOICE

case $FILTER_CHOICE in
    1)
        echo ""
        echo "Application du filtre HTTP/HTTPS..."
        gcloud compute networks subnets update subnet-monitored \
            --region=$REGION \
            --logging-filter-expr='dest_port == 80 || dest_port == 443'
        echo "Filtre appliqué : HTTP/HTTPS uniquement"
        ;;
    2)
        echo ""
        echo "Application du filtre pour le trafic externe..."
        gcloud compute networks subnets update subnet-monitored \
            --region=$REGION \
            --logging-filter-expr='inIpRange(dest_ip, "10.0.0.0/8") == false'
        echo "Filtre appliqué : Trafic externe uniquement"
        ;;
    3)
        echo ""
        echo "Suppression du filtre (tout capturer)..."
        gcloud compute networks subnets update subnet-monitored \
            --region=$REGION \
            --logging-filter-expr=""
        echo "Filtre supprimé : Tout le trafic sera capturé"
        ;;
    *)
        echo "Choix invalide. Aucune modification appliquée."
        exit 1
        ;;
esac

echo ""
echo "Configuration appliquée avec succès !"
echo ""

# Afficher la configuration actuelle
echo "=== Configuration actuelle ==="
gcloud compute networks subnets describe subnet-monitored \
    --region=$REGION \
    --format="yaml(logConfig)"

echo ""
echo "Note: Les filtres permettent de réduire significativement les coûts d'observabilité."
