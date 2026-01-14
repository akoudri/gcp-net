#!/bin/bash
# Lab 6.1 - Exercice 6.1.5 : Ajouter les enregistrements DNS
# Objectif : Créer des enregistrements DNS A et CNAME

set -e

echo "=== Lab 6.1 - Exercice 5 : Ajouter les enregistrements DNS ==="
echo ""

# Enregistrement A pour vm1
echo "Création de l'enregistrement A pour vm1..."
gcloud dns record-sets create "vm1.lab.internal." \
    --zone=zone-lab-internal \
    --type=A \
    --ttl=300 \
    --rrdatas="10.0.0.10"
echo ""

# Enregistrement A pour vm2
echo "Création de l'enregistrement A pour vm2..."
gcloud dns record-sets create "vm2.lab.internal." \
    --zone=zone-lab-internal \
    --type=A \
    --ttl=300 \
    --rrdatas="10.0.0.20"
echo ""

# Enregistrement A pour db
echo "Création de l'enregistrement A pour db..."
gcloud dns record-sets create "db.lab.internal." \
    --zone=zone-lab-internal \
    --type=A \
    --ttl=300 \
    --rrdatas="10.0.0.30"
echo ""

# Enregistrement CNAME pour un alias
echo "Création de l'enregistrement CNAME pour database..."
gcloud dns record-sets create "database.lab.internal." \
    --zone=zone-lab-internal \
    --type=CNAME \
    --ttl=300 \
    --rrdatas="db.lab.internal."
echo ""

# Enregistrement CNAME pour le web
echo "Création de l'enregistrement CNAME pour www..."
gcloud dns record-sets create "www.lab.internal." \
    --zone=zone-lab-internal \
    --type=CNAME \
    --ttl=300 \
    --rrdatas="vm1.lab.internal."
echo ""

echo "Enregistrements DNS créés avec succès !"
echo ""

# Lister tous les enregistrements
echo "=== Liste des enregistrements DNS ==="
gcloud dns record-sets list --zone=zone-lab-internal
