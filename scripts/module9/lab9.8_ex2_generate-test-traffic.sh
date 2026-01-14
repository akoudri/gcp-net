#!/bin/bash
# Lab 9.8 - Exercice 9.8.2 : Générer du trafic de test
# Objectif : Générer des requêtes qui déclenchent les règles en preview

set -e

echo "=== Lab 9.8 - Exercice 2 : Générer du trafic de test ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip --global --format="get(address)")
echo "IP du Load Balancer: $LB_IP"
echo ""

# Générer des requêtes qui déclenchent les règles en preview
echo "Génération de trafic de test..."
echo ""

# Requêtes SQL injection
echo "=== Requêtes SQL Injection ==="
for i in {1..10}; do
    echo "Requête SQLi #$i"
    curl -s "http://$LB_IP/?id=$i%20OR%201=1" > /dev/null
done

echo ""
# Requêtes LFI
echo "=== Requêtes LFI ==="
for path in "../../../etc/passwd" "....//....//etc/passwd" "/etc/passwd"; do
    echo "Requête LFI: $path"
    curl -s "http://$LB_IP/?file=$path" > /dev/null
done

echo ""
# Requêtes XSS
echo "=== Requêtes XSS ==="
curl -s "http://$LB_IP/?name=%3Cscript%3Ealert(1)%3C/script%3E" > /dev/null
echo "Requête XSS: <script>alert(1)</script>"

curl -s "http://$LB_IP/?redirect=javascript:alert(1)" > /dev/null
echo "Requête XSS: javascript:alert(1)"

echo ""
echo "Trafic de test généré avec succès !"
echo ""
echo "REMARQUE : Ces requêtes ont déclenché les règles en mode Preview."
echo "Attendez quelques minutes puis analysez les logs pour voir les détections."
echo ""
echo "Pour voir les logs :"
echo "gcloud logging read 'resource.type=\"http_load_balancer\" AND jsonPayload.enforcedSecurityPolicy.name=\"policy-web-app\"' --limit=20"
