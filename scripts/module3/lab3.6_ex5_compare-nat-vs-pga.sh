#!/bin/bash
# Lab 3.6 - Exercice 3.6.5 : Comparer Cloud NAT vs PGA
# Objectif : Comprendre les différences entre Cloud NAT et Private Google Access

set -e

echo "=== Lab 3.6 - Exercice 5 : Comparer Cloud NAT vs PGA ==="
echo ""

echo "Comparaison Cloud NAT vs Private Google Access :"
echo ""
echo "┌──────────────────────────┬──────────────┬───────────────────────────┐"
echo "│ Critère                  │ Cloud NAT    │ Private Google Access     │"
echo "├──────────────────────────┼──────────────┼───────────────────────────┤"
echo "│ Accès Internet général   │ ✅ Oui       │ ❌ Non                     │"
echo "│ Accès APIs Google        │ ✅ Oui       │ ✅ Oui                     │"
echo "│ Accès services tiers     │ ✅ Oui       │ ❌ Non                     │"
echo "│ Trafic via Internet      │ ✅ Oui       │ ❌ Non (réseau Google)     │"
echo "│ Coût                     │ Facturation  │ Gratuit                   │"
echo "│ Configuration            │ Cloud Router │ Par sous-réseau           │"
echo "└──────────────────────────┴──────────────┴───────────────────────────┘"
echo ""

echo "Cas d'usage recommandés :"
echo ""
echo "Cloud NAT :"
echo "  - VMs nécessitant un accès Internet complet (apt-get, pip install, etc.)"
echo "  - Téléchargement de packages depuis des repos externes"
echo "  - Accès à des APIs tierces (GitHub, NPM, PyPI, etc.)"
echo ""
echo "Private Google Access :"
echo "  - VMs accédant uniquement aux services GCP (GCS, BigQuery, etc.)"
echo "  - Environnements hautement sécurisés (pas d'accès Internet)"
echo "  - Optimisation des coûts (PGA est gratuit)"
echo ""
echo "Combinaison des deux :"
echo "  - VMs nécessitant à la fois l'accès Internet et un accès optimisé aux APIs Google"
echo "  - Le trafic vers les APIs Google passe par PGA (réseau privé Google)"
echo "  - Le trafic vers Internet passe par Cloud NAT"
echo ""
