# Module 5 - Options de Connexion Privée
## Corrigé des Questions et du Quizz

---

# Corrigé des Questions des Labs

## Lab 5.1 : Private Google Access - Configuration de base

### Exercice 5.1.3

**Q1 : Pourquoi la résolution DNS fonctionne-t-elle malgré l'absence d'IP externe ?**

> La résolution DNS fonctionne car elle passe par le **metadata server** de GCP à l'adresse `169.254.169.254`.
>
> Ce serveur :
> - Est accessible depuis toutes les VMs GCP, même sans IP externe
> - Fournit les services DNS de base
> - Est configuré automatiquement comme résolveur DNS dans `/etc/resolv.conf`
> - Transfère les requêtes vers les serveurs DNS appropriés (Cloud DNS ou DNS public)
>
> Le DNS est un service "control plane" qui ne nécessite pas de connectivité Internet directe.

**Q2 : Pourquoi la connexion HTTPS échoue-t-elle ?**

> La connexion HTTPS échoue car :
>
> 1. **Pas de route utilisable** : Sans PGA, le trafic vers les IPs Google (ex: 142.250.x.x) devrait passer par la route par défaut (0.0.0.0/0 → default-internet-gateway)
>
> 2. **Pas d'IP externe** : La VM n'a pas d'IP externe, donc elle ne peut pas utiliser la passerelle Internet
>
> 3. **Pas de Cloud NAT** : Sans NAT, les paquets sortants n'ont pas d'adresse source publique pour le retour
>
> Résultat : Les paquets sont abandonnés car ils ne peuvent pas atteindre leur destination.

---

### Exercice 5.1.5

**Q1 : PGA permet-il d'accéder à github.com ? Pourquoi ?**

> **Non**, PGA ne permet PAS d'accéder à github.com.
>
> PGA est limité aux **APIs et services Google** uniquement :
> - ✅ storage.googleapis.com
> - ✅ bigquery.googleapis.com
> - ✅ pubsub.googleapis.com
> - ❌ github.com
> - ❌ npmjs.com
> - ❌ pypi.org
>
> Pour accéder à Internet général (services tiers), vous avez besoin de :
> - Cloud NAT, ou
> - Une IP externe sur la VM

**Q2 : Quel mécanisme permet maintenant à la VM d'atteindre Cloud Storage ?**

> Avec PGA activé, voici le mécanisme :
>
> 1. **Routage spécial** : GCP "intercepte" le trafic destiné aux plages Google (199.36.153.x ou les IPs Anycast)
>
> 2. **Pas besoin d'IP externe** : Le trafic est routé en interne sur le réseau Google
>
> 3. **Chemin réseau** :
>    ```
>    VM (10.0.0.x) → Route interne GCP → APIs Google (199.36.153.x)
>    ```
>
> 4. **Retour** : Les réponses reviennent directement à la VM via le même chemin interne
>
> Le trafic ne quitte jamais le réseau privé de Google.

---

## Lab 5.2 : PGA - Configuration DNS avancée

### Exercice 5.2.4

**Q1 : Quelle est la différence entre les IPs Anycast publiques et 199.36.153.x ?**

> | Aspect | IPs Anycast publiques | 199.36.153.x (PGA) |
> |--------|----------------------|-------------------|
> | Exemples | 142.250.x.x, 172.217.x.x | 199.36.153.8-11 |
> | Accessibilité | Depuis Internet | Depuis VPC avec PGA uniquement |
> | Chemin réseau | Peut traverser Internet | Reste dans le réseau Google |
> | Usage | DNS public par défaut | DNS privé configuré |
> | Sécurité | Trafic potentiellement exposé | Trafic toujours privé |
>
> Les IPs 199.36.153.x sont des IPs spéciales réservées par Google pour Private Google Access.

**Q2 : Pourquoi configurer le DNS ainsi améliore-t-il la sécurité ?**

> Avantages de sécurité :
>
> 1. **Garantie de chemin privé** : En forçant la résolution vers 199.36.153.x, vous êtes certain que le trafic utilise PGA
>
> 2. **Pas de fuite vers Internet** : Même si la route par défaut existe, le trafic va vers les IPs PGA
>
> 3. **Prévention de l'exfiltration** : Avec VPC Service Controls + restricted.googleapis.com, les données ne peuvent pas sortir du périmètre
>
> 4. **Audit simplifié** : Tout le trafic vers les APIs Google passe par un chemin connu et contrôlable
>
> 5. **Compatibilité VPC-SC** : Prérequis pour VPC Service Controls

---

## Lab 5.3 : Private Services Access - Cloud SQL

### Exercice 5.3.2

**Q1 : Pourquoi réserver une plage /24 et non une seule IP ?**

> Raisons de réserver une plage et non une seule IP :
>
> 1. **Plusieurs instances** : Chaque instance Cloud SQL, Memorystore, etc. consomme une ou plusieurs IPs
>
> 2. **Haute disponibilité** : Les instances HA utilisent des IPs supplémentaires pour les réplicas
>
> 3. **Croissance future** : Nouvelles instances, scaling, nouveaux services
>
> 4. **IPs de management** : GCP utilise des IPs supplémentaires pour la gestion interne
>
> **Recommandations de dimensionnement** :
> | Nombre d'instances | Plage recommandée |
> |-------------------|-------------------|
> | < 50 | /24 (254 IPs) |
> | 50-250 | /22 (1022 IPs) |
> | 250-1000 | /20 (4094 IPs) |
> | > 1000 | /16 (65534 IPs) |

**Q2 : Cette plage peut-elle chevaucher vos sous-réseaux existants ?**

> **Non**, la plage PSA ne doit JAMAIS chevaucher :
>
> - Vos sous-réseaux VPC existants
> - Vos réseaux on-premise (si connectés via VPN/Interconnect)
> - D'autres plages PSA dans le même VPC
> - Les plages secondaires (GKE pods/services)
>
> Si chevauchement :
> - La création de la connexion PSA échouera
> - Ou des conflits de routage surviendront
>
> **Bonne pratique** : Planifier un espace d'adressage dédié aux services managés (ex: 10.100.0.0/16)

---

### Exercice 5.3.7

**Q1 : L'IP de Cloud SQL (10.100.0.x) fait-elle partie de vos sous-réseaux ?**

> **Non**, l'IP de Cloud SQL n'est PAS dans vos sous-réseaux.
>
> Elle est dans la **plage PSA réservée** (10.100.0.0/24 dans notre exemple) :
> - Cette plage est gérée par Google
> - Elle est connectée via VPC Peering automatique
> - Les IPs sont attribuées par Google, pas par vous
>
> Architecture :
> ```
> Votre VPC                     VPC Google (servicenetworking)
> ├── subnet-app (10.0.1.0/24)  ├── 10.100.0.0/24 (votre plage réservée)
> │   └── vm-sql-client         │   └── Cloud SQL (10.100.0.2)
> │                             │   └── Memorystore (10.100.0.5)
> └── [Peering automatique] ◄───┘
> ```

**Q2 : Pourquoi utiliser PSA plutôt qu'une IP publique pour Cloud SQL ?**

> Avantages de PSA (IP privée) :
>
> | Aspect | IP Publique | PSA (IP Privée) |
> |--------|-------------|-----------------|
> | Sécurité | Exposé sur Internet | Accessible uniquement depuis le VPC |
> | Latence | Variable (Internet) | Faible (réseau interne) |
> | Coût | Frais d'IP publique | Pas de frais supplémentaires |
> | Conformité | Difficile (données exposées) | Facile (données privées) |
> | Pare-feu | Règles complexes nécessaires | Simplifié (trafic interne) |
> | Accès on-prem | Via Internet | Via VPN/Interconnect + export routes |
>
> **Recommandation** : Toujours utiliser PSA pour les environnements de production.

---

## Lab 5.5 : Private Service Connect - APIs Google

### Exercice 5.5.3

**Q1 : Quelle est la différence entre `all-apis` et `vpc-sc` comme bundle ?**

> | Bundle | APIs incluses | Usage |
> |--------|--------------|-------|
> | `all-apis` | Toutes les APIs Google Cloud | Usage général, pas de VPC-SC |
> | `vpc-sc` | APIs compatibles VPC Service Controls uniquement | Projets avec périmètre VPC-SC |
>
> Détails :
> - **all-apis** : Inclut toutes les APIs (Storage, BigQuery, Compute, etc.) sans restriction
> - **vpc-sc** : Exclut les APIs non compatibles avec VPC Service Controls, garantit le respect du périmètre
>
> Choisir `vpc-sc` si :
> - Vous avez un périmètre VPC Service Controls
> - Vous voulez garantir que seules les APIs sécurisées sont accessibles
> - Exigences de conformité strictes

**Q2 : L'endpoint PSC a-t-il une IP publique ou privée ?**

> L'endpoint PSC a une **IP privée** de votre VPC.
>
> C'est l'avantage principal de PSC :
> - Vous choisissez l'IP (ex: 10.1.0.100)
> - Elle fait partie de votre sous-réseau
> - Elle est routable depuis on-premise via VPN/Interconnect
> - Aucune IP publique n'est impliquée
>
> Comparaison :
> ```
> PGA : VM → 199.36.153.x (IPs Google, pas dans votre VPC)
> PSC : VM → 10.1.0.100 (IP dans VOTRE VPC) → APIs Google
> ```

---

## Lab 5.6 : PSC - Publier un service (Producteur)

### Exercice 5.6.4

**Q1 : Pourquoi avons-nous besoin d'un sous-réseau avec `purpose=PRIVATE_SERVICE_CONNECT` ?**

> Ce sous-réseau spécial est utilisé pour le **NAT PSC** :
>
> 1. **Traduction d'adresses** : Quand un consommateur accède au service, son IP source est traduite en une IP de ce sous-réseau
>
> 2. **Isolation** : Le producteur ne voit pas l'IP réelle du consommateur, seulement une IP du subnet NAT
>
> 3. **Scalabilité** : Permet de supporter de nombreux consommateurs sans conflits d'IP
>
> Flux :
> ```
> Consommateur (10.60.0.10) 
>     → PSC Endpoint (10.60.0.100)
>     → NAT PSC (10.50.1.x)  ← IP vue par le producteur
>     → Backend (10.50.0.10)
> ```
>
> Le sous-réseau NAT doit être dimensionné selon le nombre de connexions attendues.

**Q2 : Quelle est la différence entre `ACCEPT_AUTOMATIC` et `ACCEPT_MANUAL` ?**

> | Mode | Comportement | Usage |
> |------|-------------|-------|
> | `ACCEPT_AUTOMATIC` | Toute demande de connexion est acceptée automatiquement | Dev/test, services internes de confiance |
> | `ACCEPT_MANUAL` | Le producteur doit approuver chaque demande | Production, services exposés à des tiers |
>
> Avec `ACCEPT_MANUAL` :
> - Chaque consommateur fait une demande de connexion
> - Le producteur reçoit une notification
> - Le producteur approuve ou rejette via :
>   ```bash
>   gcloud compute service-attachments update my-service \
>       --region=REGION \
>       --consumer-accept-list=PROJECT_ID
>   ```
>
> **Recommandation** : Utiliser `ACCEPT_MANUAL` en production pour contrôler qui accède à vos services.

---

## Lab 5.7 : PSC - Consommer un service (Consommateur)

### Exercice 5.7.5

**Q1 : Le consommateur connaît-il l'IP réelle du backend (10.50.0.10) ?**

> **Non**, le consommateur ne connaît PAS l'IP réelle du backend.
>
> Le consommateur voit uniquement :
> - L'IP de son endpoint PSC local (10.60.0.100)
>
> Le producteur contrôle :
> - L'architecture interne (ILB, backends)
> - Les IPs internes (10.50.0.x)
>
> Avantages de cette isolation :
> - **Sécurité** : Le consommateur ne peut pas accéder directement aux backends
> - **Flexibilité** : Le producteur peut changer son architecture sans impacter les consommateurs
> - **Abstraction** : Interface stable (endpoint) vs implémentation variable (backends)

**Q2 : Le trafic traverse-t-il Internet entre les deux VPC ?**

> **Non**, le trafic reste entièrement sur le **réseau privé de Google**.
>
> Chemin du trafic :
> ```
> Consumer VPC (10.60.0.10)
>     → PSC Endpoint (10.60.0.100)
>     → Réseau interne Google (pas Internet)
>     → Service Attachment
>     → NAT PSC (10.50.1.x)
>     → ILB (10.50.0.100)
>     → Backend (10.50.0.10)
> ```
>
> Avantages :
> - Latence minimale
> - Bande passante élevée
> - Sécurité (pas d'exposition Internet)
> - Pas de frais de trafic "egress Internet"

---

# Corrigé du Quizz du Module 5

**1. Quelle solution permet à une VM sans IP externe d'accéder à Cloud Storage ?**
- a. Cloud NAT uniquement
- **b. Private Google Access** ✅
- c. VPC Peering

> **Private Google Access (PGA)** permet aux VMs sans IP externe d'accéder aux APIs Google comme Cloud Storage.
>
> Cloud NAT permet aussi d'accéder à Cloud Storage, mais ce n'est pas la solution optimale :
> - NAT fait passer le trafic vers Internet puis vers Google
> - PGA garde le trafic sur le réseau interne Google
>
> VPC Peering ne permet pas d'accéder aux APIs Google.

---

**2. Private Services Access utilise quel mécanisme sous-jacent ?**

> **VPC Peering** (automatique) avec le VPC de Google.
>
> Quand vous créez une connexion PSA :
> 1. Vous réservez une plage IP dans votre VPC
> 2. GCP crée automatiquement un peering avec `servicenetworking.googleapis.com`
> 3. Les services managés (Cloud SQL, Memorystore) reçoivent des IPs de votre plage
>
> Vous pouvez voir ce peering avec :
> ```bash
> gcloud compute networks peerings list --network=VPC_NAME
> ```

---

**3. Avec PSC, où se trouve l'IP de l'endpoint ?**
- a. Chez Google
- **b. Dans votre VPC** ✅
- c. Sur Internet

> L'IP de l'endpoint PSC est **dans votre VPC**, dans un sous-réseau que vous choisissez.
>
> C'est l'avantage principal de PSC :
> - Vous contrôlez l'IP (ex: 10.0.1.100)
> - Elle est routable depuis vos réseaux (y compris on-premise)
> - Pas d'IP publique impliquée

---

**4. Quelle solution est recommandée pour accéder aux APIs Google depuis on-premise ?**

> **PSC (Private Service Connect)** est recommandé pour l'accès depuis on-premise.
>
> Raisons :
> - L'IP de l'endpoint est dans votre espace d'adressage (routable via VPN/Interconnect)
> - Pas besoin de configurer des routes spéciales vers les IPs Google
> - Configuration DNS simple (pointer vers l'IP de l'endpoint)
>
> Avec PGA, l'accès depuis on-premise nécessite :
> - Export des routes vers les IPs Google (199.36.153.x)
> - Configuration DNS on-premise
> - Plus complexe à maintenir

---

**5. Private Google Access permet-il d'accéder à Internet ?**

> **Non**, PGA ne permet PAS d'accéder à Internet.
>
> PGA permet uniquement d'accéder aux :
> - APIs Google Cloud (storage.googleapis.com, bigquery.googleapis.com, etc.)
> - Services Google (gcr.io, pkg.dev, etc.)
>
> Pour l'accès Internet (github.com, npmjs.com, etc.), utilisez **Cloud NAT**.
>
> Configuration recommandée : PGA + Cloud NAT pour avoir les deux.

---

**6. Quel domaine utiliser avec VPC Service Controls ?**
- a. private.googleapis.com
- **b. restricted.googleapis.com** ✅
- c. public.googleapis.com

> **restricted.googleapis.com** (199.36.153.4/30) est requis pour VPC Service Controls.
>
> Différences :
> | Domaine | IPs | Usage |
> |---------|-----|-------|
> | private.googleapis.com | 199.36.153.8/30 | PGA standard |
> | restricted.googleapis.com | 199.36.153.4/30 | VPC Service Controls |
>
> `restricted.googleapis.com` garantit que :
> - Seules les APIs compatibles VPC-SC sont accessibles
> - Le trafic respecte les périmètres de sécurité
> - Les données ne peuvent pas être exfiltrées hors du périmètre

---

**7. Avec PSA, qui gère le VPC Peering ?**

> **Google (GCP)** gère automatiquement le VPC Peering pour PSA.
>
> Vous n'avez pas à :
> - Créer manuellement le peering
> - Gérer les routes
> - Configurer les permissions de peering
>
> Vous devez seulement :
> - Réserver une plage IP (`gcloud compute addresses create`)
> - Créer la connexion (`gcloud services vpc-peerings connect`)
>
> Le peering apparaît automatiquement avec le nom `servicenetworking-googleapis-com`.

---

**8. Citez un avantage de PSC par rapport à PGA.**

> Avantages de PSC par rapport à PGA :
>
> 1. **IP dans votre VPC** : L'endpoint a une IP de votre sous-réseau, pas une IP Google
>
> 2. **Transitivité native** : L'IP est routable depuis on-premise sans configuration spéciale
>
> 3. **Isolation dédiée** : Chaque endpoint est dédié, pas partagé
>
> 4. **Contrôle granulaire** : Vous pouvez créer plusieurs endpoints pour différents services
>
> 5. **Compatibilité pare-feu** : Plus facile à contrôler avec des règles de pare-feu (IP interne)
>
> 6. **DNS simplifié** : Un seul enregistrement A vers l'IP de l'endpoint

---

# Questions de réflexion supplémentaires

**Q1 : Une entreprise a des VMs GCP et des serveurs on-premise. Tous doivent accéder à Cloud Storage. Quelle architecture recommandez-vous ?**

> Architecture recommandée : **PSC pour APIs Google**
>
> ```
>                                        Cloud Storage
>                                             │
>                                             │
>     On-premise                          PSC Endpoint
>     ┌─────────────┐                    ┌───────────┐
>     │  Serveurs   │───VPN/Interconnect─│ 10.0.1.100│───► storage.googleapis.com
>     └─────────────┘         │          └───────────┘
>                             │                │
>                          VPC GCP             │
>                      ┌─────────────┐         │
>                      │    VMs      │─────────┘
>                      └─────────────┘
> ```
>
> Configuration :
> 1. Créer un endpoint PSC avec IP 10.0.1.100
> 2. Configurer DNS on-premise : storage.googleapis.com → 10.0.1.100
> 3. Annoncer 10.0.1.100/32 via BGP vers on-premise
> 4. Les VMs GCP utilisent aussi l'endpoint via DNS privé
>
> Avantages :
> - Une seule configuration pour GCP et on-premise
> - IP stable et routable
> - Trafic privé de bout en bout

---

**Q2 : Quand utiliser PSA vs PSC pour les services managés ?**

> | Service | PSA | PSC | Recommandation |
> |---------|-----|-----|----------------|
> | Cloud SQL | ✅ Supporté | ❌ Non supporté | PSA |
> | Memorystore | ✅ Supporté | ❌ Non supporté | PSA |
> | Cloud Filestore | ✅ Supporté | ❌ Non supporté | PSA |
> | APIs Google | ❌ N/A | ✅ Supporté | PSC |
> | Services tiers/internes | ❌ N/A | ✅ Supporté | PSC |
>
> Règle simple :
> - **Services managés Google (SQL, Redis)** → PSA (c'est leur mode de connexion privée)
> - **APIs Google** → PSC (pour contrôle avancé) ou PGA (pour simplicité)
> - **Vos propres services ou services tiers** → PSC (producteur/consommateur)

---

**Q3 : Comment sécuriser au maximum l'accès aux APIs Google ?**

> Architecture de sécurité maximale :
>
> 1. **Désactiver les IP externes** sur toutes les VMs
>
> 2. **Utiliser PSC** (pas PGA) pour un contrôle total :
>    ```bash
>    gcloud compute forwarding-rules create psc-apis \
>        --target-google-apis-bundle=vpc-sc
>    ```
>
> 3. **Configurer VPC Service Controls** :
>    - Créer un périmètre autour des projets sensibles
>    - Utiliser `restricted.googleapis.com`
>
> 4. **Règles de pare-feu strictes** :
>    ```bash
>    # Bloquer tout egress
>    gcloud compute firewall-rules create deny-all-egress \
>        --direction=EGRESS --action=DENY --rules=all \
>        --destination-ranges=0.0.0.0/0 --priority=65534
>    
>    # Autoriser uniquement vers PSC
>    gcloud compute firewall-rules create allow-psc-only \
>        --direction=EGRESS --action=ALLOW --rules=tcp:443 \
>        --destination-ranges=10.0.1.100/32 --priority=1000
>    ```
>
> 5. **Activer les logs** :
>    - VPC Flow Logs
>    - Cloud Audit Logs
>    - Data Access Logs
>
> 6. **Contrôle IAM** :
>    - Principe du moindre privilège
>    - Conditions IAM basées sur l'IP source

---

**Q4 : PSA a une limitation de non-transitivité. Comment permettre l'accès depuis on-premise ?**

> Par défaut, les routes vers la plage PSA ne sont pas annoncées via BGP. Solution :
>
> 1. **Exporter les routes custom vers le peering Google** :
>    ```bash
>    gcloud compute networks peerings update servicenetworking-googleapis-com \
>        --network=VPC_NAME \
>        --export-custom-routes \
>        --import-custom-routes
>    ```
>
> 2. **Annoncer la plage PSA vers on-premise** via Cloud Router :
>    ```bash
>    gcloud compute routers update ROUTER_NAME \
>        --region=REGION \
>        --advertisement-mode=CUSTOM \
>        --set-advertisement-ranges=10.100.0.0/20  # Plage PSA
>    ```
>
> 3. **Vérifier la connectivité** depuis on-premise :
>    ```bash
>    # Depuis un serveur on-premise
>    psql -h 10.100.0.5 -U postgres -d mydb
>    ```
>
> Sans ces étapes, les serveurs on-premise ne pourront pas atteindre Cloud SQL/Memorystore via PSA.

---

**Q5 : Comment monitorer l'utilisation de la connectivité privée ?**

> Outils de monitoring :
>
> 1. **VPC Flow Logs** :
>    - Activer sur les sous-réseaux concernés
>    - Voir les flux vers les IPs PSA, PSC, PGA
>    - Identifier les connexions refusées
>
> 2. **Cloud Monitoring** :
>    - Métriques de connexion PSC
>    - Métriques des services managés (Cloud SQL, Redis)
>    - Alertes sur les erreurs de connexion
>
> 3. **Network Intelligence Center** :
>    - Connectivity Tests : Diagnostiquer les problèmes de connectivité
>    - Topology : Visualiser l'architecture
>
> 4. **Cloud Logging** :
>    - Logs d'audit des APIs
>    - Logs des services managés
>
> Requête exemple pour VPC Flow Logs :
> ```
> resource.type="gce_subnetwork"
> jsonPayload.connection.dest_ip="10.0.1.100"
> ```
