#!/bin/bash
# Lab 9.3 - Exercice 9.3.2 : Configurer la règle par défaut
# Objectif : Vérifier et comprendre la règle par défaut

set -e

echo "=== Lab 9.3 - Exercice 2 : Configurer la règle par défaut ==="
echo ""

# Vérifier la règle par défaut
echo "=== Règle par défaut ==="
gcloud compute security-policies rules describe 2147483647 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : Par défaut, la règle autorise tout (action=allow, priority=2147483647)"
echo ""
echo "Alternative : Configurer en mode 'deny by default' (plus sécurisé)"
echo "Commande (NON exécutée) :"
echo "gcloud compute security-policies rules update 2147483647 \\"
echo "    --security-policy=policy-web-app \\"
echo "    --action=deny-403"
echo ""
echo "Pour ce lab, nous gardons le comportement par défaut (ALLOW)."
