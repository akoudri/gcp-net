#!/bin/bash
# Lab 11.8 - Exercice 11.8.1 : Créer un dashboard via JSON
# Objectif : Créer un dashboard personnalisé pour les métriques réseau

set -e

echo "=== Lab 11.8 - Exercice 1 : Créer un dashboard réseau ==="
echo ""

# Créer le fichier de configuration du dashboard
echo "Création du fichier de configuration du dashboard..."
cat > /tmp/network-dashboard.json << 'EOF'
{
  "displayName": "Network Overview Dashboard",
  "mosaicLayout": {
    "columns": 12,
    "tiles": [
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Network Bytes Sent by VM",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"compute.googleapis.com/instance/network/sent_bytes_count\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_RATE",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": ["resource.label.instance_id"]
                  }
                }
              },
              "plotType": "LINE"
            }],
            "timeshiftDuration": "0s",
            "yAxis": {
              "label": "bytes/s",
              "scale": "LINEAR"
            }
          }
        }
      },
      {
        "xPos": 6,
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Network Bytes Received by VM",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"compute.googleapis.com/instance/network/received_bytes_count\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_RATE",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": ["resource.label.instance_id"]
                  }
                }
              },
              "plotType": "LINE"
            }],
            "yAxis": {
              "label": "bytes/s",
              "scale": "LINEAR"
            }
          }
        }
      },
      {
        "yPos": 4,
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Packets Sent",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"compute.googleapis.com/instance/network/sent_packets_count\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_RATE"
                  }
                }
              },
              "plotType": "LINE"
            }]
          }
        }
      },
      {
        "xPos": 6,
        "yPos": 4,
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Packets Received",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"compute.googleapis.com/instance/network/received_packets_count\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_RATE"
                  }
                }
              },
              "plotType": "LINE"
            }]
          }
        }
      }
    ]
  }
}
EOF

echo "Fichier de configuration créé : /tmp/network-dashboard.json"
echo ""

# Créer le dashboard
echo "Création du dashboard dans Cloud Monitoring..."
gcloud monitoring dashboards create --config-from-file=/tmp/network-dashboard.json

echo ""
echo "Dashboard créé avec succès !"
echo ""

# Lister les dashboards
echo "=== Dashboards disponibles ==="
gcloud monitoring dashboards list

echo ""
echo "Accédez au dashboard dans la Console GCP :"
echo "  Navigation: Cloud Console → Monitoring → Dashboards"
