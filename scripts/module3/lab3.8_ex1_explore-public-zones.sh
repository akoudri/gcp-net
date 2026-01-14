#!/bin/bash
# Lab 3.8 - Exercice 3.8.1 : Explorer les zones publiques (conceptuel)
# Objectif : Comprendre la configuration des zones DNS publiques

set -e

echo "=== Lab 3.8 - Exercice 1 : Explorer les zones publiques (conceptuel) ==="
echo ""

echo "Note : Ce lab nécessite un domaine réel pour être pleinement fonctionnel."
echo "       Nous affichons ici la structure de commande pour référence."
echo ""

echo "Structure pour créer une zone publique (nécessite un domaine que vous possédez) :"
echo ""
echo "  gcloud dns managed-zones create my-public-zone \\"
echo "      --description=\"Zone publique pour example.com\" \\"
echo "      --dns-name=\"example.com.\" \\"
echo "      --visibility=public"
echo ""

echo "Après création, GCP vous donne des serveurs NS à configurer chez votre registrar :"
echo "  - ns-cloud-a1.googledomains.com."
echo "  - ns-cloud-b1.googledomains.com."
echo "  - ns-cloud-c1.googledomains.com."
echo "  - ns-cloud-d1.googledomains.com."
echo ""

echo "Vous devez ensuite configurer ces serveurs NS chez votre registrar de domaine."
echo ""

echo "Questions à considérer :"
echo "1. Quelle est la différence entre une zone publique et une zone privée ?"
echo "2. Pourquoi faut-il configurer les serveurs NS chez le registrar ?"
echo ""
