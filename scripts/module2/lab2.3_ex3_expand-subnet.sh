#!/bin/bash
# Lab 2.3 - Exercice 2.3.3 : Étendre un sous-réseau existant
# Objectif : Comprendre l'extension de sous-réseaux (opération irréversible)

set -e

echo "=== Lab 2.3 - Exercice 3 : Étendre un sous-réseau ==="
echo ""

# Créer un petit sous-réseau initial
echo "Création d'un petit sous-réseau (/28 = 14 IPs utilisables)..."
gcloud compute networks subnets create subnet-small \
    --network=planning-vpc \
    --region=europe-west1 \
    --range=10.50.0.0/28

echo ""

# Vérifier la taille actuelle
echo "=== Taille actuelle du sous-réseau ==="
gcloud compute networks subnets describe subnet-small \
    --region=europe-west1 \
    --format="get(ipCidrRange)"

echo ""
echo "⚠️  ATTENTION : L'extension est IRRÉVERSIBLE !"
echo ""
read -p "Voulez-vous étendre le sous-réseau de /28 à /24 ? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Étendre le sous-réseau
    echo "Extension du sous-réseau à /24 (254 IPs utilisables)..."
    gcloud compute networks subnets expand-ip-range subnet-small \
        --region=europe-west1 \
        --prefix-length=24

    echo ""
    echo "Extension réussie !"
    echo ""

    # Vérifier l'extension
    echo "=== Nouvelle taille du sous-réseau ==="
    gcloud compute networks subnets describe subnet-small \
        --region=europe-west1 \
        --format="get(ipCidrRange)"

    echo ""
    echo "Questions à considérer :"
    echo "1. Peut-on réduire la taille d'un sous-réseau après extension ? → NON"
    echo "2. L'extension affecte-t-elle les VMs existantes ? → Non, transparente"
    echo "3. Contraintes : La nouvelle plage doit contenir l'ancienne plage"
else
    echo "Extension annulée."
fi
