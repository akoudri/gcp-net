#!/bin/bash
# Lab 9.10 - Exercice 9.10.2 : Créer une Edge Security Policy
# Objectif : Créer une politique de type CLOUD_ARMOR_EDGE

set -e

echo "=== Lab 9.10 - Exercice 2 : Créer une Edge Security Policy ==="
echo ""

# Créer une politique de type CLOUD_ARMOR_EDGE
echo "Création d'une Edge Security Policy..."
gcloud compute security-policies create edge-policy \
    --type=CLOUD_ARMOR_EDGE \
    --description="Politique edge pour protection CDN"

echo ""
# Ajouter une règle de blocage IP
echo "Ajout d'une règle de blocage IP au edge..."
gcloud compute security-policies rules create 100 \
    --security-policy=edge-policy \
    --src-ip-ranges="198.51.100.0/24,203.0.113.0/24" \
    --action=deny-403 \
    --description="Bloquer IPs au edge"

echo ""
# Ajouter une règle de géolocalisation
echo "Ajout d'une règle de géolocalisation au edge..."
gcloud compute security-policies rules create 200 \
    --security-policy=edge-policy \
    --expression="origin.region_code == 'XX'" \
    --action=deny-403 \
    --description="Bloquer pays XX au edge"

echo ""
echo "Edge Security Policy créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de l'Edge Policy ==="
gcloud compute security-policies describe edge-policy

echo ""
echo "=== Règles de l'Edge Policy ==="
gcloud compute security-policies rules list --security-policy=edge-policy

echo ""
echo "REMARQUE : L'Edge Policy filtre le trafic au niveau du CDN, avant qu'il atteigne les backends."
