#!/bin/bash
# Lab 5.5 - Exercice 5.5.7 : Comparer PSC avec PGA
# Objectif : Documenter les différences entre PSC et PGA

set -e

echo "=== Lab 5.5 - Exercice 7 : Comparer PSC avec PGA ==="
echo ""

cat << 'EOF'
=== Comparaison PSC vs PGA pour les APIs Google ===

┌────────────────────┬────────────────────────┬──────────────────────────┐
│ Aspect             │ PGA                    │ PSC                      │
├────────────────────┼────────────────────────┼──────────────────────────┤
│ IP utilisée        │ IPs Google             │ IP dans VOTRE VPC        │
│                    │ (199.36.153.x)         │ (10.1.0.100)             │
├────────────────────┼────────────────────────┼──────────────────────────┤
│ Configuration      │ Par sous-réseau        │ Par endpoint             │
├────────────────────┼────────────────────────┼──────────────────────────┤
│ DNS                │ Optionnel mais         │ Obligatoire              │
│                    │ recommandé             │                          │
├────────────────────┼────────────────────────┼──────────────────────────┤
│ Transitivité       │ Via routes spéciales   │ Native (IP routable)     │
│ on-prem            │                        │                          │
├────────────────────┼────────────────────────┼──────────────────────────┤
│ Isolation          │ Partagé entre tous     │ Dédié par endpoint       │
├────────────────────┼────────────────────────┼──────────────────────────┤
│ Granularité        │ Tout ou rien           │ Par bundle/service       │
├────────────────────┼────────────────────────┼──────────────────────────┤
│ Complexité         │ Simple                 │ Moyenne                  │
├────────────────────┼────────────────────────┼──────────────────────────┤
│ Coût               │ Gratuit                │ Faible coût endpoint     │
└────────────────────┴────────────────────────┴──────────────────────────┘

Quand choisir PSC :
✓ Accès depuis on-premise (IP routable dans votre espace d'adressage)
✓ Besoin d'isolation/contrôle fin par service
✓ Exigences de sécurité strictes
✓ VPC Service Controls
✓ Audit et monitoring détaillés par endpoint

Quand PGA suffit :
✓ VMs GCP uniquement (pas de connectivité on-premise)
✓ Configuration simple et rapide
✓ Pas d'exigences d'isolation par service
✓ Budget limité (PGA est gratuit)

Architecture typique :
- PME/Startup : PGA suffit généralement
- Entreprise avec on-premise : PSC recommandé
- Conformité stricte : PSC + VPC Service Controls

EOF

echo ""
echo "=== Documentation générée ==="
echo ""
echo "Votre environnement actuel utilise PSC pour démontrer la configuration avancée."
