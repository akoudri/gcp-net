# Module 2 - Principes fondamentaux du VPC
## Travaux Pratiques Détaillés

---

## Vue d'ensemble

### Objectifs pédagogiques
Ces travaux pratiques permettront aux apprenants de :
- Créer et configurer des VPC en mode custom
- Maîtriser la gestion des sous-réseaux et des plages d'adresses
- Déployer des architectures multi-régions
- Configurer des VMs avec plusieurs interfaces réseau
- Comparer et choisir les Network Tiers appropriés
- Appliquer les bonnes pratiques de planification réseau

### Prérequis
- Compte GCP avec un projet actif
- Facturation activée (certains labs génèrent des coûts minimes)
- Cloud Shell ou gcloud CLI installé localement
- Droits suffisants (roles/compute.networkAdmin, roles/compute.instanceAdmin)

### Labs proposés

| Lab | Titre | Difficulté |
|-----|-------|------------|
| 2.1 | Découverte du VPC default et ses risques | ⭐ |
| 2.2 | Créer un VPC custom multi-régions | ⭐⭐ |
| 2.3 | Planification et extension des sous-réseaux | ⭐⭐ |
| 2.4 | VM avec interfaces réseau multiples | ⭐⭐⭐ |
| 2.5 | Comparaison des Network Tiers | ⭐⭐ |
| 2.6 | Mode de routage dynamique | ⭐⭐ |
| 2.7 | Scénario complet : Architecture entreprise | ⭐⭐⭐ |
| 2.8 | Troubleshooting VPC | ⭐⭐⭐ |


---

## Lab 2.1 : Découverte du VPC default et ses risques
**Difficulté : ⭐**

### Objectifs
- Explorer le VPC par défaut et comprendre sa structure
- Identifier les risques de sécurité des règles par défaut
- Apprendre à auditer et supprimer le VPC default

### Exercices

#### Exercice 2.1.1 : Explorer le VPC default

**💡 Script disponible** : [lab2.1_ex1_explore-default-vpc.sh](scripts/module2/lab2.1_ex1_explore-default-vpc.sh)

```bash
# Exécuter le script
./scripts/module2/lab2.1_ex1_explore-default-vpc.sh
```

<details>
<summary>Ou exécuter manuellement les commandes :</summary>

```bash
# Définir le projet
export PROJECT_ID=$(gcloud config get-value project)
echo "Projet actif : $PROJECT_ID"

# Lister tous les VPC du projet
gcloud compute networks list

# Examiner les détails du VPC default
gcloud compute networks describe default

# Lister les sous-réseaux du VPC default
gcloud compute networks subnets list --network=default
```
</details>

**Questions :**
1. Combien de sous-réseaux le VPC default possède-t-il ?
2. Quelle est la plage IP du sous-réseau dans europe-west1 ?
3. Quel est le mode de création du VPC default (auto ou custom) ?

#### Exercice 2.1.2 : Auditer les règles de pare-feu par défaut

**💡 Script disponible** : [lab2.1_ex2_audit-firewall-rules.sh](scripts/module2/lab2.1_ex2_audit-firewall-rules.sh)

```bash
# Exécuter le script
./scripts/module2/lab2.1_ex2_audit-firewall-rules.sh
```

<details>
<summary>Ou exécuter manuellement les commandes :</summary>

```bash
# Lister les règles de pare-feu du VPC default
gcloud compute firewall-rules list --filter="network=default"

# Examiner chaque règle en détail
gcloud compute firewall-rules describe default-allow-ssh
gcloud compute firewall-rules describe default-allow-rdp
gcloud compute firewall-rules describe default-allow-icmp
gcloud compute firewall-rules describe default-allow-internal
```
</details>

**Questions :**
1. Quelles sont les sources autorisées pour SSH ? Est-ce sécurisé ?
2. La règle `default-allow-internal` autorise quels protocoles ?
3. Identifiez au moins 3 risques de sécurité avec ces règles par défaut.

#### Exercice 2.1.3 : Créer une VM dans le VPC default (pour démonstration)

**💡 Script disponible** : [lab2.1_ex3_create-test-vm.sh](scripts/module2/lab2.1_ex3_create-test-vm.sh)

```bash
# Exécuter le script
./scripts/module2/lab2.1_ex3_create-test-vm.sh
```

<details>
<summary>Ou exécuter manuellement les commandes :</summary>

```bash
# Créer une VM de test
gcloud compute instances create test-default-vpc \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --network=default \
    --subnet=default \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=test-vm

# Vérifier l'IP externe attribuée
gcloud compute instances describe test-default-vpc \
    --zone=europe-west1-b \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
```
</details>

**Questions :**
1. La VM a-t-elle une IP externe ? Pourquoi est-ce un risque potentiel ?
2. Cette VM est-elle accessible en SSH depuis Internet ?

#### Exercice 2.1.4 : Nettoyage et suppression du VPC default

```bash
# Supprimer la VM de test
gcloud compute instances delete test-default-vpc --zone=europe-west1-b --quiet

# Supprimer les règles de pare-feu (nécessaire avant de supprimer le VPC)
gcloud compute firewall-rules delete default-allow-icmp --quiet
gcloud compute firewall-rules delete default-allow-internal --quiet
gcloud compute firewall-rules delete default-allow-rdp --quiet
gcloud compute firewall-rules delete default-allow-ssh --quiet

# Supprimer le VPC default
gcloud compute networks delete default --quiet

# Vérifier la suppression
gcloud compute networks list
```

---

## Lab 2.2 : Créer un VPC custom multi-régions
**Difficulté : ⭐⭐**

### Objectifs
- Créer un VPC en mode custom
- Configurer des sous-réseaux dans plusieurs régions
- Configurer Cloud NAT pour l'accès sortant sécurisé
- Déployer des VMs et tester la connectivité inter-régions
- Comprendre le routage automatique au sein d'un VPC

### Architecture cible

```
                        VPC: production-vpc
                    ┌─────────────────────────────────────┐
                    │                                     │
    ┌───────────────┴───────────────┐   ┌─────────────────┴─────────────┐
    │     europe-west1 (Belgique)   │   │      us-central1 (Iowa)       │
    │     subnet-eu: 10.1.0.0/24    │   │     subnet-us: 10.2.0.0/24    │
    │                               │   │                               │
    │  ┌─────────┐    ┌─────────┐   │   │   ┌─────────┐                 │
    │  │  vm-eu  │    │ vm-eu-2 │   │   │   │  vm-us  │                 │
    │  └─────────┘    └─────────┘   │   │   └─────────┘                 │
    └───────────────────────────────┘   └───────────────────────────────┘
```

### Exercices

#### Exercice 2.2.1 : Créer le VPC en mode custom

```bash
# Variables
export VPC_NAME="production-vpc"
export PROJECT_ID=$(gcloud config get-value project)

# Créer le VPC en mode custom
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom \
    --bgp-routing-mode=regional \
    --description="VPC de production multi-régions"

# Vérifier la création
gcloud compute networks describe $VPC_NAME
```

**Questions :**
1. Quelle est la différence entre `--subnet-mode=auto` et `--subnet-mode=custom` ?
2. Pourquoi choisir le mode `regional` pour le routage BGP dans ce cas ?

#### Exercice 2.2.2 : Créer les sous-réseaux régionaux

```bash
# Sous-réseau Europe (Belgique)
gcloud compute networks subnets create subnet-eu \
    --network=$VPC_NAME \
    --region=europe-west1 \
    --range=10.1.0.0/24 \
    --description="Sous-réseau production Europe"

# Sous-réseau US (Iowa)
gcloud compute networks subnets create subnet-us \
    --network=$VPC_NAME \
    --region=us-central1 \
    --range=10.2.0.0/24 \
    --description="Sous-réseau production US"

# Vérifier les sous-réseaux créés
gcloud compute networks subnets list --network=$VPC_NAME

# Examiner les routes créées automatiquement
gcloud compute routes list --filter="network=$VPC_NAME"
```

**Questions :**
1. Combien de routes ont été créées automatiquement ?
2. Quelle est la destination de la route par défaut ?
3. Comment les routes de sous-réseaux permettent-elles la communication inter-régions ?

#### Exercice 2.2.3 : Créer les règles de pare-feu

```bash
# Règle pour autoriser SSH depuis votre IP uniquement
export MY_IP=$(curl -s ifconfig.me)
echo "Votre IP publique : $MY_IP"

gcloud compute firewall-rules create ${VPC_NAME}-allow-ssh \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-ranges=$MY_IP/32 \
    --target-tags=allow-ssh \
    --description="SSH depuis IP admin uniquement"

# Règle pour autoriser ICMP interne (ping entre VMs)
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal-icmp \
    --network=$VPC_NAME \
    --allow=icmp \
    --source-ranges=10.1.0.0/24,10.2.0.0/24 \
    --description="ICMP entre sous-réseaux internes"

# Règle pour autoriser tout le trafic interne
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal \
    --network=$VPC_NAME \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8 \
    --description="Trafic interne RFC1918"

# Lister les règles créées
gcloud compute firewall-rules list --filter="network=$VPC_NAME"
```

**Questions :**
1. Pourquoi utilise-t-on des tags (`--target-tags`) pour la règle SSH ?
2. Est-il préférable d'utiliser `10.0.0.0/8` ou les plages exactes pour `source-ranges` ?

#### Exercice 2.2.4 : Configurer Cloud NAT pour l'accès sortant

```bash
# Créer un Cloud Router (requis pour Cloud NAT)
gcloud compute routers create router-nat-eu \
    --network=$VPC_NAME \
    --region=europe-west1

gcloud compute routers create router-nat-us \
    --network=$VPC_NAME \
    --region=us-central1

# Configurer Cloud NAT pour Europe
gcloud compute routers nats create nat-eu \
    --router=router-nat-eu \
    --region=europe-west1 \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

# Configurer Cloud NAT pour US
gcloud compute routers nats create nat-us \
    --router=router-nat-us \
    --region=us-central1 \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

# Vérifier la configuration
gcloud compute routers nats list --router=router-nat-eu --region=europe-west1
gcloud compute routers nats list --router=router-nat-us --region=us-central1
```

**Questions :**
1. Pourquoi utiliser Cloud NAT plutôt que des IPs externes sur les VMs ?
2. Quel est l'avantage sécuritaire de Cloud NAT ?
3. Les VMs peuvent-elles recevoir du trafic entrant via Cloud NAT ?

#### Exercice 2.2.5 : Déployer les VMs dans chaque région

```bash
# VM en Europe
gcloud compute instances create vm-eu \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-eu \
    --no-address \
    --tags=allow-ssh \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update
        apt-get install -y traceroute mtr dnsutils'

# VM aux US
gcloud compute instances create vm-us \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-us \
    --no-address \
    --tags=allow-ssh \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update
        apt-get install -y traceroute mtr dnsutils'

# Récupérer les IPs internes
gcloud compute instances list --filter="network=$VPC_NAME" \
    --format="table(name,zone,networkInterfaces[0].networkIP)"
```

#### Exercice 2.2.6 : Tester la connectivité inter-régions

```bash
# Se connecter à vm-eu via IAP (Identity-Aware Proxy)
gcloud compute ssh vm-eu --zone=europe-west1-b --tunnel-through-iap

# Une fois connecté, tester la connectivité vers vm-us
# Remplacer <IP_VM_US> par l'IP interne de vm-us (ex: 10.2.0.2)
ping -c 5 <IP_VM_US>

# Tracer le chemin
traceroute <IP_VM_US>

# Mesurer la latence
mtr -c 10 --report <IP_VM_US>
```

**Questions :**
1. Combien de sauts entre les deux VMs ?
2. Quelle est la latence moyenne entre Europe et US ?
3. Le trafic passe-t-il par Internet ou reste-t-il sur le backbone Google ?

#### Exercice 2.2.7 : Vérifier le DNS interne automatique

```bash
# Depuis vm-eu, tester la résolution DNS interne
dig vm-us.us-central1-a.c.${PROJECT_ID}.internal

# Tester avec le nom court
ping -c 3 vm-us.us-central1-a
```

**Questions :**
1. Quel est le format complet du nom DNS interne d'une VM ?
2. Le DNS interne fonctionne-t-il entre régions différentes ?

---

## Lab 2.3 : Planification et extension des sous-réseaux
**Difficulté : ⭐⭐**

### Objectifs
- Planifier un schéma d'adressage IP cohérent
- Étendre un sous-réseau existant
- Ajouter des plages secondaires pour GKE
- Comprendre les contraintes de l'adressage GCP

### Contexte
Vous devez planifier l'adressage IP pour une entreprise avec :
- 3 environnements : Dev, Staging, Prod
- 2 régions : Europe, US
- Support futur pour GKE (pods et services)

### Exercices

#### Exercice 2.3.1 : Concevoir le plan d'adressage

**Contraintes :**
- Éviter les chevauchements entre environnements
- Prévoir la croissance (au moins 2x la taille actuelle)
- Réserver des plages pour GKE
- Ne pas utiliser les plages réservées Google

**Plan suggéré :**

| Environnement | Région | Plage principale | Pods GKE | Services GKE |
|---------------|--------|------------------|----------|--------------|
| Prod | europe-west1 | 10.10.0.0/20 | 10.10.16.0/20 | 10.10.32.0/24 |
| Prod | us-central1 | 10.20.0.0/20 | 10.20.16.0/20 | 10.20.32.0/24 |
| Staging | europe-west1 | 10.30.0.0/20 | 10.30.16.0/20 | 10.30.32.0/24 |
| Dev | europe-west1 | 10.40.0.0/20 | 10.40.16.0/20 | 10.40.32.0/24 |

**Questions de planification :**
1. Pourquoi utiliser des /20 plutôt que des /24 ?
2. Combien d'hôtes peuvent être déployés dans un /20 ?
3. Pourquoi séparer les plages de pods et services ?

#### Exercice 2.3.2 : Créer un sous-réseau avec plages secondaires

```bash
# Créer un VPC pour cet exercice
gcloud compute networks create planning-vpc \
    --subnet-mode=custom

# Créer un sous-réseau avec plages secondaires (pour GKE)
gcloud compute networks subnets create subnet-prod-eu \
    --network=planning-vpc \
    --region=europe-west1 \
    --range=10.10.0.0/20 \
    --secondary-range=pods=10.10.16.0/20,services=10.10.32.0/24 \
    --description="Production Europe avec plages GKE"

# Vérifier les plages
gcloud compute networks subnets describe subnet-prod-eu \
    --region=europe-west1 \
    --format="yaml(ipCidrRange,secondaryIpRanges)"
```

**Questions :**
1. À quoi servent les plages secondaires dans le contexte GKE ?
2. Pourquoi la plage des pods est-elle plus grande que celle des services ?

#### Exercice 2.3.3 : Étendre un sous-réseau existant

```bash
# Créer un petit sous-réseau initial
gcloud compute networks subnets create subnet-small \
    --network=planning-vpc \
    --region=europe-west1 \
    --range=10.50.0.0/28  # Seulement 14 IPs utilisables

# Vérifier la taille actuelle
gcloud compute networks subnets describe subnet-small \
    --region=europe-west1 \
    --format="get(ipCidrRange)"

# Étendre le sous-réseau (⚠️ Opération irréversible !)
gcloud compute networks subnets expand-ip-range subnet-small \
    --region=europe-west1 \
    --prefix-length=24  # Maintenant 254 IPs utilisables

# Vérifier l'extension
gcloud compute networks subnets describe subnet-small \
    --region=europe-west1 \
    --format="get(ipCidrRange)"
```

**Questions :**
1. Peut-on réduire la taille d'un sous-réseau après extension ?
2. L'extension affecte-t-elle les VMs existantes dans le sous-réseau ?
3. Quelles contraintes s'appliquent lors de l'extension ?

#### Exercice 2.3.4 : Vérifier les conflits d'adressage

```bash
# Script pour vérifier les chevauchements
cat << 'EOF' > check_overlaps.sh
#!/bin/bash
echo "=== Vérification des chevauchements de plages IP ==="
gcloud compute networks subnets list \
    --format="table(name,region,ipCidrRange,network)" \
    --sort-by=ipCidrRange
echo ""
echo "Vérifiez visuellement qu'aucune plage ne chevauche une autre."
EOF

chmod +x check_overlaps.sh
./check_overlaps.sh
```

---

## Lab 2.4 : VM avec interfaces réseau multiples (Multi-NIC)
**Difficulté : ⭐⭐⭐**

### Objectifs
- Déployer une VM avec plusieurs interfaces réseau
- Configurer le routage sur une VM multi-NIC
- Comprendre les cas d'usage des appliances réseau

### Architecture cible

```
         VPC-A (10.1.0.0/24)              VPC-B (10.2.0.0/24)
        ┌─────────────────┐              ┌─────────────────┐
        │                 │              │                 │
        │   ┌─────────┐   │              │   ┌─────────┐   │
        │   │ client-a│   │              │   │ client-b│   │
        │   │10.1.0.10│   │              │   │10.2.0.10│   │
        │   └────┬────┘   │              │   └────┬────┘   │
        │        │        │              │        │        │
        │        ▼        │              │        ▼        │
        │   ┌─────────────┴──────────────┴─────────────┐   │
        │   │           appliance-vm                   │   │
        │   │    eth0: 10.1.0.5    eth1: 10.2.0.5      │   │
        │   └──────────────────────────────────────────┘   │
        └─────────────────┘              └─────────────────┘
```

### Exercices

#### Exercice 2.4.1 : Créer les deux VPC

```bash
# Variables
export REGION="europe-west1"
export ZONE="europe-west1-b"

# VPC A
gcloud compute networks create vpc-a \
    --subnet-mode=custom

gcloud compute networks subnets create subnet-a \
    --network=vpc-a \
    --region=$REGION \
    --range=10.1.0.0/24

# VPC B
gcloud compute networks create vpc-b \
    --subnet-mode=custom

gcloud compute networks subnets create subnet-b \
    --network=vpc-b \
    --region=$REGION \
    --range=10.2.0.0/24

# Règles de pare-feu pour les deux VPC
for VPC in vpc-a vpc-b; do
    gcloud compute firewall-rules create ${VPC}-allow-internal \
        --network=$VPC \
        --allow=tcp,udp,icmp \
        --source-ranges=10.0.0.0/8

    gcloud compute firewall-rules create ${VPC}-allow-ssh \
        --network=$VPC \
        --allow=tcp:22 \
        --source-ranges=35.235.240.0/20  # Plage IAP
done
```

#### Exercice 2.4.2 : Créer la VM multi-NIC (appliance)

```bash
# La VM multi-NIC doit être créée avec toutes ses interfaces dès le départ
gcloud compute instances create appliance-vm \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=network=vpc-a,subnet=subnet-a,private-network-ip=10.1.0.5,no-address \
    --network-interface=network=vpc-b,subnet=subnet-b,private-network-ip=10.2.0.5,no-address \
    --can-ip-forward \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        # Activer le forwarding IP
        echo 1 > /proc/sys/net/ipv4/ip_forward
        echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
        
        # Installer les outils réseau
        apt-get update
        apt-get install -y iptables tcpdump net-tools'

# Vérifier la configuration réseau
gcloud compute instances describe appliance-vm \
    --zone=$ZONE \
    --format="yaml(networkInterfaces)"
```

**Questions :**
1. Que fait l'option `--can-ip-forward` ?
2. Pourquoi les deux sous-réseaux doivent-ils être dans la même région ?
3. Peut-on ajouter une interface réseau à une VM existante ?

#### Exercice 2.4.3 : Créer les VMs clientes

```bash
# Client dans VPC-A
gcloud compute instances create client-a \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-a \
    --subnet=subnet-a \
    --private-network-ip=10.1.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

# Client dans VPC-B
gcloud compute instances create client-b \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-b \
    --subnet=subnet-b \
    --private-network-ip=10.2.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud
```

#### Exercice 2.4.4 : Configurer le routage sur l'appliance

```bash
# Se connecter à l'appliance
gcloud compute ssh appliance-vm --zone=$ZONE --tunnel-through-iap

# Vérifier les interfaces
ip addr show

# Vérifier le forwarding IP
cat /proc/sys/net/ipv4/ip_forward  # Doit afficher 1

# Voir la table de routage
ip route show

# Configurer iptables pour le NAT/forwarding (optionnel pour ce lab)
sudo iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
sudo iptables -A FORWARD -i ens4 -o ens5 -j ACCEPT
sudo iptables -A FORWARD -i ens5 -o ens4 -j ACCEPT

# Vérifier les règles iptables
sudo iptables -L -v -n
sudo iptables -t nat -L -v -n
```

#### Exercice 2.4.5 : Créer des routes personnalisées

```bash
# S'assurer que les variables sont définies
export ZONE="europe-west1-b"

# Route dans VPC-A pour atteindre VPC-B via l'appliance
gcloud compute routes create route-a-to-b \
    --network=vpc-a \
    --destination-range=10.2.0.0/24 \
    --next-hop-instance=appliance-vm \
    --next-hop-instance-zone=$ZONE \
    --priority=1000

# Route dans VPC-B pour atteindre VPC-A via l'appliance
gcloud compute routes create route-b-to-a \
    --network=vpc-b \
    --destination-range=10.1.0.0/24 \
    --next-hop-instance=appliance-vm \
    --next-hop-instance-zone=$ZONE \
    --priority=1000

# Vérifier les routes
gcloud compute routes list --filter="network:vpc-a OR network:vpc-b"
```

#### Exercice 2.4.6 : Tester la connectivité via l'appliance

```bash
# Depuis client-a, tester la connectivité vers client-b
gcloud compute ssh client-a --zone=$ZONE --tunnel-through-iap

# Ping client-b
ping -c 5 10.2.0.10

# Traceroute pour voir le chemin
traceroute 10.2.0.10

# Le trafic doit passer par 10.1.0.5 (appliance)
```

```bash
# Sur l'appliance, capturer le trafic pour prouver le transit
gcloud compute ssh appliance-vm --zone=$ZONE --tunnel-through-iap

# Capturer le trafic ICMP
sudo tcpdump -i any icmp -n

# Dans un autre terminal, relancer le ping depuis client-a
```

**Questions :**
1. Le traceroute montre-t-il l'appliance comme hop intermédiaire ?
2. Que se passe-t-il si vous désactivez `ip_forward` sur l'appliance ?
3. Comment cette architecture serait-elle utilisée en production ?

---

## Lab 2.5 : Comparaison des Network Tiers
**Difficulté : ⭐⭐**

### Objectifs
- Déployer des ressources avec différents Network Tiers
- Mesurer et comparer les performances
- Comprendre l'impact sur la facturation

### Exercices

#### Exercice 2.5.1 : Créer un VPC de test

```bash
# VPC pour les tests de Network Tiers
gcloud compute networks create tier-test-vpc \
    --subnet-mode=custom

gcloud compute networks subnets create tier-test-subnet \
    --network=tier-test-vpc \
    --region=europe-west1 \
    --range=10.100.0.0/24

# Règle pare-feu pour SSH et ICMP
gcloud compute firewall-rules create tier-test-allow-all \
    --network=tier-test-vpc \
    --allow=tcp:22,icmp \
    --source-ranges=0.0.0.0/0
```

#### Exercice 2.5.2 : Créer une VM avec Premium Tier

```bash
# VM avec Premium Tier (défaut)
gcloud compute instances create vm-premium \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --network=tier-test-vpc \
    --subnet=tier-test-subnet \
    --network-tier=PREMIUM \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=http-server

# Récupérer l'IP externe
export IP_PREMIUM=$(gcloud compute instances describe vm-premium \
    --zone=europe-west1-b \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)")
echo "IP Premium : $IP_PREMIUM"
```

#### Exercice 2.5.3 : Créer une VM avec Standard Tier

```bash
# D'abord, réserver une IP Standard Tier
gcloud compute addresses create ip-standard \
    --region=europe-west1 \
    --network-tier=STANDARD

# Récupérer l'IP réservée
export IP_STANDARD=$(gcloud compute addresses describe ip-standard \
    --region=europe-west1 \
    --format="get(address)")
echo "IP Standard : $IP_STANDARD"

# VM avec Standard Tier
gcloud compute instances create vm-standard \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --network=tier-test-vpc \
    --subnet=tier-test-subnet \
    --network-tier=STANDARD \
    --address=$IP_STANDARD \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=http-server
```

#### Exercice 2.5.4 : Comparer les performances

```bash
# Depuis votre machine locale ou Cloud Shell, tester les deux IPs

# Test de latence vers Premium
echo "=== Test Premium Tier ==="
ping -c 20 $IP_PREMIUM | tail -1

# Test de latence vers Standard
echo "=== Test Standard Tier ==="
ping -c 20 $IP_STANDARD | tail -1

# Test avec mtr pour plus de détails (si disponible)
mtr -r -c 20 $IP_PREMIUM
mtr -r -c 20 $IP_STANDARD
```

#### Exercice 2.5.5 : Analyser le routage

```bash
# Traceroute vers Premium (entre via PoP Google proche)
traceroute $IP_PREMIUM

# Traceroute vers Standard (entre via la région GCP)
traceroute $IP_STANDARD
```

**Questions :**
1. Quelle est la différence de latence moyenne observée ?
2. Les chemins réseau sont-ils différents ?
3. À quel moment le trafic entre sur le réseau Google pour chaque tier ?

#### Exercice 2.5.6 : Estimer les coûts

```bash
# Afficher la configuration des VMs
gcloud compute instances list \
    --filter="name:(vm-premium OR vm-standard)" \
    --format="table(name,zone,networkInterfaces[0].networkTier,networkInterfaces[0].accessConfigs[0].natIP)"
```

**Comparaison des coûts (approximatif) :**

| Élément | Premium Tier | Standard Tier | Économie |
|---------|-------------|---------------|----------|
| Egress vers Internet (par Go) | ~$0.12 | ~$0.085 | ~30% |
| IP externe statique | ~$0.004/h | ~$0.002/h | ~50% |

**Questions :**
1. Pour un workload transférant 1 To/mois, quelle serait l'économie avec Standard ?
2. Le Standard Tier est-il adapté pour une API utilisée mondialement ?

---

## Lab 2.6 : Mode de routage dynamique
**Difficulté : ⭐⭐**

### Objectifs
- Comprendre la différence entre routage régional et global
- Configurer le mode de routage dynamique
- Observer l'impact sur la propagation des routes

### Exercices

#### Exercice 2.6.1 : Créer un VPC avec routage régional (défaut)

```bash
# VPC avec routage régional
gcloud compute networks create vpc-regional \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

# Sous-réseaux dans deux régions
gcloud compute networks subnets create subnet-eu-regional \
    --network=vpc-regional \
    --region=europe-west1 \
    --range=10.60.0.0/24

gcloud compute networks subnets create subnet-us-regional \
    --network=vpc-regional \
    --region=us-central1 \
    --range=10.61.0.0/24

# Vérifier le mode de routage
gcloud compute networks describe vpc-regional \
    --format="get(routingConfig.routingMode)"
```

#### Exercice 2.6.2 : Créer un VPC avec routage global

```bash
# VPC avec routage global
gcloud compute networks create vpc-global \
    --subnet-mode=custom \
    --bgp-routing-mode=global

# Sous-réseaux dans deux régions
gcloud compute networks subnets create subnet-eu-global \
    --network=vpc-global \
    --region=europe-west1 \
    --range=10.70.0.0/24

gcloud compute networks subnets create subnet-us-global \
    --network=vpc-global \
    --region=us-central1 \
    --range=10.71.0.0/24

# Vérifier le mode de routage
gcloud compute networks describe vpc-global \
    --format="get(routingConfig.routingMode)"
```

#### Exercice 2.6.3 : Simuler des routes dynamiques (Cloud Router)

```bash
# Créer un Cloud Router dans chaque VPC (Europe uniquement)
gcloud compute routers create router-regional \
    --network=vpc-regional \
    --region=europe-west1 \
    --asn=65001

gcloud compute routers create router-global \
    --network=vpc-global \
    --region=europe-west1 \
    --asn=65002

# Afficher les routes dans chaque VPC
echo "=== Routes VPC Regional ==="
gcloud compute routes list --filter="network=vpc-regional"

echo "=== Routes VPC Global ==="
gcloud compute routes list --filter="network=vpc-global"
```

#### Exercice 2.6.4 : Modifier le mode de routage

```bash
# Passer le VPC régional en mode global
gcloud compute networks update vpc-regional \
    --bgp-routing-mode=global

# Vérifier le changement
gcloud compute networks describe vpc-regional \
    --format="get(routingConfig.routingMode)"
```

**Questions :**
1. Quand le mode de routage global est-il nécessaire ?
2. Le changement de mode affecte-t-il les VMs existantes ?
3. Quel est l'impact sur les routes apprises via BGP ?

### Scénario explicatif

**Mode Régional :**
- Un VPN dans `europe-west1` apprend la route `192.168.0.0/16` via BGP
- Cette route est visible UNIQUEMENT par les VMs dans `europe-west1`
- Les VMs dans `us-central1` ne peuvent PAS atteindre `192.168.0.0/16`

**Mode Global :**
- La même route `192.168.0.0/16` est propagée à TOUTES les régions
- Les VMs dans `us-central1` peuvent atteindre `192.168.0.0/16` via le VPN en Europe
- Le trafic traverse le backbone Google entre les régions

---

## Lab 2.7 : Scénario complet - Architecture entreprise
**Difficulté : ⭐⭐⭐**

### Objectifs
- Concevoir et déployer une architecture VPC complète
- Configurer Cloud NAT pour l'accès Internet sécurisé (sans IPs publiques)
- Appliquer les bonnes pratiques de segmentation
- Documenter l'architecture

### Scénario
Vous devez créer l'infrastructure réseau pour une startup avec :
- Environnement de production (2 tiers : frontend, backend)
- Environnement de développement
- Séparation stricte entre environnements
- Accès SSH sécurisé via bastion

### Architecture cible

```
                           VPC: startup-vpc
    ┌────────────────────────────────────────────────────────────────────┐
    │                                                                    │
    │  ┌─────────────────────────────────────────────────────────────┐   │
    │  │                    PRODUCTION (europe-west1)                │   │
    │  │  ┌─────────────────┐          ┌─────────────────┐           │   │
    │  │  │   subnet-prod   │          │  subnet-prod    │           │   │
    │  │  │    -frontend    │          │   -backend      │           │   │
    │  │  │  10.10.0.0/24   │          │  10.10.1.0/24   │           │   │
    │  │  │                 │          │                 │           │   │
    │  │  │  ┌───────────┐  │          │  ┌───────────┐  │           │   │
    │  │  │  │ web-prod  │──┼──────────┼─▶│ api-prod  │  │           │   │
    │  │  │  └───────────┘  │          │  └───────────┘  │           │   │
    │  │  └─────────────────┘          └─────────────────┘           │   │
    │  └─────────────────────────────────────────────────────────────┘   │
    │                                                                    │
    │  ┌─────────────────────────────────────────────────────────────┐   │
    │  │                  DÉVELOPPEMENT (europe-west1)               │   │
    │  │  ┌─────────────────┐          ┌─────────────────┐           │   │
    │  │  │   subnet-dev    │          │  subnet-mgmt    │           │   │
    │  │  │  10.20.0.0/24   │          │  10.30.0.0/24   │           │   │
    │  │  │                 │          │                 │           │   │
    │  │  │  ┌───────────┐  │          │  ┌───────────┐  │           │   │
    │  │  │  │  dev-vm   │  │          │  │  bastion  │◀─┼───[SSH]   │   │
    │  │  │  └───────────┘  │          │  └───────────┘  │           │   │
    │  │  └─────────────────┘          └─────────────────┘           │   │
    │  └─────────────────────────────────────────────────────────────┘   │
    └────────────────────────────────────────────────────────────────────┘
```

### Exercice 2.7.1 : Déployer l'infrastructure complète

```bash
#!/bin/bash
# Script de déploiement complet

export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="europe-west1-b"
export VPC_NAME="startup-vpc"

echo "=== Création du VPC ==="
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

echo "=== Création des sous-réseaux ==="
# Production Frontend
gcloud compute networks subnets create subnet-prod-frontend \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.10.0.0/24 \
    --description="Production - Tier Frontend"

# Production Backend
gcloud compute networks subnets create subnet-prod-backend \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.10.1.0/24 \
    --description="Production - Tier Backend"

# Développement
gcloud compute networks subnets create subnet-dev \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.20.0.0/24 \
    --description="Environnement de développement"

# Management (Bastion)
gcloud compute networks subnets create subnet-mgmt \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.30.0.0/24 \
    --description="Management - Bastion et outils"

echo "=== Configuration Cloud NAT pour accès sortant ==="
# Créer un Cloud Router (requis pour Cloud NAT)
gcloud compute routers create router-nat \
    --network=$VPC_NAME \
    --region=$REGION

# Configurer Cloud NAT
gcloud compute routers nats create nat-config \
    --router=router-nat \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

echo "=== Création des règles de pare-feu ==="
# SSH vers bastion uniquement (via IAP)
gcloud compute firewall-rules create ${VPC_NAME}-allow-iap-ssh \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --target-tags=bastion \
    --description="SSH via IAP vers bastion"

# SSH depuis bastion vers toutes les VMs
gcloud compute firewall-rules create ${VPC_NAME}-allow-bastion-ssh \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-tags=bastion \
    --description="SSH depuis bastion"

# HTTP/HTTPS vers frontend prod
gcloud compute firewall-rules create ${VPC_NAME}-allow-web \
    --network=$VPC_NAME \
    --allow=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web \
    --description="Trafic web vers frontend"

# Communication frontend -> backend
gcloud compute firewall-rules create ${VPC_NAME}-allow-frontend-to-backend \
    --network=$VPC_NAME \
    --allow=tcp:8080 \
    --source-tags=frontend \
    --target-tags=backend \
    --description="Frontend vers Backend API"

# ICMP interne (pour debug)
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal-icmp \
    --network=$VPC_NAME \
    --allow=icmp \
    --source-ranges=10.0.0.0/8 \
    --description="Ping interne"

echo "=== Création des VMs ==="
# Bastion (conserve une IP externe pour simplifier l'accès initial)
# Note: Accessible uniquement via IAP (35.235.240.0/20)
gcloud compute instances create bastion \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-mgmt \
    --tags=bastion \
    --image-family=debian-11 \
    --image-project=debian-cloud

# Web Prod (Frontend)
# Note: --no-address = pas d'IP externe, accès Internet via Cloud NAT
gcloud compute instances create web-prod \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-prod-frontend \
    --tags=web,frontend \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx
        echo "Frontend Production" > /var/www/html/index.html'

# API Prod (Backend)
gcloud compute instances create api-prod \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-prod-backend \
    --tags=backend \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y python3
        echo "from http.server import HTTPServer, BaseHTTPRequestHandler
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b\"API Backend OK\")
HTTPServer((\"0.0.0.0\", 8080), Handler).serve_forever()" > /tmp/api.py
        python3 /tmp/api.py &'

# Dev VM
gcloud compute instances create dev-vm \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-dev \
    --tags=dev \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo "=== Résumé ==="
gcloud compute instances list --filter="network:$VPC_NAME"
```

### Exercice 2.7.2 : Tester l'architecture

```bash
# 1. Se connecter au bastion via IAP
gcloud compute ssh bastion --zone=$ZONE --tunnel-through-iap

# 2. Depuis le bastion, accéder aux autres VMs
ssh 10.10.0.X   # web-prod (remplacer X par l'IP réelle)
ssh 10.10.1.X   # api-prod
ssh 10.20.0.X   # dev-vm

# 3. Tester la communication frontend -> backend
# Depuis web-prod:
curl http://10.10.1.X:8080

# 4. Vérifier que dev ne peut pas accéder à prod directement via le port 8080
# Depuis dev-vm:
curl http://10.10.1.X:8080  # Devrait échouer (timeout)
ping 10.10.1.X              # Devrait fonctionner (ICMP autorisé)
```

### Exercice 2.7.3 : Documenter l'architecture

Créer un document incluant :
1. Schéma d'architecture réseau
2. Tableau des sous-réseaux et plages IP
3. Matrice des flux autorisés (règles de pare-feu)
4. Procédure d'accès SSH

---

## Lab 2.8 : Troubleshooting VPC
**Difficulté : ⭐⭐⭐**

### Objectifs
- Diagnostiquer les problèmes de connectivité VPC courants
- Utiliser les outils de diagnostic GCP
- Résoudre des scénarios de panne simulés

### Exercices

#### Exercice 2.8.1 : Utiliser Connectivity Tests

```bash
# Créer un test de connectivité
gcloud network-management connectivity-tests create test-web-to-api \
    --source-instance=projects/$PROJECT_ID/zones/$ZONE/instances/web-prod \
    --destination-instance=projects/$PROJECT_ID/zones/$ZONE/instances/api-prod \
    --destination-port=8080 \
    --protocol=TCP

# Exécuter et voir les résultats
gcloud network-management connectivity-tests describe test-web-to-api
```

#### Exercice 2.8.2 : Scénarios de troubleshooting

**Scénario A : VM inaccessible en SSH**

Symptôme : `ssh: connect to host X.X.X.X port 22: Connection timed out`

Checklist de diagnostic :
```bash
# 1. Vérifier que la VM est en cours d'exécution
gcloud compute instances describe <VM_NAME> --zone=$ZONE \
    --format="get(status)"

# 2. Vérifier les règles de pare-feu
gcloud compute firewall-rules list \
    --filter="network=$VPC_NAME AND allowed[].ports:22"

# 3. Vérifier les tags de la VM
gcloud compute instances describe <VM_NAME> --zone=$ZONE \
    --format="get(tags.items)"

# 4. Vérifier les logs de pare-feu (si activés)
gcloud logging read 'resource.type="gce_subnetwork" AND jsonPayload.rule_details.action="DENY"' \
    --limit=10
```

**Scénario B : Pas de connectivité entre deux VMs**

```bash
# 1. Vérifier que les VMs sont dans le même VPC
gcloud compute instances list \
    --format="table(name,zone,networkInterfaces[0].network)"

# 2. Vérifier les routes
gcloud compute routes list --filter="network=$VPC_NAME"

# 3. Tester avec Connectivity Tests
gcloud network-management connectivity-tests create test-vm-to-vm \
    --source-instance=projects/$PROJECT_ID/zones/$ZONE/instances/vm-a \
    --destination-instance=projects/$PROJECT_ID/zones/$ZONE/instances/vm-b \
    --protocol=ICMP

# 4. Vérifier le résultat
gcloud network-management connectivity-tests describe test-vm-to-vm \
    --format="yaml(result)"
```

**Scénario C : VM ne peut pas accéder à Internet**

```bash
# 1. Vérifier si la VM a une IP externe
gcloud compute instances describe <VM_NAME> --zone=$ZONE \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)"

# 2. Vérifier la route par défaut
gcloud compute routes list \
    --filter="network=$VPC_NAME AND destRange=0.0.0.0/0"

# 3. Vérifier les règles de sortie (egress)
gcloud compute firewall-rules list \
    --filter="network=$VPC_NAME AND direction=EGRESS"

# 4. Vérifier si Cloud NAT est configuré
gcloud compute routers list --filter="network=$VPC_NAME"
gcloud compute routers nats list --router=<ROUTER_NAME> --region=$REGION
```

---

## Nettoyage des ressources

```bash
#!/bin/bash
# Script de nettoyage complet

echo "=== Suppression des VMs ==="
gcloud compute instances delete bastion web-prod api-prod dev-vm \
    --zone=europe-west1-b --quiet 2>/dev/null

gcloud compute instances delete vm-eu vm-us \
    --zone=europe-west1-b --quiet 2>/dev/null
gcloud compute instances delete vm-us \
    --zone=us-central1-a --quiet 2>/dev/null

gcloud compute instances delete appliance-vm client-a client-b \
    --zone=europe-west1-b --quiet 2>/dev/null

gcloud compute instances delete vm-premium vm-standard \
    --zone=europe-west1-b --quiet 2>/dev/null

echo "=== Suppression des règles de pare-feu ==="
for RULE in $(gcloud compute firewall-rules list --format="get(name)"); do
    gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null
done

echo "=== Suppression des routes personnalisées ==="
for ROUTE in $(gcloud compute routes list --filter="NOT name~default" --format="get(name)"); do
    gcloud compute routes delete $ROUTE --quiet 2>/dev/null
done

echo "=== Suppression des adresses IP ==="
gcloud compute addresses delete ip-standard --region=europe-west1 --quiet 2>/dev/null

echo "=== Suppression des Cloud NAT ==="
for ROUTER in $(gcloud compute routers list --format="get(name,region)"); do
    ROUTER_NAME=$(echo $ROUTER | awk '{print $1}')
    ROUTER_REGION=$(echo $ROUTER | awk '{print $2}')
    # Supprimer les configurations NAT du routeur
    for NAT in $(gcloud compute routers nats list --router=$ROUTER_NAME --region=$ROUTER_REGION --format="get(name)" 2>/dev/null); do
        gcloud compute routers nats delete $NAT --router=$ROUTER_NAME --region=$ROUTER_REGION --quiet 2>/dev/null
    done
done

echo "=== Suppression des Cloud Routers ==="
for ROUTER in $(gcloud compute routers list --format="get(name,region)"); do
    ROUTER_NAME=$(echo $ROUTER | awk '{print $1}')
    ROUTER_REGION=$(echo $ROUTER | awk '{print $2}')
    gcloud compute routers delete $ROUTER_NAME --region=$ROUTER_REGION --quiet 2>/dev/null
done

echo "=== Suppression des sous-réseaux ==="
for SUBNET in $(gcloud compute networks subnets list --format="get(name,region)"); do
    NAME=$(echo $SUBNET | cut -d'/' -f1)
    REGION=$(echo $SUBNET | cut -d'/' -f2)
    gcloud compute networks subnets delete $NAME --region=$REGION --quiet 2>/dev/null
done

echo "=== Suppression des VPCs ==="
for VPC in $(gcloud compute networks list --format="get(name)" | grep -v default); do
    gcloud compute networks delete $VPC --quiet 2>/dev/null
done

echo "=== Nettoyage terminé ==="
gcloud compute networks list
gcloud compute instances list
```

---

## Annexe : Commandes gcloud essentielles pour les VPC

### Gestion des VPC
```bash
gcloud compute networks list
gcloud compute networks create <NAME> --subnet-mode=custom
gcloud compute networks describe <NAME>
gcloud compute networks delete <NAME>
gcloud compute networks update <NAME> --bgp-routing-mode=global
```

### Gestion des sous-réseaux
```bash
gcloud compute networks subnets list --network=<VPC>
gcloud compute networks subnets create <NAME> --network=<VPC> --region=<REGION> --range=<CIDR>
gcloud compute networks subnets describe <NAME> --region=<REGION>
gcloud compute networks subnets expand-ip-range <NAME> --region=<REGION> --prefix-length=<NEW_PREFIX>
gcloud compute networks subnets delete <NAME> --region=<REGION>
```

### Gestion des règles de pare-feu
```bash
gcloud compute firewall-rules list --filter="network=<VPC>"
gcloud compute firewall-rules create <NAME> --network=<VPC> --allow=<PROTOCOL:PORT>
gcloud compute firewall-rules describe <NAME>
gcloud compute firewall-rules update <NAME> --source-ranges=<CIDR>
gcloud compute firewall-rules delete <NAME>
```

### Gestion des routes
```bash
gcloud compute routes list --filter="network=<VPC>"
gcloud compute routes create <NAME> --network=<VPC> --destination-range=<CIDR> --next-hop-instance=<VM>
gcloud compute routes describe <NAME>
gcloud compute routes delete <NAME>
```

### Diagnostic
```bash
gcloud network-management connectivity-tests create <NAME> --source-instance=<VM1> --destination-instance=<VM2>
gcloud network-management connectivity-tests describe <NAME>
gcloud network-management connectivity-tests delete <NAME>
```
