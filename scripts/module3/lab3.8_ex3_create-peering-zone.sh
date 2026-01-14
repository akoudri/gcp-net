#!/bin/bash
# Lab 3.8 - Exercice 3.8.3 : Créer une zone de peering DNS
# Objectif : Comprendre le peering DNS entre VPCs

set -e

echo "=== Lab 3.8 - Exercice 3 : Créer une zone de peering DNS ==="
echo ""

echo "Note : Nécessite un second VPC avec une zone privée."
echo "       Exemple conceptuel pour référence."
echo ""

echo "La zone de peering permet de résoudre des noms d'un autre VPC :"
echo ""
echo "  gcloud dns managed-zones create peer-zone \\"
echo "      --description=\"Peering with other VPC\" \\"
echo "      --dns-name=\"other.internal.\" \\"
echo "      --visibility=private \\"
echo "      --networks=routing-lab-vpc \\"
echo "      --target-network=projects/other-project/global/networks/other-vpc \\"
echo "      --target-project=other-project"
echo ""

echo "Cas d'usage :"
echo "  - Résolution DNS entre projets GCP différents"
echo "  - Architecture multi-VPC avec DNS centralisé"
echo "  - Environnements dev/staging/prod séparés"
echo ""

echo "Questions à considérer :"
echo "1. Quelle est la différence entre peering DNS et VPC peering ?"
echo "2. Peut-on avoir du peering DNS sans VPC peering ?"
echo ""
