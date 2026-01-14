#!/bin/bash
# Lab 8.8 - Exercice 8.8.5 : Nettoyage Cloud IDS
# Objectif : Supprimer les ressources Cloud IDS pour éviter les frais

set -e

echo "=== Lab 8.8 - Exercice 5 : Nettoyage Cloud IDS ==="
echo ""

export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Région : $REGION"
echo "Zone : $ZONE"
echo ""

# Supprimer le packet mirroring
echo ">>> Suppression du packet mirroring..."
gcloud compute packet-mirrorings delete mirror-to-ids \
    --region=$REGION --quiet 2>/dev/null || echo "Packet mirroring non trouvé ou déjà supprimé"

echo ""

# Supprimer l'endpoint IDS
echo ">>> Suppression de l'endpoint IDS..."
gcloud ids endpoints delete ids-endpoint-lab \
    --zone=$ZONE --quiet 2>/dev/null || echo "Endpoint IDS non trouvé ou déjà supprimé"

echo ""
echo "=== Nettoyage terminé ==="
echo ""
echo "✓ Packet mirroring supprimé"
echo "✓ Endpoint Cloud IDS supprimé"
echo ""
echo "Cloud IDS ne génère plus de coûts."
echo ""

echo "Questions à considérer :"
echo "1. Combien de temps faut-il pour que les coûts cessent complètement ?"
echo "2. Les logs IDS générés sont-ils conservés après suppression de l'endpoint ?"
echo "3. Comment estimer le coût total de Cloud IDS avant déploiement ?"
