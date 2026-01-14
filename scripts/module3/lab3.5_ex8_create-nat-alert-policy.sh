#!/bin/bash
# Lab 3.5 - Exercice 3.5.8 : Créer une alerte sur l'utilisation des ports
# Objectif : Définir une politique d'alerte pour Cloud NAT

set -e

echo "=== Lab 3.5 - Exercice 8 : Créer une alerte sur l'utilisation des ports ==="
echo ""

# Créer un fichier de politique d'alerte
cat << 'EOF' > /tmp/nat-alert-policy.json
{
  "displayName": "Cloud NAT Port Usage High",
  "conditions": [
    {
      "displayName": "NAT port usage > 80%",
      "conditionThreshold": {
        "filter": "resource.type=\"nat_gateway\" AND metric.type=\"router.googleapis.com/nat/port_usage\"",
        "comparison": "COMPARISON_GT",
        "thresholdValue": 0.8,
        "duration": "300s"
      }
    }
  ],
  "combiner": "OR"
}
EOF

echo "Politique d'alerte définie dans /tmp/nat-alert-policy.json"
echo ""
cat /tmp/nat-alert-policy.json
echo ""

echo "Pour créer l'alerte, utilisez la Console Cloud Monitoring ou l'API."
echo ""
echo "Note : La création d'alertes via gcloud nécessite l'API Cloud Monitoring."
echo "       Référez-vous à la documentation GCP pour plus de détails."
echo ""
