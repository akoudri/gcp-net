#!/bin/bash
# Lab 6.2 - Exercice 6.2.3 : Comprendre les formats DNS
# Objectif : Afficher et vérifier les formats DNS internes GCP

set -e

echo "=== Lab 6.2 - Exercice 3 : Comprendre les formats DNS ==="
echo ""

cat << 'FORMATS'
=== Formats de noms DNS internes GCP ===

FORMAT ZONAL (recommandé):
[VM_NAME].[ZONE].c.[PROJECT_ID].internal
Exemple: vm1.europe-west1-b.c.mon-projet-123.internal

Avantages:
- Noms uniques (inclut la zone)
- Pas de collision entre VMs de même nom dans des zones différentes
- Comportement par défaut pour les nouveaux projets

FORMAT GLOBAL (ancien):
[VM_NAME].c.[PROJECT_ID].internal
Exemple: vm1.c.mon-projet-123.internal

Inconvénients:
- Collision possible si deux VMs ont le même nom
- Déprécié pour les nouveaux projets

NOMS COURTS:
- vm1 (sans suffixe)
- Fonctionnent grâce au search domain dans /etc/resolv.conf
FORMATS

echo ""
echo "Vérification de la configuration DNS d'une VM..."
echo ""

# Variables
export ZONE="europe-west1-b"

# Voir le search domain configuré
gcloud compute ssh vm1 --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Configuration DNS de la VM ==="
cat /etc/resolv.conf
echo ""
EOF
