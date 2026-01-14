#!/bin/bash
# Lab 4.1 - Exercice 4.1.4 : Créer le peering VPC
# Objectif : Configurer le peering bidirectionnel entre les VPC

set -e

echo "=== Lab 4.1 - Exercice 4 : Créer le peering VPC ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_ALPHA="vpc-alpha"
export VPC_BETA="vpc-beta"

echo "Projet : $PROJECT_ID"
echo "Configuration du peering entre $VPC_ALPHA et $VPC_BETA"
echo ""
echo "IMPORTANT: Le peering doit être configuré DES DEUX CÔTÉS"
echo ""

# Côté VPC Alpha → VPC Beta
echo "Création du peering de VPC Alpha vers VPC Beta..."
gcloud compute networks peerings create peering-alpha-to-beta \
    --network=$VPC_ALPHA \
    --peer-network=$VPC_BETA \
    --peer-project=$PROJECT_ID

echo ""
echo "Peering créé côté Alpha."
echo ""

# Vérifier le statut (devrait être INACTIVE)
echo "=== Statut du peering (devrait être INACTIVE) ==="
gcloud compute networks peerings list --network=$VPC_ALPHA
echo ""

# Attendre un peu
sleep 5

# Côté VPC Beta → VPC Alpha
echo "Création du peering de VPC Beta vers VPC Alpha..."
gcloud compute networks peerings create peering-beta-to-alpha \
    --network=$VPC_BETA \
    --peer-network=$VPC_ALPHA \
    --peer-project=$PROJECT_ID

echo ""
echo "Peering créé côté Beta."
echo ""

# Attendre que le peering devienne actif
echo "Attente de l'activation du peering..."
sleep 10

# Vérifier le statut (devrait maintenant être ACTIVE des deux côtés)
echo "=== Statut du peering Alpha (devrait être ACTIVE) ==="
gcloud compute networks peerings list --network=$VPC_ALPHA
echo ""

echo "=== Statut du peering Beta (devrait être ACTIVE) ==="
gcloud compute networks peerings list --network=$VPC_BETA
echo ""

echo "Questions à considérer :"
echo "1. Que se passe-t-il si on ne configure le peering que d'un seul côté ?"
echo "2. Quel est le statut du peering avant la configuration bilatérale ?"
echo "3. Combien de temps faut-il pour que le peering devienne actif ?"
