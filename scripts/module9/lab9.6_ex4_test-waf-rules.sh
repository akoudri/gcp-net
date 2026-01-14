#!/bin/bash
# Lab 9.6 - Exercice 9.6.4 : Tester les règles WAF
# Objectif : Tester la détection SQLi et XSS

set -e

echo "=== Lab 9.6 - Exercice 4 : Tester les règles WAF ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip --global --format="get(address)")
echo "IP du Load Balancer: $LB_IP"
echo ""

# Test SQL Injection (devrait être détecté)
echo "=== Test SQL Injection ==="
echo "Test 1: ?id=1 OR 1=1"
curl -s -o /dev/null -w "Code HTTP: %{http_code}\n" "http://$LB_IP/?id=1%20OR%201=1"

echo "Test 2: ?user=admin'--"
curl -s -o /dev/null -w "Code HTTP: %{http_code}\n" "http://$LB_IP/?user=admin'--"

echo "Test 3: ?search=test UNION SELECT * FROM users"
curl -s -o /dev/null -w "Code HTTP: %{http_code}\n" "http://$LB_IP/?search=test%20UNION%20SELECT%20*%20FROM%20users"

echo ""
# Test XSS (devrait être détecté)
echo "=== Test XSS ==="
echo "Test 1: ?name=<script>alert(1)</script>"
curl -s -o /dev/null -w "Code HTTP: %{http_code}\n" "http://$LB_IP/?name=%3Cscript%3Ealert(1)%3C/script%3E"

echo "Test 2: ?redirect=javascript:alert(1)"
curl -s -o /dev/null -w "Code HTTP: %{http_code}\n" "http://$LB_IP/?redirect=javascript:alert(1)"

echo ""
echo "REMARQUE : En mode Preview, les codes HTTP sont 200 mais les logs montrent la détection."
echo ""
echo "Pour voir les logs dans Cloud Console :"
echo "Network Security > Cloud Armor > policy-web-app > Logs"
echo ""
echo "Ou avec gcloud :"
echo "gcloud logging read 'resource.type=\"http_load_balancer\" AND jsonPayload.enforcedSecurityPolicy.name=\"policy-web-app\"' --limit=20"
