#!/bin/bash
# Lab 9.10 - Exercice 9.10.3 : Attacher l'Edge Policy
# Objectif : Activer Cloud CDN et attacher l'edge security policy

set -e

echo "=== Lab 9.10 - Exercice 3 : Attacher l'Edge Policy ==="
echo ""

# Activer Cloud CDN sur le backend
echo "Activation de Cloud CDN sur le backend service..."
gcloud compute backend-services update backend-web \
    --enable-cdn \
    --global

echo ""
# Attacher l'edge security policy
echo "Attachement de l'edge security policy..."
gcloud compute backend-services update backend-web \
    --edge-security-policy=edge-policy \
    --global

echo ""
echo "Edge Security Policy attachée avec succès !"
echo ""

# Vérifier
echo "=== Vérification de l'attachement ==="
gcloud compute backend-services describe backend-web \
    --global \
    --format="yaml(securityPolicy,edgeSecurityPolicy,enableCDN)"

echo ""
echo "REMARQUE : Le backend a maintenant :"
echo "  - Cloud CDN activé (enableCDN: true)"
echo "  - Edge Security Policy attachée (edgeSecurityPolicy)"
echo "  - Backend Security Policy attachée (securityPolicy)"
