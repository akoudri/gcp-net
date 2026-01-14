# Module 2 - Principes fondamentaux du VPC
## Corrigé des Questions et du Quizz

---

# Corrigé des Questions des Labs

## Lab 2.1 : Découverte du VPC default

### Exercice 2.1.1

**Q1 : Combien de sous-réseaux le VPC default possède-t-il ?**

> Le VPC default possède **un sous-réseau par région GCP active** (environ 35-40 selon les régions disponibles).
> 
> En mode "auto", GCP crée automatiquement un sous-réseau /20 dans chaque région. C'est pratique pour les tests mais problématique en production car :
> - Vous n'avez pas le contrôle sur les plages IP
> - Toutes les régions ont un sous-réseau même si vous n'en avez pas besoin
> - Risque de chevauchement avec vos réseaux on-premise

**Q2 : Quelle est la plage IP du sous-réseau dans europe-west1 ?**

> La plage est **10.132.0.0/20** pour europe-west1.
> 
> Les plages du mode auto suivent un pattern prévisible dans 10.128.0.0/9 :
> - us-central1 : 10.128.0.0/20
> - europe-west1 : 10.132.0.0/20
> - asia-east1 : 10.140.0.0/20
> - etc.

**Q3 : Quel est le mode de création du VPC default (auto ou custom) ?**

> Le VPC default est en mode **auto**.
> 
> Cela se vérifie avec :
> ```bash
> gcloud compute networks describe default --format="get(autoCreateSubnetworks)"
> # Retourne : True
> ```

---

### Exercice 2.1.2

**Q1 : Quelles sont les sources autorisées pour SSH ? Est-ce sécurisé ?**

> La règle `default-allow-ssh` autorise SSH depuis **0.0.0.0/0** (tout Internet).
> 
> **C'est très risqué** car :
> - Toute personne connaissant l'IP peut tenter de se connecter
> - Exposé aux attaques par force brute
> - Aucune restriction géographique ou par IP source
> 
> **Bonnes pratiques :**
> - Restreindre aux IPs connues de votre organisation
> - Utiliser IAP (Identity-Aware Proxy) : source-ranges=35.235.240.0/20
> - Utiliser un bastion/jump host

**Q2 : La règle `default-allow-internal` autorise quels protocoles ?**

> Elle autorise **tcp, udp, et icmp** sur tous les ports entre toutes les VMs du VPC.
> 
> Cela signifie qu'une VM compromise peut attaquer toutes les autres VMs du réseau sans restriction. En production, il faut segmenter et n'autoriser que les flux nécessaires.

**Q3 : Identifiez au moins 3 risques de sécurité avec ces règles par défaut.**

> 1. **SSH ouvert au monde (0.0.0.0/0)** : Attaques par force brute possibles
> 
> 2. **RDP ouvert au monde (0.0.0.0/0)** : Les serveurs Windows sont exposés aux attaques RDP (BlueKeep, etc.)
> 
> 3. **Tout le trafic interne autorisé** : Pas de segmentation, mouvement latéral facile si une VM est compromise
> 
> 4. **ICMP ouvert au monde** : Permet la reconnaissance réseau (ping sweep)
> 
> 5. **Pas de journalisation par défaut** : Aucune visibilité sur le trafic bloqué ou autorisé
> 
> 6. **Absence de règles de sortie restrictives** : Une VM compromise peut exfiltrer des données vers n'importe quelle destination

---

### Exercice 2.1.3

**Q1 : La VM a-t-elle une IP externe ? Pourquoi est-ce un risque potentiel ?**

> Oui, par défaut une VM créée dans le VPC default reçoit une **IP externe éphémère**.
> 
> Risques :
> - La VM est directement accessible depuis Internet
> - Augmente la surface d'attaque
> - Combiné avec les règles permissives (SSH ouvert), c'est une cible facile
> 
> En production, utilisez `--no-address` et accédez via Cloud NAT ou IAP.

**Q2 : Cette VM est-elle accessible en SSH depuis Internet ?**

> **Oui**, car :
> - Elle a une IP externe
> - La règle `default-allow-ssh` autorise le port 22 depuis 0.0.0.0/0
> - Le tag par défaut correspond
> 
> N'importe qui peut tenter `ssh <IP_EXTERNE>` (bien sûr, il faut la clé SSH).

---

## Lab 2.2 : Créer un VPC custom multi-régions

### Exercice 2.2.1

**Q1 : Quelle est la différence entre `--subnet-mode=auto` et `--subnet-mode=custom` ?**

> | Mode | Comportement |
> |------|-------------|
> | **auto** | GCP crée automatiquement un sous-réseau /20 dans chaque région avec des plages prédéfinies (10.128.0.0/9) |
> | **custom** | Aucun sous-réseau n'est créé automatiquement. Vous définissez manuellement chaque sous-réseau avec la plage de votre choix |
> 
> Le mode custom est **recommandé en production** car il offre :
> - Contrôle total sur l'adressage IP
> - Pas de sous-réseaux inutiles
> - Évite les conflits avec les réseaux existants

**Q2 : Pourquoi choisir le mode `regional` pour le routage BGP dans ce cas ?**

> Le mode **regional** est suffisant quand :
> - Vous n'avez pas de connectivité hybride (VPN/Interconnect)
> - Ou si votre VPN/Interconnect dessert uniquement les VMs de la même région
> 
> Le mode **global** est nécessaire quand :
> - Vous avez un VPN dans une région mais des VMs dans plusieurs régions
> - Toutes les régions doivent pouvoir atteindre le réseau on-premise via un seul point de connexion

---

### Exercice 2.2.2

**Q1 : Combien de routes ont été créées automatiquement ?**

> **3 routes** sont créées :
> 1. Route vers subnet-eu (10.1.0.0/24)
> 2. Route vers subnet-us (10.2.0.0/24)
> 3. Route par défaut vers Internet (0.0.0.0/0 via default-internet-gateway)

**Q2 : Quelle est la destination de la route par défaut ?**

> La destination est **0.0.0.0/0** (toutes les adresses IP).
> Le next-hop est **default-internet-gateway**, qui représente la passerelle Internet de GCP.

**Q3 : Comment les routes de sous-réseaux permettent-elles la communication inter-régions ?**

> Les routes de sous-réseaux sont **globales** dans le VPC. Cela signifie que :
> 
> - Depuis une VM dans subnet-eu (10.1.0.0/24), la table de routage contient aussi la route vers subnet-us (10.2.0.0/24)
> - Le trafic vers 10.2.0.X est automatiquement routé via le backbone Google vers us-central1
> - Aucune configuration supplémentaire n'est nécessaire
> 
> C'est un avantage majeur de GCP : le VPC est global, donc les sous-réseaux se "voient" automatiquement.

---

### Exercice 2.2.3

**Q1 : Pourquoi utilise-t-on des tags (`--target-tags`) pour la règle SSH ?**

> Les tags permettent d'**appliquer des règles à un sous-ensemble de VMs** plutôt qu'à tout le VPC.
> 
> Avantages :
> - Principe du moindre privilège : seules les VMs avec le tag reçoivent la règle
> - Flexibilité : on peut ajouter/retirer le tag sans modifier la règle
> - Clarté : les tags documentent le rôle de la VM (web, db, bastion...)
> 
> Exemple : Seules les VMs avec le tag `allow-ssh` accepteront les connexions SSH.

**Q2 : Est-il préférable d'utiliser `10.0.0.0/8` ou les plages exactes pour `source-ranges` ?**

> **Les plages exactes sont préférables** pour la sécurité :
> 
> | Approche | Pour | Contre |
> |----------|------|--------|
> | `10.0.0.0/8` | Simple, couvre toutes les IPs privées | Trop permissif, autorise des plages non utilisées |
> | Plages exactes (`10.1.0.0/24,10.2.0.0/24`) | Précis, sécurisé | Plus de maintenance si vous ajoutez des sous-réseaux |
> 
> En production, utilisez les plages exactes et mettez à jour les règles lors de l'ajout de sous-réseaux. Vous pouvez aussi utiliser des **service accounts** au lieu de plages IP pour plus de précision.

---

### Exercice 2.2.5

**Q1 : Combien de sauts entre les deux VMs ?**

> Généralement **1 à 3 sauts** apparaissent dans traceroute, mais cela peut varier.
> 
> En réalité, le trafic traverse le backbone Google qui n'expose pas tous ses routeurs internes. Le nombre de sauts affiché ne reflète pas la complexité réelle du chemin.

**Q2 : Quelle est la latence moyenne entre Europe et US ?**

> Typiquement **100-150 ms** entre europe-west1 et us-central1.
> 
> Cette latence est incompressible car elle dépend de la distance physique (~8000 km) et de la vitesse de la lumière dans la fibre optique.

**Q3 : Le trafic passe-t-il par Internet ou reste-t-il sur le backbone Google ?**

> Le trafic reste **entièrement sur le backbone privé de Google**.
> 
> Preuves :
> - Les adresses intermédiaires (si visibles) sont des IPs internes Google
> - La latence est stable et prévisible
> - Aucun transit par des opérateurs tiers
> 
> C'est un avantage majeur du VPC global GCP par rapport aux architectures multi-régions traditionnelles.

---

### Exercice 2.2.6

**Q1 : Quel est le format complet du nom DNS interne d'une VM ?**

> Format zonal (défaut) : 
> ```
> [NOM_VM].[ZONE].c.[PROJECT_ID].internal
> ```
> 
> Exemple :
> ```
> vm-us.us-central1-a.c.mon-projet-123.internal
> ```

**Q2 : Le DNS interne fonctionne-t-il entre régions différentes ?**

> **Oui**, le DNS interne GCP est global au sein d'un projet.
> 
> Depuis vm-eu en Europe, vous pouvez résoudre le nom de vm-us aux États-Unis. Le serveur DNS (169.254.169.254) est disponible pour toutes les VMs et connaît toutes les VMs du projet.

---

## Lab 2.3 : Planification et extension des sous-réseaux

### Exercice 2.3.1

**Q1 : Pourquoi utiliser des /20 plutôt que des /24 ?**

> Un **/20 offre 4094 adresses** utilisables contre 254 pour un /24.
> 
> Raisons de prévoir large :
> - Les besoins croissent souvent plus vite que prévu
> - Impossible de réduire un sous-réseau après création
> - GKE peut consommer beaucoup d'IPs (1 IP par pod)
> - Les services managés (Cloud SQL, etc.) réservent aussi des IPs
> - Coût nul : les IPs non utilisées ne sont pas facturées

**Q2 : Combien d'hôtes peuvent être déployés dans un /20 ?**

> **4094 hôtes** (2^12 - 2 = 4094).
> 
> Calcul : 32 - 20 = 12 bits pour les hôtes
> 2^12 = 4096 adresses totales
> - 1 adresse réseau (.0)
> - 1 adresse broadcast (.4095)
> - 2 adresses réservées GCP (.1 passerelle, avant-dernière)
> = 4092 vraiment utilisables sur GCP

**Q3 : Pourquoi séparer les plages de pods et services ?**

> GKE utilise des plages IP distinctes pour différents usages :
> 
> | Plage | Usage | Taille typique |
> |-------|-------|----------------|
> | Principale | Nœuds du cluster | /20 - /24 |
> | Pods | Chaque pod reçoit une IP | /14 - /20 (beaucoup d'IPs) |
> | Services | ClusterIP des Services K8s | /20 - /24 |
> 
> Séparer ces plages permet :
> - Éviter les conflits
> - Appliquer des règles de pare-feu différentes
> - Faciliter le routage vers/depuis l'extérieur du cluster

---

### Exercice 2.3.3

**Q1 : Peut-on réduire la taille d'un sous-réseau après extension ?**

> **Non**, l'extension est **irréversible**.
> 
> Une fois étendu de /28 à /24, vous ne pouvez pas revenir à /28. C'est pourquoi il faut planifier soigneusement dès le départ.
> 
> Si vous devez vraiment réduire, la seule option est de :
> 1. Créer un nouveau sous-réseau plus petit
> 2. Migrer les ressources
> 3. Supprimer l'ancien sous-réseau

**Q2 : L'extension affecte-t-elle les VMs existantes dans le sous-réseau ?**

> **Non**, les VMs existantes ne sont pas affectées.
> 
> - Leurs IPs restent les mêmes
> - Aucune interruption de service
> - Les nouvelles IPs sont simplement disponibles pour de futures ressources

**Q3 : Quelles contraintes s'appliquent lors de l'extension ?**

> Contraintes :
> 1. La nouvelle plage doit **inclure** l'ancienne (extension, pas modification)
> 2. La nouvelle plage ne doit pas **chevaucher** d'autres sous-réseaux du VPC
> 3. Minimum /29, maximum /8
> 4. Opération irréversible

---

## Lab 2.4 : VM avec interfaces réseau multiples

### Exercice 2.4.2

**Q1 : Que fait l'option `--can-ip-forward` ?**

> Cette option permet à la VM de **transmettre des paquets qui ne lui sont pas destinés** (routage/forwarding).
> 
> Par défaut, GCP bloque les paquets dont l'IP destination n'est pas une IP de la VM (anti-spoofing). Avec `--can-ip-forward`, la VM peut agir comme un routeur ou une appliance réseau.
> 
> Cas d'usage :
> - Firewalls virtuels (Palo Alto, Fortinet)
> - Proxys
> - VPN gateways
> - NAT instances

**Q2 : Pourquoi les deux sous-réseaux doivent-ils être dans la même région ?**

> C'est une **limitation GCP** : toutes les interfaces d'une VM doivent être dans des sous-réseaux de la **même région**.
> 
> Raisons techniques :
> - Une VM s'exécute dans une zone (qui appartient à une région)
> - La latence entre régions rendrait le multi-NIC peu performant
> - Simplifie l'architecture réseau sous-jacente

**Q3 : Peut-on ajouter une interface réseau à une VM existante ?**

> **Non**, les interfaces doivent être définies à la **création** de la VM.
> 
> Pour ajouter une interface, vous devez :
> 1. Créer un snapshot des disques
> 2. Supprimer la VM
> 3. Recréer la VM avec les interfaces supplémentaires
> 4. Rattacher les disques depuis les snapshots

---

### Exercice 2.4.6

**Q1 : Le traceroute montre-t-il l'appliance comme hop intermédiaire ?**

> **Oui**, vous devriez voir l'IP de l'appliance (10.1.0.5 ou 10.2.0.5) comme hop intermédiaire entre les deux clients.
> 
> Exemple de sortie :
> ```
> traceroute to 10.2.0.10 (10.2.0.10)
>  1  10.1.0.5  0.5 ms   <- Appliance (interface VPC-A)
>  2  10.2.0.10 1.2 ms   <- Destination
> ```

**Q2 : Que se passe-t-il si vous désactivez `ip_forward` sur l'appliance ?**

> Le trafic ne sera **plus transmis** entre les deux VPC.
> 
> Symptômes :
> - `ping` timeout
> - Traceroute s'arrête à l'appliance
> - Les paquets arrivent à l'appliance mais sont abandonnés au lieu d'être transférés
> 
> Pour désactiver : `echo 0 > /proc/sys/net/ipv4/ip_forward`

**Q3 : Comment cette architecture serait-elle utilisée en production ?**

> Cas d'usage en production :
> 
> 1. **Firewall centralisé** : Tout le trafic inter-VPC passe par une appliance (Palo Alto, Fortinet) pour inspection
> 
> 2. **IDS/IPS** : Détection et prévention d'intrusion sur le trafic transitant
> 
> 3. **Proxy de sortie** : Contrôle et journalisation du trafic Internet sortant
> 
> 4. **Segmentation réseau** : Séparation stricte entre environnements (prod/dev) avec inspection du trafic
> 
> 5. **Conformité** : Certaines réglementations exigent une inspection de tout le trafic

---

## Lab 2.5 : Comparaison des Network Tiers

### Exercice 2.5.5

**Q1 : Quelle est la différence de latence moyenne observée ?**

> Typiquement **20-50% de latence en plus** avec Standard Tier par rapport à Premium.
> 
> Exemple concret (peut varier selon votre localisation) :
> - Premium : ~25-35 ms
> - Standard : ~40-60 ms
> 
> La différence vient du fait que le trafic Standard traverse Internet public avant d'entrer sur le réseau Google.

**Q2 : Les chemins réseau sont-ils différents ?**

> **Oui**, les chemins sont très différents :
> 
> **Premium Tier :**
> - Votre requête atteint le PoP Google le plus proche (ex: Paris)
> - Transit via le backbone privé Google
> - Latence stable, peu de hops visibles
> 
> **Standard Tier :**
> - Votre requête traverse Internet public (votre FAI, backbones tiers)
> - Entre sur le réseau Google dans la région de la VM (ex: Belgique)
> - Plus de hops, latence variable, potentielle congestion

**Q3 : À quel moment le trafic entre sur le réseau Google pour chaque tier ?**

> | Tier | Point d'entrée sur le réseau Google |
> |------|-------------------------------------|
> | Premium | Au **PoP le plus proche de l'utilisateur** (>100 PoPs mondiaux) |
> | Standard | Dans la **région de la ressource GCP** uniquement |

---

### Exercice 2.5.6

**Q1 : Pour un workload transférant 1 To/mois, quelle serait l'économie avec Standard ?**

> Calcul approximatif (tarifs Europe, peuvent varier) :
> 
> | Tier | Prix/Go | Coût pour 1 To |
> |------|---------|----------------|
> | Premium | ~$0.12 | ~$120/mois |
> | Standard | ~$0.085 | ~$85/mois |
> | **Économie** | | **~$35/mois (30%)** |
> 
> Sur un an : ~$420 d'économie par To de trafic mensuel.

**Q2 : Le Standard Tier est-il adapté pour une API utilisée mondialement ?**

> **Non**, Standard Tier n'est **pas recommandé** pour une audience mondiale car :
> 
> - Latence plus élevée pour les utilisateurs distants
> - Pas de Load Balancer global (uniquement régional)
> - Pas d'IP Anycast
> - Variabilité de la latence selon la qualité d'Internet
> 
> **Recommandation** : Premium Tier pour les applications critiques avec utilisateurs mondiaux.

---

## Lab 2.6 : Mode de routage dynamique

### Questions

**Q1 : Quand le mode de routage global est-il nécessaire ?**

> Le mode **global** est nécessaire quand :
> 
> 1. Vous avez un Cloud VPN ou Interconnect dans **une région**
> 2. Mais des VMs dans **plusieurs régions** doivent accéder au réseau on-premise
> 
> Exemple : VPN à Paris, VMs à Paris ET à Londres. Sans mode global, les VMs de Londres ne peuvent pas atteindre le réseau on-premise.

**Q2 : Le changement de mode affecte-t-il les VMs existantes ?**

> **Non**, le changement est transparent pour les VMs.
> 
> Ce qui change :
> - La visibilité des routes BGP dans les différentes régions
> - Aucun redémarrage de VM nécessaire
> - Propagation des routes en quelques secondes

**Q3 : Quel est l'impact sur les routes apprises via BGP ?**

> | Mode | Comportement des routes BGP |
> |------|----------------------------|
> | Régional | Routes visibles **uniquement** dans la région du Cloud Router |
> | Global | Routes propagées à **toutes les régions** du VPC |
> 
> Impact pratique : En mode global, le trafic vers le réseau on-premise depuis n'importe quelle région passe par le VPN/Interconnect, même s'il est dans une autre région.

---

# Corrigé du Quizz du Module 2

**1. Quelle est la portée d'un VPC dans GCP ?**
- a. Zonale
- b. Régionale
- **c. Globale** ✅

> Un VPC GCP est une ressource **globale** qui s'étend automatiquement à toutes les régions. C'est une différence majeure avec AWS (VPC régional) et Azure (VNet régional).

---

**2. Quelle est la portée d'un sous-réseau dans GCP ?**

> Un sous-réseau est **régional**.
> 
> Il appartient à une seule région mais est disponible dans toutes les zones de cette région. Les VMs de n'importe quelle zone de la région peuvent utiliser le sous-réseau.

---

**3. Combien d'adresses sont réservées par GCP dans chaque sous-réseau ?**

> **4 adresses** sont réservées :
> 1. Adresse réseau (première, ex: .0)
> 2. Passerelle par défaut (deuxième, ex: .1)
> 3. Réservée GCP (avant-dernière)
> 4. Broadcast (dernière)
> 
> Exemple pour 10.0.0.0/24 :
> - 10.0.0.0 : réseau
> - 10.0.0.1 : passerelle
> - 10.0.0.254 : réservée
> - 10.0.0.255 : broadcast

---

**4. Quel mode de VPC est recommandé pour la production ?**
- a. Auto
- **b. Custom** ✅

> Le mode **custom** est recommandé car :
> - Contrôle total sur les plages IP
> - Évite les chevauchements avec les réseaux existants
> - Pas de sous-réseaux inutiles
> - Conformité aux politiques d'adressage de l'entreprise

---

**5. Quel Network Tier utilise le backbone privé de Google ?**

> Le **Premium Tier** utilise le backbone privé de Google.
> 
> Le trafic entre via le Point of Presence (PoP) le plus proche de l'utilisateur et traverse ensuite le réseau privé de Google jusqu'à la région cible.

---

**6. Une VM peut-elle avoir des interfaces dans plusieurs VPC ?**

> **Oui**, une VM peut avoir plusieurs interfaces réseau (NICs), chacune dans un VPC différent.
> 
> Contraintes :
> - Maximum 2 à 8 interfaces selon le type de machine
> - Tous les sous-réseaux doivent être dans la **même région**
> - Les interfaces sont définies à la **création** de la VM
> - Nécessite `--can-ip-forward` pour le routage

---

**7. Quelle est la taille minimale d'un sous-réseau GCP ?**

> La taille minimale est **/29** (8 adresses totales, 4 utilisables après réservations GCP).
> 
> Plage de tailles possibles :
> - Minimum : /29 (8 adresses)
> - Maximum : /8 (~16 millions d'adresses)

---

**8. Citez deux raisons d'utiliser le Standard Tier.**

> 1. **Réduction des coûts** : 25-50% moins cher sur le trafic sortant
> 
> 2. **Environnements de développement/test** : La latence n'est pas critique
> 
> 3. **Workloads batch** : Traitements non sensibles au temps de réponse
> 
> 4. **Trafic principalement intra-région** : Peu d'impact si les utilisateurs sont proches de la région GCP
> 
> 5. **Budget contraint** : Quand les performances Premium ne sont pas justifiées

---

# Questions de réflexion supplémentaires

**Q1 : Pourquoi le VPC GCP est-il global alors que chez AWS et Azure il est régional ?**

> C'est un choix d'architecture de Google basé sur leur infrastructure :
> 
> - Google possède un **backbone mondial privé** (câbles sous-marins, interconnexions)
> - Ils peuvent donc offrir une connectivité inter-régions "native" sans passer par Internet
> - Simplifie les architectures multi-régions (pas besoin de VPC Peering entre régions)
> - Cohérent avec leur philosophie "planet-scale"
> 
> Chez AWS/Azure, vous devez créer un VPC par région et les interconnecter (VPC Peering, Transit Gateway).

**Q2 : Quel est l'impact d'un sous-réseau mal dimensionné ?**

> Impacts négatifs :
> 
> 1. **Trop petit** : Impossible de déployer plus de ressources, nécessite une extension (irréversible) ou migration
> 
> 2. **Trop grand** : Gaspillage de plages IP qui pourraient chevaucher des besoins futurs
> 
> 3. **Chevauchement** : Impossible de faire du VPC Peering ou de se connecter au réseau on-premise si les plages se chevauchent
> 
> **Règle d'or** : Planifier 2-3x la taille actuellement nécessaire, documenter les allocations.

**Q3 : Comment sécuriser un VPC de production ?**

> Checklist de sécurisation :
> 
> 1. ✅ Mode custom (pas de VPC default)
> 2. ✅ Pas d'IP externes sauf nécessité absolue
> 3. ✅ Accès SSH via IAP uniquement
> 4. ✅ Règles de pare-feu basées sur service accounts/tags (pas 0.0.0.0/0)
> 5. ✅ Règle deny-all par défaut, autoriser uniquement le nécessaire
> 6. ✅ VPC Flow Logs activés pour audit
> 7. ✅ Private Google Access pour les APIs
> 8. ✅ Cloud NAT pour l'accès Internet sortant
> 9. ✅ Segmentation par environnement (prod/staging/dev)
> 10. ✅ VPC Service Controls pour les données sensibles
