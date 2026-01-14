# Module 4 - Partage de réseaux VPC
## Corrigé des Questions et du Quizz

---

# Corrigé des Questions des Labs

## Lab 4.1 : VPC Peering - Configuration de base

### Exercice 4.1.3

**Question : Pourquoi le ping échoue-t-il avant le peering ?**

> Le ping échoue car **les deux VPC sont complètement isolés** l'un de l'autre.
> 
> Sans peering :
> - vpc-alpha ne connaît pas les routes vers vpc-beta (10.20.0.0/16)
> - Le paquet vers 10.20.1.10 n'a pas de route correspondante
> - Il est soit abandonné, soit envoyé vers la route par défaut (Internet) où il échoue
> 
> Le message "Network unreachable" indique l'absence de route vers cette destination.

---

### Exercice 4.1.4

**Q1 : Que se passe-t-il si on ne configure le peering que d'un seul côté ?**

> Le peering reste en état **INACTIVE** et aucune connectivité n'est établie.
> 
> Le VPC Peering est **bidirectionnel par conception** mais nécessite une configuration **des deux côtés**. C'est une mesure de sécurité : chaque propriétaire de VPC doit explicitement accepter la connexion.
> 
> Contrairement à une demande d'ami sur un réseau social, le peering ne fonctionne pas tant que les deux parties n'ont pas configuré leur côté.

**Q2 : Quel est le statut du peering avant la configuration bilatérale ?**

> Le statut est **INACTIVE** du côté qui a configuré le peering.
> 
> États possibles :
> - **INACTIVE** : Configuré d'un seul côté, en attente de l'autre
> - **ACTIVE** : Configuré des deux côtés, connexion établie
> 
> Le statut passe automatiquement à ACTIVE dès que le peering réciproque est créé.

---

### Exercice 4.1.5

**Question : Quelles nouvelles routes apparaissent après le peering ?**

> De nouvelles routes de type **"peering"** apparaissent automatiquement :
> 
> Dans vpc-alpha :
> - Route vers 10.20.1.0/24 (subnet-beta) via le peering
> 
> Dans vpc-beta :
> - Route vers 10.10.1.0/24 (subnet-alpha) via le peering
> 
> Ces routes sont créées automatiquement par GCP et ont comme "nextHop" le peering lui-même. Elles permettent au trafic de traverser la connexion de peering.

---

### Exercice 4.1.6

**Q1 : Combien de sauts montre le traceroute ?**

> Généralement **1 seul saut** (la destination directe).
> 
> Le VPC Peering est une connexion **directe** entre les deux VPC. Le trafic ne traverse pas de routeur intermédiaire visible. Le SDN de GCP gère le routage de manière transparente.

**Q2 : Le trafic passe-t-il par Internet ?**

> **Non**, le trafic reste entièrement sur le **réseau interne de Google**.
> 
> Avantages :
> - Latence minimale
> - Bande passante élevée
> - Pas d'exposition sur Internet public
> - Pas de coût de trafic "egress" vers Internet
> 
> C'est une différence majeure avec une connexion VPN entre VPC qui passerait par Internet.

---

## Lab 4.2 : VPC Peering - Options avancées

### Exercice 4.2.4

**Q1 : Pourquoi l'export des routes personnalisées est-il désactivé par défaut ?**

> Pour des raisons de **sécurité et de contrôle** :
> 
> 1. **Principe du moindre privilège** : Par défaut, seules les routes de sous-réseaux sont partagées
> 2. **Éviter les conflits** : Les routes personnalisées pourraient entrer en conflit avec celles du VPC peer
> 3. **Contrôle explicite** : L'administrateur doit consciemment décider de partager ses routes
> 4. **Sécurité** : Empêche l'exposition accidentelle de routes vers des réseaux sensibles (on-premise via VPN)

**Q2 : Dans quel scénario activeriez-vous l'export/import des routes ?**

> Scénarios courants :
> 
> 1. **Connectivité hybride partagée** :
>    - VPC-A a un Cloud VPN vers on-premise
>    - VPC-B a besoin d'accéder à on-premise via ce VPN
>    - Solution : VPC-A exporte ses routes VPN, VPC-B les importe
> 
> 2. **Hub and spoke avec appliances** :
>    - VPC Hub a des routes vers des appliances de sécurité
>    - Les VPC spoke doivent utiliser ces routes
> 
> 3. **Agrégation de routes** :
>    - Partager des routes agrégées entre VPC pour simplifier le routage

---

## Lab 4.3 : VPC Peering - Non-transitivité

### Exercice 4.3.3

**Question : Pourquoi Alpha ne peut-il pas atteindre Gamma alors que Alpha↔Beta et Beta↔Gamma sont peerés ?**

> C'est la **non-transitivité** du VPC Peering :
> 
> ```
> Alpha ←→ Beta ←→ Gamma
>   │               │
>   └───── ✗ ───────┘
> ```
> 
> Explications :
> 1. Le peering Alpha↔Beta partage uniquement les routes **directes** de Alpha et Beta
> 2. Le peering Beta↔Gamma partage uniquement les routes **directes** de Beta et Gamma
> 3. Les routes apprises via un peering **ne sont pas re-propagées** vers un autre peering
> 
> Techniquement :
> - Alpha voit les routes de Beta (10.20.x.x)
> - Alpha ne voit **PAS** les routes de Gamma (10.30.x.x) car Beta ne les re-exporte pas
> - Le paquet vers 10.30.x.x n'a pas de route dans Alpha → échec

---

### Exercice 4.3.4

**Question : Avec 4 VPC en full mesh, combien de peerings faut-il créer ?**

> Avec 4 VPC en full mesh : **12 peerings** au total.
> 
> Calcul :
> - Nombre de connexions bidirectionnelles : n × (n-1) / 2 = 4 × 3 / 2 = 6 connexions
> - Chaque connexion nécessite 2 peerings (un de chaque côté) : 6 × 2 = **12 peerings**
> 
> Ou directement : n × (n-1) = 4 × 3 = 12 peerings
> 
> Par VPC : Chaque VPC a 3 peerings (vers les 3 autres)
> 
> Tableau de croissance :
> | VPC | Peerings/VPC | Total peerings |
> |-----|--------------|----------------|
> | 3 | 2 | 6 |
> | 4 | 3 | 12 |
> | 5 | 4 | 20 |
> | 10 | 9 | 90 |
> | 25 | 24 | 600 |
> | 26 | 25 | 650 ⚠️ Limite atteinte |

---

## Lab 4.4 : Shared VPC - Architecture et rôles IAM

### Exercice 4.4.2

**Résumé des rôles IAM Shared VPC :**

> | Rôle | Responsabilité | Qui l'a typiquement |
> |------|----------------|---------------------|
> | **compute.xpnAdmin** | Activer Shared VPC, associer projets | Admin Cloud / Architecte |
> | **compute.networkAdmin** | Gérer VPC, sous-réseaux, routes | Équipe réseau |
> | **compute.securityAdmin** | Gérer règles de pare-feu | Équipe sécurité |
> | **compute.networkUser** | Utiliser les sous-réseaux (créer VMs) | Développeurs, Service Accounts |
> 
> Points clés :
> - **xpnAdmin** se donne au niveau Organisation ou Dossier
> - **networkUser** se donne de préférence au niveau du sous-réseau (pas du projet)
> - Les Service Accounts des projets de service ont besoin de networkUser

---

## Lab 4.6 : Shared VPC - Simulation

### Exercice 4.6.4

**Explication des tests de flux :**

> **Frontend → Backend (port 8080) - Autorisé**
> - Règle `shared-vpc-frontend-to-backend` autorise tcp:8080
> - Source tag: frontend, Target tag: backend
> - La VM frontend a le tag "frontend", backend a le tag "backend" → Match
> 
> **Frontend → Database (port 5432) - Refusé**
> - Aucune règle n'autorise frontend → database sur le port 5432
> - La règle `shared-vpc-backend-to-data` n'autorise que les sources avec tag "backend"
> - Même si le trafic interne (10.0.0.0/8) est autorisé, le port spécifique n'est pas ouvert
> 
> **Backend → Database (ping) - Autorisé**
> - Règle `shared-vpc-allow-internal` autorise ICMP depuis 10.0.0.0/8
> - Les deux VMs sont dans cette plage → Match

---

## Lab 4.7 : Règles de pare-feu

### Exercice 4.7.2

**Point clé : Le peering établit la connectivité, pas l'autorisation**

> Le VPC Peering :
> - ✅ Échange les routes entre les VPC
> - ✅ Permet le transit des paquets
> - ❌ N'autorise PAS automatiquement le trafic
> 
> Les règles de pare-feu :
> - Sont évaluées **après** le routage
> - Doivent explicitement autoriser le trafic depuis les plages du VPC peeré
> - Sont gérées **indépendamment** dans chaque VPC
> 
> C'est pourquoi même avec un peering ACTIVE, le trafic peut être bloqué si les règles de pare-feu ne l'autorisent pas.

---

## Lab 4.8 : Choix Shared VPC vs Peering

### Résumé des critères de décision

> | Critère | Shared VPC | VPC Peering |
> |---------|------------|-------------|
> | Organisation GCP requise | ✅ Oui | ❌ Non |
> | Cross-organisation | ❌ Non | ✅ Oui |
> | Gestion centralisée | ✅ Oui | ❌ Non |
> | Équipes autonomes | ❌ Non | ✅ Oui |
> | Règles pare-feu uniformes | ✅ Oui (centralisées) | ❌ Non (par VPC) |
> | Limite de connexions | 1000 projets | 25 peerings/VPC |
> | Transitivité | ✅ Oui (même VPC) | ❌ Non |
> | Complexité initiale | Haute | Basse |
> | Facturation | Projet hôte | Chaque projet |

---

# Corrigé du Quizz du Module 4

**1. Quelle solution nécessite une organisation GCP ?**
- a. VPC Peering
- **b. Shared VPC** ✅
- c. Les deux

> **Shared VPC** nécessite une organisation GCP car il repose sur la hiérarchie organisation/projets.
> 
> VPC Peering fonctionne entre n'importe quels projets, même standalone, et même entre organisations différentes.

---

**2. Le VPC Peering est-il transitif ?**

> **Non**, le VPC Peering n'est **PAS transitif**.
> 
> Si VPC-A est peeré avec VPC-B, et VPC-B avec VPC-C, alors VPC-A ne peut PAS communiquer avec VPC-C à travers VPC-B.
> 
> Solutions :
> - Créer un peering direct A↔C
> - Utiliser une appliance de transit dans VPC-B
> - Utiliser Network Connectivity Center

---

**3. Combien de connexions de peering maximum par VPC ?**

> **25 peerings maximum** par VPC.
> 
> Cette limite inclut :
> - Peerings actifs
> - Peerings en cours de suppression
> 
> Pour plus de connectivité, utilisez Shared VPC ou Network Connectivity Center.

---

**4. Dans un Shared VPC, où sont créées les ressources (VMs) ?**
- a. Projet hôte
- **b. Projets de service** ✅
- c. Les deux

> Les ressources (VMs, GKE, Cloud SQL...) sont créées dans les **projets de service**.
> 
> Le projet hôte contient uniquement :
> - Le VPC partagé
> - Les sous-réseaux
> - Les règles de pare-feu
> - Les routes
> 
> Il est recommandé de **ne pas déployer de workloads** dans le projet hôte.

---

**5. Quel rôle IAM permet d'utiliser un sous-réseau partagé ?**

> Le rôle **`roles/compute.networkUser`** permet d'utiliser un sous-réseau partagé.
> 
> Ce rôle donne le droit de :
> - Créer des instances dans le sous-réseau
> - Utiliser le réseau pour les ressources
> 
> Bonne pratique : Attribuer ce rôle au niveau du **sous-réseau** (pas du projet) pour appliquer le principe du moindre privilège.

---

**6. Peut-on faire du VPC Peering entre deux organisations différentes ?**

> **Oui**, le VPC Peering supporte le cross-organisation.
> 
> C'est l'un des avantages du VPC Peering par rapport à Shared VPC :
> - Connecter des VPC de partenaires externes
> - Fusions/acquisitions entre entreprises
> - Collaboration inter-entreprises
> 
> Chaque organisation garde le contrôle de son VPC et de ses règles de pare-feu.

---

**7. Dans un Shared VPC, où sont gérées les règles de pare-feu ?**

> Les règles de pare-feu sont gérées dans le **projet hôte**.
> 
> Implications :
> - Gestion centralisée par l'équipe réseau/sécurité
> - Les projets de service ne peuvent pas créer leurs propres règles
> - Toutes les ressources du VPC partagé sont soumises aux mêmes règles
> - Uniformité des politiques de sécurité

---

**8. Citez deux avantages du VPC Peering par rapport au Shared VPC.**

> Avantages du VPC Peering :
> 
> 1. **Pas besoin d'organisation GCP** : Fonctionne avec des projets standalone
> 
> 2. **Cross-organisation** : Permet de connecter des VPC d'entreprises différentes
> 
> 3. **Autonomie des équipes** : Chaque équipe gère son propre VPC et ses règles
> 
> 4. **Simplicité de mise en œuvre** : Plus rapide à configurer que Shared VPC
> 
> 5. **Isolation** : Les règles de pare-feu sont séparées, réduisant le risque d'impact croisé
> 
> 6. **Flexibilité** : Peut être créé/supprimé sans restructuration majeure

---

# Questions de réflexion supplémentaires

**Q1 : Une entreprise a 30 équipes, chacune avec son propre VPC. Quelle solution recommandez-vous ?**

> **Shared VPC** est recommandé pour plusieurs raisons :
> 
> 1. **Limite de peering** : 30 VPC en full mesh = 30 × 29 = 870 peerings, avec 29 peerings/VPC, dépassant la limite de 25
> 
> 2. **Gestion centralisée** : Plus facile à administrer qu'un mesh complexe
> 
> 3. **Plan d'adressage unifié** : Évite les conflits d'IP
> 
> 4. **Sécurité cohérente** : Politiques de pare-feu uniformes
> 
> Architecture suggérée :
> - 1 projet hôte avec le VPC partagé
> - 30 projets de service (un par équipe)
> - Sous-réseaux dédiés par équipe avec permissions IAM granulaires

---

**Q2 : Pourquoi le trafic entre deux VPC peerés est-il facturé différemment de Shared VPC ?**

> Dans les deux cas, le trafic **intra-région** est gratuit, mais il y a des différences subtiles :
> 
> **Shared VPC** :
> - Tout le trafic est "intra-VPC"
> - Facturé au projet hôte
> - Inter-régions facturé comme du trafic interne au VPC
> 
> **VPC Peering** :
> - Trafic considéré comme "inter-VPC"
> - Facturé à chaque projet émetteur
> - Mêmes tarifs que le trafic intra-VPC (gratuit même zone, facturé inter-régions)
> 
> La différence principale est **qui reçoit la facture**, pas le montant.

---

**Q3 : Comment gérer le cas où un partenaire externe doit accéder à certains services mais pas à d'autres dans votre Shared VPC ?**

> Architecture recommandée : **Shared VPC + VPC Peering combinés**
> 
> ```
> Organisation interne (Shared VPC)
> ┌────────────────────────────────────────┐
> │  Projet Hôte                           │
> │  ├── subnet-internal (non peeré)       │
> │  └── subnet-dmz (exposé au partenaire) │
> └──────────────────┬─────────────────────┘
>                    │ VPC Peering
>                    │ (uniquement subnet-dmz exporté)
> ┌──────────────────▼─────────────────────┐
> │  VPC Partenaire (autre organisation)   │
> └────────────────────────────────────────┘
> ```
> 
> Contrôles :
> 1. **Export sélectif** : N'exporter que les routes du subnet-dmz
> 2. **Règles de pare-feu** : Autoriser uniquement les flux nécessaires
> 3. **Tags réseau** : Isoler les ressources exposées aux partenaires
> 4. **VPC Service Controls** : Ajouter une couche de protection des données

---

**Q4 : Quels sont les pièges courants lors de la migration vers Shared VPC ?**

> Pièges à éviter :
> 
> 1. **Chevauchement d'adresses IP**
>    - Les plages existantes peuvent confliter
>    - Solution : Planifier et re-adresser avant migration
> 
> 2. **Permissions IAM manquantes**
>    - Les Service Accounts des projets de service ont besoin de `networkUser`
>    - Les services managés (GKE, Cloud Run) ont des SA spécifiques
> 
> 3. **Quotas du projet hôte**
>    - Les quotas réseau s'appliquent au projet hôte, pas aux projets de service
>    - Demander une augmentation de quotas en amont
> 
> 4. **Règles de pare-feu trop permissives ou restrictives**
>    - Migrer les règles de chaque VPC vers le projet hôte
>    - Attention aux règles en conflit
> 
> 5. **Dépendances non documentées**
>    - Certaines applications dépendent de DNS interne, routes spécifiques
>    - Documenter avant de migrer
> 
> 6. **Complexité des rollbacks**
>    - La migration Shared VPC est difficile à annuler
>    - Tester dans un environnement de staging d'abord

---

**Q5 : Comment monitorer efficacement un environnement avec Shared VPC et VPC Peering ?**

> Stratégie de monitoring :
> 
> 1. **VPC Flow Logs** (activés sur les sous-réseaux critiques)
>    - Voir le trafic entre projets de service
>    - Identifier les flux bloqués
>    - Analyser les patterns de communication
> 
> 2. **Cloud Monitoring**
>    - Métriques de peering : état, bande passante
>    - Alertes sur les erreurs de connectivité
>    - Dashboards par projet et par VPC
> 
> 3. **Network Intelligence Center**
>    - Topology : Visualiser l'architecture
>    - Connectivity Tests : Diagnostiquer les problèmes
>    - Firewall Insights : Optimiser les règles
> 
> 4. **Cloud Logging**
>    - Logs d'audit pour les changements de configuration
>    - Alertes sur les modifications des peerings ou permissions
> 
> 5. **Documentation vivante**
>    - Scripts pour générer automatiquement la cartographie
>    - Revue régulière des peerings et associations
