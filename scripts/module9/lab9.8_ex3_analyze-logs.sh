#!/bin/bash
# Lab 9.8 - Exercice 9.8.3 : Analyser les logs Cloud Armor
# Objectif : Analyser les logs pour voir les détections

set -e

echo "=== Lab 9.8 - Exercice 3 : Analyser les logs Cloud Armor ==="
echo ""

# Logs des requêtes qui auraient été bloquées (preview)
echo "=== Logs des requêtes bloquées en mode Preview ==="
gcloud logging read '
    resource.type="http_load_balancer" AND
    jsonPayload.enforcedSecurityPolicy.outcome="DENY" AND
    jsonPayload.enforcedSecurityPolicy.preview=true
' --limit=20 --format=json

echo ""
echo "=== Logs des requêtes réellement bloquées ==="
gcloud logging read '
    resource.type="http_load_balancer" AND
    jsonPayload.enforcedSecurityPolicy.outcome="DENY" AND
    jsonPayload.enforcedSecurityPolicy.preview=false
' --limit=20 --format=json

echo ""
echo "=== Logs par politique spécifique (format tableau) ==="
gcloud logging read "
    resource.type=\"http_load_balancer\" AND
    jsonPayload.enforcedSecurityPolicy.name=\"policy-web-app\"
" --limit=20 --format="table(
    timestamp,
    jsonPayload.enforcedSecurityPolicy.priority,
    jsonPayload.enforcedSecurityPolicy.configuredAction,
    jsonPayload.enforcedSecurityPolicy.outcome,
    jsonPayload.enforcedSecurityPolicy.preview
)"

echo ""
echo "REMARQUE : Analysez ces logs pour identifier les faux positifs."
echo "Si pas de faux positifs, vous pouvez passer les règles en mode Enforce."
