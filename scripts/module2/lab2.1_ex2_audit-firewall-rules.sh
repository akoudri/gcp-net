#!/bin/bash
# Lab 2.1 - Exercice 2.1.2 : Auditer les règles de pare-feu par défaut
# Objectif : Identifier les risques de sécurité des règles par défaut

set -e

echo "=== Lab 2.1 - Exercice 2 : Auditer les règles de pare-feu par défaut ==="
echo ""

# Lister les règles de pare-feu du VPC default
echo "=== Règles de pare-feu du VPC default ==="
gcloud compute firewall-rules list --filter="network=default"
echo ""

# Examiner chaque règle en détail
echo "=== Détails de la règle default-allow-ssh ==="
gcloud compute firewall-rules describe default-allow-ssh
echo ""

echo "=== Détails de la règle default-allow-rdp ==="
gcloud compute firewall-rules describe default-allow-rdp
echo ""

echo "=== Détails de la règle default-allow-icmp ==="
gcloud compute firewall-rules describe default-allow-icmp
echo ""

echo "=== Détails de la règle default-allow-internal ==="
gcloud compute firewall-rules describe default-allow-internal
echo ""

echo "Questions à considérer :"
echo "1. Quelles sont les sources autorisées pour SSH ? Est-ce sécurisé ?"
echo "2. La règle default-allow-internal autorise quels protocoles ?"
echo "3. Identifiez au moins 3 risques de sécurité avec ces règles par défaut."
