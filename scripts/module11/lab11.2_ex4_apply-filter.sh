#!/bin/bash
# Lab 11.2 - Exercice 11.2.4 : Appliquer un filtre
# Objectif : Filtrer les Flow Logs pour réduire le volume

set -e

echo "=== Lab 11.2 - Exercice 4 : Appliquer un filtre ==="
echo ""

# Variables
export REGION="europe-west1"

echo "Application d'un filtre pour capturer uniquement le trafic HTTP/HTTPS..."
echo ""

# Capturer uniquement le trafic HTTP/HTTPS
gcloud compute networks subnets update subnet-monitored \
    --region=$REGION \
    --logging-filter-expr='dest_port == 80 || dest_port == 443 || src_port == 80 || src_port == 443'

echo ""
echo "Filtre appliqué avec succès !"
echo ""
echo "Seul le trafic HTTP (80) et HTTPS (443) sera capturé."
echo ""

# Afficher d'autres exemples de filtres
echo "=== Exemples d'autres filtres possibles ==="
echo ""
echo "1. Capturer uniquement le trafic d'une VM spécifique :"
echo '   --logging-filter-expr='"'"'src_ip == "10.0.1.10" || dest_ip == "10.0.1.10"'"'"
echo ""
echo "2. Capturer uniquement le trafic externe (non RFC1918) :"
echo '   --logging-filter-expr='"'"'inIpRange(dest_ip, "10.0.0.0/8") == false'"'"
echo ""
echo "3. Pour supprimer le filtre (capturer tout) :"
echo '   --logging-filter-expr=""'
echo ""

# Afficher la configuration actuelle
echo "=== Configuration actuelle ==="
gcloud compute networks subnets describe subnet-monitored \
    --region=$REGION \
    --format="yaml(logConfig)"
