#!/bin/bash
# Lab 2.3 - Exercice 2.3.4 : Vérifier les conflits d'adressage
# Objectif : Script pour détecter les chevauchements de plages IP

set -e

echo "=== Lab 2.3 - Exercice 4 : Vérification des chevauchements ==="
echo ""

echo "Liste de tous les sous-réseaux triés par plage IP :"
echo ""

gcloud compute networks subnets list \
    --format="table(name,region,ipCidrRange,network)" \
    --sort-by=ipCidrRange

echo ""
echo "⚠️  Vérifiez visuellement qu'aucune plage ne chevauche une autre."
echo ""
echo "Conseil : Utilisez un calculateur CIDR en ligne pour vérifier les chevauchements."
echo "Exemple : https://www.subnet-calculator.com/cidr.php"
