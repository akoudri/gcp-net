#!/bin/bash
# Lab 11.9 - Exercice 11.9.2 : Créer une alerte sur la bande passante
# Objectif : Créer une alerte pour détecter un trafic réseau élevé

set -e

echo "=== Lab 11.9 - Exercice 2 : Créer une alerte sur la bande passante ==="
echo ""

# Récupérer le Channel ID
echo "Récupération du canal de notification..."
CHANNEL_ID=$(gcloud alpha monitoring channels list --format="get(name)" | head -1)

if [ -z "$CHANNEL_ID" ]; then
    echo "Erreur: Aucun canal de notification trouvé."
    echo "Exécutez d'abord le script lab11.9_ex1_create-notification-channel.sh"
    exit 1
fi

echo "Canal de notification : $CHANNEL_ID"
echo ""

# Créer le fichier de politique d'alerte
echo "Création de la politique d'alerte..."
cat > /tmp/alert-bandwidth.json << EOF
{
  "displayName": "High Network Bandwidth Alert",
  "conditions": [
    {
      "displayName": "Bytes sent > 100MB/min",
      "conditionThreshold": {
        "filter": "metric.type=\"compute.googleapis.com/instance/network/sent_bytes_count\" resource.type=\"gce_instance\"",
        "aggregations": [
          {
            "alignmentPeriod": "60s",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "thresholdValue": 1747626,
        "duration": "300s",
        "trigger": {
          "count": 1
        }
      }
    }
  ],
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": ["$CHANNEL_ID"],
  "documentation": {
    "content": "Le trafic réseau sortant dépasse 100MB/min. Vérifier l'activité de la VM.",
    "mimeType": "text/markdown"
  }
}
EOF

echo "Fichier de configuration créé : /tmp/alert-bandwidth.json"
echo ""

# Créer la politique
echo "Création de la politique d'alerte..."
gcloud alpha monitoring policies create --policy-from-file=/tmp/alert-bandwidth.json

echo ""
echo "=== Alerte créée avec succès ==="
echo ""
echo "Alerte : High Network Bandwidth Alert"
echo "Seuil : > 100MB/min pendant 5 minutes"
echo "Action : Notification vers $CHANNEL_ID"
echo ""
echo "Consultez les alertes dans la Console GCP :"
echo "  Navigation: Cloud Console → Monitoring → Alerting"
