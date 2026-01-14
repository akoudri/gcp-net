#!/bin/bash
# Lab 6.7 - Exercice 6.7.4 : Analyser les logs en détail
# Objectif : Explorer la structure complète des logs DNS

set -e

echo "=== Lab 6.7 - Exercice 4 : Analyser les logs en détail ==="
echo ""

# Voir un log complet en JSON
echo "=== Exemple de log DNS complet (format JSON) ==="
gcloud logging read 'resource.type="dns_query"' \
    --limit=1 \
    --format=json
echo ""

cat << 'STRUCTURE'
=== Structure des logs DNS ===

Champs disponibles dans les logs DNS:

{
  "queryName": "vm2.lab.internal.",     # Nom demandé
  "queryType": "A",                      # Type de requête
  "responseCode": "NOERROR",             # Code réponse
  "rdata": "10.0.0.20",                  # Réponse
  "sourceNetwork": "vpc-dns-lab",        # VPC source
  "vmInstanceId": "1234567890",          # ID VM
  "vmInstanceName": "vm1",               # Nom VM
  "vmProjectId": "mon-projet",           # Projet
  "vmZoneName": "europe-west1-b",        # Zone
  "targetType": "PRIVATE_ZONE"           # Type de zone
}

Codes de réponse courants:
- NOERROR: Succès
- NXDOMAIN: Domaine inexistant
- SERVFAIL: Erreur serveur
- REFUSED: Requête refusée
STRUCTURE
