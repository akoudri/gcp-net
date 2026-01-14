#!/bin/bash
# Lab 11.11 - Exercice 11.11.1 : Optimiser le sampling
# Objectif : Configurer différents niveaux de sampling selon l'environnement

set -e

echo "=== Lab 11.11 - Exercice 1 : Optimiser le sampling ==="
echo ""

# Variables
export REGION="europe-west1"

echo "Région : $REGION"
echo ""

echo "Configurations de sampling disponibles :"
echo ""
echo "1. Configuration économique (dev/test)"
echo "   - Sampling : 10% (0.1)"
echo "   - Intervalle : 10 minutes"
echo "   - Coût estimé : 0.1-0.5 EUR/VM/mois"
echo ""
echo "2. Configuration équilibrée (production standard)"
echo "   - Sampling : 50% (0.5)"
echo "   - Intervalle : 1 minute"
echo "   - Coût estimé : 1-5 EUR/VM/mois"
echo ""
echo "3. Configuration complète (investigation temporaire)"
echo "   - Sampling : 100% (1.0)"
echo "   - Intervalle : 30 secondes"
echo "   - Coût estimé : 5-20 EUR/VM/mois"
echo ""

read -p "Choisissez une configuration (1, 2 ou 3) : " CONFIG_CHOICE

case $CONFIG_CHOICE in
    1)
        echo ""
        echo "Application de la configuration économique..."
        gcloud compute networks subnets update subnet-monitored \
            --region=$REGION \
            --logging-flow-sampling=0.1 \
            --logging-aggregation-interval=INTERVAL_10_MIN
        ;;
    2)
        echo ""
        echo "Application de la configuration équilibrée..."
        gcloud compute networks subnets update subnet-monitored \
            --region=$REGION \
            --logging-flow-sampling=0.5 \
            --logging-aggregation-interval=INTERVAL_1_MIN
        ;;
    3)
        echo ""
        echo "Application de la configuration complète..."
        gcloud compute networks subnets update subnet-monitored \
            --region=$REGION \
            --logging-flow-sampling=1.0 \
            --logging-aggregation-interval=INTERVAL_30_SEC
        ;;
    *)
        echo "Choix invalide. Aucune modification appliquée."
        exit 1
        ;;
esac

echo ""
echo "Configuration appliquée avec succès !"
echo ""

# Afficher la configuration actuelle
echo "=== Configuration actuelle ==="
gcloud compute networks subnets describe subnet-monitored \
    --region=$REGION \
    --format="yaml(logConfig)"
