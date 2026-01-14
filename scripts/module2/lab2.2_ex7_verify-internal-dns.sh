#!/bin/bash
# Lab 2.2 - Exercice 2.2.7 : Vérifier le DNS interne automatique
# Objectif : Comprendre la résolution DNS interne de GCP

set -e

echo "=== Lab 2.2 - Exercice 7 : Vérifier le DNS interne ==="
echo ""

export PROJECT_ID=$(gcloud config get-value project)

echo "Instructions pour tester le DNS interne :"
echo ""
echo "1. Connectez-vous à vm-eu via IAP :"
echo "   gcloud compute ssh vm-eu --zone=europe-west1-b --tunnel-through-iap"
echo ""
echo "2. Une fois connecté, testez la résolution DNS :"
echo ""
echo "   # Résolution DNS complète"
echo "   dig vm-us.us-central1-a.c.${PROJECT_ID}.internal"
echo ""
echo "   # Test avec le nom court"
echo "   ping -c 3 vm-us.us-central1-a"
echo ""
echo "Questions à considérer :"
echo "1. Quel est le format complet du nom DNS interne d'une VM ?"
echo "2. Le DNS interne fonctionne-t-il entre régions différentes ?"
