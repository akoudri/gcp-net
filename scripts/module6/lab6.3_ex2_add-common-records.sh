#!/bin/bash
# Lab 6.3 - Exercice 6.3.2 : Ajouter des enregistrements courants
# Objectif : Créer des enregistrements A, AAAA et CNAME

set -e

echo "=== Lab 6.3 - Exercice 2 : Ajouter des enregistrements courants ==="
echo ""

export DOMAIN="example-lab.com"

echo "Domaine : $DOMAIN"
echo ""

# Enregistrement A pour le domaine racine
echo "Création de l'enregistrement A pour le domaine racine..."
gcloud dns record-sets create "${DOMAIN}." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --rrdatas="203.0.113.10"
echo ""

# Enregistrement A pour www
echo "Création de l'enregistrement A pour www..."
gcloud dns record-sets create "www.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --rrdatas="203.0.113.10"
echo ""

# Enregistrement AAAA (IPv6)
echo "Création de l'enregistrement AAAA (IPv6) pour www..."
gcloud dns record-sets create "www.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=AAAA \
    --ttl=300 \
    --rrdatas="2001:db8::1"
echo ""

# Enregistrement CNAME pour un sous-domaine
echo "Création de l'enregistrement CNAME pour blog..."
gcloud dns record-sets create "blog.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=CNAME \
    --ttl=300 \
    --rrdatas="www.${DOMAIN}."
echo ""

# Enregistrement MX pour les emails
echo "Création des enregistrements MX pour les emails..."
gcloud dns record-sets create "${DOMAIN}." \
    --zone=zone-public-lab \
    --type=MX \
    --ttl=300 \
    --rrdatas="10 mail1.${DOMAIN}.","20 mail2.${DOMAIN}."
echo ""

# Enregistrement A pour les serveurs mail
echo "Création des enregistrements A pour les serveurs mail..."
gcloud dns record-sets create "mail1.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --rrdatas="203.0.113.25"

gcloud dns record-sets create "mail2.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --rrdatas="203.0.113.26"
echo ""

echo "Enregistrements courants créés avec succès !"
echo ""

echo "=== Liste des enregistrements ==="
gcloud dns record-sets list --zone=zone-public-lab
