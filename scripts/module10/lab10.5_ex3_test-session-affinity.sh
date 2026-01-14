#!/bin/bash
# Lab 10.5 - Exercice 10.5.3 : Tester l'affinité de session
# Objectif : Vérifier que les requêtes vont au même backend avec le cookie

set -e

echo "=== Lab 10.5 - Exercice 3 : Tester l'affinité de session ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip-global --global --format="get(address)")
echo "IP du Load Balancer : $LB_IP"
echo ""

# Restaurer l'URL Map original
echo "Restauration de l'URL Map original..."
gcloud compute target-http-proxies update proxy-http-app \
    --url-map=urlmap-app

echo ""
echo "=== Test avec cookies (session affinity) ==="
echo ""

# Première requête - le LB génère un cookie
echo "Première requête (le LB génère un cookie) :"
curl -c cookies.txt -b cookies.txt -s http://$LB_IP/ | grep "Hostname"

echo ""
echo "Cookies générés :"
cat cookies.txt

echo ""
echo ""
echo "Requêtes suivantes (même backend attendu) :"

# Requêtes suivantes avec le cookie - même backend
for i in {1..5}; do
    echo -n "Requête $i : "
    curl -c cookies.txt -b cookies.txt -s http://$LB_IP/ | grep "Hostname"
done

echo ""
echo ""
echo "=== Test sans cookies (pas de session affinity) ==="
echo ""

# Sans cookie - backend peut changer
for i in {1..5}; do
    echo -n "Requête $i : "
    curl -s http://$LB_IP/ | grep "Hostname"
done

echo ""
echo ""
echo "=== Résumé ==="
echo "Avec cookies : Toutes les requêtes devraient aller au même backend"
echo "Sans cookies : Les requêtes peuvent être distribuées sur différents backends"
echo ""
echo "Nettoyage..."
rm -f cookies.txt

echo ""
echo "Test terminé !"
