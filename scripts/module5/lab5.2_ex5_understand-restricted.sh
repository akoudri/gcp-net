#!/bin/bash
# Lab 5.2 - Exercice 5.2.5 : Comprendre restricted.googleapis.com
# Objectif : Documenter la différence entre private et restricted

set -e

echo "=== Lab 5.2 - Exercice 5 : Comprendre restricted.googleapis.com ==="
echo ""

cat << 'EOF'
=== Comparaison private.googleapis.com vs restricted.googleapis.com ===

┌────────────────────┬──────────────────────────┬────────────────────────────┐
│ Aspect             │ private.googleapis.com   │ restricted.googleapis.com  │
├────────────────────┼──────────────────────────┼────────────────────────────┤
│ IPs                │ 199.36.153.8/30          │ 199.36.153.4/30            │
│ Usage              │ PGA standard             │ VPC Service Controls       │
│ Services           │ Tous les services Google │ Services compatibles VPC-SC│
│ Périmètre          │ Pas de restriction       │ Respecte les périmètres    │
│ Cas d'usage        │ VMs sans IP externe      │ Données sensibles          │
└────────────────────┴──────────────────────────┴────────────────────────────┘

Quand utiliser restricted.googleapis.com :
✓ Projet dans un périmètre VPC Service Controls
✓ Exigences de conformité strictes (HIPAA, PCI-DSS)
✓ Prévention de l'exfiltration de données
✓ Contrôle d'accès basé sur le périmètre

Quand private.googleapis.com suffit :
✓ Pas de VPC Service Controls
✓ VMs sans IP externe accédant aux APIs Google
✓ Configuration simple et standard

IMPORTANT:
restricted.googleapis.com nécessite VPC Service Controls (VPC-SC).
Si vous n'avez pas configuré VPC-SC, utilisez private.googleapis.com.

EOF

echo ""
echo "=== Documentation générée ==="
echo ""
echo "Pour plus d'informations sur VPC Service Controls :"
echo "https://cloud.google.com/vpc-service-controls"
