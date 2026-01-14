#!/bin/bash
# Lab 2.5 - Exercice 2.5.5 : Estimer les coûts
# Objectif : Afficher la configuration et comparer les coûts

set -e

echo "=== Lab 2.5 - Exercice 5 : Estimation des coûts ==="
echo ""

# Afficher la configuration des VMs
echo "=== Configuration des VMs ==="
gcloud compute instances list \
    --filter="name:(vm-premium OR vm-standard)" \
    --format="table(name,zone,networkInterfaces[0].networkTier,networkInterfaces[0].accessConfigs[0].natIP)"

echo ""
echo "=== Comparaison des coûts (approximatif) ==="
echo ""

cat << 'EOF'
┌───────────────────────────┬──────────────┬───────────────┬──────────┐
│ Élément                   │ Premium Tier │ Standard Tier │ Économie │
├───────────────────────────┼──────────────┼───────────────┼──────────┤
│ Egress Internet (par Go)  │ ~$0.12       │ ~$0.085       │ ~30%     │
│ IP externe statique (par h)│ ~$0.004     │ ~$0.002       │ ~50%     │
└───────────────────────────┴──────────────┴───────────────┴──────────┘

Cas d'usage :

Premium Tier :
  ✓ Applications globales nécessitant faible latence
  ✓ Services critiques avec SLA exigeants
  ✓ Trafic entrant via le PoP Google le plus proche

Standard Tier :
  ✓ Applications régionales
  ✓ Workloads sensibles aux coûts
  ✓ Transfert de données volumineux (backups, logs)

Exemple d'économie :
  Workload transférant 1 To/mois vers Internet :
  - Premium : 1024 Go × $0.12 = ~$123/mois
  - Standard : 1024 Go × $0.085 = ~$87/mois
  - Économie : ~$36/mois (29%)

Questions :
1. Pour un workload transférant 1 To/mois, quelle serait l'économie avec Standard ?
   → Environ $36/mois (29% d'économie)

2. Le Standard Tier est-il adapté pour une API utilisée mondialement ?
   → Non, la latence sera plus élevée pour les utilisateurs éloignés
   → Premium est préférable pour une audience globale
EOF
