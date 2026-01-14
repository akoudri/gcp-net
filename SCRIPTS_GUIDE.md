# Guide des Scripts GCP Networking Training

## 🎯 Accès Rapide

Les scripts d'exercices sont maintenant disponibles dans le dossier [scripts/](scripts/).

### ✅ TOUS LES MODULES COMPLÉTÉS (429 scripts)

| Module | Nom | Scripts | Documentation |
|--------|-----|---------|--------------|
| 1 | TCP/IP Fundamentals | 24 | [Liste](scripts/module1/LIST.md) |
| 2 | VPC Fundamentals | 34 | [Liste](scripts/module2/LIST.md) |
| 3 | Routing and Addressing | 47 | [Liste](scripts/module3/LIST.md) |
| 4 | VPC Sharing | 42 | [Liste](scripts/module4/LIST.md) |
| 5 | Private Connectivity | 44 | [Liste](scripts/module5/LIST.md) |
| 6 | Cloud DNS | 60 | [Liste](scripts/module6/LIST.md) |
| 7 | Hybrid Connectivity | 29 | [Liste](scripts/module7/LIST.md) |
| 8 | Network Security | 34 | [Liste](scripts/module8/LIST.md) |
| 9 | DDoS Protection and Cloud Armor | 39 | [Liste](scripts/module9/LIST.md) |
| 10 | Load Balancing | 42 | [Liste](scripts/module10/LIST.md) |
| 11 | Monitoring and Logging | 34 | [Liste](scripts/module11/LIST.md) |

**TOTAL : 429 scripts pour 11 modules complets**

## 📚 Documentation

- **[scripts/README.md](scripts/README.md)** : Documentation complète sur l'organisation et l'utilisation des scripts
- **[scripts/SUMMARY.md](scripts/SUMMARY.md)** : Résumé détaillé de la refactorisation avec détails par module
- **[scripts/moduleX/LIST.md](scripts/)** : Liste exhaustive des scripts de chaque module

## 🚀 Démarrage Rapide

### Exécuter un exercice

```bash
# 1. Naviguer vers le module
cd scripts/module2

# 2. Exécuter un script
./lab2.1_ex1_explore-default-vpc.sh

# 3. Suivre la séquence du lab
./lab2.1_ex2_audit-firewall-rules.sh
./lab2.1_ex3_create-test-vm.sh
./lab2.1_ex4_cleanup-default-vpc.sh
```

### Nettoyer les ressources

```bash
# Nettoyage complet d'un module
cd scripts/module2
./cleanup-module2.sh
```

## 📖 Convention de Nommage

Format : `labX.Y_exN_description-courte.sh`

**Exemples :**
- `lab2.1_ex1_explore-default-vpc.sh` - Lab 2.1, Exercice 1
- `lab3.5_ex3_configure-cloud-nat.sh` - Lab 3.5, Exercice 3
- `lab7.2_ex4_test-vpn-connectivity.sh` - Lab 7.2, Exercice 4
- `cleanup-moduleX.sh` - Script de nettoyage du module

## 💡 Utilisation dans les Labs

Les fichiers markdown des labs peuvent être mis à jour avec des références aux scripts :

**Exemple :**

```markdown
#### Exercice 2.1.1 : Explorer le VPC default

**💡 Script disponible** : [lab2.1_ex1_explore-default-vpc.sh](scripts/module2/lab2.1_ex1_explore-default-vpc.sh)

```bash
# Exécuter le script
./scripts/module2/lab2.1_ex1_explore-default-vpc.sh
```

<details>
<summary>Ou exécuter manuellement les commandes :</summary>

```bash
# Commandes manuelles ici...
```
</details>
```

## ✨ Avantages

1. **Plus de copier-coller** : Scripts prêts à l'emploi
2. **Répétabilité** : Exécution cohérente
3. **Code propre** : Commenté et structuré
4. **Nettoyage facile** : Scripts de cleanup automatiques
5. **Progression claire** : Numérotation suivant le cours

## 📂 Structure d'un Script Type

```bash
#!/bin/bash
# Lab X.Y - Exercice X.Y.Z : Titre
# Objectif : Description

set -e

echo "=== Lab X.Y - Exercice Z : Titre ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)

# Commandes gcloud
gcloud compute networks create ...

echo ""
echo "Questions à considérer :"
echo "1. Question pédagogique..."
```

## 📊 Détail par Module

### Module 1 - TCP/IP Fundamentals (24 scripts)
- Exploration des interfaces réseau
- Analyse de paquets avec Wireshark
- Protocoles TCP/IP, DNS, DHCP
- Simulation avec Packet Tracer

### Module 2 - VPC Fundamentals (34 scripts)
- VPC default et risques de sécurité
- VPC custom multi-régions
- Planification IP et plages secondaires
- VMs multi-NIC (appliances réseau)
- Network Tiers (Premium vs Standard)
- Modes de routage (régional vs global)

### Module 3 - Routing and Addressing (47 scripts)
- Routes système et table de routage
- Routes statiques et priorités
- Cloud Router et BGP
- Cloud NAT
- Private Google Access
- Cloud DNS (zones privées, publiques, forwarding)

### Module 4 - VPC Sharing (42 scripts)
- VPC Peering (configuration, transitivité)
- Export de routes personnalisées
- Shared VPC (host/service projects)
- IAM pour Shared VPC
- Architecture hub-and-spoke

### Module 5 - Private Connectivity (44 scripts)
- Private Google Access
- Private Service Access (PSA)
- Private Service Connect (PSC)
- Cloud SQL et Redis avec connectivité privée
- Service Attachments

### Module 6 - Cloud DNS (60 scripts)
- Zones DNS privées et publiques
- DNS Forwarding (outbound/inbound)
- DNS Peering
- Split-horizon DNS
- DNSSEC
- Routing policies (geolocation, weighted)

### Module 7 - Hybrid Connectivity (29 scripts)
- Cloud VPN (HA VPN, Classic VPN)
- Cloud Interconnect (Dedicated, Partner)
- Architecture hybride on-premises/cloud
- Routage BGP avec on-premises

### Module 8 - Network Security (34 scripts)
- Firewall rules hiérarchiques
- VPC Service Controls
- Cloud IDS/IPS
- Packet Mirroring
- SSL Policies
- Security Command Center

### Module 9 - DDoS Protection and Cloud Armor (39 scripts)
- Cloud Armor configuration
- WAF rules et policies
- Rate limiting et adaptive protection
- DDoS protection
- Bot management
- Logging et monitoring

### Module 10 - Load Balancing (42 scripts)
- HTTP(S) Load Balancer (Global, Regional)
- TCP/UDP Load Balancer
- Internal Load Balancer
- Backend services et health checks
- CDN integration
- Traffic management

### Module 11 - Monitoring and Logging (34 scripts)
- VPC Flow Logs
- Firewall Logs
- Cloud Logging et Cloud Monitoring
- Network Intelligence Center
- Performance Dashboard
- Alerting et dashboards

## 🧹 Scripts de Nettoyage

Chaque module dispose d'un script `cleanup-moduleX.sh` qui :
- Supprime toutes les ressources créées dans le module
- Respecte l'ordre de dépendances GCP
- Demande confirmation avant suppression
- Affiche un résumé des ressources supprimées

## 🔗 Liens Utiles

- **Documentation GCP** : https://cloud.google.com/vpc/docs
- **gcloud CLI Reference** : https://cloud.google.com/sdk/gcloud/reference

---

**Créé le** : Janvier 2026  
**Version** : 2.0 - COMPLET  
**Total** : 429 scripts pour 11 modules
