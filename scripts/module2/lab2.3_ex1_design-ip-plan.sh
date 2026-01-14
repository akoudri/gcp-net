#!/bin/bash
# Lab 2.3 - Exercice 2.3.1 : Concevoir le plan d'adressage
# Objectif : Afficher le plan d'adressage IP suggéré

set -e

echo "=== Lab 2.3 - Exercice 1 : Plan d'adressage IP ==="
echo ""

cat << 'EOF'
Plan d'adressage IP suggéré pour l'entreprise :

┌──────────────┬──────────────┬─────────────────┬────────────────┬──────────────────┐
│ Environnement│    Région    │ Plage principale│   Pods GKE     │  Services GKE    │
├──────────────┼──────────────┼─────────────────┼────────────────┼──────────────────┤
│ Prod         │ europe-west1 │ 10.10.0.0/20    │ 10.10.16.0/20  │ 10.10.32.0/24    │
│ Prod         │ us-central1  │ 10.20.0.0/20    │ 10.20.16.0/20  │ 10.20.32.0/24    │
│ Staging      │ europe-west1 │ 10.30.0.0/20    │ 10.30.16.0/20  │ 10.30.32.0/24    │
│ Dev          │ europe-west1 │ 10.40.0.0/20    │ 10.40.16.0/20  │ 10.40.32.0/24    │
└──────────────┴──────────────┴─────────────────┴────────────────┴──────────────────┘

Contraintes respectées :
✓ Pas de chevauchements entre environnements
✓ Plages /20 permettent ~4000 hôtes par environnement
✓ Plages secondaires réservées pour GKE
✓ Évite les plages réservées Google

Questions de planification :
1. Pourquoi utiliser des /20 plutôt que des /24 ?
   → Un /20 offre 4096 adresses (vs 256 pour /24), permettant la croissance

2. Combien d'hôtes peuvent être déployés dans un /20 ?
   → 4096 adresses - 4 réservées GCP = 4092 adresses utilisables

3. Pourquoi séparer les plages de pods et services ?
   → Isolation réseau et flexibilité pour GKE (alias IP)
   → Les pods et services ont des besoins de dimensionnement différents

EOF
