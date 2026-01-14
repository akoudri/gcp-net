#!/bin/bash
# Lab 3.7 - Exercice 3.7.2 : Ajouter des enregistrements DNS
# Objectif : Créer des enregistrements A et CNAME dans la zone privée

set -e

echo "=== Lab 3.7 - Exercice 2 : Ajouter des enregistrements DNS ==="
echo ""

# Démarrer une transaction
echo "Démarrage de la transaction DNS..."
gcloud dns record-sets transaction start --zone=internal-zone

echo ""
echo "Ajout de l'enregistrement A pour vm-eu.internal.lab..."
# Ajouter un enregistrement A
gcloud dns record-sets transaction add 10.1.0.10 \
    --name="vm-eu.internal.lab." \
    --ttl=300 \
    --type=A \
    --zone=internal-zone

echo "Ajout de l'enregistrement A pour vm-us.internal.lab..."
# Ajouter un autre enregistrement A
gcloud dns record-sets transaction add 10.2.0.10 \
    --name="vm-us.internal.lab." \
    --ttl=300 \
    --type=A \
    --zone=internal-zone

echo "Ajout de l'enregistrement CNAME pour database.internal.lab..."
# Ajouter un enregistrement CNAME
gcloud dns record-sets transaction add "vm-eu.internal.lab." \
    --name="database.internal.lab." \
    --ttl=300 \
    --type=CNAME \
    --zone=internal-zone

echo ""
echo "Exécution de la transaction..."
# Exécuter la transaction
gcloud dns record-sets transaction execute --zone=internal-zone

echo ""
echo "Enregistrements DNS ajoutés avec succès !"
echo ""

# Lister les enregistrements
echo "=== Enregistrements de la zone ==="
gcloud dns record-sets list --zone=internal-zone
echo ""
