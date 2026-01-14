#!/bin/bash
# Lab 6.10 - Exercice 6.10.5 : Geolocation avec health checks
# Objectif : Afficher la configuration avancée avec failover

set -e

echo "=== Lab 6.10 - Exercice 5 : Geolocation avec health checks ==="
echo ""

cat << 'CONFIG'
=== Configuration avancée Geolocation + Health Check ===

Pour une configuration production avec failover géographique:

1. Créer des ressources dans chaque région
2. Configurer des health checks
3. Utiliser la politique GEO avec backup

Exemple de configuration avec backup:

gcloud dns record-sets create "app.example.com." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --routing-policy-type=GEO \
    --routing-policy-data="
        europe-west1=10.0.0.100;
        us-central1=10.1.0.100;
        asia-east1=10.2.0.100
    " \
    --enable-health-checking \
    --health-check=projects/PROJECT/global/healthChecks/hc-dns

Comportement:
- Si un backend régional échoue au health check,
  le trafic est automatiquement redirigé vers la région la plus proche.

Configuration du health check:

gcloud compute health-checks create http hc-dns-geo \
    --port=80 \
    --request-path=/health \
    --check-interval=10s \
    --timeout=5s \
    --unhealthy-threshold=3 \
    --healthy-threshold=2

Avantages:
- Haute disponibilité automatique
- Réduction de la latence
- Failover géographique transparent
CONFIG

echo ""
echo "Cette configuration permet une résilience et des performances optimales."
