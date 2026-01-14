#!/bin/bash
# Lab 5.3 - Exercice 5.3.5 : Configurer l'utilisateur et la base de données
# Objectif : Configurer Cloud SQL pour les tests

set -e

echo "=== Lab 5.3 - Exercice 5 : Configurer Cloud SQL ==="
echo ""

# Définir le mot de passe de l'utilisateur postgres
echo "Configuration du mot de passe pour l'utilisateur postgres..."
gcloud sql users set-password postgres \
    --instance=sql-private \
    --password=MySecureP@ssw0rd!

echo ""
echo "Mot de passe configuré !"
echo ""

# Créer une base de données
echo "Création de la base de données testdb..."
gcloud sql databases create testdb --instance=sql-private

echo ""
echo "Base de données créée !"
echo ""

# Récupérer l'IP privée de l'instance
echo "=== Informations de connexion ==="
export SQL_IP=$(gcloud sql instances describe sql-private \
    --format="get(ipAddresses[0].ipAddress)")

echo "Nom de l'instance : sql-private"
echo "IP privée : $SQL_IP"
echo "Base de données : testdb"
echo "Utilisateur : postgres"
echo "Mot de passe : MySecureP@ssw0rd!"
echo ""

# Sauvegarder l'IP pour les scripts suivants
echo "export SQL_IP=$SQL_IP" > /tmp/sql-ip.env
echo ""
echo "=== Configuration terminée ! ==="
echo ""
echo "L'IP privée a été sauvegardée dans /tmp/sql-ip.env"
echo "pour les scripts suivants."
