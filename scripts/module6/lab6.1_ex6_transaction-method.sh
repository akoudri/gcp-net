#!/bin/bash
# Lab 6.1 - Exercice 6.1.6 : Méthode par transaction
# Objectif : Utiliser les transactions DNS pour des modifications atomiques

set -e

echo "=== Lab 6.1 - Exercice 6 : Méthode par transaction ==="
echo ""

echo "Utilisation des transactions DNS pour ajouter un enregistrement TXT..."
echo ""

# Démarrer une transaction
echo "Démarrage de la transaction..."
gcloud dns record-sets transaction start --zone=zone-lab-internal
echo ""

# Ajouter un enregistrement TXT
echo "Ajout de l'enregistrement TXT..."
gcloud dns record-sets transaction add "env=lab;owner=training" \
    --name="metadata.lab.internal." \
    --ttl=300 \
    --type=TXT \
    --zone=zone-lab-internal
echo ""

# Exécuter la transaction
echo "Exécution de la transaction..."
gcloud dns record-sets transaction execute --zone=zone-lab-internal
echo ""

echo "Transaction exécutée avec succès !"
echo ""

# Vérifier
echo "=== Liste des enregistrements DNS ==="
gcloud dns record-sets list --zone=zone-lab-internal \
    --format="table(name,type,ttl,rrdatas)"
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi utiliser une transaction plutôt que des commandes individuelles ?"
echo "2. Que se passe-t-il si la transaction échoue à mi-chemin ?"
