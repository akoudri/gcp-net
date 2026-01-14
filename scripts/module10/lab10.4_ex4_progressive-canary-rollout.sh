#!/bin/bash
# Lab 10.4 - Exercice 10.4.4 : Augmenter progressivement le trafic Canary
# Objectif : Script pour augmenter progressivement le trafic vers la version canary

set -e

echo "=== Lab 10.4 - Exercice 4 : Rollout Canary progressif ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)

# Fonction pour mettre à jour les poids
update_weights() {
    V1_WEIGHT=$1
    V2_WEIGHT=$2

    cat > urlmap-canary.yaml << EOF
name: urlmap-canary
defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
hostRules:
- hosts:
  - "*"
  pathMatcher: canary-matcher
pathMatchers:
- name: canary-matcher
  defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
  routeRules:
  - priority: 1
    matchRules:
    - prefixMatch: /
    routeAction:
      weightedBackendServices:
      - backendService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
        weight: $V1_WEIGHT
      - backendService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v2
        weight: $V2_WEIGHT
EOF

    gcloud compute url-maps import urlmap-canary \
        --source=urlmap-canary.yaml \
        --global --quiet

    echo "Poids mis à jour : v1=$V1_WEIGHT%, v2=$V2_WEIGHT%"
}

# Progression Canary
echo "=== Phase 1 : 90/10 ==="
update_weights 90 10
sleep 5

echo ""
echo "=== Phase 2 : 50/50 ==="
update_weights 50 50
sleep 5

echo ""
echo "=== Phase 3 : 10/90 ==="
update_weights 10 90
sleep 5

echo ""
echo "=== Phase 4 : 0/100 (rollout complet) ==="
update_weights 0 100

echo ""
echo "Rollout Canary terminé !"
echo ""
echo "La version 2 reçoit maintenant 100% du trafic."
echo ""
echo "Note : Dans un environnement de production, laissez plusieurs minutes"
echo "       entre chaque phase et surveillez les métriques."
