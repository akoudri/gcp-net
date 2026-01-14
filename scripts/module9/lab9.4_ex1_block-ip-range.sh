#!/bin/bash
# Lab 9.4 - Exercice 9.4.1 : Bloquer une plage IP
# Objectif : Créer une règle pour bloquer votre IP (test)

set -e

echo "=== Lab 9.4 - Exercice 1 : Bloquer une plage IP ==="
echo ""

# Récupérer votre IP publique
MY_IP=$(curl -s ifconfig.me)
echo "Votre IP publique : $MY_IP"
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip --global --format="get(address)")

# Créer une règle pour bloquer votre IP (pour test)
echo "Création d'une règle pour bloquer votre IP (test)..."
gcloud compute security-policies rules create 100 \
    --security-policy=policy-web-app \
    --src-ip-ranges="$MY_IP/32" \
    --action=deny-403 \
    --description="Bloquer mon IP pour test"

echo ""
echo "Règle créée avec succès !"
echo ""

# Attendre un peu
echo "Attente de l'application de la règle (10 secondes)..."
sleep 10

# Tester - devrait retourner 403
echo "Test de blocage..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$LB_IP)
echo "Code HTTP retourné : $HTTP_CODE"
echo ""

if [ "$HTTP_CODE" == "403" ]; then
    echo "✓ Votre IP est bien bloquée (HTTP 403)"
else
    echo "⚠ Code HTTP : $HTTP_CODE (attendu : 403)"
    echo "La règle peut prendre quelques secondes à s'appliquer, réessayez dans un moment."
fi

echo ""
echo "Pour supprimer cette règle de test :"
echo "gcloud compute security-policies rules delete 100 --security-policy=policy-web-app --quiet"
echo ""

read -p "Voulez-vous supprimer la règle maintenant ? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Suppression de la règle..."
    gcloud compute security-policies rules delete 100 \
        --security-policy=policy-web-app --quiet
    echo "Règle supprimée !"
else
    echo "Règle conservée. Supprimez-la manuellement quand nécessaire."
fi
