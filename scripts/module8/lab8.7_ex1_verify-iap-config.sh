#!/bin/bash
# Lab 8.7 - Exercice 8.7.1 : Vérifier la configuration IAP
# Objectif : S'assurer que les règles de pare-feu pour IAP sont en place

set -e

echo "=== Lab 8.7 - Exercice 1 : Vérifier la configuration IAP ==="
echo ""

export VPC_NAME="vpc-security-lab"

echo "VPC : $VPC_NAME"
echo ""

# Vérifier que la règle pare-feu pour IAP existe
echo ">>> Vérification de la règle pare-feu IAP..."
gcloud compute firewall-rules list \
    --filter="network:$VPC_NAME AND sourceRanges:35.235.240.0/20" \
    --format="table(name,direction,allowed)"

echo ""

# Si elle n'existe pas, la créer
if ! gcloud compute firewall-rules describe ${VPC_NAME}-allow-iap &>/dev/null; then
    echo ">>> Règle IAP non trouvée, création..."
    gcloud compute firewall-rules create ${VPC_NAME}-allow-iap \
        --network=$VPC_NAME \
        --direction=INGRESS \
        --action=ALLOW \
        --rules=tcp:22,tcp:3389 \
        --source-ranges=35.235.240.0/20 \
        --description="Autoriser SSH/RDP via IAP"

    echo ""
    echo "Règle IAP créée avec succès !"
else
    echo "Règle IAP existe déjà."
fi

echo ""
echo "=== Informations IAP ==="
echo ""
echo "Plage IP IAP : 35.235.240.0/20"
echo "Ports à autoriser : tcp:22 (SSH), tcp:3389 (RDP)"
echo ""
echo "Comment fonctionne IAP :"
echo "1. L'utilisateur s'authentifie avec son compte Google"
echo "2. IAP crée un tunnel HTTPS depuis votre machine"
echo "3. Le trafic arrive sur la VM depuis la plage 35.235.240.0/20"
echo "4. La VM n'a pas besoin d'IP publique"
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi IAP est-il plus sécurisé qu'un bastion avec IP publique ?"
echo "2. Quelles permissions IAM sont nécessaires pour utiliser IAP ?"
echo "3. Comment auditer les connexions IAP ?"
