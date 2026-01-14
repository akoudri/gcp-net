# 🎓 Projet de Formation GCP Networking
## Configuration d'un environnement de lab sécurisé

---

## 📋 Vue d'ensemble

Ce kit de scripts permet de configurer un projet GCP partagé pour former des apprenants sur le networking Google Cloud, avec des sécurités intégrées :

- ✅ Rôles personnalisés limités (pas d'accès admin)
- ✅ Budgets et alertes automatiques
- ✅ Script de nettoyage des ressources
- ✅ Documentation pour les apprenants

---

## 📦 Contenu du kit

```
gcp-training-setup/
├── README.md                    # Ce fichier
├── config.env.template          # Template de configuration
├── setup-training-project.sh    # Script de setup principal
├── cleanup-resources.sh         # Script de nettoyage
├── manage-trainees.sh           # Gestion des apprenants
├── check-status.sh              # Vérification du status
└── INSTRUCTIONS_APPRENANTS.md   # Guide pour les apprenants
```

---

## 🚀 Guide de démarrage rapide

### Étape 1 : Prérequis

```bash
# Vérifier que gcloud est installé
gcloud version

# S'authentifier
gcloud auth login

# Trouver votre Billing Account ID
gcloud billing accounts list
```

### Étape 2 : Configuration

```bash
# Copier le template de configuration
cp config.env.template config.env

# Éditer la configuration
nano config.env
```

Remplissez les valeurs :
```bash
PROJECT_ID="formation-gcp-networking-2025"
BILLING_ACCOUNT_ID="XXXXXX-XXXXXX-XXXXXX"  # Votre ID
REGION="europe-west1"
BUDGET_AMOUNT="200"
ALERT_EMAIL="votre-email@example.com"
TRAINEES="apprenant1@gmail.com, apprenant2@gmail.com"
```

### Étape 3 : Exécution du setup

```bash
# Rendre le script exécutable
chmod +x setup-training-project.sh

# Lancer le setup
./setup-training-project.sh
```

### Étape 4 : Configuration manuelle du budget

Après le setup, configurez le budget dans la Console :

1. Allez sur [console.cloud.google.com](https://console.cloud.google.com)
2. Navigation → Facturation → Budgets et alertes
3. Créer un budget pour le projet

---

## 👥 Gestion des apprenants

### Ajouter un apprenant
```bash
./manage-trainees.sh add nouvel-apprenant@gmail.com
```

### Supprimer un apprenant
```bash
./manage-trainees.sh remove ancien-apprenant@gmail.com
```

### Lister les apprenants
```bash
./manage-trainees.sh list
```

---

## 🧹 Nettoyage des ressources

### Nettoyage interactif (avec confirmation)
```bash
./cleanup-resources.sh
```

### Simulation (voir ce qui serait supprimé)
```bash
./cleanup-resources.sh --dry-run
```

### Nettoyage automatique (sans confirmation)
```bash
./cleanup-resources.sh --force
```

### Nettoyer uniquement les ressources d'un apprenant
```bash
./cleanup-resources.sh --prefix=ali-
```

---

## 📊 Vérification du status

```bash
./check-status.sh
```

Affiche :
- État du projet
- Budget consommé
- Nombre de ressources actives
- Apprenants configurés

---

## 💰 Estimation des coûts

### Coûts typiques pour 5 apprenants sur 3 jours

| Ressource | Quantité | Coût estimé |
|-----------|----------|-------------|
| VMs e2-small (8h/jour) | 25 VM-heures/jour | ~10€ |
| VPCs, Subnets, Firewall | Illimité | Gratuit |
| Cloud NAT | 5 instances | ~5€ |
| Load Balancers | 10 forwarding rules | ~15€ |
| VPN Gateways | 5 tunnels | ~10€ |
| Cloud DNS | 10 zones | ~3€ |
| VPC Flow Logs | Modéré | ~5€ |
| **Total estimé (3 jours)** | | **~50-100€** |

### Conseils pour réduire les coûts

1. **Utiliser des VMs e2-micro/small** au lieu de n1-standard
2. **Supprimer les ressources chaque soir** avec le script de cleanup
3. **Éviter les VMs avec GPU**
4. **Désactiver les Flow Logs** après les labs de monitoring

---

## 🔒 Sécurités intégrées

### Rôle personnalisé "Trainee"

Les apprenants ont un rôle limité qui leur permet de :
- ✅ Créer/gérer des VMs, VPCs, sous-réseaux
- ✅ Configurer des Load Balancers, NAT, VPN
- ✅ Gérer Cloud DNS, Cloud Armor
- ✅ Voir les logs et métriques

Mais pas de :
- ❌ Modifier les IAM/permissions
- ❌ Accéder à la facturation
- ❌ Créer des Service Accounts avec privilèges
- ❌ Supprimer le projet

### Budgets et alertes

Le script configure des alertes à :
- 25% du budget
- 50% du budget
- 75% du budget
- 90% du budget
- 100% du budget

### Quotas recommandés

Les quotas par défaut sont généralement suffisants, mais vous pouvez les réduire :

| Quota | Valeur recommandée |
|-------|-------------------|
| CPUs par région | 24 |
| Adresses IP | 10 |
| VPC networks | 10 |
| Firewall rules | 100 |

---

## 🆘 Dépannage

### Erreur "Billing account not found"
```bash
# Vérifier vos comptes de facturation
gcloud billing accounts list

# Vérifier les permissions
gcloud organizations get-iam-policy ORGANIZATION_ID
```

### Erreur "Permission denied" pour un apprenant
```bash
# Vérifier les rôles de l'apprenant
gcloud projects get-iam-policy PROJECT_ID \
    --flatten="bindings[].members" \
    --filter="bindings.members:user:EMAIL"
```

### Ressources non supprimées
Certaines ressources ont des dépendances. Ordre de suppression :
1. Load Balancers (forwarding rules → proxies → url-maps → backend services)
2. VPN (tunnels → gateways)
3. VMs
4. Firewall rules
5. Routes
6. Subnets
7. VPCs

---

## 📚 Ressources

- [Documentation GCP Networking](https://cloud.google.com/vpc/docs)
- [IAM Best Practices](https://cloud.google.com/iam/docs/using-iam-securely)
- [Budget Alerts](https://cloud.google.com/billing/docs/how-to/budgets)

---

## 📝 Licence

Ce kit est fourni pour un usage éducatif dans le cadre de formations GCP.

---

## 🤝 Support

En cas de problème :
1. Consultez la section Dépannage ci-dessus
2. Vérifiez les logs : `gcloud logging read --limit=50`
3. Contactez le formateur
