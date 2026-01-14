# Instructions pour les Apprenants
## Formation GCP Networking

---

## Bienvenue ! 👋

Vous avez été invité à participer à la formation **GCP Networking**. Ce document contient toutes les informations nécessaires pour accéder à l'environnement de lab.

---

## 1. Prérequis

### Compte Google
Vous devez avoir un compte Google (Gmail ou Google Workspace) correspondant à l'email avec lequel vous avez été invité.

- **Email invité** : `votre-email@gmail.com`
- Si vous n'avez pas de compte Google, créez-en un sur [accounts.google.com](https://accounts.google.com)

### Navigateur
Utilisez un navigateur moderne :
- Google Chrome (recommandé)
- Mozilla Firefox
- Microsoft Edge

### Installation de gcloud CLI (optionnel mais recommandé)

#### Windows
```powershell
# Télécharger l'installeur depuis :
# https://cloud.google.com/sdk/docs/install
# Exécuter GoogleCloudSDKInstaller.exe
```

#### macOS
```bash
brew install google-cloud-sdk
```

#### Linux (Debian/Ubuntu)
```bash
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install google-cloud-cli
```

---

## 2. Accès au projet

### Via la Console Web

1. Ouvrez [console.cloud.google.com](https://console.cloud.google.com)

2. Connectez-vous avec votre compte Google invité

3. Sélectionnez le projet de formation :
   - Cliquez sur le sélecteur de projet en haut
   - Cherchez : `formation-gcp-networking-2025`
   - Cliquez dessus pour le sélectionner

4. Vous devriez voir le tableau de bord du projet

### Via gcloud CLI

```bash
# Authentification
gcloud auth login

# Configurer le projet
gcloud config set project formation-gcp-networking-2025

# Vérifier
gcloud config list
```

---

## 3. Règles importantes ⚠️

### Ce que vous POUVEZ faire
✅ Créer des VMs, VPCs, sous-réseaux, règles de pare-feu  
✅ Configurer des Load Balancers, Cloud NAT, VPN  
✅ Créer des zones DNS  
✅ Activer VPC Flow Logs, Cloud Monitoring  
✅ Exécuter tous les labs de la formation  

### Ce que vous NE POUVEZ PAS faire
❌ Modifier les paramètres du projet (IAM, facturation)  
❌ Créer des VMs avec des types de machines très coûteux (GPU, etc.)  
❌ Supprimer ou modifier les ressources d'autres apprenants  
❌ Inviter d'autres utilisateurs  

### Bonnes pratiques obligatoires

1. **Nommez vos ressources avec votre prénom**
   ```bash
   # Exemple
   gcloud compute networks create vpc-ali-lab1
   gcloud compute instances create vm-ali-web
   ```

2. **Supprimez vos ressources à la fin de chaque session**
   ```bash
   # Supprimer une VM
   gcloud compute instances delete vm-ali-web --zone=europe-west1-b
   
   # Supprimer un VPC (après avoir supprimé les sous-réseaux)
   gcloud compute networks delete vpc-ali-lab1
   ```

3. **Ne laissez pas de ressources tourner la nuit**
   - Les VMs qui tournent = des coûts
   - Arrêtez ou supprimez à la fin de chaque journée

4. **Utilisez des types de machines économiques**
   - `e2-micro` : Pour les tests simples
   - `e2-small` : Pour les labs standard
   - `e2-medium` : Maximum recommandé

---

## 4. Régions et zones

### Région principale
- **Région** : `europe-west1` (Belgique)
- **Zones** : `europe-west1-b`, `europe-west1-c`, `europe-west1-d`

### Configuration par défaut
```bash
# Configurer la région et zone par défaut
gcloud config set compute/region europe-west1
gcloud config set compute/zone europe-west1-b
```

---

## 5. Premiers pas

### Créer votre première VM
```bash
# Remplacez VOTRE_PRENOM par votre prénom
gcloud compute instances create vm-VOTRE_PRENOM-test \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --image-family=debian-11 \
    --image-project=debian-cloud
```

### Se connecter à la VM
```bash
# Via SSH
gcloud compute ssh vm-VOTRE_PRENOM-test --zone=europe-west1-b

# Ou via IAP (si pas d'IP publique)
gcloud compute ssh vm-VOTRE_PRENOM-test --zone=europe-west1-b --tunnel-through-iap
```

### Supprimer la VM
```bash
gcloud compute instances delete vm-VOTRE_PRENOM-test --zone=europe-west1-b
```

---

## 6. Structure des labs

Les labs sont organisés par module :

```
Module 1  : Rappels TCP/IP
Module 2  : Fondamentaux VPC
Module 3  : Routage et Adressage
Module 4  : Partage de réseaux VPC
Module 5  : Options de connexion privée
Module 6  : Cloud DNS
Module 7  : Connectivité hybride
Module 8  : Sécurité réseau
Module 9  : Protection DDoS et Cloud Armor
Module 10 : Équilibrage de charge
Module 11 : Surveillance et journalisation
```

### Convention de nommage pour les labs
```
vpc-PRENOM-moduleX-labY
subnet-PRENOM-moduleX-labY
vm-PRENOM-moduleX-labY
fw-PRENOM-moduleX-labY
```

Exemple pour Ali, Module 2, Lab 3 :
```
vpc-ali-m2-l3
subnet-ali-m2-l3
vm-ali-m2-l3-web
```

---

## 7. Commandes utiles

### Lister vos ressources
```bash
# VMs
gcloud compute instances list --filter="name~VOTRE_PRENOM"

# VPCs
gcloud compute networks list --filter="name~VOTRE_PRENOM"

# Règles de pare-feu
gcloud compute firewall-rules list --filter="name~VOTRE_PRENOM"
```

### Supprimer toutes vos ressources d'un lab
```bash
# Exemple : supprimer tout ce qui contient "ali-m2-l3"
# VMs d'abord
gcloud compute instances list --filter="name~ali-m2-l3" --format="get(name,zone)" | \
    while read name zone; do
        gcloud compute instances delete $name --zone=$zone --quiet
    done

# Puis les règles de pare-feu
gcloud compute firewall-rules list --filter="name~ali-m2-l3" --format="get(name)" | \
    xargs -I {} gcloud compute firewall-rules delete {} --quiet

# Puis les sous-réseaux
gcloud compute networks subnets list --filter="name~ali-m2-l3" --format="get(name,region)" | \
    while read name region; do
        gcloud compute networks subnets delete $name --region=$region --quiet
    done

# Enfin les VPCs
gcloud compute networks list --filter="name~ali-m2-l3" --format="get(name)" | \
    xargs -I {} gcloud compute networks delete {} --quiet
```

---

## 8. Dépannage

### "Permission denied"
- Vérifiez que vous utilisez le bon compte Google
- Vérifiez que vous êtes sur le bon projet

```bash
# Vérifier le compte actif
gcloud auth list

# Vérifier le projet
gcloud config get-value project
```

### "Quota exceeded"
- Vous avez atteint une limite de ressources
- Supprimez des ressources inutilisées
- Contactez le formateur si nécessaire

### "Resource already exists"
- Une ressource avec ce nom existe déjà
- Utilisez un nom différent ou supprimez l'existante

### Impossible de se connecter en SSH
```bash
# Essayer via IAP
gcloud compute ssh VM_NAME --zone=ZONE --tunnel-through-iap

# Vérifier les règles de pare-feu
gcloud compute firewall-rules list --filter="name~allow-ssh"
```

---

## 9. Contacts

### Formateur
- **Nom** : Ali Koudri
- **Email** : [ali.koudri@gmail.com]

### En cas de problème technique
1. Vérifiez d'abord cette documentation
2. Consultez [cloud.google.com/docs](https://cloud.google.com/docs)
3. Contactez le formateur

---

## 10. Ressources utiles

### Documentation officielle
- [Documentation GCP Networking](https://cloud.google.com/vpc/docs)
- [Référence gcloud](https://cloud.google.com/sdk/gcloud/reference)

### Tarification
- [Calculateur de prix](https://cloud.google.com/products/calculator)
- [Types de machines Compute Engine](https://cloud.google.com/compute/docs/machine-types)

### Raccourcis Console
- Console : `console.cloud.google.com`
- VPC : `console.cloud.google.com/networking/networks`
- VMs : `console.cloud.google.com/compute/instances`
- Firewall : `console.cloud.google.com/networking/firewalls`

---

**Bonne formation ! 🚀**
