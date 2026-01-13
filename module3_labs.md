# Module 3 - Routage et Adressage dans GCP
## Travaux Pratiques Détaillés

---

## Vue d'ensemble

### Objectifs pédagogiques
Ces travaux pratiques permettront aux apprenants de :
- Comprendre et manipuler les tables de routage GCP
- Créer des routes statiques et dynamiques
- Configurer Cloud NAT pour l'accès Internet sortant
- Maîtriser Cloud DNS (zones publiques, privées, forwarding)
- Mettre en œuvre Private Google Access
- Comprendre BYOIP et ses cas d'usage

### Prérequis
- Modules 1 et 2 complétés
- Projet GCP avec facturation activée
- Droits : roles/compute.networkAdmin, roles/dns.admin

### Labs proposés

| Lab | Titre | Difficulté |
|-----|-------|------------|
| 3.1 | Comprendre les routes système et la table de routage | ⭐ |
| 3.2 | Routes statiques personnalisées et priorités | ⭐⭐ |
| 3.3 | Routage via appliance avec tags réseau | ⭐⭐⭐ |
| 3.4 | Cloud Router et routes dynamiques (BGP) | ⭐⭐⭐ |
| 3.5 | Cloud NAT - Configuration et monitoring | ⭐⭐ |
| 3.6 | Private Google Access | ⭐⭐ |
| 3.7 | Cloud DNS - Zones privées | ⭐⭐ |
| 3.8 | Cloud DNS - Zones publiques et forwarding | ⭐⭐⭐ |
| 3.9 | Scénario intégrateur : Architecture hybride complète | ⭐⭐⭐ |

---

## Lab 3.1 : Comprendre les routes système et la table de routage
**Difficulté : ⭐**

### Objectifs
- Explorer la table de routage d'un VPC
- Comprendre les routes créées automatiquement
- Identifier le rôle de chaque type de route

### Exercices

#### Exercice 3.1.1 : Créer un VPC de test avec sous-réseaux

```bash
# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_NAME="routing-lab-vpc"
export REGION_EU="europe-west1"
export REGION_US="us-central1"

# Créer le VPC
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom \
    --bgp-routing-mode=global

# Créer deux sous-réseaux dans différentes régions
gcloud compute networks subnets create subnet-eu \
    --network=$VPC_NAME \
    --region=$REGION_EU \
    --range=10.1.0.0/24

gcloud compute networks subnets create subnet-us \
    --network=$VPC_NAME \
    --region=$REGION_US \
    --range=10.2.0.0/24

echo "VPC et sous-réseaux créés."
```

#### Exercice 3.1.2 : Explorer la table de routage

```bash
# Lister toutes les routes du VPC
gcloud compute routes list --filter="network=$VPC_NAME"

# Afficher les détails de chaque route
gcloud compute routes list \
    --filter="network=$VPC_NAME" \
    --format="table(name,destRange,nextHopGateway,nextHopNetwork,priority)"
```

**Questions :**
1. Combien de routes ont été créées automatiquement ?
2. Identifiez la route par défaut vers Internet. Quel est son next-hop ?
3. Identifiez les routes de sous-réseau. Quelle est leur destination ?

#### Exercice 3.1.3 : Examiner une route en détail

```bash
# Obtenir le nom exact de la route par défaut
DEFAULT_ROUTE=$(gcloud compute routes list \
    --filter="network=$VPC_NAME AND destRange=0.0.0.0/0" \
    --format="get(name)")

echo "Route par défaut : $DEFAULT_ROUTE"

# Examiner les détails complets
gcloud compute routes describe $DEFAULT_ROUTE

# Examiner une route de sous-réseau
SUBNET_ROUTE=$(gcloud compute routes list \
    --filter="network=$VPC_NAME AND destRange=10.1.0.0/24" \
    --format="get(name)")

gcloud compute routes describe $SUBNET_ROUTE
```

**Questions :**
1. Quelle est la priorité de la route par défaut ?
2. Les routes de sous-réseau ont-elles un next-hop explicite ?
3. Que signifie `nextHopNetwork` pour une route de sous-réseau ?

#### Exercice 3.1.4 : Tester la suppression de la route par défaut

```bash
# Supprimer la route par défaut
gcloud compute routes delete $DEFAULT_ROUTE --quiet

# Vérifier qu'elle a disparu
gcloud compute routes list --filter="network=$VPC_NAME"

# Recréer la route par défaut manuellement
gcloud compute routes create default-internet-route \
    --network=$VPC_NAME \
    --destination-range=0.0.0.0/0 \
    --next-hop-gateway=default-internet-gateway \
    --priority=1000

# Vérifier
gcloud compute routes list --filter="network=$VPC_NAME"
```

**Questions :**
1. Après suppression de la route par défaut, les VMs peuvent-elles accéder à Internet ?
2. La route par défaut peut-elle être recréée avec une priorité différente ?

---

## Lab 3.2 : Routes statiques personnalisées et priorités
**Difficulté : ⭐⭐**

### Objectifs
- Créer des routes statiques vers différents next-hop
- Comprendre le mécanisme de priorité
- Observer le longest prefix match en action

### Architecture cible

```
                    VPC: routing-lab-vpc
    ┌─────────────────────────────────────────────────────────┐
    │                                                         │
    │   subnet-eu (10.1.0.0/24)      subnet-us (10.2.0.0/24) │
    │   ┌─────────────────┐          ┌─────────────────┐     │
    │   │                 │          │                 │     │
    │   │  ┌───────────┐  │          │  ┌───────────┐  │     │
    │   │  │  vm-eu    │  │          │  │  vm-us    │  │     │
    │   │  │ 10.1.0.10 │  │          │  │ 10.2.0.10 │  │     │
    │   │  └───────────┘  │          │  └───────────┘  │     │
    │   │                 │          │                 │     │
    │   └─────────────────┘          └─────────────────┘     │
    │                                                         │
    │   Routes personnalisées :                               │
    │   - 10.99.0.0/24 → vm-eu (next-hop instance)           │
    │   - 10.99.0.0/16 → blackhole (priorité basse)          │
    └─────────────────────────────────────────────────────────┘
```

### Exercices

#### Exercice 3.2.1 : Déployer les VMs de test

```bash
# Règles de pare-feu
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal \
    --network=$VPC_NAME \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_NAME}-allow-ssh-iap \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

# VM en Europe
gcloud compute instances create vm-eu \
    --zone=${REGION_EU}-b \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-eu \
    --private-network-ip=10.1.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --can-ip-forward \
    --metadata=startup-script='#!/bin/bash
        echo 1 > /proc/sys/net/ipv4/ip_forward
        apt-get update && apt-get install -y tcpdump traceroute'

# VM aux US
gcloud compute instances create vm-us \
    --zone=${REGION_US}-a \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-us \
    --private-network-ip=10.2.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y tcpdump traceroute'
```

#### Exercice 3.2.2 : Créer des routes avec différentes priorités

```bash
# Route vers 10.99.0.0/24 via vm-eu (priorité haute = 100)
gcloud compute routes create route-specific \
    --network=$VPC_NAME \
    --destination-range=10.99.0.0/24 \
    --next-hop-instance=vm-eu \
    --next-hop-instance-zone=${REGION_EU}-b \
    --priority=100 \
    --description="Route spécifique vers 10.99.0.0/24"

# Route vers 10.99.0.0/16 blackhole (priorité basse = 1000)
# Note: On utilise next-hop-gateway=none pour simuler un blackhole
gcloud compute routes create route-broad \
    --network=$VPC_NAME \
    --destination-range=10.99.0.0/16 \
    --next-hop-instance=vm-us \
    --next-hop-instance-zone=${REGION_US}-a \
    --priority=1000 \
    --description="Route large vers 10.99.0.0/16"

# Vérifier les routes créées
gcloud compute routes list \
    --filter="network=$VPC_NAME AND destRange~10.99" \
    --format="table(name,destRange,nextHopInstance,priority)"
```

**Questions :**
1. Un paquet vers 10.99.0.50 utilisera quelle route ? Pourquoi ?
2. Un paquet vers 10.99.1.50 utilisera quelle route ? Pourquoi ?

#### Exercice 3.2.3 : Observer le longest prefix match

```bash
# Se connecter à vm-us
gcloud compute ssh vm-us --zone=${REGION_US}-a --tunnel-through-iap

# Depuis vm-us, tracer vers différentes destinations
# (Ces IPs n'existent pas, mais on observe quelle route serait utilisée)

# Vers 10.99.0.50 - devrait utiliser route-specific (/24)
traceroute -n 10.99.0.50

# Vers 10.99.1.50 - devrait utiliser route-broad (/16)
traceroute -n 10.99.1.50
```

#### Exercice 3.2.4 : Tester les priorités avec même destination

```bash
# Créer une deuxième route vers 10.99.0.0/24 avec priorité plus basse
gcloud compute routes create route-specific-backup \
    --network=$VPC_NAME \
    --destination-range=10.99.0.0/24 \
    --next-hop-instance=vm-us \
    --next-hop-instance-zone=${REGION_US}-a \
    --priority=500 \
    --description="Route backup vers 10.99.0.0/24"

# Lister les routes vers 10.99.0.0/24
gcloud compute routes list \
    --filter="network=$VPC_NAME AND destRange=10.99.0.0/24" \
    --format="table(name,destRange,nextHopInstance,priority)"

# La route avec priorité 100 gagne sur celle avec priorité 500
```

**Questions :**
1. Si on supprime route-specific, quelle route sera utilisée pour 10.99.0.50 ?
2. Deux routes avec même destination ET même priorité : que se passe-t-il ?

#### Exercice 3.2.5 : Nettoyer les routes de test

```bash
# Supprimer les routes personnalisées
gcloud compute routes delete route-specific route-broad route-specific-backup --quiet
```

---

## Lab 3.3 : Routage via appliance avec tags réseau
**Difficulté : ⭐⭐⭐**

### Objectifs
- Router sélectivement le trafic via une appliance
- Utiliser les tags réseau pour cibler des VMs
- Vérifier le transit du trafic avec tcpdump

### Architecture cible

```
                         VPC: routing-lab-vpc
    ┌────────────────────────────────────────────────────────────────┐
    │                                                                │
    │     VMs avec tag              Appliance           Destination  │
    │    "needs-proxy"              (proxy)                          │
    │   ┌───────────┐           ┌───────────┐        ┌───────────┐  │
    │   │  client1  │──────────▶│  proxy-vm │───────▶│  server   │  │
    │   │ 10.1.0.20 │   route   │ 10.1.0.100│        │ 10.2.0.50 │  │
    │   └───────────┘  custom   └───────────┘        └───────────┘  │
    │                                                                │
    │   ┌───────────┐                                                │
    │   │  client2  │────────────────────────────────▶ (direct)     │
    │   │ 10.1.0.21 │  pas de tag = route directe                   │
    │   └───────────┘                                                │
    └────────────────────────────────────────────────────────────────┘
```

### Exercices

#### Exercice 3.3.1 : Déployer l'infrastructure

```bash
# VM Proxy/Appliance avec IP forwarding
gcloud compute instances create proxy-vm \
    --zone=${REGION_EU}-b \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-eu \
    --private-network-ip=10.1.0.100 \
    --no-address \
    --can-ip-forward \
    --tags=proxy \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        echo 1 > /proc/sys/net/ipv4/ip_forward
        echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
        apt-get update && apt-get install -y tcpdump iptables
        # Activer le forwarding avec iptables
        iptables -A FORWARD -i ens4 -j ACCEPT
        iptables -A FORWARD -o ens4 -j ACCEPT'

# Client 1 - avec tag "needs-proxy"
gcloud compute instances create client1 \
    --zone=${REGION_EU}-b \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-eu \
    --private-network-ip=10.1.0.20 \
    --no-address \
    --tags=needs-proxy \
    --image-family=debian-11 \
    --image-project=debian-cloud

# Client 2 - sans tag
gcloud compute instances create client2 \
    --zone=${REGION_EU}-b \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-eu \
    --private-network-ip=10.1.0.21 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

# Serveur de destination
gcloud compute instances create server \
    --zone=${REGION_US}-a \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-us \
    --private-network-ip=10.2.0.50 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx tcpdump
        echo "Server OK - $(hostname)" > /var/www/html/index.html'
```

#### Exercice 3.3.2 : Créer la route avec tag

```bash
# Route vers subnet-us via proxy, uniquement pour les VMs avec tag "needs-proxy"
gcloud compute routes create route-via-proxy \
    --network=$VPC_NAME \
    --destination-range=10.2.0.0/24 \
    --next-hop-instance=proxy-vm \
    --next-hop-instance-zone=${REGION_EU}-b \
    --priority=100 \
    --tags=needs-proxy \
    --description="Route vers US via proxy pour VMs taguées"

# Vérifier la route
gcloud compute routes describe route-via-proxy
```

**Questions :**
1. Cette route s'applique-t-elle à client2 ? Pourquoi ?
2. Sans le tag, quel chemin prend le trafic de client2 vers server ?

#### Exercice 3.3.3 : Vérifier le routage différencié

**Terminal 1 - Capturer sur le proxy :**
```bash
gcloud compute ssh proxy-vm --zone=${REGION_EU}-b --tunnel-through-iap

# Capturer le trafic ICMP
sudo tcpdump -i ens4 icmp -n
```

**Terminal 2 - Tester depuis client1 (avec tag) :**
```bash
gcloud compute ssh client1 --zone=${REGION_EU}-b --tunnel-through-iap

# Ping vers le serveur
ping -c 5 10.2.0.50

# Traceroute
traceroute -n 10.2.0.50
```

**Terminal 3 - Tester depuis client2 (sans tag) :**
```bash
gcloud compute ssh client2 --zone=${REGION_EU}-b --tunnel-through-iap

# Ping vers le serveur
ping -c 5 10.2.0.50

# Traceroute
traceroute -n 10.2.0.50
```

**Questions :**
1. Le tcpdump sur proxy-vm voit-il le trafic de client1 ?
2. Le tcpdump sur proxy-vm voit-il le trafic de client2 ?
3. Comparez les traceroutes des deux clients.

#### Exercice 3.3.4 : Ajouter/Retirer des tags dynamiquement

```bash
# Ajouter le tag à client2
gcloud compute instances add-tags client2 \
    --zone=${REGION_EU}-b \
    --tags=needs-proxy

# Retester depuis client2 - maintenant le trafic passe par le proxy
# (Répéter le test de l'exercice précédent)

# Retirer le tag
gcloud compute instances remove-tags client2 \
    --zone=${REGION_EU}-b \
    --tags=needs-proxy
```

**Questions :**
1. Le changement de tag est-il instantané ?
2. Les connexions existantes sont-elles affectées ?

---

## Lab 3.4 : Cloud Router et routes dynamiques (BGP)
**Difficulté : ⭐⭐⭐**

### Objectifs
- Créer et configurer un Cloud Router
- Comprendre les ASN et le BGP
- Observer les routes dynamiques

### Contexte
Cloud Router est utilisé avec Cloud VPN et Cloud Interconnect pour échanger des routes dynamiquement via BGP. Dans ce lab, nous créons un Cloud Router et explorons sa configuration.

### Exercices

#### Exercice 3.4.1 : Créer un Cloud Router

```bash
# Créer un Cloud Router avec un ASN privé
gcloud compute routers create my-cloud-router \
    --network=$VPC_NAME \
    --region=$REGION_EU \
    --asn=65001 \
    --description="Cloud Router pour lab BGP"

# Vérifier la création
gcloud compute routers describe my-cloud-router \
    --region=$REGION_EU
```

**Questions :**
1. Qu'est-ce qu'un ASN (Autonomous System Number) ?
2. Pourquoi utilise-t-on un ASN dans la plage 64512-65534 ?

#### Exercice 3.4.2 : Explorer la configuration BGP

```bash
# Voir le statut BGP du router
gcloud compute routers get-status my-cloud-router \
    --region=$REGION_EU

# Voir les routes annoncées (vide sans VPN/Interconnect)
gcloud compute routers get-status my-cloud-router \
    --region=$REGION_EU \
    --format="yaml(result.bgpPeerStatus)"
```

#### Exercice 3.4.3 : Configurer des annonces personnalisées

```bash
# Configurer le router pour annoncer des plages personnalisées
gcloud compute routers update my-cloud-router \
    --region=$REGION_EU \
    --advertisement-mode=CUSTOM \
    --set-advertisement-groups=ALL_SUBNETS \
    --set-advertisement-ranges=10.100.0.0/16,10.200.0.0/16

# Vérifier la configuration
gcloud compute routers describe my-cloud-router \
    --region=$REGION_EU \
    --format="yaml(bgp)"
```

**Questions :**
1. Quelle est la différence entre `DEFAULT` et `CUSTOM` pour advertisement-mode ?
2. Pourquoi voudrait-on annoncer des plages supplémentaires ?

#### Exercice 3.4.4 : Comprendre le mode de routage (rappel)

```bash
# Vérifier le mode de routage du VPC
gcloud compute networks describe $VPC_NAME \
    --format="get(routingConfig.routingMode)"

# Le mode GLOBAL propage les routes BGP à toutes les régions
# Le mode REGIONAL limite les routes à la région du Cloud Router
```

#### Exercice 3.4.5 : Simuler l'apprentissage de routes (conceptuel)

Dans un scénario réel avec Cloud VPN :
1. Le Cloud Router établit une session BGP avec votre routeur on-premise
2. Votre routeur annonce ses routes (ex: 192.168.0.0/16)
3. Cloud Router injecte ces routes dans la table de routage du VPC
4. Les VMs peuvent atteindre 192.168.0.0/16 via le tunnel VPN

```bash
# Visualiser les routes apprises (vide sans VPN actif)
gcloud compute routes list \
    --filter="network=$VPC_NAME" \
    --format="table(name,destRange,nextHopVpnTunnel,priority)"
```

---

## Lab 3.5 : Cloud NAT - Configuration et monitoring
**Difficulté : ⭐⭐**

### Objectifs
- Configurer Cloud NAT pour l'accès Internet sortant
- Tester la connectivité avant/après NAT
- Monitorer et ajuster Cloud NAT

### Architecture cible

```
                                           Internet
                                               │
                                               │
                      ┌────────────────────────┴─────────────────────────┐
                      │                    Cloud NAT                      │
                      │                  (IP: auto)                       │
                      └────────────────────────┬─────────────────────────┘
                                               │
    ┌──────────────────────────────────────────┴──────────────────────────┐
    │                           VPC                                       │
    │   ┌─────────────────────────────────────────────────────────────┐  │
    │   │                    subnet-eu (10.1.0.0/24)                   │  │
    │   │                                                              │  │
    │   │   ┌───────────┐    ┌───────────┐    ┌───────────┐          │  │
    │   │   │   vm-nat1 │    │   vm-nat2 │    │   vm-nat3 │          │  │
    │   │   │ (no ext IP)│   │ (no ext IP)│   │ (no ext IP)│          │  │
    │   │   └───────────┘    └───────────┘    └───────────┘          │  │
    │   └─────────────────────────────────────────────────────────────┘  │
    └─────────────────────────────────────────────────────────────────────┘
```

### Exercices

#### Exercice 3.5.1 : Créer une VM sans IP externe

```bash
# Créer une VM sans IP externe pour tester Cloud NAT
gcloud compute instances create vm-nat-test \
    --zone=${REGION_EU}-b \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-eu \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y curl dnsutils'

# Vérifier qu'elle n'a pas d'IP externe
gcloud compute instances describe vm-nat-test \
    --zone=${REGION_EU}-b \
    --format="get(networkInterfaces[0].accessConfigs)"
# Devrait être vide
```

#### Exercice 3.5.2 : Tester la connectivité AVANT Cloud NAT

```bash
# Se connecter via IAP
gcloud compute ssh vm-nat-test --zone=${REGION_EU}-b --tunnel-through-iap

# Tester l'accès Internet (devrait échouer)
curl -s --connect-timeout 5 https://api.ipify.org && echo " - Mon IP publique"
# Timeout attendu

# Tester la résolution DNS (peut fonctionner via le metadata server)
dig google.com +short

# Tester l'accès aux APIs Google (échoue sans PGA)
curl -s --connect-timeout 5 https://storage.googleapis.com
# Timeout attendu

exit
```

#### Exercice 3.5.3 : Configurer Cloud NAT

```bash
# Créer un Cloud Router (requis pour Cloud NAT)
gcloud compute routers create nat-router \
    --network=$VPC_NAME \
    --region=$REGION_EU

# Configurer Cloud NAT
gcloud compute routers nats create my-cloud-nat \
    --router=nat-router \
    --region=$REGION_EU \
    --auto-allocate-nat-external-ips \
    --nat-all-subnet-ip-ranges \
    --enable-logging \
    --log-filter=ALL

# Vérifier la configuration
gcloud compute routers nats describe my-cloud-nat \
    --router=nat-router \
    --region=$REGION_EU
```

#### Exercice 3.5.4 : Tester la connectivité APRÈS Cloud NAT

```bash
# Se reconnecter à la VM
gcloud compute ssh vm-nat-test --zone=${REGION_EU}-b --tunnel-through-iap

# Tester l'accès Internet (devrait fonctionner maintenant)
curl -s https://api.ipify.org && echo " - Mon IP publique (NAT)"

# L'IP affichée est l'IP NAT, pas une IP de la VM

# Tester d'autres destinations
curl -s --head https://www.google.com | head -5
curl -s --head https://github.com | head -5

# Télécharger un package (preuve d'accès Internet)
sudo apt-get update
sudo apt-get install -y htop

exit
```

**Questions :**
1. L'IP publique vue par les serveurs externes est-elle l'IP de la VM ?
2. Plusieurs VMs partagent-elles la même IP NAT ?

#### Exercice 3.5.5 : Examiner les IPs NAT allouées

```bash
# Voir les IPs NAT automatiquement allouées
gcloud compute routers nats describe my-cloud-nat \
    --router=nat-router \
    --region=$REGION_EU \
    --format="yaml(natIps)"

# Ou via le statut du router
gcloud compute routers get-nat-mapping-info nat-router \
    --region=$REGION_EU
```

#### Exercice 3.5.6 : Ajuster la configuration des ports

```bash
# Augmenter le nombre de ports par VM
gcloud compute routers nats update my-cloud-nat \
    --router=nat-router \
    --region=$REGION_EU \
    --min-ports-per-vm=256 \
    --max-ports-per-vm=4096 \
    --enable-dynamic-port-allocation

# Vérifier les changements
gcloud compute routers nats describe my-cloud-nat \
    --router=nat-router \
    --region=$REGION_EU \
    --format="yaml(minPortsPerVm,maxPortsPerVm,enableDynamicPortAllocation)"
```

#### Exercice 3.5.7 : Consulter les logs NAT

```bash
# Voir les logs NAT dans Cloud Logging
gcloud logging read 'resource.type="nat_gateway"' \
    --limit=20 \
    --format="table(timestamp,jsonPayload.connection.src_ip,jsonPayload.connection.dest_ip,jsonPayload.allocation_status)"

# Filtrer les erreurs uniquement
gcloud logging read 'resource.type="nat_gateway" AND jsonPayload.allocation_status!="OK"' \
    --limit=10
```

#### Exercice 3.5.8 : Créer une alerte sur l'utilisation des ports

```bash
# Créer une politique d'alerte (via gcloud ou Console)
# Cette commande crée un filtre de métriques
cat << 'EOF' > nat-alert-policy.json
{
  "displayName": "Cloud NAT Port Usage High",
  "conditions": [
    {
      "displayName": "NAT port usage > 80%",
      "conditionThreshold": {
        "filter": "resource.type=\"nat_gateway\" AND metric.type=\"router.googleapis.com/nat/port_usage\"",
        "comparison": "COMPARISON_GT",
        "thresholdValue": 0.8,
        "duration": "300s"
      }
    }
  ],
  "combiner": "OR"
}
EOF

echo "Politique d'alerte définie. À créer via la Console Cloud Monitoring."
```

---

## Lab 3.6 : Private Google Access
**Difficulté : ⭐⭐**

### Objectifs
- Comprendre la différence entre Cloud NAT et Private Google Access
- Activer PGA sur un sous-réseau
- Tester l'accès aux APIs Google sans IP externe

### Exercices

#### Exercice 3.6.1 : Créer un sous-réseau sans accès Internet

```bash
# Créer un sous-réseau isolé
gcloud compute networks subnets create subnet-isolated \
    --network=$VPC_NAME \
    --region=$REGION_EU \
    --range=10.3.0.0/24

# Créer une VM dans ce sous-réseau (sans NAT)
gcloud compute instances create vm-isolated \
    --zone=${REGION_EU}-b \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-isolated \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --scopes=storage-ro
```

#### Exercice 3.6.2 : Tester AVANT Private Google Access

```bash
# Se connecter
gcloud compute ssh vm-isolated --zone=${REGION_EU}-b --tunnel-through-iap

# Tester l'accès à Cloud Storage (devrait échouer)
gsutil ls gs://gcp-public-data-landsat
# Erreur de connexion attendue

# Tester l'accès à Internet (devrait échouer)
curl -s --connect-timeout 5 https://www.google.com
# Timeout attendu

exit
```

#### Exercice 3.6.3 : Activer Private Google Access

```bash
# Activer PGA sur le sous-réseau
gcloud compute networks subnets update subnet-isolated \
    --region=$REGION_EU \
    --enable-private-google-access

# Vérifier l'activation
gcloud compute networks subnets describe subnet-isolated \
    --region=$REGION_EU \
    --format="get(privateIpGoogleAccess)"
# Devrait afficher: True
```

#### Exercice 3.6.4 : Tester APRÈS Private Google Access

```bash
# Se reconnecter
gcloud compute ssh vm-isolated --zone=${REGION_EU}-b --tunnel-through-iap

# Tester l'accès à Cloud Storage (devrait fonctionner maintenant)
gsutil ls gs://gcp-public-data-landsat | head -5
# Liste des fichiers du bucket public

# Tester l'accès à Internet (toujours impossible - PGA ≠ NAT)
curl -s --connect-timeout 5 https://www.github.com
# Timeout attendu - PGA ne donne pas accès à Internet

# Tester l'accès à une API Google
curl -s -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/project/project-id"

exit
```

**Questions :**
1. Private Google Access permet-il d'accéder à github.com ?
2. Peut-on combiner Cloud NAT et Private Google Access ?
3. PGA utilise-t-il la route par défaut (0.0.0.0/0) ?

#### Exercice 3.6.5 : Comparer Cloud NAT vs PGA

| Critère | Cloud NAT | Private Google Access |
|---------|-----------|----------------------|
| Accès Internet général | ✅ Oui | ❌ Non |
| Accès APIs Google | ✅ Oui | ✅ Oui |
| Accès services tiers | ✅ Oui | ❌ Non |
| Trafic via Internet public | ✅ Oui | ❌ Non (réseau Google) |
| Coût | Facturation NAT | Gratuit |
| Configuration | Cloud Router + NAT | Par sous-réseau |

---

## Lab 3.7 : Cloud DNS - Zones privées
**Difficulté : ⭐⭐**

### Objectifs
- Créer une zone DNS privée
- Ajouter des enregistrements DNS
- Tester la résolution depuis les VMs

### Exercices

#### Exercice 3.7.1 : Créer une zone DNS privée

```bash
# Créer une zone privée
gcloud dns managed-zones create internal-zone \
    --description="Zone DNS interne" \
    --dns-name="internal.lab." \
    --visibility=private \
    --networks=$VPC_NAME

# Vérifier la création
gcloud dns managed-zones describe internal-zone
```

#### Exercice 3.7.2 : Ajouter des enregistrements DNS

```bash
# Démarrer une transaction
gcloud dns record-sets transaction start --zone=internal-zone

# Ajouter un enregistrement A
gcloud dns record-sets transaction add 10.1.0.10 \
    --name="vm-eu.internal.lab." \
    --ttl=300 \
    --type=A \
    --zone=internal-zone

# Ajouter un autre enregistrement A
gcloud dns record-sets transaction add 10.2.0.10 \
    --name="vm-us.internal.lab." \
    --ttl=300 \
    --type=A \
    --zone=internal-zone

# Ajouter un enregistrement CNAME
gcloud dns record-sets transaction add "vm-eu.internal.lab." \
    --name="database.internal.lab." \
    --ttl=300 \
    --type=CNAME \
    --zone=internal-zone

# Exécuter la transaction
gcloud dns record-sets transaction execute --zone=internal-zone

# Lister les enregistrements
gcloud dns record-sets list --zone=internal-zone
```

#### Exercice 3.7.3 : Tester la résolution DNS

```bash
# Se connecter à une VM du VPC
gcloud compute ssh vm-eu --zone=${REGION_EU}-b --tunnel-through-iap

# Tester la résolution des noms créés
dig vm-eu.internal.lab +short
dig vm-us.internal.lab +short
dig database.internal.lab +short

# Tester avec nslookup
nslookup vm-eu.internal.lab

# Ping en utilisant le nom DNS
ping -c 3 vm-us.internal.lab

exit
```

**Questions :**
1. La zone privée est-elle accessible depuis Internet ?
2. Quel serveur DNS résout ces requêtes ?

#### Exercice 3.7.4 : Ajouter des enregistrements supplémentaires

```bash
# Ajouter un enregistrement MX
gcloud dns record-sets transaction start --zone=internal-zone

gcloud dns record-sets transaction add "mail.internal.lab." \
    --name="internal.lab." \
    --ttl=300 \
    --type=MX \
    --zone=internal-zone \

gcloud dns record-sets transaction execute --zone=internal-zone

# Ajouter un enregistrement TXT
gcloud dns record-sets create "internal.lab." \
    --type=TXT \
    --ttl=300 \
    --rrdatas='"v=spf1 include:_spf.google.com ~all"' \
    --zone=internal-zone

# Vérifier
gcloud dns record-sets list --zone=internal-zone \
    --format="table(name,type,ttl,rrdatas)"
```

#### Exercice 3.7.5 : Modifier et supprimer des enregistrements

```bash
# Modifier un enregistrement (supprimer puis recréer)
gcloud dns record-sets delete "vm-eu.internal.lab." \
    --type=A \
    --zone=internal-zone

gcloud dns record-sets create "vm-eu.internal.lab." \
    --type=A \
    --ttl=600 \
    --rrdatas="10.1.0.11" \
    --zone=internal-zone

# Vérifier le changement
gcloud dns record-sets list --zone=internal-zone --filter="name=vm-eu.internal.lab."
```

---

## Lab 3.8 : Cloud DNS - Zones publiques et forwarding
**Difficulté : ⭐⭐⭐**

### Objectifs
- Créer une zone DNS publique (simulation)
- Configurer le DNS forwarding
- Comprendre les politiques DNS

### Exercices

#### Exercice 3.8.1 : Explorer les zones publiques (conceptuel)

```bash
# Note: Ce lab nécessite un domaine réel pour être pleinement fonctionnel
# Nous simulons la configuration

# Structure d'une commande pour créer une zone publique
echo "
# Créer une zone publique (nécessite un domaine que vous possédez)
gcloud dns managed-zones create my-public-zone \\
    --description=\"Zone publique pour example.com\" \\
    --dns-name=\"example.com.\" \\
    --visibility=public

# Après création, GCP vous donne des serveurs NS à configurer chez votre registrar:
# ns-cloud-a1.googledomains.com.
# ns-cloud-b1.googledomains.com.
# ns-cloud-c1.googledomains.com.
# ns-cloud-d1.googledomains.com.
"
```

#### Exercice 3.8.2 : Créer une zone de forwarding

```bash
# Zone de forwarding vers un DNS externe (ex: on-premise)
# Note: Les IPs cibles doivent être accessibles (via VPN/Interconnect en production)

gcloud dns managed-zones create forward-zone \
    --description="Forward to external DNS" \
    --dns-name="corp.example." \
    --visibility=private \
    --networks=$VPC_NAME \
    --forwarding-targets="8.8.8.8,8.8.4.4"

# Vérifier la configuration
gcloud dns managed-zones describe forward-zone
```

**Note :** En production, remplacez 8.8.8.8 par l'IP de votre serveur DNS on-premise (accessible via VPN).

#### Exercice 3.8.3 : Créer une zone de peering DNS

```bash
# Note: Nécessite un second VPC avec une zone privée
# Exemple conceptuel:

echo "
# La zone de peering permet de résoudre des noms d'un autre VPC
gcloud dns managed-zones create peer-zone \\
    --description=\"Peering with other VPC\" \\
    --dns-name=\"other.internal.\" \\
    --visibility=private \\
    --networks=$VPC_NAME \\
    --target-network=projects/other-project/global/networks/other-vpc \\
    --target-project=other-project
"
```

#### Exercice 3.8.4 : Configurer une politique DNS de serveur entrant

```bash
# Permettre aux clients on-premise de résoudre les noms GCP
gcloud dns policies create inbound-dns-policy \
    --description="Allow inbound DNS queries" \
    --networks=$VPC_NAME \
    --enable-inbound-forwarding

# Cette configuration crée des IPs dans chaque sous-réseau pour recevoir les requêtes DNS

# Voir les adresses créées
gcloud compute addresses list --filter="purpose=DNS_RESOLVER"
```

#### Exercice 3.8.5 : Créer une politique DNS pour le routage sortant

```bash
# Créer une politique de serveur alternatif
gcloud dns policies create outbound-dns-policy \
    --description="Use custom DNS servers" \
    --networks=$VPC_NAME \
    --alternative-name-servers="8.8.8.8,1.1.1.1"

# Note: Cette politique remplace le DNS GCP par défaut pour toutes les requêtes
```

**Questions :**
1. Quand utiliserait-on une zone de forwarding ?
2. Quelle est la différence entre une zone de forwarding et une politique DNS ?

---

## Lab 3.9 : Scénario intégrateur - Architecture hybride complète
**Difficulté : ⭐⭐⭐**

### Objectifs
- Combiner toutes les connaissances du module
- Créer une architecture réaliste
- Documenter la solution

### Scénario
Vous devez créer une infrastructure pour une entreprise avec :
- Des VMs backend sans IP externe (sécurité)
- Accès Internet sortant via Cloud NAT
- Accès aux APIs Google via PGA
- DNS interne personnalisé
- Route personnalisée vers une appliance de filtrage

### Architecture cible

```
                                         Internet
                                             │
                    ┌────────────────────────┴─────────────────────────┐
                    │                   Cloud NAT                       │
                    └────────────────────────┬─────────────────────────┘
                                             │
┌────────────────────────────────────────────┴──────────────────────────────────────┐
│                                    VPC                                            │
│                                                                                   │
│   ┌─────────────────────────┐                   ┌─────────────────────────┐      │
│   │  subnet-frontend        │                   │  subnet-backend         │      │
│   │  10.10.0.0/24           │                   │  10.20.0.0/24           │      │
│   │  PGA: activé            │                   │  PGA: activé            │      │
│   │                         │                   │                         │      │
│   │  ┌─────────┐            │                   │  ┌─────────┐            │      │
│   │  │ web-vm  │────────────┼──────────────────▶│  │ api-vm  │            │      │
│   │  └─────────┘            │    (direct)       │  └─────────┘            │      │
│   │                         │                   │        │                │      │
│   │  ┌─────────┐            │                   │        ▼                │      │
│   │  │ proxy   │◀───────────┼───────────────────│  ┌─────────┐            │      │
│   │  └─────────┘            │   (route tags)    │  │ db-vm   │            │      │
│   │                         │                   │  └─────────┘            │      │
│   └─────────────────────────┘                   └─────────────────────────┘      │
│                                                                                   │
│   Cloud DNS Zone: app.internal                                                   │
│   - web.app.internal → 10.10.0.10                                               │
│   - api.app.internal → 10.20.0.10                                               │
│   - db.app.internal  → 10.20.0.20                                               │
└───────────────────────────────────────────────────────────────────────────────────┘
```

### Exercice : Script de déploiement complet

```bash
#!/bin/bash
# Script de déploiement de l'architecture hybride

set -e

export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"
export VPC_NAME="hybrid-vpc"

echo "=== 1. Création du VPC ==="
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

echo "=== 2. Création des sous-réseaux ==="
# Frontend
gcloud compute networks subnets create subnet-frontend \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.10.0.0/24 \
    --enable-private-google-access

# Backend
gcloud compute networks subnets create subnet-backend \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.20.0.0/24 \
    --enable-private-google-access

echo "=== 3. Configuration Cloud NAT ==="
gcloud compute routers create hybrid-router \
    --network=$VPC_NAME \
    --region=$REGION

gcloud compute routers nats create hybrid-nat \
    --router=hybrid-router \
    --region=$REGION \
    --auto-allocate-nat-external-ips \
    --nat-all-subnet-ip-ranges \
    --enable-logging

echo "=== 4. Règles de pare-feu ==="
# SSH via IAP
gcloud compute firewall-rules create ${VPC_NAME}-allow-iap \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

# Trafic interne
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal \
    --network=$VPC_NAME \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

# Health checks Google
gcloud compute firewall-rules create ${VPC_NAME}-allow-health-check \
    --network=$VPC_NAME \
    --allow=tcp:80,tcp:443 \
    --source-ranges=35.191.0.0/16,130.211.0.0/22

echo "=== 5. Déploiement des VMs ==="
# Web VM
gcloud compute instances create web-vm \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-frontend \
    --private-network-ip=10.10.0.10 \
    --no-address \
    --tags=web,frontend \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx curl dnsutils
        echo "Web Server: $(hostname)" > /var/www/html/index.html'

# Proxy VM
gcloud compute instances create proxy-vm \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-frontend \
    --private-network-ip=10.10.0.100 \
    --no-address \
    --can-ip-forward \
    --tags=proxy \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        echo 1 > /proc/sys/net/ipv4/ip_forward
        apt-get update && apt-get install -y squid tcpdump'

# API VM
gcloud compute instances create api-vm \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-backend \
    --private-network-ip=10.20.0.10 \
    --no-address \
    --tags=api,backend \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y python3 curl
        echo "from http.server import HTTPServer, BaseHTTPRequestHandler
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b\"API OK\")
HTTPServer((\"0.0.0.0\", 8080), Handler).serve_forever()" > /tmp/api.py
        python3 /tmp/api.py &'

# DB VM
gcloud compute instances create db-vm \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-backend \
    --private-network-ip=10.20.0.20 \
    --no-address \
    --tags=database,needs-proxy \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo "=== 6. Configuration DNS privé ==="
gcloud dns managed-zones create app-internal \
    --description="Zone interne pour l'application" \
    --dns-name="app.internal." \
    --visibility=private \
    --networks=$VPC_NAME

gcloud dns record-sets transaction start --zone=app-internal
gcloud dns record-sets transaction add 10.10.0.10 \
    --name="web.app.internal." --ttl=300 --type=A --zone=app-internal
gcloud dns record-sets transaction add 10.20.0.10 \
    --name="api.app.internal." --ttl=300 --type=A --zone=app-internal
gcloud dns record-sets transaction add 10.20.0.20 \
    --name="db.app.internal." --ttl=300 --type=A --zone=app-internal
gcloud dns record-sets transaction execute --zone=app-internal

echo "=== 7. Route personnalisée pour db-vm via proxy ==="
gcloud compute routes create db-outbound-via-proxy \
    --network=$VPC_NAME \
    --destination-range=0.0.0.0/0 \
    --next-hop-instance=proxy-vm \
    --next-hop-instance-zone=$ZONE \
    --priority=100 \
    --tags=needs-proxy

echo "=== Déploiement terminé ==="
echo ""
echo "Tests à effectuer :"
echo "1. Se connecter à web-vm et tester: curl api.app.internal:8080"
echo "2. Se connecter à db-vm et vérifier que le trafic passe par proxy-vm"
echo "3. Vérifier l'accès Internet via Cloud NAT depuis toutes les VMs"
echo "4. Tester la résolution DNS interne"
```

### Tests de validation

```bash
# Test 1 : Résolution DNS
gcloud compute ssh web-vm --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test DNS ==="
dig web.app.internal +short
dig api.app.internal +short
dig db.app.internal +short
EOF

# Test 2 : Connectivité interne
gcloud compute ssh web-vm --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test connectivité API ==="
curl -s http://api.app.internal:8080
echo ""
echo "=== Ping DB ==="
ping -c 3 db.app.internal
EOF

# Test 3 : Cloud NAT fonctionne
gcloud compute ssh api-vm --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test accès Internet via NAT ==="
curl -s https://api.ipify.org && echo " (IP NAT)"
EOF

# Test 4 : Route via proxy pour db-vm
# Terminal 1 : Capturer sur proxy
gcloud compute ssh proxy-vm --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "Démarrage capture (Ctrl+C pour arrêter)..."
sudo tcpdump -i ens4 host 10.20.0.20 -n
EOF

# Terminal 2 : Générer du trafic depuis db-vm
gcloud compute ssh db-vm --zone=$ZONE --tunnel-through-iap << 'EOF'
curl -s https://www.google.com > /dev/null && echo "OK via proxy"
EOF
```

---

## Script de nettoyage complet

```bash
#!/bin/bash
# Nettoyage de toutes les ressources des labs du Module 3

echo "=== Suppression des VMs ==="
for VM in vm-eu vm-us vm-nat-test vm-isolated proxy-vm client1 client2 server \
          web-vm api-vm db-vm; do
    gcloud compute instances delete $VM --zone=europe-west1-b --quiet 2>/dev/null
done

gcloud compute instances delete vm-us --zone=us-central1-a --quiet 2>/dev/null
gcloud compute instances delete server --zone=us-central1-a --quiet 2>/dev/null

echo "=== Suppression des Cloud NAT ==="
gcloud compute routers nats delete my-cloud-nat --router=nat-router --region=europe-west1 --quiet 2>/dev/null
gcloud compute routers nats delete hybrid-nat --router=hybrid-router --region=europe-west1 --quiet 2>/dev/null

echo "=== Suppression des Cloud Routers ==="
gcloud compute routers delete nat-router --region=europe-west1 --quiet 2>/dev/null
gcloud compute routers delete my-cloud-router --region=europe-west1 --quiet 2>/dev/null
gcloud compute routers delete hybrid-router --region=europe-west1 --quiet 2>/dev/null

echo "=== Suppression des zones DNS ==="
# Supprimer les enregistrements puis les zones
for ZONE in internal-zone forward-zone app-internal; do
    gcloud dns record-sets transaction start --zone=$ZONE 2>/dev/null
    gcloud dns record-sets transaction abort --zone=$ZONE 2>/dev/null
    gcloud dns managed-zones delete $ZONE --quiet 2>/dev/null
done

echo "=== Suppression des politiques DNS ==="
gcloud dns policies delete inbound-dns-policy --quiet 2>/dev/null
gcloud dns policies delete outbound-dns-policy --quiet 2>/dev/null

echo "=== Suppression des routes personnalisées ==="
for ROUTE in route-specific route-broad route-specific-backup route-via-proxy \
             default-internet-route db-outbound-via-proxy; do
    gcloud compute routes delete $ROUTE --quiet 2>/dev/null
done

echo "=== Suppression des règles de pare-feu ==="
for RULE in $(gcloud compute firewall-rules list --format="get(name)" \
              --filter="network:routing-lab-vpc OR network:hybrid-vpc"); do
    gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null
done

echo "=== Suppression des sous-réseaux ==="
for SUBNET in subnet-eu subnet-us subnet-isolated subnet-frontend subnet-backend; do
    gcloud compute networks subnets delete $SUBNET --region=europe-west1 --quiet 2>/dev/null
    gcloud compute networks subnets delete $SUBNET --region=us-central1 --quiet 2>/dev/null
done

echo "=== Suppression des VPCs ==="
gcloud compute networks delete routing-lab-vpc --quiet 2>/dev/null
gcloud compute networks delete hybrid-vpc --quiet 2>/dev/null

echo "=== Nettoyage terminé ==="
```

---

## Annexe : Commandes essentielles du Module 3

### Routes
```bash
gcloud compute routes list --filter="network=VPC_NAME"
gcloud compute routes create NAME --network=VPC --destination-range=CIDR --next-hop-instance=VM
gcloud compute routes describe NAME
gcloud compute routes delete NAME
```

### Cloud Router
```bash
gcloud compute routers create NAME --network=VPC --region=REGION --asn=ASN
gcloud compute routers describe NAME --region=REGION
gcloud compute routers get-status NAME --region=REGION
gcloud compute routers delete NAME --region=REGION
```

### Cloud NAT
```bash
gcloud compute routers nats create NAME --router=ROUTER --region=REGION --auto-allocate-nat-external-ips
gcloud compute routers nats describe NAME --router=ROUTER --region=REGION
gcloud compute routers nats update NAME --router=ROUTER --region=REGION --min-ports-per-vm=N
gcloud compute routers nats delete NAME --router=ROUTER --region=REGION
```

### Cloud DNS
```bash
gcloud dns managed-zones create NAME --dns-name="domain." --visibility=private --networks=VPC
gcloud dns managed-zones describe NAME
gcloud dns record-sets list --zone=NAME
gcloud dns record-sets create "name.domain." --type=A --ttl=300 --rrdatas="IP" --zone=NAME
gcloud dns managed-zones delete NAME
```

### Private Google Access
```bash
gcloud compute networks subnets update SUBNET --region=REGION --enable-private-google-access
gcloud compute networks subnets describe SUBNET --region=REGION --format="get(privateIpGoogleAccess)"
```
