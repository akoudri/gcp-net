#!/bin/bash
# Lab 2.1 - Exercice 2.1.4 : Nettoyage et suppression du VPC default
# Objectif : Supprimer le VPC default (bonne pratique de sécurité)

set -e

echo "=== Lab 2.1 - Exercice 4 : Nettoyage et suppression du VPC default ==="
echo ""

# Supprimer la VM de test
echo "Suppression de la VM de test..."
gcloud compute instances delete test-default-vpc --zone=europe-west1-b --quiet
echo ""

# Supprimer les règles de pare-feu (nécessaire avant de supprimer le VPC)
echo "Suppression des règles de pare-feu..."
gcloud compute firewall-rules delete default-allow-icmp --quiet
gcloud compute firewall-rules delete default-allow-internal --quiet
gcloud compute firewall-rules delete default-allow-rdp --quiet
gcloud compute firewall-rules delete default-allow-ssh --quiet
echo ""

# Supprimer le VPC default
echo "Suppression du VPC default..."
gcloud compute networks delete default --quiet
echo ""

# Vérifier la suppression
echo "=== Vérification - Liste des VPC restants ==="
gcloud compute networks list
echo ""

echo "Nettoyage terminé !"
