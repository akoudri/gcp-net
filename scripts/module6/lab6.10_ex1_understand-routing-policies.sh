#!/bin/bash
# Lab 6.10 - Exercice 6.10.1 : Comprendre les routing policies
# Objectif : Afficher les concepts des routing policies

set -e

echo "=== Lab 6.10 - Exercice 1 : Comprendre les routing policies ==="
echo ""

cat << 'POLICIES'
=== Routing Policies Cloud DNS ===

TYPE 1: Geolocation
- Réponse basée sur la localisation géographique du client
- Utile pour: CDN, réduction de latence, conformité régionale

TYPE 2: Weighted Round Robin (WRR)
- Distribution pondérée du trafic entre plusieurs cibles
- Utile pour: Canary deployments, migration progressive, A/B testing

TYPE 3: Failover
- Basculement automatique si la cible principale est indisponible
- Utile pour: Haute disponibilité, disaster recovery

PRÉREQUIS:
- Zones publiques uniquement
- Health checks configurés (pour WRR et Failover)

=== Exemples d'utilisation ===

Geolocation:
- Clients européens → Serveur EU
- Clients américains → Serveur US
- Clients asiatiques → Serveur ASIA

Weighted Round Robin:
- 90% du trafic → Version stable
- 10% du trafic → Version canary

Failover:
- Primary: Serveur principal
- Backup: Serveur de secours (utilisé si primary down)
POLICIES

echo ""
echo "Ces policies permettent un routage DNS intelligent et dynamique."
