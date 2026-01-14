#!/bin/bash
# Lab 9.2 - Exercice 9.2.5 : Tester le Load Balancer
# Objectif : Vérifier le fonctionnement du Load Balancer

set -e

echo "=== Lab 9.2 - Exercice 5 : Tester le Load Balancer ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip --global --format="get(address)")
echo "IP du Load Balancer: $LB_IP"
echo ""

# Attendre que les backends soient healthy
echo "Vérification de l'état de santé des backends..."
echo "Attente de la mise en service (60 secondes)..."
sleep 60

echo ""
echo "=== État de santé des backends ==="
gcloud compute backend-services get-health backend-web --global

echo ""
echo "=== Test de connectivité ==="
echo "Test de l'accès au Load Balancer..."

# Tester l'accès
if curl -s -o /dev/null -w "%{http_code}" http://$LB_IP | grep -q "200"; then
    echo "✓ Load Balancer répond avec succès (HTTP 200)"
    echo ""
    echo "Contenu de la page :"
    curl -s http://$LB_IP
else
    echo "✗ Le Load Balancer ne répond pas encore ou retourne une erreur"
    echo "Attendez quelques minutes supplémentaires et réessayez"
fi

echo ""
echo "=== Test de répartition de charge ==="
echo "Test de 5 requêtes successives pour voir la répartition..."

for i in {1..5}; do
    echo "=== Requête $i ==="
    curl -s http://$LB_IP | grep -E "(Hostname|Zone|Internal IP)" || echo "Pas de réponse"
    echo ""
done

echo ""
echo "REMARQUE : Vous devriez voir différents hostnames si plusieurs instances sont actives."
echo ""
echo "Pour tester manuellement : curl http://$LB_IP"
