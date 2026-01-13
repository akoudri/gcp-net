# Extra Lab : Activer le Dual-Stack et communiquer en IPv6

## Objectifs

À la fin de ce lab, vous serez capable de :

- Comprendre le concept de Dual-Stack (IPv4 + IPv6)
- Activer IPv6 sur un VPC et un subnet
- Créer des VMs avec des adresses IPv6
- Configurer les règles de pare-feu pour IPv6
- Tester la connectivité IPv6 entre VMs

---

## Prérequis

- Accès à un projet GCP avec les droits d'édition
- Cloud Shell ou gcloud CLI configuré
- Connaissances de base sur IPv4 et les VPCs

---

## Contexte

### Qu'est-ce que le Dual-Stack ?

Le Dual-Stack permet à vos ressources d'avoir **simultanément** une adresse IPv4 et une adresse IPv6. Cela facilite la transition vers IPv6 tout en maintenant la compatibilité avec IPv4.

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  VM avec Dual-Stack                                             │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                                                           │  │
│  │  Interface réseau :                                       │  │
│  │  • IPv4 : 10.0.1.5                                        │  │
│  │  • IPv6 : 2600:1900:4000:xxxx::1                          │  │
│  │                                                           │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  La VM peut communiquer en IPv4 ET en IPv6                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Pourquoi IPv6 ?

- Espace d'adressage quasi illimité (340 undécillions d'adresses)
- Épuisement progressif des adresses IPv4
- Simplification du routage
- Requis pour certains services modernes

---

## Architecture cible

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                        VPC "vpc-dual-stack"                                 │
│                        (Dual-Stack activé)                                  │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  Subnet "subnet-dual" (europe-west1)                                  │  │
│  │  IPv4 : 10.0.1.0/24                                                   │  │
│  │  IPv6 : 2600:1900:4000:xxxx::/64 (attribué par Google)                │  │
│  │                                                                       │  │
│  │  ┌─────────────────────┐         ┌─────────────────────┐              │  │
│  │  │       VM-A          │         │       VM-B          │              │  │
│  │  │                     │         │                     │              │  │
│  │  │ IPv4: 10.0.1.10     │◄───────►│ IPv4: 10.0.1.20     │              │  │
│  │  │ IPv6: 2600:...:a    │  ping6  │ IPv6: 2600:...:b    │              │  │
│  │  │                     │         │                     │              │  │
│  │  └─────────────────────┘         └─────────────────────┘              │  │
│  │                                                                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Instructions

### Partie 1 : Préparation de l'environnement

**Tâche 1.1** : Définissez les variables d'environnement pour le lab.

```bash
export PROJECT_ID=$(gcloud config get-value project)
export REGION=europe-west1
export ZONE=europe-west1-b
```

**Tâche 1.2** : Vérifiez que vous êtes dans le bon projet.

```bash
echo "Projet actif : $PROJECT_ID"
```

---

### Partie 2 : Création du VPC Dual-Stack

**Tâche 2.1** : Créez un VPC personnalisé avec le support Dual-Stack.

 Lors de la création du VPC, vous devez spécifier que le mode de routage BGP doit supporter IPv6. Utilisez l'option `--enable-ula-internal-ipv6` pour activer les adresses IPv6 internes.

```bash
gcloud compute networks create vpc-dual-stack \
    --subnet-mode=custom \
    --enable-ula-internal-ipv6
```

**Tâche 2.2** : Vérifiez que le VPC a été créé avec le support IPv6.

```bash
gcloud compute networks describe vpc-dual-stack \
    --format="yaml(name,autoCreateSubnetworks,enableUlaInternalIpv6)"
```

---

### Partie 3 : Création du Subnet Dual-Stack

**Tâche 3.1** : Créez un subnet avec Dual-Stack activé.

> 💡 **Options** :
> - Utilisez `--stack-type=IPV4_IPV6` pour activer le Dual-Stack
> - Utilisez `--ipv6-access-type=INTERNAL` pour des adresses IPv6 internes
> - La plage IPv6 est attribuée automatiquement par Google

```bash
gcloud compute networks subnets create subnet-dual \
    --network=vpc-dual-stack \
    --region=$REGION \
    --range=10.0.1.0/24 \
    --stack-type=IPV4_IPV6 \
    --ipv6-access-type=INTERNAL
```

**Tâche 3.2** : Vérifiez la configuration du subnet et notez la plage IPv6 attribuée.

```bash
gcloud compute networks subnets describe subnet-dual \
    --region=$REGION \
    --format="yaml(name,ipCidrRange,ipv6CidrRange,stackType,ipv6AccessType)"
```

> 📝 **Question** : Quelle est la plage IPv6 attribuée à votre subnet ? Notez-la pour la suite.

---

### Partie 4 : Création des règles de pare-feu

**Tâche 4.1** : Créez une règle pour autoriser le ping (ICMP) en IPv4.

```bash
gcloud compute firewall-rules create allow-icmp-ipv4 \
    --network=vpc-dual-stack \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=icmp \
    --source-ranges=10.0.1.0/24
```

**Tâche 4.2** : Créez une règle pour autoriser le ping (ICMPv6) en IPv6.

Pour IPv6, le protocole ICMP s'appelle `58` (ICMPv6) et vous devez utiliser `--source-ranges` avec la notation IPv6.

```bash
gcloud compute firewall-rules create allow-icmp-ipv6 \
    --network=vpc-dual-stack \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=58 \
    --source-ranges=::/0
```

> 💡 Vous pouvez utiliser `::/0` pour autoriser toutes les sources IPv6, ou être plus restrictif avec la plage de votre subnet.

**Tâche 4.3** : Créez une règle pour autoriser SSH (pour l'administration).

```bash
gcloud compute firewall-rules create allow-ssh-dual \
    --network=vpc-dual-stack \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0
```

---

### Partie 5 : Création des VMs Dual-Stack

**Tâche 5.1** : Créez la première VM (VM-A) avec Dual-Stack.

> 💡 **Option** : Utilisez `--stack-type=IPV4_IPV6` dans la configuration de l'interface réseau.

Complétez la commande :

```bash
gcloud compute instances create vm-a \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network-interface=network=vpc-dual-stack,subnet=subnet-dual,??? \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=dual-stack-vm
```

**Tâche 5.2** : Créez la deuxième VM (VM-B) avec Dual-Stack.

Adaptez la commande précédente pour créer VM-B.

**Tâche 5.3** : Vérifiez que les VMs ont bien des adresses IPv4 et IPv6.

```bash
gcloud compute instances describe vm-a \
    --zone=$ZONE \
    --format="yaml(name,networkInterfaces[].networkIP,networkInterfaces[].ipv6Address)"

gcloud compute instances describe vm-b \
    --zone=$ZONE \
    --format="yaml(name,networkInterfaces[].networkIP,networkInterfaces[].ipv6Address)"
```

> 📝 **Question** : Notez les adresses IPv4 et IPv6 de chaque VM.

| VM | Adresse IPv4 | Adresse IPv6 |
|----|--------------|--------------|
| VM-A | | |
| VM-B | | |

---

### Partie 6 : Test de connectivité IPv6

**Tâche 6.1** : Connectez-vous à VM-A en SSH.

```bash
gcloud compute ssh vm-a --zone=$ZONE
```

**Tâche 6.2** : Depuis VM-A, vérifiez vos adresses IP.

```bash
ip addr show
```

> 📝 **Question** : Identifiez l'interface réseau et ses adresses IPv4 et IPv6.

**Tâche 6.3** : Testez le ping IPv4 vers VM-B.

```bash
ping -c 4 <IPv4_VM_B>
```

Remplacez `<IPv4_VM_B>` par l'adresse IPv4 de VM-B (ex: 10.0.1.20).

**Tâche 6.4** : Testez le ping IPv6 vers VM-B.

```bash
ping6 -c 4 <IPv6_VM_B>
```

Remplacez `<IPv6_VM_B>` par l'adresse IPv6 de VM-B.

> 💡 **Note** : La commande `ping6` est spécifique à IPv6. Sur certains systèmes, vous pouvez aussi utiliser `ping -6`.

**Tâche 6.5** : Quittez la session SSH.

```bash
exit
```

---

### Partie 7 : Exploration supplémentaire

**Tâche 7.1** : Examinez la table de routage IPv6 depuis VM-A.

Reconnectez-vous à VM-A et exécutez :

```bash
ip -6 route show
```

> 📝 **Question** : Quelle est la passerelle par défaut IPv6 ?

**Tâche 7.2** : Testez la résolution DNS IPv6.

```bash
host -t AAAA google.com
```

> 📝 **Question** : Quelle est l'adresse IPv6 de google.com ?

**Tâche 7.3** : Quittez la session SSH.

```bash
exit
```

---

### Partie 8 : Nettoyage

**Tâche 8.1** : Supprimez les ressources créées pendant le lab.

```bash
# Supprimer les VMs
gcloud compute instances delete vm-a vm-b --zone=$ZONE --quiet

# Supprimer les règles de pare-feu
gcloud compute firewall-rules delete allow-icmp-ipv4 allow-icmp-ipv6 allow-ssh-dual --quiet

# Supprimer le subnet
gcloud compute networks subnets delete subnet-dual --region=$REGION --quiet

# Supprimer le VPC
gcloud compute networks delete vpc-dual-stack --quiet
```

**Tâche 8.2** : Vérifiez que toutes les ressources ont été supprimées.

```bash
gcloud compute networks list --filter="name=vpc-dual-stack"
```

---

## Questions de validation

Avant de terminer ce lab, assurez-vous de pouvoir répondre aux questions suivantes :

1. Quelle option permet d'activer IPv6 interne sur un VPC ?

2. Quel est le `stack-type` à utiliser pour activer Dual-Stack sur un subnet ?

3. Quel protocole (numéro) représente ICMPv6 dans les règles de pare-feu ?

4. Quelle commande permet de faire un ping en IPv6 ?

5. Les plages IPv6 sont-elles choisies par l'utilisateur ou attribuées par Google ?

---

## Pour aller plus loin

- Essayez de configurer un accès IPv6 **externe** (`--ipv6-access-type=EXTERNAL`)
- Explorez la connectivité IPv6 vers Internet
- Configurez un Load Balancer avec support IPv6

---

## Ressources

- [Documentation GCP - IPv6](https://cloud.google.com/vpc/docs/using-ipv6)
- [Documentation GCP - Dual-Stack](https://cloud.google.com/compute/docs/ip-addresses/configure-ipv6-address)
- [RFC 8200 - IPv6 Specification](https://tools.ietf.org/html/rfc8200)
