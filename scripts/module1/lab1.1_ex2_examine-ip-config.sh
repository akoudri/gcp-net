#!/bin/bash
# Lab 1.1 - Exercice 1.1.2 : Examiner la configuration IP
# Objectif : Comprendre les adresses MAC et IP

set -e

echo "=== Lab 1.1 - Exercice 2 : Examiner la configuration IP ==="
echo ""

# Afficher les adresses IP
echo "=== Toutes les adresses IP ==="
ip addr show
echo ""

# Afficher uniquement IPv4
echo "=== Adresses IPv4 uniquement ==="
ip -4 addr show
echo ""

# Afficher uniquement IPv6
echo "=== Adresses IPv6 uniquement ==="
ip -6 addr show
echo ""

echo "Questions à considérer :"
echo "1. Quelle est votre adresse IP privée ? Dans quelle classe/plage se trouve-t-elle ?"
echo "2. Quel est le masque de sous-réseau (notation CIDR et décimale) ?"
echo "3. Avez-vous une adresse IPv6 ? De quel type (link-local, global) ?"
