#!/bin/bash
# Lab 6.3 - Exercice 6.3.1 : Créer une zone publique
# Objectif : Créer une zone DNS publique

set -e

echo "=== Lab 6.3 - Exercice 1 : Créer une zone publique ==="
echo ""

# Variable pour le domaine (remplacer par votre domaine ou utiliser un exemple)
export DOMAIN="example-lab.com"

echo "Domaine : $DOMAIN"
echo ""
echo "⚠️  Note : Pour une zone publique fonctionnelle, vous devez posséder"
echo "un nom de domaine et configurer les serveurs de noms chez votre registrar."
echo ""

# Créer la zone publique
echo "Création de la zone publique..."
gcloud dns managed-zones create zone-public-lab \
    --dns-name="${DOMAIN}." \
    --description="Zone publique pour le lab" \
    --visibility=public
echo ""

echo "Zone publique créée avec succès !"
echo ""

# Voir les serveurs de noms attribués
echo "=== Serveurs de noms attribués ==="
gcloud dns managed-zones describe zone-public-lab \
    --format="yaml(nameServers)"
echo ""

echo "Ces serveurs doivent être configurés chez votre registrar."
echo ""
echo "Exemple de résultat :"
echo "nameServers:"
echo "- ns-cloud-a1.googledomains.com."
echo "- ns-cloud-a2.googledomains.com."
echo "- ns-cloud-a3.googledomains.com."
echo "- ns-cloud-a4.googledomains.com."
