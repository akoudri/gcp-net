#!/bin/bash
# Lab 8.7 - Exercice 8.7.5 : Auditer les connexions IAP
# Objectif : Consulter les logs d'accès IAP

set -e

echo "=== Lab 8.7 - Exercice 5 : Auditer les connexions IAP ==="
echo ""

# Consulter les logs d'accès IAP
echo ">>> Logs d'authentification IAP (10 dernières entrées)..."
echo ""
gcloud logging read '
    protoPayload.serviceName="iap.googleapis.com" AND
    protoPayload.methodName="AuthorizeUser"
' --limit=10 --format="table(
    timestamp,
    protoPayload.authenticationInfo.principalEmail,
    protoPayload.resourceName,
    protoPayload.response.allowed
)" 2>/dev/null || echo "Aucun log IAP trouvé. Connectez-vous d'abord via IAP avec lab8.7_ex3_test-ssh-via-iap.sh"

echo ""
echo ">>> Logs de tunneling IAP..."
echo ""
gcloud logging read '
    protoPayload.serviceName="iap.googleapis.com"
' --limit=10 --format=json 2>/dev/null | head -100 || echo "Aucun log disponible"

echo ""
echo "=== Informations disponibles dans les logs IAP ==="
echo ""
echo "- principalEmail: Qui s'est connecté"
echo "- timestamp: Quand"
echo "- resourceName: À quelle ressource"
echo "- allowed: Connexion autorisée ou refusée"
echo "- sourceIp: IP source de l'utilisateur"
echo ""

echo "=== Créer une alerte sur les accès IAP ==="
echo ""
echo "Pour créer une alerte sur les accès IAP refusés :"
echo ""
echo "1. Créer une métrique basée sur les logs"
echo "gcloud logging metrics create iap-denied-access \\"
echo "    --description='Accès IAP refusés' \\"
echo "    --log-filter='protoPayload.serviceName=\"iap.googleapis.com\" AND protoPayload.response.allowed=false'"
echo ""
echo "2. Créer une alerte dans Cloud Monitoring sur cette métrique"
echo ""

echo "Questions à considérer :"
echo "1. Combien de temps les logs IAP sont-ils conservés ?"
echo "2. Comment exporter les logs IAP vers un SIEM externe ?"
echo "3. Quelles informations de conformité peut-on extraire des logs IAP ?"
