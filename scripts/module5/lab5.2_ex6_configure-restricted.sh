#!/bin/bash
# Lab 5.2 - Exercice 5.2.6 : (Optionnel) Configurer pour restricted.googleapis.com
# Objectif : Montrer comment configurer restricted (pour information uniquement)

set -e

echo "=== Lab 5.2 - Exercice 6 : Configurer restricted.googleapis.com (OPTIONNEL) ==="
echo ""

cat << 'EOF'
⚠️  ATTENTION : Cet exercice est fourni à titre INFORMATIF uniquement.

restricted.googleapis.com nécessite VPC Service Controls (VPC-SC).
Si vous n'avez pas configuré VPC-SC, ces commandes échoueront.

Pour référence, voici la configuration pour restricted.googleapis.com :

# 1. Créer une zone DNS pour VPC Service Controls
gcloud dns managed-zones create googleapis-restricted \
    --dns-name="googleapis.com." \
    --visibility=private \
    --networks=VPC_AVEC_VPC_SC \
    --description="Zone pour VPC Service Controls"

# 2. Enregistrement A pour restricted.googleapis.com
gcloud dns record-sets create "restricted.googleapis.com." \
    --zone=googleapis-restricted \
    --type=A \
    --ttl=300 \
    --rrdatas="199.36.153.4,199.36.153.5,199.36.153.6,199.36.153.7"

# 3. CNAME wildcard
gcloud dns record-sets create "*.googleapis.com." \
    --zone=googleapis-restricted \
    --type=CNAME \
    --ttl=300 \
    --rrdatas="restricted.googleapis.com."

NOTES IMPORTANTES :
- IPs restricted: 199.36.153.4/30 (différent de private)
- Nécessite un périmètre VPC Service Controls configuré
- Les APIs non compatibles VPC-SC ne fonctionneront pas
- Utilisé pour des exigences de conformité strictes

Pour en savoir plus sur la configuration de VPC Service Controls :
https://cloud.google.com/vpc-service-controls/docs/set-up-gcp-org

EOF

echo ""
echo "=== Exercice informatif terminé ==="
echo ""
echo "Pour ce lab, continuez avec private.googleapis.com."
