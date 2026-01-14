#!/bin/bash
# Lab 9.6 - Exercice 9.6.5 : Ajuster la sensibilité et exclure des règles
# Objectif : Reconfigurer SQLi avec sensibilité et exclusions

set -e

echo "=== Lab 9.6 - Exercice 5 : Ajuster la sensibilité et exclure des règles ==="
echo ""

# Supprimer la règle existante
echo "Suppression de la règle 1000 existante..."
gcloud compute security-policies rules delete 1000 \
    --security-policy=policy-web-app --quiet

echo ""
# Recréer avec sensibilité ajustée et exclusions
echo "Création de la règle SQLi avec sensibilité 2 et exclusions..."
gcloud compute security-policies rules create 1000 \
    --security-policy=policy-web-app \
    --expression="evaluatePreconfiguredWaf('sqli-v33-stable', {'sensitivity': 2, 'opt_out_rule_ids': ['owasp-crs-v030301-id942260-sqli', 'owasp-crs-v030301-id942430-sqli']})" \
    --action=deny-403 \
    --preview \
    --description="WAF: SQLi sensibilité 2, règles bruyantes exclues"

echo ""
echo "Règle recréée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 1000 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : Sensibilité 2 = équilibré (recommandé pour commencer)."
echo "Les règles opt_out_rule_ids sont exclues pour réduire les faux positifs."
