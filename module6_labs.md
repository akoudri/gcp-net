# Module 6 - Cloud DNS
## Travaux Pratiques Détaillés

---

## Vue d'ensemble

### Objectifs pédagogiques
Ces travaux pratiques permettront aux apprenants de :
- Créer et gérer des zones DNS publiques et privées
- Configurer le DNS interne automatique GCP
- Implémenter le transfert DNS (forwarding) vers des serveurs externes
- Mettre en place le peering DNS entre VPC
- Configurer et analyser le DNS logging
- Sécuriser le DNS avec DNSSEC
- Implémenter le split-horizon DNS
- Utiliser les routing policies pour le routage intelligent

### Prérequis
- Modules 1 à 5 complétés
- Projet GCP avec facturation activée
- API Cloud DNS activée
- Droits : roles/dns.admin, roles/compute.networkAdmin
- (Optionnel) Un nom de domaine pour les labs de zones publiques

### Labs proposés

| Lab | Titre | Difficulté |
|-----|-------|------------|
| 6.1 | Zones privées - Configuration de base | ⭐ |
| 6.2 | DNS interne automatique GCP | ⭐ |
| 6.3 | Zones publiques et enregistrements | ⭐⭐ |
| 6.4 | Forwarding DNS vers on-premise | ⭐⭐ |
| 6.5 | Inbound Forwarding - Résolution depuis on-premise | ⭐⭐ |
| 6.6 | Peering DNS entre VPC | ⭐⭐ |
| 6.7 | Politiques DNS et Logging | ⭐⭐ |
| 6.8 | DNSSEC - Sécurisation du DNS | ⭐⭐ |
| 6.9 | Split-horizon DNS | ⭐⭐⭐ |
| 6.10 | Routing Policies - Routage intelligent | ⭐⭐⭐ |
| 6.11 | Scénario intégrateur - Architecture DNS hybride | ⭐⭐⭐ |

---

## Lab 6.1 : Zones privées - Configuration de base
**Difficulté : ⭐**

### Objectifs
- Créer une zone DNS privée
- Ajouter des enregistrements DNS
- Tester la résolution depuis les VMs

### Architecture cible

```
                            Zone DNS Privée
                           lab.internal.
                      ┌─────────────────────┐
                      │ vm1.lab.internal    │
                      │   → 10.0.0.10       │
                      │ vm2.lab.internal    │
                      │   → 10.0.0.20       │
                      │ db.lab.internal     │
                      │   → 10.0.0.30       │
                      └──────────┬──────────┘
                                 │
    ┌────────────────────────────┴────────────────────────────┐
    │                         VPC                             │
    │   ┌─────────────────────────────────────────────────┐   │
    │   │                  subnet-dns                     │   │
    │   │                 10.0.0.0/24                     │   │
    │   │                                                 │   │
    │   │   ┌───────────┐  ┌───────────┐  ┌───────────┐   │   │
    │   │   │   vm1     │  │   vm2     │  │    db     │   │   │
    │   │   │ 10.0.0.10 │  │ 10.0.0.20 │  │ 10.0.0.30 │   │   │
    │   │   └───────────┘  └───────────┘  └───────────┘   │   │
    │   │                                                 │   │
    │   └─────────────────────────────────────────────────┘   │
    └─────────────────────────────────────────────────────────┘
```

### Exercices

#### Exercice 6.1.1 : Créer l'infrastructure

```bash
# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_NAME="vpc-dns-lab"
export REGION="europe-west1"
export ZONE="${REGION}-b"

# Activer l'API Cloud DNS
gcloud services enable dns.googleapis.com

# Créer le VPC
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom \
    --description="VPC pour les labs Cloud DNS"

# Créer le sous-réseau
gcloud compute networks subnets create subnet-dns \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.0.0.0/24

# Règles de pare-feu
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal \
    --network=$VPC_NAME \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_NAME}-allow-ssh-iap \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20
```

#### Exercice 6.1.2 : Créer les VMs

```bash
# VM 1 - Serveur web
gcloud compute instances create vm1 \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-dns \
    --private-network-ip=10.0.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsutils nginx
        echo "<h1>VM1 - Web Server</h1>" > /var/www/html/index.html'

# VM 2 - Serveur applicatif
gcloud compute instances create vm2 \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-dns \
    --private-network-ip=10.0.0.20 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsutils'

# VM 3 - Base de données
gcloud compute instances create db \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-dns \
    --private-network-ip=10.0.0.30 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsutils'
```

#### Exercice 6.1.3 : Créer la zone DNS privée

```bash
# Créer la zone privée
gcloud dns managed-zones create zone-lab-internal \
    --dns-name="lab.internal." \
    --description="Zone DNS privée pour le lab" \
    --visibility=private \
    --networks=$VPC_NAME

# Vérifier la création
gcloud dns managed-zones describe zone-lab-internal

# Lister les zones
gcloud dns managed-zones list
```

#### Exercice 6.1.4 : Ajouter les enregistrements DNS

```bash
# Méthode 1: Commandes individuelles
# Enregistrement A pour vm1
gcloud dns record-sets create "vm1.lab.internal." \
    --zone=zone-lab-internal \
    --type=A \
    --ttl=300 \
    --rrdatas="10.0.0.10"

# Enregistrement A pour vm2
gcloud dns record-sets create "vm2.lab.internal." \
    --zone=zone-lab-internal \
    --type=A \
    --ttl=300 \
    --rrdatas="10.0.0.20"

# Enregistrement A pour db
gcloud dns record-sets create "db.lab.internal." \
    --zone=zone-lab-internal \
    --type=A \
    --ttl=300 \
    --rrdatas="10.0.0.30"

# Enregistrement CNAME pour un alias
gcloud dns record-sets create "database.lab.internal." \
    --zone=zone-lab-internal \
    --type=CNAME \
    --ttl=300 \
    --rrdatas="db.lab.internal."

# Enregistrement CNAME pour le web
gcloud dns record-sets create "www.lab.internal." \
    --zone=zone-lab-internal \
    --type=CNAME \
    --ttl=300 \
    --rrdatas="vm1.lab.internal."

# Lister tous les enregistrements
gcloud dns record-sets list --zone=zone-lab-internal
```

#### Exercice 6.1.5 : Méthode par transaction

```bash
# Méthode 2: Transaction (atomique, recommandée pour plusieurs enregistrements)

# Démarrer une transaction
gcloud dns record-sets transaction start --zone=zone-lab-internal

# Ajouter un enregistrement TXT
gcloud dns record-sets transaction add "env=lab;owner=training" \
    --name="metadata.lab.internal." \
    --ttl=300 \
    --type=TXT \
    --zone=zone-lab-internal

# Exécuter la transaction
gcloud dns record-sets transaction execute --zone=zone-lab-internal

# Vérifier
gcloud dns record-sets list --zone=zone-lab-internal \
    --format="table(name,type,ttl,rrdatas)"
```

#### Exercice 6.1.6 : Tester la résolution DNS

```bash
# Se connecter à vm1
gcloud compute ssh vm1 --zone=$ZONE --tunnel-through-iap

# Tester la résolution DNS
echo "=== Test nslookup ==="
nslookup vm2.lab.internal

echo "=== Test dig ==="
dig vm2.lab.internal +short

echo "=== Test dig détaillé ==="
dig db.lab.internal

echo "=== Test CNAME ==="
nslookup www.lab.internal
nslookup database.lab.internal

echo "=== Test TXT ==="
dig metadata.lab.internal TXT +short

echo "=== Test connectivité ==="
ping -c 3 vm2.lab.internal
ping -c 3 db.lab.internal

echo "=== Serveur DNS utilisé ==="
cat /etc/resolv.conf

exit
```

**Questions :**
1. Quel serveur DNS est configuré sur les VMs GCP ?
2. Pourquoi utiliser un CNAME plutôt qu'un second enregistrement A ?

---

## Lab 6.2 : DNS interne automatique GCP
**Difficulté : ⭐**

### Objectifs
- Comprendre le DNS interne automatique
- Différencier DNS zonal et global
- Utiliser les noms automatiques

### Exercices

#### Exercice 6.2.1 : Découvrir le DNS interne automatique

```bash
# Se connecter à vm1
gcloud compute ssh vm1 --zone=$ZONE --tunnel-through-iap

# Tester le nom DNS automatique (format zonal)
# Format: [VM_NAME].[ZONE].c.[PROJECT_ID].internal
nslookup vm2.europe-west1-b.c.$(gcloud config get-value project).internal

# Tester avec ping
ping -c 3 vm2.europe-west1-b.c.$(gcloud config get-value project).internal

# Tester le nom court (peut fonctionner selon la config)
ping -c 3 vm2

exit
```

#### Exercice 6.2.2 : Vérifier la configuration DNS du projet

```bash
# Voir la configuration DNS actuelle du projet
gcloud compute project-info describe \
    --format="get(vmDnsSetting)"

# Résultat possible:
# - ZONAL_ONLY : DNS zonal (recommandé)
# - GLOBAL_DEFAULT : DNS global (ancien comportement)
# - Vide : Configuration par défaut
```

#### Exercice 6.2.3 : Comprendre les formats DNS

=== Formats de noms DNS internes GCP ===

FORMAT ZONAL (recommandé):
[VM_NAME].[ZONE].c.[PROJECT_ID].internal
Exemple: vm1.europe-west1-b.c.mon-projet-123.internal

Avantages:
- Noms uniques (inclut la zone)
- Pas de collision entre VMs de même nom dans des zones différentes
- Comportement par défaut pour les nouveaux projets

FORMAT GLOBAL (ancien):
[VM_NAME].c.[PROJECT_ID].internal
Exemple: vm1.c.mon-projet-123.internal

Inconvénients:
- Collision possible si deux VMs ont le même nom
- Déprécié pour les nouveaux projets

NOMS COURTS:
- vm1 (sans suffixe)
- Fonctionnent grâce au search domain dans /etc/resolv.conf

```bash
# Voir le search domain configuré
gcloud compute ssh vm1 --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Configuration DNS de la VM ==="
cat /etc/resolv.conf
EOF
```

#### Exercice 6.2.4 : Activer le DNS zonal (si nécessaire)

```bash
# Activer le DNS zonal pour le projet
gcloud compute project-info update \
    --default-vm-dns-setting=ZONAL_ONLY

# Vérifier
gcloud compute project-info describe \
    --format="get(vmDnsSetting)"

# Note: Les VMs existantes peuvent nécessiter un redémarrage
# pour prendre en compte le changement
```

---

## Lab 6.3 : Zones publiques et enregistrements
**Difficulté : ⭐⭐**

### Objectifs
- Créer une zone DNS publique
- Gérer différents types d'enregistrements
- Comprendre la délégation DNS

### Note préalable
⚠️ Pour une zone publique fonctionnelle, vous devez posséder un nom de domaine et configurer les serveurs de noms chez votre registrar. Ce lab peut être réalisé en simulation sans domaine réel.

### Exercices

#### Exercice 6.3.1 : Créer une zone publique

```bash
# Variable pour le domaine (remplacer par votre domaine ou utiliser un exemple)
export DOMAIN="example-lab.com"

# Créer la zone publique
gcloud dns managed-zones create zone-public-lab \
    --dns-name="${DOMAIN}." \
    --description="Zone publique pour le lab" \
    --visibility=public

# Voir les serveurs de noms attribués
gcloud dns managed-zones describe zone-public-lab \
    --format="yaml(nameServers)"

# Ces serveurs doivent être configurés chez votre registrar
# Exemple de résultat:
# nameServers:
# - ns-cloud-a1.googledomains.com.
# - ns-cloud-a2.googledomains.com.
# - ns-cloud-a3.googledomains.com.
# - ns-cloud-a4.googledomains.com.
```

#### Exercice 6.3.2 : Ajouter des enregistrements courants

```bash
# Enregistrement A pour le domaine racine
gcloud dns record-sets create "${DOMAIN}." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --rrdatas="203.0.113.10"

# Enregistrement A pour www
gcloud dns record-sets create "www.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --rrdatas="203.0.113.10"

# Enregistrement AAAA (IPv6)
gcloud dns record-sets create "www.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=AAAA \
    --ttl=300 \
    --rrdatas="2001:db8::1"

# Enregistrement CNAME pour un sous-domaine
gcloud dns record-sets create "blog.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=CNAME \
    --ttl=300 \
    --rrdatas="www.${DOMAIN}."

# Enregistrement MX pour les emails
gcloud dns record-sets create "${DOMAIN}." \
    --zone=zone-public-lab \
    --type=MX \
    --ttl=300 \
    --rrdatas="10 mail1.${DOMAIN}.","20 mail2.${DOMAIN}."

# Enregistrement A pour les serveurs mail
gcloud dns record-sets create "mail1.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --rrdatas="203.0.113.25"

gcloud dns record-sets create "mail2.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --rrdatas="203.0.113.26"
```

#### Exercice 6.3.3 : Enregistrements TXT (SPF, DKIM, vérification)

```bash
# SPF pour la validation email
gcloud dns record-sets create "${DOMAIN}." \
    --zone=zone-public-lab \
    --type=TXT \
    --ttl=300 \
    --rrdatas='"v=spf1 include:_spf.google.com ~all"'

# Enregistrement de vérification Google
gcloud dns record-sets create "${DOMAIN}." \
    --zone=zone-public-lab \
    --type=TXT \
    --ttl=300 \
    --rrdatas='"google-site-verification=XXXXXXXXXXXX"'

# Note: Pour ajouter plusieurs TXT au même nom, utiliser une transaction
# ou spécifier toutes les valeurs dans --rrdatas
```

#### Exercice 6.3.4 : Enregistrement SRV

```bash
# Enregistrement SRV pour un service SIP
# Format: priorité poids port cible
gcloud dns record-sets create "_sip._tcp.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=SRV \
    --ttl=300 \
    --rrdatas="10 5 5060 sip.${DOMAIN}."

# Enregistrement A pour le serveur SIP
gcloud dns record-sets create "sip.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --rrdatas="203.0.113.50"
```

#### Exercice 6.3.5 : Enregistrement CAA

```bash
# CAA (Certificate Authority Authorization)
# Spécifie quelles CA peuvent émettre des certificats pour ce domaine
gcloud dns record-sets create "${DOMAIN}." \
    --zone=zone-public-lab \
    --type=CAA \
    --ttl=300 \
    --rrdatas='0 issue "letsencrypt.org"','0 issue "pki.goog"','0 iodef "mailto:security@${DOMAIN}"'
```

#### Exercice 6.3.6 : Lister et vérifier les enregistrements

```bash
# Lister tous les enregistrements
gcloud dns record-sets list --zone=zone-public-lab \
    --format="table(name,type,ttl,rrdatas)"

# Exporter en format BIND (pour backup)
gcloud dns record-sets export zone-public-lab.zone \
    --zone=zone-public-lab \
    --zone-file-format

cat zone-public-lab.zone
```

#### Exercice 6.3.7 : Modifier et supprimer des enregistrements

```bash
# Pour modifier un enregistrement, il faut le supprimer puis le recréer
# Ou utiliser une transaction

# Supprimer un enregistrement
gcloud dns record-sets delete "blog.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=CNAME

# Recréer avec une nouvelle valeur
gcloud dns record-sets create "blog.${DOMAIN}." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --rrdatas="203.0.113.100"
```

---

## Lab 6.4 : Forwarding DNS vers on-premise
**Difficulté : ⭐⭐**

### Objectifs
- Configurer une zone de forwarding
- Simuler un serveur DNS on-premise
- Tester la résolution via forwarding

### Architecture cible

```
    VPC GCP                                      "On-premise" (simulé)
    ┌────────────────────────────────────┐      ┌─────────────────────────┐
    │                                    │      │                         │
    │   ┌───────────────┐                │      │   ┌───────────────┐     │
    │   │   vm-client   │                │      │   │  dns-server   │     │
    │   │   10.0.0.10   │                │      │   │  10.0.1.53    │     │
    │   └───────┬───────┘                │      │   │  (dnsmasq)    │     │
    │           │                        │      │   └───────────────┘     │
    │           │ Requête:               │      │           ▲             │
    │           │ server.corp.local      │      │           │             │
    │           ▼                        │      │           │             │
    │   ┌───────────────────────┐        │      │           │             │
    │   │  Zone Forwarding      │────────┼──────┼───────────┘             │
    │   │  corp.local →         │        │      │                         │
    │   │  10.0.1.53            │        │      │   Zone: corp.local      │
    │   └───────────────────────┘        │      │   server → 10.0.1.100   │
    │                                    │      │   db → 10.0.1.101       │
    └────────────────────────────────────┘      └─────────────────────────┘
```

### Exercices

#### Exercice 6.4.1 : Créer un sous-réseau pour le "on-premise"

```bash
# Sous-réseau simulant le réseau on-premise
gcloud compute networks subnets create subnet-onprem \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.0.1.0/24
```

#### Exercice 6.4.2 : Créer un serveur DNS simulé (dnsmasq)

```bash
# VM serveur DNS avec dnsmasq
gcloud compute instances create dns-server \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-onprem \
    --private-network-ip=10.0.1.53 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
# Installer dnsmasq
apt-get update && apt-get install -y dnsmasq dnsutils

# Configurer dnsmasq
cat > /etc/dnsmasq.conf << EOF
# Écouter sur toutes les interfaces
listen-address=0.0.0.0
bind-interfaces

# Ne pas utiliser /etc/resolv.conf
no-resolv

# Serveur DNS upstream (Google DNS)
server=8.8.8.8

# Enregistrements locaux pour corp.local
address=/server.corp.local/10.0.1.100
address=/db.corp.local/10.0.1.101
address=/app.corp.local/10.0.1.102
address=/mail.corp.local/10.0.1.103

# Log des requêtes
log-queries

# Fichier de log
log-facility=/var/log/dnsmasq.log
EOF

# Redémarrer dnsmasq
systemctl restart dnsmasq
systemctl enable dnsmasq

echo "DNS Server configuré!"'

# Attendre que le serveur démarre
sleep 30
```

#### Exercice 6.4.3 : Tester le serveur DNS directement

```bash
# Se connecter au serveur DNS pour vérifier
gcloud compute ssh dns-server --zone=$ZONE --tunnel-through-iap

# Tester localement
dig @127.0.0.1 server.corp.local +short
dig @127.0.0.1 db.corp.local +short

# Voir les logs
sudo tail -f /var/log/dnsmasq.log &

# Tester une requête
dig @127.0.0.1 app.corp.local

exit
```

#### Exercice 6.4.4 : Créer la zone de forwarding

```bash
# Créer la zone de forwarding vers le serveur DNS "on-premise"
gcloud dns managed-zones create zone-forward-corp \
    --dns-name="corp.local." \
    --description="Forwarding vers DNS on-premise simulé" \
    --visibility=private \
    --networks=$VPC_NAME \
    --forwarding-targets="10.0.1.53"

# Vérifier
gcloud dns managed-zones describe zone-forward-corp
```

#### Exercice 6.4.5 : Tester le forwarding depuis une VM cliente

```bash
# Se connecter à vm1 (client)
gcloud compute ssh vm1 --zone=$ZONE --tunnel-through-iap

# Tester la résolution de noms corp.local (via forwarding)
echo "=== Test forwarding DNS ==="
nslookup server.corp.local
dig db.corp.local +short
dig app.corp.local +short

# Vérifier que les autres zones fonctionnent toujours
echo "=== Test zone privée ==="
nslookup vm2.lab.internal

exit
```

#### Exercice 6.4.6 : Observer le flux DNS

```bash
# Sur le serveur DNS, observer les requêtes reçues
gcloud compute ssh dns-server --zone=$ZONE --tunnel-through-iap

# Voir les logs en temps réel
sudo tail -f /var/log/dnsmasq.log

# Dans un autre terminal, depuis vm1, faire des requêtes
# Les requêtes devraient apparaître dans les logs

exit
```

**Questions :**
1. Pourquoi le forwarding utilise-t-il le routage privé pour les IPs RFC 1918 ?
2. Que se passe-t-il si le serveur DNS cible est injoignable ?

---

## Lab 6.5 : Inbound Forwarding - Résolution depuis on-premise
**Difficulté : ⭐⭐**

### Objectifs
- Configurer l'inbound forwarding
- Permettre la résolution Cloud DNS depuis "on-premise"
- Comprendre les adresses de forwarding

### Architecture cible

```
    "On-premise" (simulé)                    VPC GCP + Cloud DNS
    ┌─────────────────────────┐             ┌────────────────────────────────┐
    │                         │             │                                │
    │   ┌───────────────┐     │             │   Zone: lab.internal           │
    │   │  client-onprem│     │             │   vm1 → 10.0.0.10              │
    │   │  10.0.1.10    │     │             │   vm2 → 10.0.0.20              │
    │   └───────┬───────┘     │             │                                │
    │           │             │             │   ┌────────────────────────┐   │
    │           │ Requête:    │             │   │  Inbound Forwarder     │   │
    │           │ vm1.lab.internal          │   │  10.0.0.2 (auto)       │   │
    │           │             │             │   └────────────────────────┘   │
    │           └─────────────┼─────────────┼──►          │                  │
    │                         │             │             ▼                  │
    │                         │             │       Cloud DNS                │
    │                         │             │                                │
    └─────────────────────────┘             └────────────────────────────────┘
```

### Exercices

#### Exercice 6.5.1 : Créer une politique DNS avec inbound forwarding

```bash
# Créer la politique DNS
gcloud dns policies create policy-inbound \
    --networks=$VPC_NAME \
    --enable-inbound-forwarding \
    --description="Politique avec inbound forwarding"

# Vérifier la création
gcloud dns policies describe policy-inbound

# Lister les adresses de forwarding inbound créées automatiquement
gcloud compute addresses list \
    --filter="purpose=DNS_RESOLVER" \
    --format="table(name,address,region,subnetwork)"
```

#### Exercice 6.5.2 : Identifier les adresses de forwarding

```bash
# Les adresses de forwarding sont créées automatiquement dans chaque sous-réseau
# Elles permettent aux clients externes de résoudre via Cloud DNS

# Récupérer l'adresse de forwarding
export INBOUND_IP=$(gcloud compute addresses list \
    --filter="purpose=DNS_RESOLVER AND subnetwork~subnet-dns" \
    --format="get(address)")
echo "Adresse Inbound Forwarder: $INBOUND_IP"
```

#### Exercice 6.5.3 : Créer un client "on-premise"

```bash
# VM simulant un client on-premise
gcloud compute instances create client-onprem \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-onprem \
    --private-network-ip=10.0.1.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsutils'
```

#### Exercice 6.5.4 : Tester l'inbound forwarding

```bash
# Se connecter au client on-premise
gcloud compute ssh client-onprem --zone=$ZONE --tunnel-through-iap

# Par défaut, le client utilise le DNS metadata (169.254.169.254)
# Simuler une requête vers l'inbound forwarder

# Remplacer <INBOUND_IP> par l'adresse obtenue précédemment
dig @<INBOUND_IP> vm1.lab.internal +short
dig @<INBOUND_IP> vm2.lab.internal +short
dig @<INBOUND_IP> db.lab.internal +short

# Tester aussi le DNS automatique GCP
dig @<INBOUND_IP> vm1.europe-west1-b.c.$(gcloud config get-value project).internal +short

exit
```

#### Exercice 6.5.5 : Configurer le client pour utiliser l'inbound forwarder

```bash
# Sur le client on-premise, configurer le DNS
gcloud compute ssh client-onprem --zone=$ZONE --tunnel-through-iap

# Modifier resolv.conf (temporaire)
sudo bash -c 'echo "nameserver <INBOUND_IP>" > /etc/resolv.conf'

# Maintenant les requêtes passent par Cloud DNS
nslookup vm1.lab.internal
nslookup vm2.lab.internal

exit
```

**Note :** Dans un vrai scénario on-premise, vous configureriez vos serveurs DNS on-premise pour transférer les requêtes vers ces adresses via VPN/Interconnect.

---

## Lab 6.6 : Peering DNS entre VPC
**Difficulté : ⭐⭐**

### Objectifs
- Comprendre le peering DNS
- Configurer le peering DNS entre deux VPC
- Résoudre des noms d'un VPC depuis un autre

### Architecture cible

```
    VPC Hub (DNS centralisé)                    VPC Spoke
    ┌────────────────────────────┐             ┌────────────────────────────┐
    │                            │             │                            │
    │   Zone: services.internal  │             │   Zone peering vers Hub    │
    │   api → 10.10.0.10         │  Peering    │                            │
    │   cache → 10.10.0.20       │◄───DNS──────│   ┌───────────────┐        │
    │   monitoring → 10.10.0.30  │             │   │   vm-spoke    │        │
    │                            │             │   │   10.20.0.10  │        │
    │   ┌───────────────┐        │             │   └───────────────┘        │
    │   │   vm-hub      │        │             │                            │
    │   │   10.10.0.5   │        │             │   Peut résoudre:           │
    │   └───────────────┘        │             │   api.services.internal    │
    │                            │             │                            │
    └────────────────────────────┘             └────────────────────────────┘
```

### Exercices

#### Exercice 6.6.1 : Créer le VPC Hub

```bash
# VPC Hub (services centralisés)
gcloud compute networks create vpc-hub \
    --subnet-mode=custom \
    --description="VPC Hub avec DNS centralisé"

gcloud compute networks subnets create subnet-hub \
    --network=vpc-hub \
    --region=$REGION \
    --range=10.10.0.0/24

# Règles de pare-feu
gcloud compute firewall-rules create vpc-hub-allow-internal \
    --network=vpc-hub \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create vpc-hub-allow-ssh-iap \
    --network=vpc-hub \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20
```

#### Exercice 6.6.2 : Créer la zone DNS dans le Hub

```bash
# Zone DNS privée dans le VPC Hub
gcloud dns managed-zones create zone-services \
    --dns-name="services.internal." \
    --description="Zone DNS pour services partagés" \
    --visibility=private \
    --networks=vpc-hub

# Ajouter des enregistrements
gcloud dns record-sets create "api.services.internal." \
    --zone=zone-services \
    --type=A \
    --ttl=300 \
    --rrdatas="10.10.0.10"

gcloud dns record-sets create "cache.services.internal." \
    --zone=zone-services \
    --type=A \
    --ttl=300 \
    --rrdatas="10.10.0.20"

gcloud dns record-sets create "monitoring.services.internal." \
    --zone=zone-services \
    --type=A \
    --ttl=300 \
    --rrdatas="10.10.0.30"
```

#### Exercice 6.6.3 : Créer le VPC Spoke

```bash
# VPC Spoke
gcloud compute networks create vpc-spoke \
    --subnet-mode=custom \
    --description="VPC Spoke consommateur de DNS"

gcloud compute networks subnets create subnet-spoke \
    --network=vpc-spoke \
    --region=$REGION \
    --range=10.20.0.0/24

# Règles de pare-feu
gcloud compute firewall-rules create vpc-spoke-allow-internal \
    --network=vpc-spoke \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create vpc-spoke-allow-ssh-iap \
    --network=vpc-spoke \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

# VM dans le spoke
gcloud compute instances create vm-spoke \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-spoke \
    --subnet=subnet-spoke \
    --private-network-ip=10.20.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='apt-get update && apt-get install -y dnsutils'
```

#### Exercice 6.6.4 : Créer le peering DNS

```bash
# Zone de peering DNS dans le VPC Spoke vers le VPC Hub
gcloud dns managed-zones create peering-to-hub \
    --dns-name="services.internal." \
    --description="Peering DNS vers VPC Hub" \
    --visibility=private \
    --networks=vpc-spoke \
    --target-network=vpc-hub \
    --target-project=$PROJECT_ID

# Vérifier
gcloud dns managed-zones describe peering-to-hub
```

**Important :** Le peering DNS est différent du VPC Peering réseau. Il concerne uniquement la résolution DNS, pas la connectivité réseau.

#### Exercice 6.6.5 : Tester la résolution via peering DNS

```bash
# Se connecter à la VM spoke
gcloud compute ssh vm-spoke --zone=$ZONE --tunnel-through-iap

# Tester la résolution des noms du Hub
echo "=== Test peering DNS ==="
nslookup api.services.internal
dig cache.services.internal +short
dig monitoring.services.internal +short

exit
```

**Questions :**
1. La VM spoke peut-elle faire un ping vers api.services.internal ?
2. Quelle est la différence entre peering DNS et peering VPC ?

#### Exercice 6.6.6 : Comprendre les limites

=== Peering DNS vs VPC Peering ===

| Aspect | Peering DNS | VPC Peering |
|--------|-------------|-------------|
| Fonction | Résolution de noms | Connectivité réseau |
| Trafic | DNS uniquement | Tout le trafic |
| Transitif | Non | Non |
| Configuration | Par zone DNS | Par VPC |

Pour une connectivité complète Hub-Spoke :
1. Peering DNS : Pour la résolution des noms
2. VPC Peering : Pour la connectivité réseau
   OU
   Shared VPC : Pour tout centraliser

---

## Lab 6.7 : Politiques DNS et Logging
**Difficulté : ⭐⭐**

### Objectifs
- Créer et gérer des politiques DNS
- Activer le logging DNS
- Analyser les requêtes DNS

### Exercices

#### Exercice 6.7.1 : Créer une politique DNS complète

```bash
# Supprimer la politique existante si elle existe
gcloud dns policies delete policy-inbound --quiet 2>/dev/null

# Créer une nouvelle politique DNS complète
gcloud dns policies create policy-dns-full \
    --networks=$VPC_NAME \
    --enable-inbound-forwarding \
    --enable-logging \
    --description="Politique DNS complète avec logging"

# Vérifier
gcloud dns policies describe policy-dns-full
```

#### Exercice 6.7.2 : Générer du trafic DNS

```bash
# Se connecter à vm1 et générer des requêtes DNS
gcloud compute ssh vm1 --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Génération de trafic DNS ==="

# Requêtes vers la zone privée
for i in {1..5}; do
    dig vm2.lab.internal +short
    dig db.lab.internal +short
done

# Requêtes vers des domaines externes
dig www.google.com +short
dig www.github.com +short

# Requêtes inexistantes (pour générer NXDOMAIN)
dig nonexistent.lab.internal +short

echo "Requêtes DNS générées!"
EOF
```

#### Exercice 6.7.3 : Consulter les logs DNS

```bash
# Attendre quelques minutes pour la propagation des logs

# Consulter les logs DNS récents
gcloud logging read 'resource.type="dns_query"' \
    --limit=20 \
    --format="table(timestamp,jsonPayload.queryName,jsonPayload.queryType,jsonPayload.responseCode)"

# Filtrer par nom de domaine spécifique
gcloud logging read 'resource.type="dns_query" AND jsonPayload.queryName:"lab.internal"' \
    --limit=10

# Voir les requêtes avec erreurs
gcloud logging read 'resource.type="dns_query" AND jsonPayload.responseCode!="NOERROR"' \
    --limit=10
```

#### Exercice 6.7.4 : Analyser les logs en détail

```bash
# Voir un log complet en JSON
gcloud logging read 'resource.type="dns_query"' \
    --limit=1 \
    --format=json
```

```
Champs disponibles dans les logs DNS:

=== Structure des logs DNS ===

{
  "queryName": "vm2.lab.internal.",     # Nom demandé
  "queryType": "A",                      # Type de requête
  "responseCode": "NOERROR",             # Code réponse
  "rdata": "10.0.0.20",                  # Réponse
  "sourceNetwork": "vpc-dns-lab",        # VPC source
  "vmInstanceId": "1234567890",          # ID VM
  "vmInstanceName": "vm1",               # Nom VM
  "vmProjectId": "mon-projet",           # Projet
  "vmZoneName": "europe-west1-b",        # Zone
  "targetType": "PRIVATE_ZONE"           # Type de zone
}

Codes de réponse courants:
- NOERROR: Succès
- NXDOMAIN: Domaine inexistant
- SERVFAIL: Erreur serveur
- REFUSED: Requête refusée
```

#### Exercice 6.7.5 : Créer une alerte sur les requêtes DNS suspectes

```bash
# Créer un sink vers BigQuery pour analyse avancée (optionnel)
gcloud logging sinks create dns-logs-sink \
    bigquery.googleapis.com/projects/$PROJECT_ID/datasets/dns_logs \
    --log-filter='resource.type="dns_query"'

# Alternative: Créer une métrique basée sur les logs
gcloud logging metrics create dns-nxdomain-count \
    --description="Nombre de requêtes DNS avec NXDOMAIN" \
    --log-filter='resource.type="dns_query" AND jsonPayload.responseCode="NXDOMAIN"'

# Voir les métriques
gcloud logging metrics describe dns-nxdomain-count
```

---

## Lab 6.8 : DNSSEC - Sécurisation du DNS
**Difficulté : ⭐⭐**

### Objectifs
- Comprendre DNSSEC et son fonctionnement
- Activer DNSSEC sur une zone publique
- Obtenir les DS records pour le registrar

### Exercices

#### Exercice 6.8.1 : Comprendre DNSSEC

```
=== DNSSEC - Sécurisation du DNS ===

PROBLÈME:
- Les réponses DNS peuvent être falsifiées (spoofing)
- Attaques "cache poisoning"
- Redirection vers des sites malveillants

SOLUTION DNSSEC:
- Signature cryptographique des enregistrements
- Chaîne de confiance depuis la racine DNS
- Vérification d'authenticité des réponses

TYPES DE CLÉS:
┌─────────────────────────────────────────────────────────┐
│ KSK (Key Signing Key)                                   │
│ - Signe les clés de zone                                │
│ - Référencée dans le DS record chez le registrar        │
│ - Rotation moins fréquente                              │
├─────────────────────────────────────────────────────────┤
│ ZSK (Zone Signing Key)                                  │
│ - Signe les enregistrements de la zone                  │
│ - Rotation automatique par Cloud DNS                    │
└─────────────────────────────────────────────────────────┘

CHAÎNE DE CONFIANCE:
Root (.) → TLD (.com) → Votre domaine → Enregistrements
    DS        DS           KSK+ZSK         RRSIG
```

#### Exercice 6.8.2 : Activer DNSSEC sur la zone publique

```bash
# Activer DNSSEC (sur la zone publique créée précédemment)
gcloud dns managed-zones update zone-public-lab \
    --dnssec-state=on

# Vérifier l'état DNSSEC
gcloud dns managed-zones describe zone-public-lab \
    --format="yaml(dnsSecConfig)"
```

#### Exercice 6.8.3 : Obtenir les informations DNSSEC

```bash
# Lister les clés DNSSEC
gcloud dns dns-keys list --zone=zone-public-lab

# Obtenir le DS record pour le registrar (KSK uniquement)
gcloud dns dns-keys list --zone=zone-public-lab \
    --filter="type=keySigning" \
    --format="table(keyTag,algorithm,digestType,ds_record())"

# Format détaillé
gcloud dns dns-keys describe $(gcloud dns dns-keys list \
    --zone=zone-public-lab \
    --filter="type=keySigning" \
    --format="get(id)") \
    --zone=zone-public-lab
```

#### Exercice 6.8.4 : Vérifier DNSSEC (si domaine réel)

```bash
# Si vous avez un domaine réel avec DNSSEC configuré chez le registrar:

# Vérifier avec dig
dig +dnssec example-lab.com A

# Vérifier la chaîne de confiance
dig +trace +dnssec example-lab.com

# Outils en ligne pour vérifier DNSSEC:
# - https://dnsviz.net/
# - https://dnssec-analyzer.verisignlabs.com/
```

#### Exercice 6.8.5 : Gestion des clés

```bash
# Cloud DNS gère automatiquement la rotation des ZSK
# Pour la rotation KSK (si nécessaire):

# Voir l'état des clés
gcloud dns dns-keys list --zone=zone-public-lab \
    --format="table(id,type,keyTag,isActive)"

# Note: La rotation KSK nécessite une mise à jour du DS record
# chez le registrar, donc à faire avec précaution
```

---

## Lab 6.9 : Split-horizon DNS
**Difficulté : ⭐⭐⭐**

### Objectifs
- Implémenter le split-horizon DNS
- Servir des réponses différentes selon l'origine
- Cas d'usage : IP publique vs IP privée

### Architecture cible

```
                                api.example.com
                                      │
                   ┌──────────────────┴───────────────────┐
                   │                                      │
           Depuis Internet                         Depuis VPC
           (Zone publique)                        (Zone privée)
                   │                                      │
                   ▼                                      ▼
           ┌─────────────┐                        ┌─────────────┐
           │  35.x.x.x   │                        │  10.0.0.50  │
           │(IP publique)│                        │ (IP privée) │
           └─────────────┘                        └─────────────┘
                   │                                      │
                   └──────────────────┬───────────────────┘
                                      │
                              ┌───────────────┐
                              │   Même VM     │
                              │   (backend)   │
                              └───────────────┘
```

### Exercices

#### Exercice 6.9.1 : Créer le backend avec IP publique et privée

```bash
# Créer une VM avec IP publique (pour le split-horizon)
gcloud compute instances create vm-api \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-dns \
    --private-network-ip=10.0.0.50 \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=http-server \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx
        echo "<h1>API Server</h1><p>Hostname: $(hostname)</p>" > /var/www/html/index.html
        systemctl start nginx'

# Règle de pare-feu pour HTTP externe
gcloud compute firewall-rules create ${VPC_NAME}-allow-http \
    --network=$VPC_NAME \
    --allow=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# Récupérer l'IP publique
export PUBLIC_IP=$(gcloud compute instances describe vm-api \
    --zone=$ZONE \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)")
echo "IP Publique: $PUBLIC_IP"
```

#### Exercice 6.9.2 : Zone publique (vue Internet)

```bash
# Pour ce lab, nous utilisons un domaine fictif
# En production, vous utiliseriez votre vrai domaine

export SPLIT_DOMAIN="api-split.example.com"

# Créer/mettre à jour la zone publique
gcloud dns managed-zones create zone-split-public \
    --dns-name="example.com." \
    --description="Zone publique pour split-horizon" \
    --visibility=public 2>/dev/null || true

# Enregistrement public
gcloud dns record-sets create "api-split.example.com." \
    --zone=zone-split-public \
    --type=A \
    --ttl=300 \
    --rrdatas="$PUBLIC_IP"

# Vérifier
gcloud dns record-sets list --zone=zone-split-public \
    --filter="name:api-split"
```

#### Exercice 6.9.3 : Zone privée (vue VPC)

```bash
# Créer la zone privée avec le MÊME nom de domaine
gcloud dns managed-zones create zone-split-private \
    --dns-name="example.com." \
    --description="Zone privée pour split-horizon" \
    --visibility=private \
    --networks=$VPC_NAME

# Enregistrement privé (IP privée)
gcloud dns record-sets create "api-split.example.com." \
    --zone=zone-split-private \
    --type=A \
    --ttl=300 \
    --rrdatas="10.0.0.50"

# Vérifier
gcloud dns record-sets list --zone=zone-split-private \
    --filter="name:api-split"
```

#### Exercice 6.9.4 : Tester le split-horizon

```bash
# Test depuis une VM du VPC (devrait retourner l'IP privée)
gcloud compute ssh vm1 --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Résolution depuis le VPC ==="
nslookup api-split.example.com
dig api-split.example.com +short

# Tester la connectivité
curl -s http://api-split.example.com 2>/dev/null || echo "Connexion OK vers IP privée"
EOF

# Test depuis Internet (simulation)
# Utiliser un serveur DNS public qui ne voit pas la zone privée
echo "=== Résolution depuis Internet (simulation) ==="
echo "IP publique attendue: $PUBLIC_IP"

# Note: Pour tester réellement depuis Internet, vous devriez:
# 1. Avoir un domaine réel configuré
# 2. Tester depuis une machine externe au VPC
```

#### Exercice 6.9.5 : Comprendre la priorité des zones

```
=== Priorité de résolution DNS dans GCP ===

Ordre de priorité (de la plus haute à la plus basse):

1. Zones privées attachées au VPC
   → Priorité absolue pour les VMs du VPC

2. Zones de peering DNS
   → Pour les noms délégués à un autre VPC

3. Zones de forwarding
   → Pour les noms transférés vers des serveurs externes

4. DNS interne automatique GCP
   → [VM].[ZONE].c.[PROJECT].internal

5. Zone publique / Internet
   → Résolution via les serveurs DNS publics

Conséquence pour le split-horizon:
- La zone privée "example.com" a priorité sur la zone publique
- Les VMs du VPC voient TOUJOURS l'IP privée
- Les clients externes voient l'IP publique
```

---

## Lab 6.10 : Routing Policies - Routage intelligent
**Difficulté : ⭐⭐⭐**

### Objectifs
- Configurer le routage géographique (Geolocation)
- Implémenter le Weighted Round Robin
- Comprendre le routage failover

### Exercices

#### Exercice 6.10.1 : Comprendre les routing policies

```
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
```

#### Exercice 6.10.2 : Routing Geolocation

```bash
# Créer des enregistrements avec politique de géolocalisation
# Les clients seront dirigés vers le serveur le plus proche

gcloud dns record-sets create "geo.example.com." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --routing-policy-type=GEO \
    --routing-policy-data="europe-west1=10.0.0.100;us-central1=10.1.0.100;asia-east1=10.2.0.100"

# Vérifier
gcloud dns record-sets describe "geo.example.com." \
    --zone=zone-public-lab \
    --type=A
```

#### Exercice 6.10.3 : Weighted Round Robin

```bash
# Créer un health check pour Cloud DNS
gcloud compute health-checks create http hc-dns-wrr \
    --port=80 \
    --request-path=/health

# Créer des enregistrements avec politique WRR
# 80% du trafic vers primary, 20% vers canary
gcloud dns record-sets create "wrr.example.com." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=60 \
    --routing-policy-type=WRR \
    --routing-policy-data="0.8=10.0.0.101;0.2=10.0.0.102"

# Vérifier la configuration
gcloud dns record-sets describe "wrr.example.com." \
    --zone=zone-public-lab \
    --type=A
```

#### Exercice 6.10.4 : Simuler des requêtes et observer la distribution

```bash
# Script pour observer la distribution WRR
cat << 'SCRIPT' > test_wrr.sh
#!/bin/bash
# Test WRR distribution

DOMAIN="wrr.example.com"
COUNT=100

echo "Testing WRR distribution with $COUNT queries..."

declare -A results

for i in $(seq 1 $COUNT); do
    ip=$(dig +short $DOMAIN @8.8.8.8 | head -1)
    if [ -n "$ip" ]; then
        ((results[$ip]++))
    fi
done

echo "Results:"
for ip in "${!results[@]}"; do
    pct=$((100 * ${results[$ip]} / $COUNT))
    echo "  $ip: ${results[$ip]} requests ($pct%)"
done
SCRIPT

chmod +x test_wrr.sh

# Note: Ce script fonctionne uniquement si le domaine est réellement configuré
# avec les NS de Cloud DNS chez votre registrar
```

#### Exercice 6.10.5 : Geolocation avec health checks

```
# Pour une configuration production avec failover géographique:

=== Configuration avancée Geolocation + Health Check ===

# 1. Créer des ressources dans chaque région
# 2. Configurer des health checks
# 3. Utiliser la politique GEO avec backup

Exemple de configuration avec backup:

gcloud dns record-sets create "app.example.com." \
    --zone=zone-public-lab \
    --type=A \
    --ttl=300 \
    --routing-policy-type=GEO \
    --routing-policy-data="
        europe-west1=10.0.0.100;
        us-central1=10.1.0.100;
        asia-east1=10.2.0.100
    " \
    --enable-health-checking \
    --health-check=projects/PROJECT/global/healthChecks/hc-dns

Note: Si un backend régional échoue au health check,
le trafic est automatiquement redirigé vers la région la plus proche.
```

#### Exercice 6.10.6 : Lister et gérer les routing policies

```bash
# Lister tous les enregistrements avec routing policy
gcloud dns record-sets list --zone=zone-public-lab \
    --filter="routingPolicy.geo OR routingPolicy.wrr" \
    --format="table(name,type,routingPolicy)"

# Supprimer un enregistrement avec routing policy
gcloud dns record-sets delete "geo.example.com." \
    --zone=zone-public-lab \
    --type=A
```

---

## Lab 6.11 : Scénario intégrateur - Architecture DNS hybride
**Difficulté : ⭐⭐⭐**

### Objectifs
- Combiner toutes les fonctionnalités Cloud DNS
- Créer une architecture DNS enterprise
- Documenter l'architecture complète

### Architecture cible

```
                                        Internet
                                            │
                                            │ Zone publique
                                            │ example.com
                                            │
    ┌───────────────────────────────────────┴───────────────────────────────────────┐
    │                                                                               │
    │                              VPC Production                                   │
    │                                                                               │
    │   ┌────────────────────────────────────────────────────────────────────────┐  │
    │   │                                                                        │  │
    │   │   Zone privée: prod.internal                                           │  │
    │   │   - api.prod.internal → 10.1.0.10                                      │  │
    │   │   - db.prod.internal → 10.1.0.20                                       │  │
    │   │   - cache.prod.internal → 10.1.0.30                                    │  │
    │   │                                                                        │  │
    │   │   Split-horizon: api.example.com                                       │  │
    │   │   - Externe: IP publique                                               │  │
    │   │   - Interne: 10.1.0.10                                                 │  │
    │   │                                                                        │  │
    │   │   Forwarding: corp.local → DNS on-premise (192.168.1.53)               │  │
    │   │                                                                        │  │
    │   │   Inbound: Permet résolution depuis on-premise                         │  │
    │   │                                                                        │  │
    │   │   Logging: Activé pour audit                                           │  │
    │   │                                                                        │  │
    │   └────────────────────────────────────────────────────────────────────────┘  │
    │                                                                               │
    │                                     │ VPN/Interconnect                        │
    │                                     ▼                                         │
    │                              On-premise                                       │
    │                           (192.168.0.0/16)                                    │
    │                                                                               │
    └───────────────────────────────────────────────────────────────────────────────┘
```

### Exercice : Déploiement complet

```bash
#!/bin/bash
# Script de déploiement de l'architecture DNS hybride

set -e

export PROJECT_ID=$(gcloud config get-value project)
export VPC_PROD="vpc-prod-dns"
export REGION="europe-west1"
export ZONE="${REGION}-b"
export DOMAIN="example-corp.com"

echo "=== 1. Création du VPC Production ==="
gcloud compute networks create $VPC_PROD \
    --subnet-mode=custom \
    --description="VPC Production avec DNS hybride"

gcloud compute networks subnets create subnet-prod \
    --network=$VPC_PROD \
    --region=$REGION \
    --range=10.1.0.0/24

gcloud compute networks subnets create subnet-onprem-sim \
    --network=$VPC_PROD \
    --region=$REGION \
    --range=192.168.1.0/24

# Pare-feu
gcloud compute firewall-rules create ${VPC_PROD}-allow-all-internal \
    --network=$VPC_PROD \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8,192.168.0.0/16

gcloud compute firewall-rules create ${VPC_PROD}-allow-ssh-iap \
    --network=$VPC_PROD \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

gcloud compute firewall-rules create ${VPC_PROD}-allow-http \
    --network=$VPC_PROD \
    --allow=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

echo "=== 2. Déploiement des VMs ==="
# VM API
gcloud compute instances create vm-api-prod \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_PROD \
    --subnet=subnet-prod \
    --private-network-ip=10.1.0.10 \
    --tags=http-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx dnsutils
        echo "<h1>API Production</h1>" > /var/www/html/index.html'

# VM DB
gcloud compute instances create vm-db-prod \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_PROD \
    --subnet=subnet-prod \
    --private-network-ip=10.1.0.20 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

# VM Cache
gcloud compute instances create vm-cache-prod \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_PROD \
    --subnet=subnet-prod \
    --private-network-ip=10.1.0.30 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

# DNS Server on-premise simulé
gcloud compute instances create dns-onprem \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_PROD \
    --subnet=subnet-onprem-sim \
    --private-network-ip=192.168.1.53 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsmasq
        cat > /etc/dnsmasq.conf << EOF
listen-address=0.0.0.0
bind-interfaces
no-resolv
server=8.8.8.8
address=/server.corp.local/192.168.1.100
address=/ldap.corp.local/192.168.1.101
log-queries
EOF
        systemctl restart dnsmasq'

echo "=== 3. Configuration des zones DNS ==="

# Zone privée prod.internal
gcloud dns managed-zones create zone-prod-internal \
    --dns-name="prod.internal." \
    --description="Zone privée production" \
    --visibility=private \
    --networks=$VPC_PROD

gcloud dns record-sets create "api.prod.internal." \
    --zone=zone-prod-internal --type=A --ttl=300 --rrdatas="10.1.0.10"

gcloud dns record-sets create "db.prod.internal." \
    --zone=zone-prod-internal --type=A --ttl=300 --rrdatas="10.1.0.20"

gcloud dns record-sets create "cache.prod.internal." \
    --zone=zone-prod-internal --type=A --ttl=300 --rrdatas="10.1.0.30"

# Zone publique
gcloud dns managed-zones create zone-corp-public \
    --dns-name="${DOMAIN}." \
    --description="Zone publique corporate" \
    --visibility=public

PUBLIC_IP=$(gcloud compute instances describe vm-api-prod \
    --zone=$ZONE --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

gcloud dns record-sets create "api.${DOMAIN}." \
    --zone=zone-corp-public --type=A --ttl=300 --rrdatas="$PUBLIC_IP"

# Zone privée pour split-horizon
gcloud dns managed-zones create zone-corp-private \
    --dns-name="${DOMAIN}." \
    --description="Zone privée split-horizon" \
    --visibility=private \
    --networks=$VPC_PROD

gcloud dns record-sets create "api.${DOMAIN}." \
    --zone=zone-corp-private --type=A --ttl=300 --rrdatas="10.1.0.10"

# Zone de forwarding vers on-premise
gcloud dns managed-zones create zone-forward-corp \
    --dns-name="corp.local." \
    --description="Forwarding vers DNS on-premise" \
    --visibility=private \
    --networks=$VPC_PROD \
    --forwarding-targets="192.168.1.53"

echo "=== 4. Politique DNS avec logging et inbound ==="
gcloud dns policies create policy-prod \
    --networks=$VPC_PROD \
    --enable-inbound-forwarding \
    --enable-logging \
    --description="Politique DNS production"

echo "=== 5. Récupération des informations ==="
echo ""
echo "=== ARCHITECTURE DNS DÉPLOYÉE ==="
echo ""
echo "VPC: $VPC_PROD"
echo "Domaine public: $DOMAIN"
echo "IP publique API: $PUBLIC_IP"
echo ""
echo "Zones DNS:"
gcloud dns managed-zones list --format="table(name,dnsName,visibility)"
echo ""
echo "Inbound forwarder:"
gcloud compute addresses list --filter="purpose=DNS_RESOLVER"
echo ""
echo "=== Déploiement terminé ==="
```

### Tests de validation

```bash
# Test 1: Zone privée prod.internal
gcloud compute ssh vm-api-prod --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test zone privée ==="
nslookup db.prod.internal
nslookup cache.prod.internal
EOF

# Test 2: Split-horizon
gcloud compute ssh vm-api-prod --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test split-horizon (vue interne) ==="
nslookup api.example-corp.com
EOF

# Test 3: Forwarding vers on-premise
gcloud compute ssh vm-api-prod --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test forwarding on-premise ==="
nslookup server.corp.local
nslookup ldap.corp.local
EOF

# Test 4: Logs DNS
echo "=== Logs DNS récents ==="
gcloud logging read 'resource.type="dns_query"' --limit=10 \
    --format="table(timestamp,jsonPayload.queryName,jsonPayload.responseCode)"
```

---

## Script de nettoyage complet

```bash
#!/bin/bash
# Nettoyage de toutes les ressources des labs du Module 6

echo "=== Suppression des VMs ==="
for VM in vm1 vm2 db vm-api dns-server client-onprem vm-spoke vm-api-prod vm-db-prod vm-cache-prod dns-onprem; do
    gcloud compute instances delete $VM --zone=europe-west1-b --quiet 2>/dev/null
done

echo "=== Suppression des politiques DNS ==="
for POLICY in policy-inbound policy-dns-full policy-prod; do
    gcloud dns policies delete $POLICY --quiet 2>/dev/null
done

echo "=== Suppression des zones DNS ==="
for ZONE in zone-lab-internal zone-public-lab zone-forward-corp zone-services \
            peering-to-hub zone-split-public zone-split-private zone-prod-internal \
            zone-corp-public zone-corp-private; do
    # Supprimer les enregistrements (sauf SOA et NS)
    for RS in $(gcloud dns record-sets list --zone=$ZONE \
                --format="csv[no-heading](name,type)" 2>/dev/null | grep -v "SOA\|NS"); do
        NAME=$(echo $RS | cut -d',' -f1)
        TYPE=$(echo $RS | cut -d',' -f2)
        gcloud dns record-sets delete "$NAME" --zone=$ZONE --type=$TYPE --quiet 2>/dev/null
    done
    gcloud dns managed-zones delete $ZONE --quiet 2>/dev/null
done

echo "=== Suppression des health checks ==="
gcloud compute health-checks delete hc-dns-wrr --quiet 2>/dev/null

echo "=== Suppression des règles de pare-feu ==="
for VPC in vpc-dns-lab vpc-hub vpc-spoke vpc-prod-dns; do
    for RULE in $(gcloud compute firewall-rules list \
                  --filter="network:$VPC" --format="get(name)" 2>/dev/null); do
        gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null
    done
done

echo "=== Suppression des sous-réseaux ==="
for SUBNET in subnet-dns subnet-onprem subnet-hub subnet-spoke subnet-prod subnet-onprem-sim; do
    gcloud compute networks subnets delete $SUBNET \
        --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression des VPCs ==="
for VPC in vpc-dns-lab vpc-hub vpc-spoke vpc-prod-dns; do
    gcloud compute networks delete $VPC --quiet 2>/dev/null
done

echo "=== Nettoyage terminé ==="
```

---

## Annexe : Commandes essentielles du Module 6

### Zones DNS
```bash
# Créer zone privée
gcloud dns managed-zones create NAME --dns-name="domain." --visibility=private --networks=VPC

# Créer zone publique
gcloud dns managed-zones create NAME --dns-name="domain." --visibility=public

# Zone de forwarding
gcloud dns managed-zones create NAME --dns-name="domain." --visibility=private --networks=VPC --forwarding-targets="IP1,IP2"

# Peering DNS
gcloud dns managed-zones create NAME --dns-name="domain." --visibility=private --networks=VPC --target-network=TARGET_VPC
```

### Enregistrements
```bash
# Créer enregistrement
gcloud dns record-sets create "name.domain." --zone=ZONE --type=TYPE --ttl=TTL --rrdatas="DATA"

# Lister
gcloud dns record-sets list --zone=ZONE

# Supprimer
gcloud dns record-sets delete "name.domain." --zone=ZONE --type=TYPE
```

### Politiques
```bash
# Créer politique
gcloud dns policies create NAME --networks=VPC --enable-inbound-forwarding --enable-logging

# Lister
gcloud dns policies list
```

### DNSSEC
```bash
# Activer
gcloud dns managed-zones update ZONE --dnssec-state=on

# Voir les clés
gcloud dns dns-keys list --zone=ZONE
```
