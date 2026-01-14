#!/bin/bash
# Lab 8.6 - Exercice 8.6.1 : Activer le logging
# Objectif : Activer les logs sur les règles de pare-feu

set -e

echo "=== Lab 8.6 - Exercice 1 : Activer le logging des règles ==="
echo ""

export VPC_NAME="vpc-security-lab"

echo "VPC : $VPC_NAME"
echo ""

# Activer le logging sur une règle existante (allow)
echo ">>> Activation du logging sur la règle allow-http-web-sa..."
if gcloud compute firewall-rules describe ${VPC_NAME}-allow-http-web-sa &>/dev/null; then
    gcloud compute firewall-rules update ${VPC_NAME}-allow-http-web-sa \
        --enable-logging \
        --logging-metadata=INCLUDE_ALL_METADATA
    echo "Logging activé !"
else
    echo "AVERTISSEMENT : Règle ${VPC_NAME}-allow-http-web-sa non trouvée."
    echo "Veuillez d'abord exécuter les labs 8.3 pour créer les règles avec Service Accounts."
fi

echo ""

# Activer le logging sur une règle de deny
echo ">>> Activation du logging sur la règle deny-dangerous-ports..."
if gcloud compute firewall-rules describe ${VPC_NAME}-deny-dangerous-ports &>/dev/null; then
    gcloud compute firewall-rules update ${VPC_NAME}-deny-dangerous-ports \
        --enable-logging \
        --logging-metadata=INCLUDE_ALL_METADATA
    echo "Logging activé !"
else
    echo "AVERTISSEMENT : Règle ${VPC_NAME}-deny-dangerous-ports non trouvée."
    echo "Veuillez d'abord exécuter le lab 8.2.6 pour créer cette règle."
fi

echo ""

# Vérifier le statut du logging
echo "=== Vérification du statut du logging ==="
echo ""
echo "Règles avec logging activé :"
gcloud compute firewall-rules list \
    --filter="network:$VPC_NAME AND logConfig.enable=true" \
    --format="table(name,logConfig.enable,logConfig.metadata)"

echo ""
echo "Questions à considérer :"
echo "1. Quel est l'impact du logging sur les performances ?"
echo "2. Pourquoi utiliser INCLUDE_ALL_METADATA ?"
echo "3. Combien de temps les logs sont-ils conservés par défaut ?"
