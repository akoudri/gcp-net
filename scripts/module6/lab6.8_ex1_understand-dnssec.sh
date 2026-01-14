#!/bin/bash
# Lab 6.8 - Exercice 6.8.1 : Comprendre DNSSEC
# Objectif : Afficher les concepts DNSSEC

set -e

echo "=== Lab 6.8 - Exercice 1 : Comprendre DNSSEC ==="
echo ""

cat << 'DNSSEC'
=== DNSSEC - Sécurisation du DNS ===

PROBLÈME:
- Les réponses DNS peuvent être falsifiées (spoofing)
- Attaques "cache poisoning"
- Redirection vers des sites malveillants

SOLUTION DNSSEC:
- Signature cryptographique des enregistrements
- Chaîne de confiance depuis la racine DNS
- Vérification d'authenticité des réponses

TYPES DE CLÉS:
┌─────────────────────────────────────────────────────────┐
│ KSK (Key Signing Key)                                   │
│ - Signe les clés de zone                                │
│ - Référencée dans le DS record chez le registrar        │
│ - Rotation moins fréquente                              │
├─────────────────────────────────────────────────────────┤
│ ZSK (Zone Signing Key)                                  │
│ - Signe les enregistrements de la zone                  │
│ - Rotation automatique par Cloud DNS                    │
└─────────────────────────────────────────────────────────┘

CHAÎNE DE CONFIANCE:
Root (.) → TLD (.com) → Votre domaine → Enregistrements
    DS        DS           KSK+ZSK         RRSIG
DNSSEC

echo ""
echo "DNSSEC permet de garantir l'authenticité et l'intégrité des réponses DNS."
