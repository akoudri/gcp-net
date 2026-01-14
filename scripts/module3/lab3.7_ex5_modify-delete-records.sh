#!/bin/bash
# Lab 3.7 - Exercice 3.7.5 : Modifier et supprimer des enregistrements
# Objectif : Gérer le cycle de vie des enregistrements DNS

set -e

echo "=== Lab 3.7 - Exercice 5 : Modifier et supprimer des enregistrements ==="
echo ""

# Modifier un enregistrement (supprimer puis recréer)
echo "Suppression de l'enregistrement vm-eu.internal.lab..."
gcloud dns record-sets delete "vm-eu.internal.lab." \
    --type=A \
    --zone=internal-zone

echo ""
echo "Recréation de l'enregistrement avec une nouvelle IP..."
gcloud dns record-sets create "vm-eu.internal.lab." \
    --type=A \
    --ttl=600 \
    --rrdatas="10.1.0.11" \
    --zone=internal-zone

echo ""
echo "Enregistrement modifié avec succès !"
echo ""

# Vérifier le changement
echo "=== Enregistrement modifié ==="
gcloud dns record-sets list --zone=internal-zone --filter="name=vm-eu.internal.lab."
echo ""

echo "Note : Pour modifier un enregistrement, il faut d'abord le supprimer puis le recréer."
echo ""
