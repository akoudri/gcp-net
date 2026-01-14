# Module 8 - Contrôle d'Accès et Sécurité Réseau
## Corrigé des Questions et du Quizz

---

# Corrigé des Questions des Labs

## Lab 8.2 : Règles de pare-feu VPC

### Exercice 8.2.4

**Q1 : Pourquoi utiliser des priorités différentes (500 vs 1000) ?**

> Les priorités différentes permettent de **contrôler l'ordre d'évaluation** des règles :
>
> - **Priorité 500 (plus haute)** : Les règles DENY sont évaluées en premier
> - **Priorité 1000 (plus basse)** : Les règles ALLOW sont évaluées après
>
> Avantages de cette stratégie :
> 1. Les blocages de sécurité sont toujours appliqués en premier
> 2. Impossible de créer une règle ALLOW qui contourne un DENY important
> 3. Structure claire : deny=100-500, allow=1000+
>
> Exemple :
> ```
> Règle 1 (priorité 500): DENY tcp:23 from 0.0.0.0/0
> Règle 2 (priorité 1000): ALLOW tcp:23 from 10.0.0.0/8
> 
> Résultat: Telnet depuis Internet bloqué, mais Telnet interne autorisé
> (car 10.0.0.0/8 ne matche pas 0.0.0.0/0 dans la règle deny)
> ```

**Q2 : Que se passe-t-il si deux règles ont la même priorité mais des actions différentes ?**

> Si deux règles ont la **même priorité** et des actions différentes :
>
> - GCP ne garantit PAS l'ordre d'évaluation entre elles
> - Le comportement peut être **imprévisible**
> - C'est une **mauvaise pratique** à éviter
>
> Recommandations :
> - Toujours utiliser des priorités distinctes
> - Documenter la stratégie de priorités
> - Utiliser des plages réservées (deny: 100-500, allow: 1000+)
>
> Note technique : GCP évalue les règles de la plus haute priorité (nombre le plus bas) à la plus basse. La première règle qui matche est appliquée, les suivantes sont ignorées.

---

## Lab 8.3 : Tags réseau vs Service Accounts

### Pourquoi les Service Accounts sont plus sécurisés ?

> Les Service Accounts offrent une **sécurité renforcée** par rapport aux tags car :
>
> | Aspect | Tags | Service Accounts |
> |--------|------|------------------|
> | Modification | Quiconque peut éditer la VM | Nécessite roles/iam.serviceAccountUser |
> | Contrôle IAM | Non | Oui |
> | Audit | Non | Oui (Cloud Audit Logs) |
> | Identité | Simple label | Identité forte |
>
> Scénario de risque avec les tags :
> ```
> 1. Un développeur a accès à vm-web
> 2. Il exécute: gcloud compute instances add-tags vm-web --tags=db
> 3. La VM a maintenant le tag "db"
> 4. Les règles basées sur le tag "db" s'appliquent
> 5. VIOLATION: La VM web peut recevoir du trafic destiné aux DB
> ```
>
> Avec Service Accounts, cette attaque est impossible car :
> - Le changement de SA nécessite un rôle IAM spécifique
> - La modification est auditée
> - Une seule identité par VM

---

## Lab 8.5 : Hierarchical Firewall Policies

### Quand utiliser GOTO_NEXT ?

> L'action **GOTO_NEXT** est utilisée pour **déléguer des décisions** aux niveaux inférieurs :
>
> Cas d'usage :
>
> 1. **Délégation contrôlée**
>    - L'organisation définit les règles obligatoires (deny)
>    - Les dossiers/projets décident pour certains protocoles
>
> 2. **Exceptions par département**
>    - Règle org: GOTO_NEXT pour HTTP
>    - Dossier Prod: DENY HTTP (pas de web exposé)
>    - Dossier Dev: ALLOW HTTP (pour les tests)
>
> 3. **Politique deny-by-default avec exceptions**
>    ```
>    Org: DENY all (priorité 65000)
>    Org: GOTO_NEXT pour tcp:443 (priorité 1000)
>    Projet: ALLOW tcp:443 pour certaines VMs
>    ```
>
> Important : GOTO_NEXT ne décide pas, il **passe la main** au niveau suivant.

---

## Lab 8.7 : IAP pour TCP

### Avantages de l'approche "bastionless"

> L'accès via IAP élimine le besoin de serveurs bastion :
>
> **Avec bastion traditionnel** :
> ```
> Internet → Bastion (IP publique) → VM cible (IP privée)
> 
> Problèmes:
> - Le bastion est une cible d'attaque
> - Nécessite maintenance et patching
> - Coût du serveur
> - Gestion des accès sur le bastion
> ```
>
> **Avec IAP** :
> ```
> Utilisateur → IAP (Google) → VM cible (IP privée)
> 
> Avantages:
> - Pas de serveur à gérer
> - Authentification IAM
> - Audit trail complet
> - Pas d'IP publique sur les VMs
> - Protection contre les scans de ports
> ```
>
> Configuration requise :
> - Règle pare-feu : ALLOW tcp:22 FROM 35.235.240.0/20
> - Rôle IAM : roles/iap.tunnelResourceAccessor

---

## Lab 8.8 : Cloud IDS

### Différence entre IDS et IPS

> | Aspect | IDS (Détection) | IPS (Prévention) |
> |--------|-----------------|------------------|
> | Action | Détecte et alerte | Détecte et bloque |
> | Impact trafic | Aucun (copie) | Inline (peut bloquer) |
> | Réponse | Manuelle | Automatique |
> | Faux positifs | Non bloquants | Peuvent bloquer du trafic légitime |
> | Déploiement | Plus sûr | Plus risqué |
>
> Cloud IDS (GCP) :
> - Mode **détection uniquement**
> - Utilise la technologie Palo Alto Networks
> - Analyse une copie du trafic (packet mirroring)
> - Les alertes remontent dans Cloud Logging et Security Command Center
>
> Pour le blocage automatique : utiliser **Cloud NGFW avec IPS**
> - Ajoute la prévention d'intrusion
> - Action apply_security_profile_group dans les firewall policies
> - Recommandation : commencer en mode Alert, puis passer en Deny

---

# Corrigé du Quizz du Module 8

**1. Dans quel ordre sont évaluées les politiques de pare-feu ?**
- a. VPC Rules → Global Policies → Hierarchical
- **b. Hierarchical → Global Policies → VPC Rules** ✅
- c. Global Policies → Hierarchical → VPC Rules

> L'ordre d'évaluation est :
>
> ```
> 1. Hierarchical Firewall Policies (Organisation/Dossier)
>        ↓
> 2. Global Network Firewall Policies
>        ↓
> 3. Regional Network Firewall Policies
>        ↓
> 4. VPC Firewall Rules
> ```
>
> Cet ordre garantit que les politiques de sécurité de l'organisation sont appliquées en premier et ne peuvent pas être contournées par les projets.

---

**2. Quelle action permet de déléguer la décision au niveau inférieur ?**

> L'action **GOTO_NEXT** permet de déléguer la décision au niveau inférieur.
>
> ```bash
> gcloud compute firewall-policies rules create 1000 \
>     --firewall-policy=org-policy \
>     --action=goto_next \
>     --layer4-configs=tcp:80,tcp:443 \
>     --description="Déléguer HTTP/HTTPS aux niveaux inférieurs"
> ```
>
> Comportement :
> - `allow` : Autorise et ARRÊTE l'évaluation
> - `deny` : Bloque et ARRÊTE l'évaluation
> - `goto_next` : CONTINUE l'évaluation au niveau suivant
> - `apply_security_profile_group` : Applique l'inspection IDS/IPS

---

**3. Quelle est la différence entre IDS et IPS ?**

> | IDS | IPS |
> |-----|-----|
> | **Intrusion Detection System** | **Intrusion Prevention System** |
> | Détecte et alerte | Détecte et bloque |
> | Passif (copie du trafic) | Actif (inline) |
> | Pas d'impact sur le trafic | Peut bloquer du trafic |
> | Réponse manuelle requise | Réponse automatique |
>
> Cloud IDS = Détection uniquement
> Cloud NGFW = Détection + Prévention

---

**4. Les VPC Firewall Rules sont-elles stateful ou stateless ?**

> Les VPC Firewall Rules sont **stateful**.
>
> Cela signifie :
> - Si vous autorisez le trafic entrant, le trafic retour est automatiquement autorisé
> - Pas besoin de créer une règle pour les réponses
>
> Exemple :
> ```
> Règle: ALLOW tcp:80 INGRESS
> 
> Client → VM (tcp:80) : Autorisé par la règle
> VM → Client (réponse) : Autorisé automatiquement (stateful)
> ```
>
> Note : Les connexions sont suivies dans une table d'état pendant ~10 minutes d'inactivité.

---

**5. Quel mécanisme Cloud IDS utilise-t-il pour analyser le trafic ?**

> Cloud IDS utilise le **Packet Mirroring** pour analyser le trafic.
>
> Fonctionnement :
> 1. Le trafic réseau est **copié** (mirrored)
> 2. La copie est envoyée à l'endpoint Cloud IDS
> 3. L'endpoint analyse le trafic avec les signatures Palo Alto
> 4. Les alertes sont générées dans Cloud Logging
>
> Avantages du mirroring :
> - Pas d'impact sur le trafic de production
> - Pas de latence ajoutée
> - Analyse complète des paquets

---

**6. Citez deux avantages d'utiliser les Service Accounts plutôt que les tags.**

> Avantages des Service Accounts :
>
> 1. **Contrôle IAM** : La modification du SA d'une VM nécessite le rôle `roles/iam.serviceAccountUser`, contrairement aux tags modifiables par quiconque peut éditer la VM.
>
> 2. **Audit trail** : Tous les changements de Service Account sont enregistrés dans Cloud Audit Logs, permettant la traçabilité.
>
> Autres avantages :
> - Identité forte (vs simple label)
> - Non modifiable par les développeurs
> - Intégration avec les autres contrôles IAM

---

**7. Quel service permet de filtrer le trafic HTTP/HTTPS sortant ?**

> **Secure Web Proxy (SWP)** permet de filtrer le trafic HTTP/HTTPS sortant.
>
> Fonctionnalités :
> - Filtrage par URL et domaine
> - Inspection TLS (décryptage/re-cryptage)
> - Politiques basées sur l'identité
> - Intégration avec Cloud Logging
>
> Cas d'usage :
> - Contrôler l'accès Internet des VMs
> - Bloquer les sites non autorisés
> - Prévenir l'exfiltration de données
> - Conformité et audit

---

**8. Quelle est la priorité de la règle implicite "deny all ingress" ?**

> La règle implicite "deny all ingress" a la priorité **65535**.
>
> ```
> Règles implicites (non visibles):
> ┌──────────────────────────────────────────────────┐
> │ Deny all ingress  │ Priorité: 65535 │ Implicite │
> │ Allow all egress  │ Priorité: 65535 │ Implicite │
> └──────────────────────────────────────────────────┘
> ```
>
> Caractéristiques :
> - Ces règles ne peuvent pas être supprimées
> - Elles peuvent être "overridées" par des règles de priorité plus haute (nombre plus bas)
> - Plage de priorités utilisables : 0 à 65534

---

# Questions de réflexion supplémentaires

**Q1 : Comment implémenter une architecture "Zero Trust" dans GCP ?**

> Architecture Zero Trust dans GCP :
>
> 1. **Identité forte** :
>    - Utiliser Service Accounts pour les VMs
>    - Authentification IAP pour les accès admin
>    - Pas de confiance basée sur le réseau
>
> 2. **Micro-segmentation** :
>    - Règles de pare-feu par Service Account
>    - Deny all par défaut, allow explicite
>    - Segmentation par workload
>
> 3. **Inspection du trafic** :
>    - Cloud IDS pour la détection
>    - VPC Flow Logs pour la visibilité
>    - Secure Web Proxy pour l'egress
>
> 4. **Accès conditionnel** :
>    - VPC Service Controls
>    - Context-Aware Access
>    - BeyondCorp Enterprise
>
> 5. **Chiffrement** :
>    - TLS partout
>    - CMEK pour les données
>    - Chiffrement en transit (mTLS)

---

**Q2 : Comment auditer efficacement les règles de pare-feu ?**

> Stratégie d'audit des règles de pare-feu :
>
> 1. **Inventaire des règles** :
>    ```bash
>    gcloud compute firewall-rules list --format=json > firewall-audit.json
>    ```
>
> 2. **Identifier les règles risquées** :
>    - Règles avec source 0.0.0.0/0
>    - Règles sans description
>    - Règles utilisant des tags (vs SA)
>    - Règles sans logging
>
> 3. **Analyse des logs** :
>    ```bash
>    gcloud logging read 'resource.type="gce_subnetwork"' --limit=1000
>    ```
>
> 4. **Vérification de conformité** :
>    - Comparer avec la politique de sécurité
>    - Identifier les écarts
>    - Documenter les exceptions
>
> 5. **Automatisation** :
>    - Utiliser Forseti ou Cloud Asset Inventory
>    - Créer des alertes sur les modifications
>    - Intégrer dans la CI/CD

---

**Q3 : Quelle est la stratégie recommandée pour les règles de pare-feu ?**

> Stratégie recommandée :
>
> ```
> ┌────────────────────────────────────────────────────────────────────┐
> │                  STRATÉGIE DE PARE-FEU                            │
> ├────────────────────────────────────────────────────────────────────┤
> │                                                                    │
> │  1. DENY BY DEFAULT                                               │
> │     - Créer des règles deny-all avec priorité 65000               │
> │     - Forcer l'autorisation explicite                             │
> │                                                                    │
> │  2. STRUCTURE DES PRIORITÉS                                       │
> │     - 100-500: Règles DENY critiques                              │
> │     - 1000-2000: Règles ALLOW standard                            │
> │     - 65000: Règles deny-all par défaut                           │
> │                                                                    │
> │  3. UTILISER SERVICE ACCOUNTS                                     │
> │     - Pas de tags en production                                   │
> │     - Un SA par tier/fonction                                     │
> │                                                                    │
> │  4. LOGGING SYSTÉMATIQUE                                          │
> │     - Activer sur toutes les règles critiques                     │
> │     - Analyser régulièrement                                      │
> │                                                                    │
> │  5. DOCUMENTATION                                                 │
> │     - Description claire sur chaque règle                         │
> │     - Propriétaire identifié                                      │
> │     - Date de création/révision                                   │
> │                                                                    │
> └────────────────────────────────────────────────────────────────────┘
> ```

---

**Q4 : Comment gérer les faux positifs avec Cloud IDS ?**

> Gestion des faux positifs Cloud IDS :
>
> 1. **Phase d'observation** :
>    - Déployer en mode INFORMATIONAL
>    - Collecter les alertes pendant 2-4 semaines
>    - Identifier les patterns récurrents
>
> 2. **Analyse des alertes** :
>    - Classifier : vrai positif vs faux positif
>    - Documenter le contexte de chaque type
>    - Impliquer les équipes applicatives
>
> 3. **Tuning** :
>    - Ajuster le niveau de sévérité (INFORMATIONAL → LOW → MEDIUM)
>    - Exclure les plages IP de confiance si nécessaire
>    - Filtrer les signatures bruyantes
>
> 4. **Escalade progressive** :
>    - Commencer avec sévérité INFORMATIONAL
>    - Passer à MEDIUM après validation
>    - Ne pas aller directement à CRITICAL
>
> 5. **Documentation** :
>    - Maintenir une liste des faux positifs connus
>    - Procédure de traitement des alertes
>    - SLA de réponse par sévérité

---

**Q5 : Comment sécuriser l'accès à une base de données sans IP publique ?**

> Architecture sécurisée pour une base de données :
>
> ```
> ┌─────────────────────────────────────────────────────────────────┐
> │                                                                 │
> │   Application (SA: sa-app)                                     │
> │         │                                                       │
> │         │ tcp:5432 (autorisé par règle pare-feu)               │
> │         ▼                                                       │
> │   Database (SA: sa-db, pas d'IP publique)                      │
> │         │                                                       │
> │         │ Cloud SQL Auth Proxy (optionnel)                      │
> │         ▼                                                       │
> │   Cloud SQL (Private IP via PSA)                               │
> │                                                                 │
> │   Accès admin:                                                 │
> │   - Via IAP (gcloud sql connect --tunnel-through-iap)          │
> │   - Ou via VM bastion dans le même VPC                         │
> │                                                                 │
> └─────────────────────────────────────────────────────────────────┘
> ```
>
> Mesures de sécurité :
> 1. Pas d'IP publique sur la DB
> 2. Règles pare-feu basées sur Service Accounts
> 3. Private Services Access pour Cloud SQL
> 4. Accès admin via IAP ou bastion
> 5. Chiffrement au repos et en transit
> 6. Cloud Audit Logs activés
