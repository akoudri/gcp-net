#!/bin/bash
# Lab 6.8 - Exercice 6.8.5 : Gestion des clés
# Objectif : Comprendre la gestion des clés DNSSEC

set -e

echo "=== Lab 6.8 - Exercice 5 : Gestion des clés DNSSEC ==="
echo ""

echo "Cloud DNS gère automatiquement la rotation des ZSK (Zone Signing Key)."
echo ""

# Voir l'état des clés
echo "=== État des clés DNSSEC ==="
gcloud dns dns-keys list --zone=zone-public-lab \
    --format="table(id,type,keyTag,isActive)"
echo ""

cat << 'MANAGEMENT'
=== Gestion des clés DNSSEC ===

Rotation automatique:
- ZSK (Zone Signing Key) : Rotation automatique tous les 90 jours
- Cloud DNS gère le processus complet
- Aucune action requise

Rotation KSK (Key Signing Key):
- Moins fréquente (rarement nécessaire)
- Nécessite une mise à jour du DS record chez le registrar
- À effectuer avec précaution

Processus de rotation KSK:
1. Cloud DNS génère une nouvelle KSK
2. Les deux clés coexistent pendant une période
3. Mettre à jour le DS record chez le registrar
4. Attendre la propagation DNS
5. Ancienne KSK désactivée automatiquement

Note : Ne pas désactiver DNSSEC sans supprimer d'abord
le DS record chez le registrar, sous peine de casser
la résolution DNS !
MANAGEMENT

echo ""
echo "Pour plus d'informations sur la rotation manuelle des clés :"
echo "https://cloud.google.com/dns/docs/dnssec-config"
