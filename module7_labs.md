# Module 7 - Options de Connectivité Hybride
## Travaux Pratiques Détaillés

---

## Vue d'ensemble

### Objectifs pédagogiques
Ces travaux pratiques permettront aux apprenants de :
- Configurer Cloud VPN HA avec routage BGP
- Comprendre les modes Actif/Actif et Actif/Passif
- Simuler des architectures hybrides GCP ↔ On-premise
- Appréhender Cloud Interconnect (Dedicated et Partner)
- Découvrir Cross-Cloud Interconnect et Network Connectivity Center
- Choisir la bonne solution selon le contexte

### Prérequis
- Modules 1 à 6 complétés
- Projet GCP avec facturation activée
- APIs activées : Compute Engine, Network Connectivity
- Droits : roles/compute.networkAdmin, roles/compute.securityAdmin

### Note importante
⚠️ Les labs Cloud Interconnect (Dedicated, Partner, Cross-Cloud) sont principalement **théoriques et de simulation** car ils nécessitent :
- Des équipements physiques dans des colocations
- Des contrats avec des partenaires télécom
- Des délais de plusieurs semaines pour le provisioning
- Des coûts significatifs

Les labs VPN sont entièrement réalisables dans un environnement GCP standard.

### Labs proposés

| Lab | Titre | Difficulté | Type |
|-----|-------|-------|------------|------|
| 7.1 | Cloud VPN HA - Configuration complète | ⭐⭐ | Pratique |
| 7.2 | BGP avec Cloud Router | ⭐⭐ | Pratique |
| 7.3 | VPN Actif/Actif vs Actif/Passif | ⭐⭐⭐ | Pratique |
| 7.4 | Failover et haute disponibilité VPN | ⭐⭐ | Pratique |
| 7.5 | Dedicated Interconnect - Concepts et simulation | ⭐⭐ | Théorique |
| 7.6 | Partner Interconnect - Concepts et simulation |⭐⭐ | Théorique |
| 7.7 | Cross-Cloud Interconnect - Multi-cloud | ⭐⭐ | Théorique |
| 7.8 | Network Connectivity Center - Hub and Spoke | ⭐⭐⭐ | Pratique |
| 7.9 | Comparaison et choix de solutions | ⭐⭐ | Analyse |
| 7.10 | Scénario intégrateur - Architecture hybride multi-sites | ⭐⭐⭐ | Pratique |

---

## Lab 7.1 : Cloud VPN HA - Configuration complète
**Difficulté : ⭐⭐ | Type : Pratique**

### Objectifs
- Créer une passerelle HA VPN
- Configurer les tunnels VPN avec BGP
- Établir la connectivité entre deux VPC simulant GCP et on-premise

### Architecture cible

```
    VPC "GCP" (Production)                        VPC "On-premise" (Simulé)
    ┌────────────────────────────────┐           ┌────────────────────────────────┐
    │                                │           │                                │
    │   10.0.0.0/24                  │           │   192.168.0.0/24               │
    │                                │           │                                │
    │   ┌───────────────┐            │           │            ┌───────────────┐   │
    │   │    vm-gcp     │            │           │            │  vm-onprem    │   │
    │   │   10.0.0.10   │            │           │            │ 192.168.0.10  │   │
    │   └───────────────┘            │           │            └───────────────┘   │
    │                                │           │                                │
    │   ┌───────────────┐            │           │            ┌───────────────┐   │
    │   │ Cloud Router  │            │           │            │ Cloud Router  │   │
    │   │  ASN 65001    │            │           │            │  ASN 65002    │   │
    │   └───────┬───────┘            │           │            └───────┬───────┘   │
    │           │                    │           │                    │           │
    │   ┌───────┴───────┐            │           │            ┌───────┴───────┐   │
    │   │  HA VPN GW    │◄═══════════╪═══════════╪════════════►│  HA VPN GW    │   │
    │   │ Interface 0,1 │  Tunnel 0  │           │  Tunnel 0  │ Interface 0,1 │   │
    │   └───────────────┘  Tunnel 1  │           │  Tunnel 1  └───────────────┘   │
    │                                │           │                                │
    └────────────────────────────────┘           └────────────────────────────────┘
```

### Exercices

#### Exercice 7.1.1 : Créer l'infrastructure des deux VPC

```bash
# Variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

# ===== VPC "GCP" (Production) =====
gcloud compute networks create vpc-gcp \
    --subnet-mode=custom \
    --description="VPC simulant l'environnement GCP production"

gcloud compute networks subnets create subnet-gcp \
    --network=vpc-gcp \
    --region=$REGION \
    --range=10.0.0.0/24

# ===== VPC "On-premise" (Simulé) =====
gcloud compute networks create vpc-onprem \
    --subnet-mode=custom \
    --description="VPC simulant le datacenter on-premise"

gcloud compute networks subnets create subnet-onprem \
    --network=vpc-onprem \
    --region=$REGION \
    --range=192.168.0.0/24

# Règles de pare-feu pour les deux VPC
for VPC in vpc-gcp vpc-onprem; do
    gcloud compute firewall-rules create ${VPC}-allow-internal \
        --network=$VPC \
        --allow=tcp,udp,icmp \
        --source-ranges=10.0.0.0/8,192.168.0.0/16

    gcloud compute firewall-rules create ${VPC}-allow-ssh-iap \
        --network=$VPC \
        --allow=tcp:22 \
        --source-ranges=35.235.240.0/20
done
```

#### Exercice 7.1.2 : Déployer les VMs de test

```bash
# VM dans le VPC GCP
gcloud compute instances create vm-gcp \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-gcp \
    --subnet=subnet-gcp \
    --private-network-ip=10.0.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsutils traceroute mtr'

# VM dans le VPC On-premise
gcloud compute instances create vm-onprem \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-onprem \
    --subnet=subnet-onprem \
    --private-network-ip=192.168.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsutils traceroute mtr'
```

#### Exercice 7.1.3 : Vérifier l'absence de connectivité initiale

```bash
# Se connecter à vm-gcp et tenter de joindre vm-onprem
gcloud compute ssh vm-gcp --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test connectivité AVANT VPN ==="
ping -c 3 -W 2 192.168.0.10 2>&1 || echo "Ping échoué (attendu)"
EOF
# Résultat attendu: Network unreachable ou timeout
```

#### Exercice 7.1.4 : Créer les Cloud Routers

```bash
# Cloud Router pour VPC GCP (ASN 65001)
gcloud compute routers create router-gcp \
    --network=vpc-gcp \
    --region=$REGION \
    --asn=65001 \
    --description="Cloud Router pour VPC GCP"

# Cloud Router pour VPC On-premise (ASN 65002)
gcloud compute routers create router-onprem \
    --network=vpc-onprem \
    --region=$REGION \
    --asn=65002 \
    --description="Cloud Router pour VPC On-premise simulé"

# Vérifier les Cloud Routers
gcloud compute routers list --filter="region:$REGION"
```

#### Exercice 7.1.5 : Créer les passerelles HA VPN

```bash
# Passerelle HA VPN pour VPC GCP
gcloud compute vpn-gateways create vpn-gw-gcp \
    --network=vpc-gcp \
    --region=$REGION

# Passerelle HA VPN pour VPC On-premise
gcloud compute vpn-gateways create vpn-gw-onprem \
    --network=vpc-onprem \
    --region=$REGION

# Récupérer les IPs des passerelles
echo "=== IPs Passerelle GCP ==="
gcloud compute vpn-gateways describe vpn-gw-gcp \
    --region=$REGION \
    --format="yaml(vpnInterfaces)"

echo "=== IPs Passerelle On-premise ==="
gcloud compute vpn-gateways describe vpn-gw-onprem \
    --region=$REGION \
    --format="yaml(vpnInterfaces)"
```

#### Exercice 7.1.6 : Créer les tunnels VPN (4 tunnels au total)

```bash
# Générer des secrets partagés sécurisés
SECRET_0=$(openssl rand -base64 24)
SECRET_1=$(openssl rand -base64 24)

echo "Secret Tunnel 0: $SECRET_0"
echo "Secret Tunnel 1: $SECRET_1"

# ===== Tunnels côté GCP =====
# Tunnel 0: Interface 0 GCP → Interface 0 On-premise
gcloud compute vpn-tunnels create tunnel-gcp-to-onprem-0 \
    --vpn-gateway=vpn-gw-gcp \
    --vpn-gateway-region=$REGION \
    --peer-gcp-gateway=vpn-gw-onprem \
    --peer-gcp-gateway-region=$REGION \
    --interface=0 \
    --ike-version=2 \
    --shared-secret="$SECRET_0" \
    --router=router-gcp \
    --router-region=$REGION

# Tunnel 1: Interface 1 GCP → Interface 1 On-premise
gcloud compute vpn-tunnels create tunnel-gcp-to-onprem-1 \
    --vpn-gateway=vpn-gw-gcp \
    --vpn-gateway-region=$REGION \
    --peer-gcp-gateway=vpn-gw-onprem \
    --peer-gcp-gateway-region=$REGION \
    --interface=1 \
    --ike-version=2 \
    --shared-secret="$SECRET_1" \
    --router=router-gcp \
    --router-region=$REGION

# ===== Tunnels côté On-premise =====
# Tunnel 0: Interface 0 On-premise → Interface 0 GCP
gcloud compute vpn-tunnels create tunnel-onprem-to-gcp-0 \
    --vpn-gateway=vpn-gw-onprem \
    --vpn-gateway-region=$REGION \
    --peer-gcp-gateway=vpn-gw-gcp \
    --peer-gcp-gateway-region=$REGION \
    --interface=0 \
    --ike-version=2 \
    --shared-secret="$SECRET_0" \
    --router=router-onprem \
    --router-region=$REGION

# Tunnel 1: Interface 1 On-premise → Interface 1 GCP
gcloud compute vpn-tunnels create tunnel-onprem-to-gcp-1 \
    --vpn-gateway=vpn-gw-onprem \
    --vpn-gateway-region=$REGION \
    --peer-gcp-gateway=vpn-gw-gcp \
    --peer-gcp-gateway-region=$REGION \
    --interface=1 \
    --ike-version=2 \
    --shared-secret="$SECRET_1" \
    --router=router-onprem \
    --router-region=$REGION

# Vérifier les tunnels
gcloud compute vpn-tunnels list --filter="region:$REGION"
```

#### Exercice 7.1.7 : Configurer les interfaces et peers BGP

```bash
# ===== Interfaces BGP côté GCP =====
# Interface pour tunnel 0
gcloud compute routers add-interface router-gcp \
    --interface-name=bgp-if-gcp-0 \
    --vpn-tunnel=tunnel-gcp-to-onprem-0 \
    --ip-address=169.254.0.1 \
    --mask-length=30 \
    --region=$REGION

# Interface pour tunnel 1
gcloud compute routers add-interface router-gcp \
    --interface-name=bgp-if-gcp-1 \
    --vpn-tunnel=tunnel-gcp-to-onprem-1 \
    --ip-address=169.254.1.1 \
    --mask-length=30 \
    --region=$REGION

# ===== Interfaces BGP côté On-premise =====
# Interface pour tunnel 0
gcloud compute routers add-interface router-onprem \
    --interface-name=bgp-if-onprem-0 \
    --vpn-tunnel=tunnel-onprem-to-gcp-0 \
    --ip-address=169.254.0.2 \
    --mask-length=30 \
    --region=$REGION

# Interface pour tunnel 1
gcloud compute routers add-interface router-onprem \
    --interface-name=bgp-if-onprem-1 \
    --vpn-tunnel=tunnel-onprem-to-gcp-1 \
    --ip-address=169.254.1.2 \
    --mask-length=30 \
    --region=$REGION

# ===== Peers BGP côté GCP =====
gcloud compute routers add-bgp-peer router-gcp \
    --peer-name=bgp-peer-onprem-0 \
    --peer-asn=65002 \
    --interface=bgp-if-gcp-0 \
    --peer-ip-address=169.254.0.2 \
    --region=$REGION

gcloud compute routers add-bgp-peer router-gcp \
    --peer-name=bgp-peer-onprem-1 \
    --peer-asn=65002 \
    --interface=bgp-if-gcp-1 \
    --peer-ip-address=169.254.1.2 \
    --region=$REGION

# ===== Peers BGP côté On-premise =====
gcloud compute routers add-bgp-peer router-onprem \
    --peer-name=bgp-peer-gcp-0 \
    --peer-asn=65001 \
    --interface=bgp-if-onprem-0 \
    --peer-ip-address=169.254.0.1 \
    --region=$REGION

gcloud compute routers add-bgp-peer router-onprem \
    --peer-name=bgp-peer-gcp-1 \
    --peer-asn=65001 \
    --interface=bgp-if-onprem-1 \
    --peer-ip-address=169.254.1.1 \
    --region=$REGION
```

#### Exercice 7.1.8 : Vérifier l'état des tunnels et sessions BGP

```bash
# Attendre quelques secondes pour l'établissement
sleep 30

# État des tunnels VPN
echo "=== État des tunnels VPN ==="
gcloud compute vpn-tunnels list --filter="region:$REGION" \
    --format="table(name,status,peerIp)"

# Statut BGP côté GCP
echo "=== Statut BGP Router GCP ==="
gcloud compute routers get-status router-gcp --region=$REGION \
    --format="yaml(result.bgpPeerStatus)"

# Statut BGP côté On-premise
echo "=== Statut BGP Router On-premise ==="
gcloud compute routers get-status router-onprem --region=$REGION \
    --format="yaml(result.bgpPeerStatus)"

# Routes apprises
echo "=== Routes apprises par router-gcp ==="
gcloud compute routers get-status router-gcp --region=$REGION \
    --format="yaml(result.bestRoutes)"
```

#### Exercice 7.1.9 : Tester la connectivité

```bash
# Test depuis vm-gcp vers vm-onprem
gcloud compute ssh vm-gcp --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test connectivité APRÈS VPN ==="
echo ""
echo "=== Ping ==="
ping -c 5 192.168.0.10

echo ""
echo "=== Traceroute ==="
traceroute -n 192.168.0.10

echo ""
echo "=== MTR (si disponible) ==="
mtr -r -c 10 192.168.0.10 2>/dev/null || echo "MTR non disponible"
EOF

# Test inverse depuis vm-onprem vers vm-gcp
gcloud compute ssh vm-onprem --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test depuis On-premise vers GCP ==="
ping -c 5 10.0.0.10
traceroute -n 10.0.0.10
EOF
```

**Questions :**
1. Combien de "hops" montre le traceroute ? Pourquoi ?
2. Pourquoi avons-nous créé 4 tunnels au total ?

### Livrable
HA VPN fonctionnel avec sessions BGP établies et connectivité validée.

---

## Lab 7.2 : BGP avec Cloud Router
**Difficulté : ⭐⭐ | Type : Pratique**

### Objectifs
- Comprendre le fonctionnement de BGP dans Cloud Router
- Observer l'échange de routes
- Annoncer des routes personnalisées

### Exercices

#### Exercice 7.2.1 : Explorer la configuration BGP

```bash
# Voir la configuration complète du Cloud Router GCP
gcloud compute routers describe router-gcp --region=$REGION

# Détails des interfaces BGP
gcloud compute routers describe router-gcp --region=$REGION \
    --format="yaml(interfaces)"

# Détails des peers BGP
gcloud compute routers describe router-gcp --region=$REGION \
    --format="yaml(bgpPeers)"
```

#### Exercice 7.2.2 : Comprendre les routes échangées

```bash
cat << 'EOF'
=== Fonctionnement de l'échange de routes BGP ===

Cloud Router annonce automatiquement:
- Les sous-réseaux du VPC auquel il est attaché
- Les plages personnalisées configurées (custom advertisements)

Ce qui est annoncé par router-gcp (ASN 65001):
- 10.0.0.0/24 (subnet-gcp)

Ce qui est annoncé par router-onprem (ASN 65002):
- 192.168.0.0/24 (subnet-onprem)

Après l'échange BGP:
- router-gcp apprend 192.168.0.0/24 de router-onprem
- router-onprem apprend 10.0.0.0/24 de router-gcp
- Les routes sont installées automatiquement dans les VPC
EOF

# Voir les routes dans le VPC GCP
echo "=== Routes dans VPC GCP ==="
gcloud compute routes list --filter="network:vpc-gcp" \
    --format="table(name,destRange,nextHopVpnTunnel,priority)"

# Voir les routes dans le VPC On-premise
echo "=== Routes dans VPC On-premise ==="
gcloud compute routes list --filter="network:vpc-onprem" \
    --format="table(name,destRange,nextHopVpnTunnel,priority)"
```

#### Exercice 7.2.3 : Ajouter un sous-réseau et observer la propagation

```bash
# Ajouter un nouveau sous-réseau dans vpc-gcp
gcloud compute networks subnets create subnet-gcp-new \
    --network=vpc-gcp \
    --region=$REGION \
    --range=10.1.0.0/24

# Attendre la propagation BGP
sleep 30

# Vérifier que le nouveau sous-réseau est annoncé
echo "=== Routes apprises par router-onprem après ajout ==="
gcloud compute routers get-status router-onprem --region=$REGION \
    --format="yaml(result.bestRoutes)"

# Le sous-réseau 10.1.0.0/24 devrait maintenant apparaître
```

#### Exercice 7.2.4 : Configurer des annonces personnalisées

```bash
# Par défaut, Cloud Router annonce tous les sous-réseaux
# On peut personnaliser ce comportement

# Voir le mode d'annonce actuel
gcloud compute routers describe router-gcp --region=$REGION \
    --format="get(bgp.advertiseMode)"

# Passer en mode custom pour annoncer des routes spécifiques
gcloud compute routers update router-gcp \
    --region=$REGION \
    --advertisement-mode=CUSTOM \
    --set-advertisement-groups=ALL_SUBNETS \
    --set-advertisement-ranges=172.16.0.0/16:route-vers-autre-dc

# Vérifier la configuration
gcloud compute routers describe router-gcp --region=$REGION \
    --format="yaml(bgp)"

# Voir si la route personnalisée est annoncée
gcloud compute routers get-status router-onprem --region=$REGION \
    --format="yaml(result.bestRoutes)"
```

#### Exercice 7.2.5 : Comprendre les attributs BGP

```bash
cat << 'EOF'
=== Attributs BGP importants dans Cloud Router ===

1. ASN (Autonomous System Number)
   - Identifie votre réseau de manière unique
   - Plage privée: 64512-65534 (recommandé)
   - Cloud Router côté GCP: ASN au choix
   - Côté on-premise: ASN de votre équipement

2. MED (Multi-Exit Discriminator)
   - Influence le choix du chemin pour le trafic entrant
   - Valeur plus basse = préférence plus haute
   - Utilisé pour Actif/Passif

3. AS Path
   - Liste des ASN traversés
   - Plus court = préféré

4. Local Preference
   - Influence le choix du chemin pour le trafic sortant
   - Valeur plus haute = préférence plus haute

5. Keepalive / Hold Timer
   - Keepalive: 20 secondes (par défaut Cloud Router)
   - Hold: 60 secondes (3x keepalive)
   - Si aucun message reçu pendant le hold timer, session down
EOF
```

### Livrable
Documentation des routes BGP échangées et configuration personnalisée.

---

## Lab 7.3 : VPN Actif/Actif vs Actif/Passif
**Difficulté : ⭐⭐⭐ | Type : Pratique**

### Objectifs
- Configurer le mode Actif/Actif (ECMP)
- Configurer le mode Actif/Passif avec MED
- Comprendre les avantages de chaque mode

### Architecture comparée

```
    MODE ACTIF/ACTIF (ECMP)                    MODE ACTIF/PASSIF
    
    ┌──────────────────────┐                  ┌──────────────────────┐
    │      VPC GCP         │                  │      VPC GCP         │
    │                      │                  │                      │
    │   Trafic réparti     │                  │   Trafic principal   │
    │   50% / 50%          │                  │   100% / 0%          │
    │                      │                  │                      │
    │   ┌──────┬──────┐    │                  │   ┌──────┬──────┐    │
    │   │  T0  │  T1  │    │                  │   │  T0  │  T1  │    │
    │   │Active│Active│    │                  │   │Active│Standby│   │
    │   │MED100│MED100│    │                  │   │MED100│MED200│    │
    │   └──────┴──────┘    │                  │   └──────┴──────┘    │
    └──────────────────────┘                  └──────────────────────┘
    
    Avantages:                                Avantages:
    - Bande passante agrégée                  - Évite problèmes asymétriques
    - Utilisation optimale des ressources    - Simplifie le troubleshooting
    - Failover automatique                    - Compatible avec firewalls stateful
```

### Exercices

#### Exercice 7.3.1 : Vérifier le mode actuel (Actif/Actif par défaut)

```bash
# Par défaut, les deux tunnels ont la même priorité
echo "=== Routes via VPN (mode Actif/Actif) ==="
gcloud compute routes list --filter="network:vpc-gcp AND nextHopVpnTunnel~tunnel" \
    --format="table(name,destRange,nextHopVpnTunnel,priority)"

# Les deux tunnels apparaissent avec la même priorité (1000)
# Le trafic est réparti via ECMP (Equal Cost Multi-Path)
```

#### Exercice 7.3.2 : Observer la répartition de charge ECMP

```bash
# Se connecter à vm-gcp et envoyer du trafic
gcloud compute ssh vm-gcp --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test répartition ECMP ==="
echo "Envoi de 20 pings, observer si les deux tunnels sont utilisés..."

for i in {1..20}; do
    ping -c 1 -W 1 192.168.0.10 > /dev/null 2>&1
done

echo "Pour observer la répartition, vérifier les métriques des tunnels dans la console GCP"
echo "Monitoring > Metrics Explorer > vpn.googleapis.com/tunnel/sent_bytes_count"
EOF
```

#### Exercice 7.3.3 : Configurer le mode Actif/Passif avec MED

```bash
# Pour passer en Actif/Passif, on modifie la priorité MED annoncée
# MED plus basse = priorité plus haute

# Configurer le peer BGP du tunnel 0 avec MED basse (préféré)
gcloud compute routers update-bgp-peer router-gcp \
    --peer-name=bgp-peer-onprem-0 \
    --region=$REGION \
    --advertised-route-priority=100

# Configurer le peer BGP du tunnel 1 avec MED haute (backup)
gcloud compute routers update-bgp-peer router-gcp \
    --peer-name=bgp-peer-onprem-1 \
    --region=$REGION \
    --advertised-route-priority=200

# Faire de même côté On-premise
gcloud compute routers update-bgp-peer router-onprem \
    --peer-name=bgp-peer-gcp-0 \
    --region=$REGION \
    --advertised-route-priority=100

gcloud compute routers update-bgp-peer router-onprem \
    --peer-name=bgp-peer-gcp-1 \
    --region=$REGION \
    --advertised-route-priority=200

echo "Mode Actif/Passif configuré"
```

#### Exercice 7.3.4 : Vérifier la configuration Actif/Passif

```bash
# Attendre la convergence BGP
sleep 30

# Voir les routes avec leurs priorités
echo "=== Routes après configuration Actif/Passif ==="
gcloud compute routes list --filter="network:vpc-gcp AND destRange=192.168.0.0/24" \
    --format="table(name,destRange,nextHopVpnTunnel,priority)"

# La route via tunnel-0 devrait avoir priorité 100
# La route via tunnel-1 devrait avoir priorité 200
# Tout le trafic passe par tunnel-0 (priorité 100)
```

#### Exercice 7.3.5 : Revenir au mode Actif/Actif

```bash
# Réinitialiser les priorités MED à la même valeur
gcloud compute routers update-bgp-peer router-gcp \
    --peer-name=bgp-peer-onprem-0 \
    --region=$REGION \
    --advertised-route-priority=100

gcloud compute routers update-bgp-peer router-gcp \
    --peer-name=bgp-peer-onprem-1 \
    --region=$REGION \
    --advertised-route-priority=100

gcloud compute routers update-bgp-peer router-onprem \
    --peer-name=bgp-peer-gcp-0 \
    --region=$REGION \
    --advertised-route-priority=100

gcloud compute routers update-bgp-peer router-onprem \
    --peer-name=bgp-peer-gcp-1 \
    --region=$REGION \
    --advertised-route-priority=100

echo "Mode Actif/Actif restauré"
```

#### Exercice 7.3.6 : Tableau comparatif

```bash
cat << 'EOF'
=== Comparaison Actif/Actif vs Actif/Passif ===

| Critère | Actif/Actif (ECMP) | Actif/Passif |
|---------|-------------------|--------------|
| Bande passante | Agrégée (2x 3Gbps = ~6Gbps) | Limitée au tunnel actif (3Gbps) |
| Utilisation ressources | Optimale (deux tunnels) | Un tunnel inactif |
| Failover | Automatique | Automatique |
| Configuration | MED identique | MED différente |
| Complexité | Simple | Simple |
| Firewalls stateful | Peut causer des problèmes | Compatible |
| Asymétrie trafic | Possible | Évitée |
| Troubleshooting | Plus complexe | Plus simple |

Recommandations:
- Actif/Actif: Par défaut, pour maximiser la bande passante
- Actif/Passif: Si problèmes avec firewalls stateful on-premise
               ou si besoin de simplifier le troubleshooting
EOF
```

### Livrable
Configuration fonctionnelle des deux modes avec documentation des différences.

---

## Lab 7.4 : Failover et haute disponibilité VPN
**Difficulté : ⭐⭐ | Type : Pratique**

### Objectifs
- Simuler une panne de tunnel
- Observer le failover automatique
- Mesurer le temps de convergence

### Exercices

#### Exercice 7.4.1 : Préparer le test de failover

```bash
# Vérifier que les deux tunnels sont actifs
echo "=== État initial des tunnels ==="
gcloud compute vpn-tunnels list --filter="region:$REGION" \
    --format="table(name,status)"

# Vérifier les sessions BGP
echo "=== Sessions BGP actives ==="
gcloud compute routers get-status router-gcp --region=$REGION \
    --format="table(result.bgpPeerStatus[].name,result.bgpPeerStatus[].status)"
```

#### Exercice 7.4.2 : Lancer un ping continu

```bash
# Dans un terminal, se connecter à vm-gcp et lancer un ping continu
gcloud compute ssh vm-gcp --zone=$ZONE --tunnel-through-iap

# Une fois connecté:
ping 192.168.0.10

# Laisser ce terminal ouvert pour observer les pertes pendant le failover
```

#### Exercice 7.4.3 : Simuler une panne de tunnel

```bash
# Dans un autre terminal, désactiver un tunnel
# Note: On ne peut pas vraiment "désactiver" un tunnel, 
# mais on peut le supprimer et le recréer

# Option 1: Supprimer temporairement un tunnel
echo "=== Suppression du tunnel 0 pour simuler une panne ==="
gcloud compute vpn-tunnels delete tunnel-gcp-to-onprem-0 \
    --region=$REGION --quiet

# Observer le ping dans l'autre terminal
# Quelques paquets peuvent être perdus pendant la convergence BGP

# Vérifier le statut
gcloud compute vpn-tunnels list --filter="region:$REGION"
gcloud compute routers get-status router-gcp --region=$REGION \
    --format="yaml(result.bgpPeerStatus)"
```

#### Exercice 7.4.4 : Observer la convergence

```bash
# Le trafic devrait maintenant passer uniquement par le tunnel 1
echo "=== Routes après panne du tunnel 0 ==="
gcloud compute routes list --filter="network:vpc-gcp AND destRange=192.168.0.0/24" \
    --format="table(name,destRange,nextHopVpnTunnel,priority)"

# Seule la route via tunnel-1 devrait rester
```

#### Exercice 7.4.5 : Restaurer le tunnel

```bash
# Recréer le tunnel supprimé
SECRET_0="votre-secret-original"  # Utilisez le même secret qu'au lab 7.1

gcloud compute vpn-tunnels create tunnel-gcp-to-onprem-0 \
    --vpn-gateway=vpn-gw-gcp \
    --vpn-gateway-region=$REGION \
    --peer-gcp-gateway=vpn-gw-onprem \
    --peer-gcp-gateway-region=$REGION \
    --interface=0 \
    --ike-version=2 \
    --shared-secret="$SECRET_0" \
    --router=router-gcp \
    --router-region=$REGION

# Attendre la convergence
sleep 60

# Vérifier que les deux tunnels sont de nouveau actifs
gcloud compute vpn-tunnels list --filter="region:$REGION"
gcloud compute routers get-status router-gcp --region=$REGION \
    --format="table(result.bgpPeerStatus[].name,result.bgpPeerStatus[].status)"
```

#### Exercice 7.4.6 : Documenter les temps de convergence

```bash
cat << 'EOF'
=== Temps de convergence typiques ===

Événement                          | Temps typique
----------------------------------|---------------
Détection panne tunnel            | 10-30 secondes (BGP hold timer)
Mise à jour table de routage      | 1-5 secondes
Convergence complète              | 30-60 secondes

Facteurs influençant le temps:
- Hold timer BGP (par défaut 60s, détection après 20s sans keepalive)
- Nombre de routes à mettre à jour
- Charge du Cloud Router

Bonnes pratiques pour minimiser le temps de convergence:
- Utiliser BFD (Bidirectional Forwarding Detection) si disponible
- Configurer des timers BGP agressifs (avec précaution)
- Avoir des tunnels sur des interfaces distinctes
EOF
```

### Livrable
Rapport de test de failover avec temps de convergence mesurés.

---

## Lab 7.5 : Dedicated Interconnect - Concepts et simulation
**Difficulté : ⭐⭐ | Type : Théorique**

### Objectifs
- Comprendre l'architecture Dedicated Interconnect
- Connaître le processus de provisioning
- Explorer les configurations via les commandes (simulation)

### Exercices

#### Exercice 7.5.1 : Comprendre l'architecture

```bash
cat << 'EOF'
=== Architecture Dedicated Interconnect ===

┌─────────────────────────────────────────────────────────────────────────────┐
│                           Colocation Facility                                │
│                        (ex: Equinix Paris PA2)                              │
│                                                                             │
│   ┌─────────────────────┐           ┌─────────────────────┐                │
│   │  Votre équipement   │           │   Google Edge       │                │
│   │  (Router/Switch)    │           │   (Point of Presence)│                │
│   │                     │           │                     │                │
│   │  ┌───────────────┐  │           │  ┌───────────────┐  │                │
│   │  │ Port 10/100G  │──┼───────────┼──│ Port 10/100G  │  │                │
│   │  └───────────────┘  │  Cross-   │  └───────────────┘  │                │
│   │                     │  Connect  │                     │                │
│   └─────────────────────┘           └─────────────────────┘                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
            │                                       │
            │                                       │
            ▼                                       ▼
    ┌───────────────────┐                   ┌───────────────────┐
    │  Datacenter       │                   │     Google Cloud   │
    │  On-premise       │                   │                   │
    │                   │                   │   ┌───────────┐   │
    │  192.168.0.0/16   │◄─── BGP ────────►│   │Cloud Router│   │
    │                   │                   │   └───────────┘   │
    │                   │                   │        │         │
    └───────────────────┘                   │        ▼         │
                                            │   ┌───────────┐   │
                                            │   │    VPC    │   │
                                            │   │10.0.0.0/8 │   │
                                            │   └───────────┘   │
                                            └───────────────────┘

Caractéristiques:
- Connexion physique directe (pas Internet)
- 10 Gbps ou 100 Gbps par lien
- Latence très faible et stable
- SLA jusqu'à 99.99%
- Trafic à tarif réduit
EOF
```

#### Exercice 7.5.2 : Processus de provisioning

```bash
cat << 'EOF'
=== Processus de provisioning Dedicated Interconnect ===

Étape 1: Planification (1-2 semaines)
─────────────────────────────────────
- Identifier la colocation facility
- Vérifier la présence de Google (Point of Presence)
- Planifier la capacité (10G ou 100G, nombre de liens)
- Préparer l'équipement on-premise

Étape 2: Commande (1-2 jours)
─────────────────────────────
- Commander l'Interconnect dans la console GCP
- Recevoir la LOA-CFA (Letter of Authorization - Connecting Facility Assignment)
- Ce document autorise le cross-connect

Étape 3: Cross-connect (1-4 semaines)
─────────────────────────────────────
- Fournir la LOA-CFA à la colocation
- La colo établit le câblage physique
- Délai variable selon la colo et disponibilité

Étape 4: Activation (1-2 jours)
───────────────────────────────
- Google détecte le lien et l'active
- Configurer les VLAN attachments
- Établir les sessions BGP

Étape 5: Tests et validation
────────────────────────────
- Tester la connectivité
- Vérifier les performances
- Valider la redondance

DÉLAI TOTAL: 4-8 semaines
EOF
```

#### Exercice 7.5.3 : Explorer les commandes (simulation)

```bash
# Ces commandes sont fournies à titre informatif
# Elles nécessitent une vraie infrastructure pour fonctionner

cat << 'EOF'
=== Commandes Dedicated Interconnect (pour référence) ===

# 1. Créer l'interconnect
gcloud compute interconnects create mon-interconnect \
    --location=par-zone1-2 \
    --link-type=LINK_TYPE_ETHERNET_10G_LR \
    --requested-link-count=2 \
    --admin-enabled \
    --description="Interconnect Paris"

# 2. Récupérer la LOA-CFA
gcloud compute interconnects describe mon-interconnect \
    --format="get(provisionedLinkCount,state)"

# 3. Créer un Cloud Router pour l'Interconnect
gcloud compute routers create router-interconnect \
    --network=mon-vpc \
    --region=europe-west1 \
    --asn=65001

# 4. Créer un VLAN attachment
gcloud compute interconnects attachments dedicated create attachment-1 \
    --interconnect=mon-interconnect \
    --router=router-interconnect \
    --region=europe-west1 \
    --bandwidth=BPS_1G \
    --vlan=100

# 5. Configurer BGP
gcloud compute routers add-interface router-interconnect \
    --interface-name=if-attachment-1 \
    --interconnect-attachment=attachment-1 \
    --region=europe-west1

gcloud compute routers add-bgp-peer router-interconnect \
    --peer-name=peer-onprem \
    --peer-asn=65002 \
    --interface=if-attachment-1 \
    --peer-ip-address=169.254.100.2 \
    --region=europe-west1
EOF
```

#### Exercice 7.5.4 : Points de présence Google en Europe

```bash
cat << 'EOF'
=== Points de Présence Google - Europe ===

Ville          | Facility           | Location ID
---------------|--------------------|-----------------
Paris          | Equinix PA2       | par-zone1-16
Paris          | Equinix PA3       | par-zone1-4
Paris          | Equinix PA4       | par-zone2-430
Amsterdam      | Equinix AM1       | ams-zone1-5
Amsterdam      | Equinix AM2       | ams-zone1-6
Francfort      | Equinix FR2       | fra-zone1-6
Francfort      | Equinix FR4       | fra-zone1-56
Francfort      | Equinix FR5       | fra-zone2-57
Londres        | Equinix LD4       | lon-zone1-8
Londres        | Equinix LD5       | lon-zone1-56
Zurich         | Equinix ZH4       | zrh-zone1-1
Dublin         | Equinix DB1       | dub-zone1-8

Liste complète: https://cloud.google.com/network-connectivity/docs/interconnect/concepts/colocation-facilities
EOF
```

### Livrable
Documentation du processus de provisioning Dedicated Interconnect.

---

## Lab 7.6 : Partner Interconnect - Concepts et simulation
**Difficulté : ⭐⭐ | Type : Théorique**

### Objectifs
- Comprendre les avantages de Partner Interconnect
- Connaître le processus de configuration
- Identifier les partenaires disponibles

### Exercices

#### Exercice 7.6.1 : Quand utiliser Partner Interconnect ?

```bash
cat << 'EOF'
=== Partner Interconnect vs Dedicated Interconnect ===

Choisir Partner Interconnect si:
✅ Pas de présence dans une colo où Google est présent
✅ Besoin de moins de 10 Gbps
✅ Budget plus limité
✅ Déploiement rapide souhaité (1-2 semaines vs 4-8)
✅ Sites distants à connecter

Choisir Dedicated Interconnect si:
✅ Présence dans une colo Google
✅ Besoin de 10 Gbps ou plus
✅ Contrôle total souhaité
✅ Budget conséquent disponible

Capacités Partner Interconnect:
- 50 Mbps à 50 Gbps
- Par incréments: 50M, 100M, 200M, 300M, 400M, 500M, 1G, 2G, 5G, 10G, 20G, 50G
EOF
```

#### Exercice 7.6.2 : Architecture Partner Interconnect

```bash
cat << 'EOF'
=== Architecture Partner Interconnect ===

┌──────────────┐      ┌──────────────────────┐      ┌──────────────────┐
│  Votre       │      │     Partenaire       │      │   Google Cloud   │
│  Datacenter  │      │  (Orange, Colt...)   │      │                  │
│              │      │                      │      │                  │
│              │ MPLS │   ┌──────────────┐   │      │ ┌──────────────┐ │
│  ┌────────┐  │ ou   │   │  Edge Router │   │ Peering│ │ Cloud Router│ │
│  │ Router │──┼──────┼───│              │───┼──────┼─│              │ │
│  └────────┘  │ VPN  │   └──────────────┘   │      │ └──────────────┘ │
│              │      │                      │      │        │        │
└──────────────┘      └──────────────────────┘      │        ▼        │
                                                    │   ┌──────────┐  │
                                                    │   │   VPC    │  │
                                                    │   └──────────┘  │
                                                    └──────────────────┘

Avantages:
- Pas besoin d'être dans une colo Google
- Le partenaire gère la connexion physique
- Flexibilité des capacités
- Déploiement plus rapide
EOF
```

#### Exercice 7.6.3 : Partenaires disponibles en France

```bash
cat << 'EOF'
=== Partenaires Interconnect en France ===

Partenaire              | Type de service      | Capacités
------------------------|---------------------|------------------
Orange Business Services| Layer 2 / Layer 3   | 50M - 10G
Colt Technology Services| Layer 2             | 50M - 10G
Equinix Fabric          | Layer 2             | 50M - 10G
Megaport                | Layer 2             | 50M - 10G
Console Connect         | Layer 2             | 50M - 10G
PCCW Global             | Layer 2             | 50M - 10G
Zayo                    | Layer 2             | 50M - 10G

Layer 2 vs Layer 3:
- Layer 2: Vous gérez BGP directement avec Google
- Layer 3: Le partenaire gère BGP, vous recevez des routes

Liste complète: https://cloud.google.com/network-connectivity/docs/interconnect/concepts/service-providers
EOF
```

#### Exercice 7.6.4 : Processus de configuration

```bash
cat << 'EOF'
=== Configuration Partner Interconnect ===

# Étape 1: Créer un Cloud Router
gcloud compute routers create router-partner \
    --network=mon-vpc \
    --region=europe-west1 \
    --asn=16550

# Étape 2: Créer le VLAN attachment (type PARTNER)
gcloud compute interconnects attachments partner create partner-attachment \
    --router=router-partner \
    --region=europe-west1 \
    --edge-availability-domain=availability-domain-1

# Étape 3: Récupérer la clé d'appairage
gcloud compute interconnects attachments describe partner-attachment \
    --region=europe-west1 \
    --format="get(pairingKey)"

# Cette clé ressemble à:
# 7e51371e-72a3-40b5-b844-2e3efefaee59/europe-west1/1

# Étape 4: Fournir cette clé au partenaire
# Le partenaire configure son côté avec cette clé

# Étape 5: Une fois le partenaire prêt, activer l'attachment
gcloud compute interconnects attachments partner update partner-attachment \
    --region=europe-west1 \
    --admin-enabled

# Étape 6: Vérifier le statut
gcloud compute interconnects attachments describe partner-attachment \
    --region=europe-west1
EOF
```

### Livrable
Comparaison documentée entre Partner et Dedicated Interconnect.

---

## Lab 7.7 : Cross-Cloud Interconnect - Multi-cloud
**Difficulté : ⭐⭐ | Type : Théorique**

### Objectifs
- Comprendre Cross-Cloud Interconnect
- Connaître les clouds supportés
- Explorer les cas d'usage multi-cloud

### Exercices

#### Exercice 7.7.1 : Vue d'ensemble Cross-Cloud Interconnect

```bash
cat << 'EOF'
=== Cross-Cloud Interconnect ===

Cross-Cloud Interconnect fournit une connexion dédiée haute performance
entre GCP et d'autres fournisseurs cloud.

Clouds supportés:
┌──────────────────────────────────────────────────────────┐
│  Google Cloud ◄──────────────────────► AWS              │
│  Google Cloud ◄──────────────────────► Microsoft Azure  │
│  Google Cloud ◄──────────────────────► Oracle Cloud     │
│  Google Cloud ◄──────────────────────► Alibaba Cloud    │
└──────────────────────────────────────────────────────────┘

Caractéristiques:
- Bande passante: 10-100 Gbps
- Connexion privée (pas Internet)
- Latence faible et prévisible
- Chiffrement optionnel (MACsec)
- SLA de disponibilité

Cas d'usage:
1. Applications multi-cloud
2. Disaster Recovery cross-cloud
3. Migration entre clouds
4. Arbitrage de services (utiliser le meilleur service de chaque cloud)
5. Conformité réglementaire (données dans plusieurs régions/providers)
EOF
```

#### Exercice 7.7.2 : Architecture Cross-Cloud

```bash
cat << 'EOF'
=== Architecture Cross-Cloud Interconnect (exemple GCP ↔ AWS) ===

┌─────────────────────────────────────────────────────────────────────────────┐
│                         Colocation Facility                                  │
│                      (zone commune GCP et AWS)                              │
│                                                                             │
│   ┌─────────────────────┐           ┌─────────────────────┐                │
│   │   Google Edge       │           │   AWS Direct Connect │                │
│   │   (Cross-Cloud      │───────────│   Location          │                │
│   │    Interconnect)    │           │                     │                │
│   └─────────────────────┘           └─────────────────────┘                │
│             │                                   │                           │
└─────────────┼───────────────────────────────────┼───────────────────────────┘
              │                                   │
              ▼                                   ▼
┌─────────────────────────────┐     ┌─────────────────────────────┐
│       Google Cloud          │     │           AWS               │
│                             │     │                             │
│   ┌───────────────────┐     │     │     ┌───────────────────┐   │
│   │    Cloud Router   │     │     │     │ Direct Connect GW │   │
│   │    ASN 65001      │◄────┼─BGP─┼────►│    ASN 65002      │   │
│   └─────────┬─────────┘     │     │     └─────────┬─────────┘   │
│             │               │     │               │             │
│   ┌─────────▼─────────┐     │     │     ┌─────────▼─────────┐   │
│   │       VPC         │     │     │     │        VPC        │   │
│   │   10.0.0.0/16     │     │     │     │   172.16.0.0/16   │   │
│   └───────────────────┘     │     │     └───────────────────┘   │
└─────────────────────────────┘     └─────────────────────────────┘
EOF
```

#### Exercice 7.7.3 : Configuration conceptuelle

```bash
cat << 'EOF'
=== Configuration Cross-Cloud Interconnect (pour référence) ===

# Côté GCP:

# 1. Créer l'interconnect Cross-Cloud
gcloud compute interconnects create xcloud-to-aws \
    --interconnect-type=DEDICATED \
    --link-type=LINK_TYPE_ETHERNET_10G_LR \
    --location=iad-zone1-1 \
    --requested-link-count=1 \
    --remote-cloud-region=us-east-1 \
    --remote-cloud-provider=AWS

# 2. Créer le Cloud Router
gcloud compute routers create router-xcloud \
    --network=vpc-multicloud \
    --region=us-east4 \
    --asn=65001

# 3. Créer le VLAN attachment
gcloud compute interconnects attachments dedicated create xcloud-attachment \
    --interconnect=xcloud-to-aws \
    --router=router-xcloud \
    --region=us-east4 \
    --bandwidth=BPS_10G

# Côté AWS (console AWS):
# 1. Créer une connexion Direct Connect correspondante
# 2. Créer un Virtual Private Gateway
# 3. Associer au VPC AWS
# 4. Configurer BGP

# Configuration BGP des deux côtés pour échanger les routes
EOF
```

### Livrable
Documentation des cas d'usage multi-cloud avec Cross-Cloud Interconnect.

---

## Lab 7.8 : Network Connectivity Center - Hub and Spoke
**Difficulté : ⭐⭐⭐ | Type : Pratique**

### Objectifs
- Créer un hub Network Connectivity Center
- Configurer des spokes VPN
- Activer la connectivité transitive

### Architecture cible

```
                              Network Connectivity Center
                            ┌─────────────────────────────┐
                            │           HUB               │
                            │                             │
                            │   Connectivité transitive   │
                            │   entre tous les spokes     │
                            │                             │
                            └──────────────┬──────────────┘
                                           │
              ┌────────────────────────────┼────────────────────────────┐
              │                            │                            │
              ▼                            ▼                            ▼
    ┌─────────────────┐          ┌─────────────────┐          ┌─────────────────┐
    │   Spoke A       │          │   Spoke B       │          │   Spoke C       │
    │   (VPN)         │          │   (VPN)         │          │   (VPN)         │
    │                 │          │                 │          │                 │
    │   Site Paris    │◄────────►│   Site Lyon     │◄────────►│   Site Berlin   │
    │   10.1.0.0/24   │          │   10.2.0.0/24   │          │   10.3.0.0/24   │
    └─────────────────┘          └─────────────────┘          └─────────────────┘
    
    Sans NCC: Paris ↔ Lyon nécessite configuration explicite
    Avec NCC: Tous les sites communiquent automatiquement via le hub
```

### Exercices

#### Exercice 7.8.1 : Créer l'infrastructure multi-sites

```bash
# Créer le VPC central (Hub)
gcloud compute networks create vpc-hub-ncc \
    --subnet-mode=custom

gcloud compute networks subnets create subnet-hub \
    --network=vpc-hub-ncc \
    --region=$REGION \
    --range=10.0.0.0/24

# Créer les VPC des sites (simulés)
for SITE in paris lyon berlin; do
    case $SITE in
        paris)  RANGE="10.1.0.0/24" ;;
        lyon)   RANGE="10.2.0.0/24" ;;
        berlin) RANGE="10.3.0.0/24" ;;
    esac
    
    gcloud compute networks create vpc-site-${SITE} \
        --subnet-mode=custom
    
    gcloud compute networks subnets create subnet-${SITE} \
        --network=vpc-site-${SITE} \
        --region=$REGION \
        --range=$RANGE
    
    gcloud compute firewall-rules create vpc-site-${SITE}-allow-all \
        --network=vpc-site-${SITE} \
        --allow=tcp,udp,icmp \
        --source-ranges=10.0.0.0/8
    
    gcloud compute firewall-rules create vpc-site-${SITE}-allow-ssh \
        --network=vpc-site-${SITE} \
        --allow=tcp:22 \
        --source-ranges=35.235.240.0/20
done
```

#### Exercice 7.8.2 : Créer le Hub NCC

```bash
# Activer l'API Network Connectivity
gcloud services enable networkconnectivity.googleapis.com

# Créer le hub
gcloud network-connectivity hubs create hub-multisite \
    --description="Hub central pour connectivité multi-sites"

# Vérifier
gcloud network-connectivity hubs describe hub-multisite
```

#### Exercice 7.8.3 : Établir les VPN vers chaque site

```bash
# Cette partie est simplifiée - en production, chaque site aurait
# son propre équipement VPN

# Créer les Cloud Routers pour le hub
for SITE in paris lyon berlin; do
    ASN=$((65010 + $(echo $SITE | md5sum | tr -d -c '0-9' | head -c 2)))
    
    gcloud compute routers create router-hub-${SITE} \
        --network=vpc-hub-ncc \
        --region=$REGION \
        --asn=$ASN
    
    gcloud compute vpn-gateways create vpn-gw-hub-${SITE} \
        --network=vpc-hub-ncc \
        --region=$REGION
    
    gcloud compute routers create router-site-${SITE} \
        --network=vpc-site-${SITE} \
        --region=$REGION \
        --asn=$((65020 + $(echo $SITE | md5sum | tr -d -c '0-9' | head -c 2)))
    
    gcloud compute vpn-gateways create vpn-gw-site-${SITE} \
        --network=vpc-site-${SITE} \
        --region=$REGION
done

# Note: La création des tunnels VPN complets suivrait le même pattern
# que dans le Lab 7.1, répété pour chaque site
```

#### Exercice 7.8.4 : Créer les spokes NCC

```bash
# Une fois les VPN établis, créer les spokes

# Note: Cette commande nécessite que les tunnels VPN existent
cat << 'EOF'
# Exemple de création de spoke avec VPN
gcloud network-connectivity spokes linked-vpn-tunnels create spoke-paris \
    --hub=hub-multisite \
    --vpn-tunnels=tunnel-hub-to-paris-0,tunnel-hub-to-paris-1 \
    --region=europe-west1 \
    --site-to-site-data-transfer

gcloud network-connectivity spokes linked-vpn-tunnels create spoke-lyon \
    --hub=hub-multisite \
    --vpn-tunnels=tunnel-hub-to-lyon-0,tunnel-hub-to-lyon-1 \
    --region=europe-west1 \
    --site-to-site-data-transfer

gcloud network-connectivity spokes linked-vpn-tunnels create spoke-berlin \
    --hub=hub-multisite \
    --vpn-tunnels=tunnel-hub-to-berlin-0,tunnel-hub-to-berlin-1 \
    --region=europe-west1 \
    --site-to-site-data-transfer
EOF
```

#### Exercice 7.8.5 : Vérifier la connectivité transitive

```bash
# Lister les spokes
gcloud network-connectivity spokes list --hub=hub-multisite

# Voir la topologie
gcloud network-connectivity hubs describe hub-multisite

cat << 'EOF'
=== Connectivité transitive avec NCC ===

Avec site-to-site-data-transfer activé:
- Paris ↔ Lyon: Trafic via le hub NCC
- Lyon ↔ Berlin: Trafic via le hub NCC
- Paris ↔ Berlin: Trafic via le hub NCC

Sans NCC, il faudrait:
- Configurer un VPN direct Paris ↔ Lyon
- Configurer un VPN direct Lyon ↔ Berlin
- Configurer un VPN direct Paris ↔ Berlin
= 3 connexions supplémentaires!

Avec 10 sites:
- Sans NCC: 45 connexions (n*(n-1)/2)
- Avec NCC: 10 connexions (une par site vers le hub)
EOF
```

### Livrable
Hub NCC fonctionnel avec documentation de la connectivité transitive.

---

## Lab 7.9 : Comparaison et choix de solutions
**Difficulté : ⭐⭐ | Type : Analyse**

### Objectifs
- Comparer toutes les solutions de connectivité
- Créer un arbre de décision
- Analyser des scénarios réels

### Exercices

#### Exercice 7.9.1 : Tableau comparatif complet

```bash
cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════════════════════════════╗
║                        COMPARAISON DES SOLUTIONS DE CONNECTIVITÉ HYBRIDE                          ║
╠═══════════════════════════════════════════════════════════════════════════════════════════════════╣
║ Critère           │ Cloud VPN HA    │ Partner         │ Dedicated       │ Cross-Cloud     ║
║                   │                 │ Interconnect    │ Interconnect    │ Interconnect    ║
╠═══════════════════╪═════════════════╪═════════════════╪═════════════════╪═════════════════╣
║ Bande passante    │ 3 Gbps/tunnel   │ 50M - 50 Gbps   │ 10 - 200 Gbps   │ 10 - 100 Gbps   ║
║ max               │ (agrégeable)    │                 │                 │                 ║
╠═══════════════════╪═════════════════╪═════════════════╪═════════════════╪═════════════════╣
║ Latence           │ Variable        │ Faible          │ Très faible     │ Faible          ║
║                   │ (Internet)      │                 │                 │                 ║
╠═══════════════════╪═════════════════╪═════════════════╪═════════════════╪═════════════════╣
║ Transit           │ Internet        │ Privé           │ Privé           │ Privé           ║
╠═══════════════════╪═════════════════╪═════════════════╪═════════════════╪═════════════════╣
║ Chiffrement       │ IPsec natif     │ À ajouter       │ MACsec option   │ MACsec option   ║
╠═══════════════════╪═════════════════╪═════════════════╪═════════════════╪═════════════════╣
║ Délai setup       │ Minutes         │ 1-2 semaines    │ 4-8 semaines    │ 4-8 semaines    ║
╠═══════════════════╪═════════════════╪═════════════════╪═════════════════╪═════════════════╣
║ Coût fixe         │ ~100-300€/mois  │ ~500-1500€/mois │ ~2000-5000€/mois│ Variable        ║
╠═══════════════════╪═════════════════╪═════════════════╪═════════════════╪═════════════════╣
║ Coût trafic       │ Standard        │ Réduit          │ Réduit          │ Réduit          ║
╠═══════════════════╪═════════════════╪═════════════════╪═════════════════╪═════════════════╣
║ SLA               │ 99.99%          │ 99.9-99.99%     │ 99.99%          │ 99.99%          ║
╠═══════════════════╪═════════════════╪═════════════════╪═════════════════╪═════════════════╣
║ Prérequis         │ Aucun           │ Contrat         │ Présence colo   │ Colo commune    ║
║                   │                 │ partenaire      │ Google          │ avec autre cloud║
╚═══════════════════╧═════════════════╧═════════════════╧═════════════════╧═════════════════╝
EOF
```

#### Exercice 7.9.2 : Arbre de décision

```
                    ┌─────────────────────────────────────┐
                    │ Besoin de connectivité hybride ?    │
                    └─────────────────┬───────────────────┘
                                      │
                         ┌────────────┴────────────┐
                         │                         │
                    Multi-cloud ?             On-premise ?
                         │                         │
                         ▼                         │
            ┌────────────────────────┐            │
            │  Cross-Cloud           │            │
            │  Interconnect          │            │
            └────────────────────────┘            │
                                                  ▼
                              ┌────────────────────────────────────┐
                              │ Bande passante requise ?           │
                              └─────────────────┬──────────────────┘
                                                │
                    ┌───────────────────────────┼───────────────────────────┐
                    │                           │                           │
                < 3 Gbps                   3-50 Gbps                    > 50 Gbps
                    │                           │                           │
                    ▼                           ▼                           ▼
           ┌──────────────┐           ┌──────────────────┐        ┌──────────────────┐
           │  Cloud VPN   │           │ Présence colo    │        │   Dedicated      │
           │  HA          │           │ Google ?         │        │   Interconnect   │
           └──────────────┘           └────────┬─────────┘        └──────────────────┘
                                               │
                              ┌────────────────┴────────────────┐
                              │                                 │
                            Oui                               Non
                              │                                 │
                              ▼                                 ▼
                   ┌──────────────────┐              ┌──────────────────┐
                   │   Dedicated      │              │    Partner       │
                   │   Interconnect   │              │    Interconnect  │
                   └──────────────────┘              └──────────────────┘
```

#### Exercice 7.9.3 : Analyse de scénarios

```bash
cat << 'EOF'
=== Scénario 1: Startup tech ===
Contexte: 50 employés, infrastructure on-premise légère, budget limité
Besoins: Backup, accès aux services GCP, <500 Mbps
→ Recommandation: Cloud VPN HA
Raisons: Coût faible, déploiement rapide, suffisant pour les besoins

=== Scénario 2: Entreprise industrielle ===
Contexte: Usines connectées, données temps réel, exigences de latence
Besoins: 5 Gbps, latence <10ms, haute disponibilité
→ Recommandation: Partner Interconnect
Raisons: Bande passante suffisante, latence faible, pas de présence colo

=== Scénario 3: Banque nationale ===
Contexte: Datacenter dans colo Google, workloads critiques, conformité
Besoins: 50 Gbps, latence minimale, isolation totale
→ Recommandation: Dedicated Interconnect
Raisons: Contrôle total, performances maximales, conformité

=== Scénario 4: SaaS multi-cloud ===
Contexte: Application utilisant GCP + AWS, besoin de synchronisation
Besoins: Communication rapide GCP↔AWS, 10 Gbps
→ Recommandation: Cross-Cloud Interconnect
Raisons: Connexion directe inter-cloud, performances garanties

=== Scénario 5: Entreprise multi-sites ===
Contexte: 20 bureaux dans le monde, hub central sur GCP
Besoins: Tous les sites doivent communiquer entre eux
→ Recommandation: VPN HA + Network Connectivity Center
Raisons: Connectivité transitive, gestion centralisée
EOF
```

### Livrable
Document de recommandation personnalisé selon votre contexte.

---

## Lab 7.10 : Scénario intégrateur - Architecture hybride multi-sites
**Difficulté : ⭐⭐⭐ | Type : Pratique**

### Objectifs
- Déployer une architecture hybride complète
- Combiner VPN HA avec monitoring
- Documenter l'architecture

### Architecture cible

```
                                    ┌──────────────────────────────────────┐
                                    │            GCP Production            │
                                    │                                      │
                                    │   vpc-production (10.0.0.0/16)       │
                                    │                                      │
                                    │   ┌────────────┐  ┌────────────┐     │
                                    │   │ App Servers│  │ Databases  │     │
                                    │   │ 10.0.1.0/24│  │ 10.0.2.0/24│     │
                                    │   └────────────┘  └────────────┘     │
                                    │                                      │
                                    │         ┌──────────────┐             │
                                    │         │ Cloud Router │             │
                                    │         │  ASN 65001   │             │
                                    │         └──────┬───────┘             │
                                    │                │                     │
                                    │         ┌──────┴───────┐             │
                                    │         │  HA VPN GW   │             │
                                    │         └──────┬───────┘             │
                                    └────────────────┼─────────────────────┘
                                                     │
                              ╔══════════════════════╪══════════════════════╗
                              ║        Tunnels VPN IPsec (Internet)         ║
                              ╚══════════════════════╪══════════════════════╝
                                                     │
        ┌────────────────────────────────────────────┼────────────────────────────────────────────┐
        │                                            │                                            │
┌───────┴───────────────────┐              ┌────────┴────────────────┐              ┌─────────────┴─────────────┐
│   Datacenter Principal    │              │   Datacenter Secours    │              │   Bureau distant          │
│   (Paris)                 │              │   (Lyon)                │              │   (Berlin)                │
│                           │              │                         │              │                           │
│   192.168.1.0/24          │              │   192.168.2.0/24        │              │   192.168.3.0/24          │
│                           │              │                         │              │                           │
│   ┌─────────────┐         │              │   ┌─────────────┐       │              │   ┌─────────────┐         │
│   │ VPN Router  │         │              │   │ VPN Router  │       │              │   │ VPN Router  │         │
│   │ ASN 65002   │         │              │   │ ASN 65003   │       │              │   │ ASN 65004   │         │
│   └─────────────┘         │              │   └─────────────┘       │              │   └─────────────┘         │
└───────────────────────────┘              └─────────────────────────┘              └───────────────────────────┘
```

### Exercice : Script de déploiement complet

```bash
#!/bin/bash
# Architecture hybride multi-sites complète

set -e

export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "=========================================="
echo "  DÉPLOIEMENT ARCHITECTURE HYBRIDE"
echo "=========================================="

# ===== 1. VPC PRODUCTION GCP =====
echo ">>> Création VPC Production..."
gcloud compute networks create vpc-production \
    --subnet-mode=custom

gcloud compute networks subnets create subnet-apps \
    --network=vpc-production \
    --region=$REGION \
    --range=10.0.1.0/24

gcloud compute networks subnets create subnet-data \
    --network=vpc-production \
    --region=$REGION \
    --range=10.0.2.0/24

# ===== 2. VPCs SITES (simulés) =====
echo ">>> Création VPCs sites..."
declare -A SITES=(
    ["paris"]="192.168.1.0/24:65002"
    ["lyon"]="192.168.2.0/24:65003"
    ["berlin"]="192.168.3.0/24:65004"
)

for SITE in "${!SITES[@]}"; do
    IFS=':' read -r RANGE ASN <<< "${SITES[$SITE]}"
    
    gcloud compute networks create vpc-site-${SITE} --subnet-mode=custom
    
    gcloud compute networks subnets create subnet-${SITE} \
        --network=vpc-site-${SITE} \
        --region=$REGION \
        --range=$RANGE
done

# ===== 3. RÈGLES PARE-FEU =====
echo ">>> Configuration pare-feu..."
for VPC in vpc-production vpc-site-paris vpc-site-lyon vpc-site-berlin; do
    gcloud compute firewall-rules create ${VPC}-allow-internal \
        --network=$VPC \
        --allow=tcp,udp,icmp \
        --source-ranges=10.0.0.0/8,192.168.0.0/16
    
    gcloud compute firewall-rules create ${VPC}-allow-ssh \
        --network=$VPC \
        --allow=tcp:22 \
        --source-ranges=35.235.240.0/20
done

# ===== 4. CLOUD ROUTER PRODUCTION =====
echo ">>> Création Cloud Router Production..."
gcloud compute routers create router-prod \
    --network=vpc-production \
    --region=$REGION \
    --asn=65001

# ===== 5. HA VPN GATEWAY PRODUCTION =====
echo ">>> Création HA VPN Gateway Production..."
gcloud compute vpn-gateways create vpn-gw-prod \
    --network=vpc-production \
    --region=$REGION

# ===== 6. CONFIGURATION PAR SITE =====
echo ">>> Configuration VPN par site..."
for SITE in "${!SITES[@]}"; do
    IFS=':' read -r RANGE ASN <<< "${SITES[$SITE]}"
    
    echo "    Configuration site: $SITE (ASN: $ASN)"
    
    # Cloud Router du site
    gcloud compute routers create router-${SITE} \
        --network=vpc-site-${SITE} \
        --region=$REGION \
        --asn=$ASN
    
    # VPN Gateway du site
    gcloud compute vpn-gateways create vpn-gw-${SITE} \
        --network=vpc-site-${SITE} \
        --region=$REGION
    
    # Secrets
    SECRET=$(openssl rand -base64 24)
    
    # Tunnels Prod → Site
    gcloud compute vpn-tunnels create tunnel-prod-to-${SITE} \
        --vpn-gateway=vpn-gw-prod \
        --vpn-gateway-region=$REGION \
        --peer-gcp-gateway=vpn-gw-${SITE} \
        --peer-gcp-gateway-region=$REGION \
        --interface=0 \
        --ike-version=2 \
        --shared-secret="$SECRET" \
        --router=router-prod \
        --router-region=$REGION
    
    # Tunnels Site → Prod
    gcloud compute vpn-tunnels create tunnel-${SITE}-to-prod \
        --vpn-gateway=vpn-gw-${SITE} \
        --vpn-gateway-region=$REGION \
        --peer-gcp-gateway=vpn-gw-prod \
        --peer-gcp-gateway-region=$REGION \
        --interface=0 \
        --ike-version=2 \
        --shared-secret="$SECRET" \
        --router=router-${SITE} \
        --router-region=$REGION
done

# ===== 7. CONFIGURATION BGP =====
echo ">>> Configuration BGP..."
INDEX=0
for SITE in "${!SITES[@]}"; do
    IFS=':' read -r RANGE ASN <<< "${SITES[$SITE]}"
    
    IP_PROD="169.254.${INDEX}.1"
    IP_SITE="169.254.${INDEX}.2"
    
    # Interface BGP côté Prod
    gcloud compute routers add-interface router-prod \
        --interface-name=bgp-if-${SITE} \
        --vpn-tunnel=tunnel-prod-to-${SITE} \
        --ip-address=$IP_PROD \
        --mask-length=30 \
        --region=$REGION
    
    # Interface BGP côté Site
    gcloud compute routers add-interface router-${SITE} \
        --interface-name=bgp-if-prod \
        --vpn-tunnel=tunnel-${SITE}-to-prod \
        --ip-address=$IP_SITE \
        --mask-length=30 \
        --region=$REGION
    
    # Peer BGP côté Prod
    gcloud compute routers add-bgp-peer router-prod \
        --peer-name=peer-${SITE} \
        --peer-asn=$ASN \
        --interface=bgp-if-${SITE} \
        --peer-ip-address=$IP_SITE \
        --region=$REGION
    
    # Peer BGP côté Site
    gcloud compute routers add-bgp-peer router-${SITE} \
        --peer-name=peer-prod \
        --peer-asn=65001 \
        --interface=bgp-if-prod \
        --peer-ip-address=$IP_PROD \
        --region=$REGION
    
    ((INDEX++))
done

# ===== 8. VMs DE TEST =====
echo ">>> Déploiement VMs de test..."
gcloud compute instances create vm-prod \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-production \
    --subnet=subnet-apps \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

for SITE in paris lyon berlin; do
    gcloud compute instances create vm-${SITE} \
        --zone=$ZONE \
        --machine-type=e2-micro \
        --network=vpc-site-${SITE} \
        --subnet=subnet-${SITE} \
        --no-address \
        --image-family=debian-11 \
        --image-project=debian-cloud
done

echo "=========================================="
echo "  DÉPLOIEMENT TERMINÉ"
echo "=========================================="
echo ""
echo "Vérification des tunnels:"
gcloud compute vpn-tunnels list --filter="region:$REGION" \
    --format="table(name,status)"
echo ""
echo "Vérification BGP:"
gcloud compute routers get-status router-prod --region=$REGION \
    --format="table(result.bgpPeerStatus[].name,result.bgpPeerStatus[].status)"
```

### Livrable final
Architecture hybride multi-sites complète et documentée.

---

## Script de nettoyage complet

```bash
#!/bin/bash
# Nettoyage de toutes les ressources des labs du Module 7

echo "=== Suppression des VMs ==="
for VM in vm-gcp vm-onprem vm-prod vm-paris vm-lyon vm-berlin; do
    gcloud compute instances delete $VM --zone=europe-west1-b --quiet 2>/dev/null
done

echo "=== Suppression des spokes NCC ==="
for SPOKE in spoke-paris spoke-lyon spoke-berlin; do
    gcloud network-connectivity spokes delete $SPOKE --quiet 2>/dev/null
done

echo "=== Suppression du hub NCC ==="
gcloud network-connectivity hubs delete hub-multisite --quiet 2>/dev/null

echo "=== Suppression des tunnels VPN ==="
for TUNNEL in $(gcloud compute vpn-tunnels list --format="get(name)" 2>/dev/null); do
    gcloud compute vpn-tunnels delete $TUNNEL --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression des passerelles VPN ==="
for GW in $(gcloud compute vpn-gateways list --format="get(name)" 2>/dev/null); do
    gcloud compute vpn-gateways delete $GW --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression des Cloud Routers ==="
for ROUTER in $(gcloud compute routers list --format="get(name)" 2>/dev/null); do
    gcloud compute routers delete $ROUTER --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression des règles de pare-feu ==="
for VPC in vpc-gcp vpc-onprem vpc-hub-ncc vpc-site-paris vpc-site-lyon vpc-site-berlin vpc-production; do
    for RULE in $(gcloud compute firewall-rules list --filter="network:$VPC" --format="get(name)" 2>/dev/null); do
        gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null
    done
done

echo "=== Suppression des sous-réseaux ==="
for SUBNET in $(gcloud compute networks subnets list --filter="region:europe-west1" --format="get(name)" 2>/dev/null); do
    gcloud compute networks subnets delete $SUBNET --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression des VPCs ==="
for VPC in vpc-gcp vpc-onprem vpc-hub-ncc vpc-site-paris vpc-site-lyon vpc-site-berlin vpc-production; do
    gcloud compute networks delete $VPC --quiet 2>/dev/null
done

echo "=== Nettoyage terminé ==="
```

---

## Annexe : Commandes essentielles du Module 7

### Cloud VPN HA
```bash
# Créer Cloud Router
gcloud compute routers create NAME --network=VPC --region=REGION --asn=ASN

# Créer passerelle HA VPN
gcloud compute vpn-gateways create NAME --network=VPC --region=REGION

# Créer tunnel VPN
gcloud compute vpn-tunnels create NAME --vpn-gateway=GW --peer-gcp-gateway=PEER_GW \
    --interface=0 --ike-version=2 --shared-secret=SECRET --router=ROUTER --region=REGION

# Configurer BGP
gcloud compute routers add-interface ROUTER --interface-name=IF --vpn-tunnel=TUNNEL \
    --ip-address=IP --mask-length=30 --region=REGION

gcloud compute routers add-bgp-peer ROUTER --peer-name=PEER --peer-asn=ASN \
    --interface=IF --peer-ip-address=PEER_IP --region=REGION
```

### Monitoring VPN
```bash
# État des tunnels
gcloud compute vpn-tunnels list --filter="region:REGION"

# Statut BGP
gcloud compute routers get-status ROUTER --region=REGION

# Routes apprises
gcloud compute routes list --filter="network:VPC"
```

### Network Connectivity Center
```bash
# Créer hub
gcloud network-connectivity hubs create NAME

# Créer spoke VPN
gcloud network-connectivity spokes linked-vpn-tunnels create NAME \
    --hub=HUB --vpn-tunnels=TUNNEL1,TUNNEL2 --region=REGION --site-to-site-data-transfer
```
