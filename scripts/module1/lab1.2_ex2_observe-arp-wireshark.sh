#!/bin/bash
# Lab 1.2 - Exercice 1.2.2 : Observer ARP en action avec Wireshark
# Objectif : Capturer des requêtes/réponses ARP

set -e

echo "=== Lab 1.2 - Exercice 2 : Observer ARP en action ==="
echo ""

# Obtenir la passerelle par défaut
GATEWAY=$(ip route show default | awk '{print $3}' | head -n1)

if [ -z "$GATEWAY" ]; then
    echo "❌ Impossible de trouver la passerelle par défaut"
    exit 1
fi

echo "Passerelle détectée : $GATEWAY"
echo ""

# Vider la table ARP
echo "1. Vidage de la table ARP..."
sudo ip neigh flush all
echo "✓ Table ARP vidée"
echo ""

echo "2. ⚠️  INSTRUCTIONS :"
echo "   - Ouvrez Wireshark et sélectionnez votre interface réseau"
echo "   - Appliquez le filtre : arp"
echo "   - Cliquez sur 'Start capturing'"
echo ""
read -p "Appuyez sur Entrée quand Wireshark est prêt..."
echo ""

# Effectuer un ping vers la passerelle
echo "3. Envoi d'un ping vers la passerelle $GATEWAY..."
ping -c 1 $GATEWAY
echo ""

echo "4. 📊 ANALYSE DANS WIRESHARK :"
echo "   - Identifiez la requête ARP (Who has $GATEWAY? Tell ...)"
echo "   - Identifiez la réponse ARP ($GATEWAY is at AA:BB:CC:DD:EE:FF)"
echo "   - Notez les adresses MAC source et destination"
echo ""

echo "Questions à considérer :"
echo "1. Quelle est l'adresse MAC de destination d'une requête ARP ? Pourquoi ?"
echo "2. Combien de temps les entrées ARP restent-elles en cache ?"
echo "3. Que se passe-t-il si l'hôte cible n'existe pas ?"
