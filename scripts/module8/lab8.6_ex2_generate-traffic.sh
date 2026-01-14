#!/bin/bash
# Lab 8.6 - Exercice 8.6.2 : Générer du trafic pour les logs
# Objectif : Créer du trafic pour tester les logs de pare-feu

set -e

echo "=== Lab 8.6 - Exercice 2 : Générer du trafic pour les logs ==="
echo ""

export ZONE="europe-west1-b"

echo "Zone : $ZONE"
echo ""

# Vérifier si vm-web-sa existe
if ! gcloud compute instances describe vm-web-sa --zone=$ZONE &>/dev/null; then
    echo "ERREUR : vm-web-sa n'existe pas."
    echo "Veuillez d'abord exécuter le lab 8.3.4 pour créer les VMs avec Service Accounts."
    exit 1
fi

# Générer du trafic HTTP (sera loggé comme ALLOWED)
echo ">>> Génération de trafic HTTP vers vm-web-sa..."
VM_WEB_IP=$(gcloud compute instances describe vm-web-sa --zone=$ZONE \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null || echo "")

if [ -n "$VM_WEB_IP" ]; then
    echo "IP externe de vm-web-sa : $VM_WEB_IP"
    curl -m 5 http://$VM_WEB_IP 2>/dev/null || echo "Connexion HTTP testée (peut échouer si nginx pas encore démarré)"
else
    echo "vm-web-sa n'a pas d'IP externe, test HTTP sauté."
fi

echo ""

# Tenter une connexion Telnet (sera loggé comme DENIED)
echo ">>> Test de connexion Telnet (sera bloqué)..."
gcloud compute ssh vm-web-sa --zone=$ZONE --command="
echo 'Test de connexion Telnet depuis vm-web-sa...'
nc -zv localhost 23 -w 2 2>&1 || echo 'Port 23 bloqué (attendu)'
" 2>/dev/null || true

echo ""
echo "Trafic généré avec succès !"
echo ""

echo "Attendez quelques minutes pour que les logs soient disponibles..."
echo ""
echo "Pour consulter les logs, exécutez :"
echo "  ./lab8.6_ex3_view-logs.sh"
echo ""

echo "Questions à considérer :"
echo "1. Combien de temps faut-il pour que les logs apparaissent ?"
echo "2. Tous les paquets sont-ils loggés ou seulement un échantillon ?"
echo "3. Comment distinguer le trafic autorisé du trafic bloqué dans les logs ?"
