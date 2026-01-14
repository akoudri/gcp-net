# Module 3 - Routage et Adressage dans GCP
## Corrigé des Questions et du Quizz

---

# Corrigé des Questions des Labs

## Lab 3.1 : Comprendre les routes système et la table de routage

### Exercice 3.1.2

**Q1 : Combien de routes ont été créées automatiquement ?**

> **3 routes** sont créées automatiquement :
> 1. Route vers subnet-eu (10.1.0.0/24)
> 2. Route vers subnet-us (10.2.0.0/24)
> 3. Route par défaut vers Internet (0.0.0.0/0)
>
> Chaque sous-réseau génère automatiquement une route de sous-réseau, et GCP crée une route par défaut pour l'accès Internet.

**Q2 : Identifiez la route par défaut vers Internet. Quel est son next-hop ?**

> La route par défaut a :
> - **Destination** : 0.0.0.0/0 (toutes les adresses)
> - **Next-hop** : `default-internet-gateway`
>
> Ce next-hop représente la passerelle Internet virtuelle de GCP qui permet aux VMs avec IP externe d'accéder à Internet.

**Q3 : Identifiez les routes de sous-réseau. Quelle est leur destination ?**

> Les routes de sous-réseau ont pour destination la plage CIDR exacte du sous-réseau :
> - subnet-eu → destination : 10.1.0.0/24
> - subnet-us → destination : 10.2.0.0/24
>
> Ces routes permettent le routage automatique du trafic vers les VMs du sous-réseau correspondant.

---

### Exercice 3.1.3

**Q1 : Quelle est la priorité de la route par défaut ?**

> La priorité par défaut est **1000**.
>
> Les priorités vont de 0 (la plus haute) à 65535 (la plus basse). 1000 est une valeur moyenne qui permet d'insérer des routes avec priorité plus haute ou plus basse.

**Q2 : Les routes de sous-réseau ont-elles un next-hop explicite ?**

> **Non**, les routes de sous-réseau n'ont pas de next-hop explicite comme une IP ou une instance.
>
> Elles ont un `nextHopNetwork` qui pointe vers le VPC lui-même, indiquant que le trafic reste dans le réseau local et est géré par le SDN de GCP.

**Q3 : Que signifie `nextHopNetwork` pour une route de sous-réseau ?**

> `nextHopNetwork` indique que le trafic correspondant à cette route reste **à l'intérieur du VPC**.
>
> Le SDN de GCP se charge de livrer le paquet directement à la VM de destination sans passer par un routeur intermédiaire explicite. C'est la magie du réseau software-defined.

---

### Exercice 3.1.4

**Q1 : Après suppression de la route par défaut, les VMs peuvent-elles accéder à Internet ?**

> **Non**, sans la route par défaut (0.0.0.0/0), les VMs ne peuvent pas accéder à Internet car elles ne savent pas où envoyer les paquets destinés à des IPs externes.
>
> Effets :
> - Pas d'accès aux sites web
> - Pas de téléchargement de packages (apt, pip...)
> - Les APIs Google restent accessibles si Private Google Access est activé

**Q2 : La route par défaut peut-elle être recréée avec une priorité différente ?**

> **Oui**, vous pouvez recréer la route par défaut avec n'importe quelle priorité (0-65535).
>
> Cela permet par exemple de :
> - Créer une route vers un proxy avec priorité 500
> - Garder la route Internet avec priorité 1000 comme backup
> - Le trafic passera par le proxy (priorité plus haute) sauf si celui-ci est indisponible

---

## Lab 3.2 : Routes statiques personnalisées et priorités

### Exercice 3.2.2

**Q1 : Un paquet vers 10.99.0.50 utilisera quelle route ? Pourquoi ?**

> Le paquet utilisera **route-specific** (10.99.0.0/24, priorité 100).
>
> Raison : Le **longest prefix match** s'applique en premier.
> - 10.99.0.50 correspond à 10.99.0.0/24 (/24 = masque de 24 bits)
> - 10.99.0.50 correspond aussi à 10.99.0.0/16 (/16 = masque de 16 bits)
> - /24 est plus spécifique que /16, donc route-specific gagne
>
> La priorité n'est pas consultée car les masques sont différents.

**Q2 : Un paquet vers 10.99.1.50 utilisera quelle route ? Pourquoi ?**

> Le paquet utilisera **route-broad** (10.99.0.0/16, priorité 1000).
>
> Raison : 
> - 10.99.1.50 ne correspond PAS à 10.99.0.0/24 (qui couvre uniquement 10.99.0.0-10.99.0.255)
> - 10.99.1.50 correspond à 10.99.0.0/16 (qui couvre 10.99.0.0-10.99.255.255)
> - Seule route-broad correspond, elle est donc utilisée

---

### Exercice 3.2.4

**Q1 : Si on supprime route-specific, quelle route sera utilisée pour 10.99.0.50 ?**

> La route **route-specific-backup** (10.99.0.0/24, priorité 500) sera utilisée.
>
> Explication :
> - Après suppression de route-specific, il reste route-specific-backup (/24) et route-broad (/16)
> - Pour 10.99.0.50, les deux correspondent mais /24 > /16 en spécificité
> - Donc route-specific-backup est choisie

**Q2 : Deux routes avec même destination ET même priorité : que se passe-t-il ?**

> GCP utilise un **algorithme déterministe interne** pour choisir une seule route.
>
> Points importants :
> - Il n'y a **pas de load balancing** entre les deux routes
> - Le choix est cohérent (même route toujours choisie) mais non documenté
> - En pratique, évitez cette situation en utilisant des priorités différentes
> - Si un next-hop devient indisponible, GCP bascule sur l'autre

---

## Lab 3.3 : Routage via appliance avec tags réseau

### Exercice 3.3.2

**Q1 : Cette route s'applique-t-elle à client2 ? Pourquoi ?**

> **Non**, la route ne s'applique pas à client2.
>
> Raison : La route a été créée avec `--tags=needs-proxy`. Seules les VMs possédant ce tag network sont affectées par cette route. Client2 n'a pas ce tag, donc il utilise les routes par défaut.

**Q2 : Sans le tag, quel chemin prend le trafic de client2 vers server ?**

> Le trafic de client2 vers server (10.2.0.50) prend le **chemin direct** via les routes de sous-réseau automatiques.
>
> Chemin : client2 → route de sous-réseau 10.2.0.0/24 → server
>
> Le SDN de GCP route directement le paquet sans passer par une appliance.

---

### Exercice 3.3.3

**Q1 : Le tcpdump sur proxy-vm voit-il le trafic de client1 ?**

> **Oui**, le tcpdump sur proxy-vm capture le trafic ICMP de client1.
>
> Parce que :
> - client1 a le tag `needs-proxy`
> - La route `route-via-proxy` avec ce tag dirige le trafic vers 10.2.0.0/24 via proxy-vm
> - Le paquet traverse physiquement proxy-vm avant d'atteindre server

**Q2 : Le tcpdump sur proxy-vm voit-il le trafic de client2 ?**

> **Non**, le tcpdump sur proxy-vm ne voit PAS le trafic de client2.
>
> Parce que :
> - client2 n'a pas le tag `needs-proxy`
> - La route personnalisée ne s'applique pas
> - Le trafic est routé directement vers server sans passer par proxy-vm

**Q3 : Comparez les traceroutes des deux clients.**

> **Depuis client1 (avec tag)** :
> ```
> 1  10.10.0.100 (proxy-vm)   0.5ms
> 2  10.2.0.50 (server)       1.2ms
> ```
>
> **Depuis client2 (sans tag)** :
> ```
> 1  10.2.0.50 (server)       0.8ms
> ```
>
> Client1 montre un hop supplémentaire (le proxy), tandis que client2 atteint server directement.

---

### Exercice 3.3.4

**Q1 : Le changement de tag est-il instantané ?**

> **Quasiment instantané** (quelques secondes).
>
> Les tags sont évalués en temps réel par le SDN de GCP. Dès qu'un tag est ajouté/retiré, les routes correspondantes s'appliquent ou cessent de s'appliquer.

**Q2 : Les connexions existantes sont-elles affectées ?**

> **Oui**, les connexions existantes peuvent être affectées.
>
> Les nouvelles décisions de routage s'appliquent aux paquets suivants. Une connexion TCP en cours pourrait voir son chemin changer, ce qui peut causer :
> - Réordonnancement de paquets
> - Potentielle rupture de connexion si le nouveau chemin ne fonctionne pas
>
> En production, planifiez ces changements avec soin.

---

## Lab 3.4 : Cloud Router et routes dynamiques (BGP)

### Exercice 3.4.1

**Q1 : Qu'est-ce qu'un ASN (Autonomous System Number) ?**

> Un **ASN** est un numéro unique qui identifie un réseau autonome dans le protocole BGP.
>
> - C'est comme un "numéro de téléphone" pour les réseaux
> - Permet aux routeurs BGP de s'identifier mutuellement
> - Utilisé pour échanger des routes entre organisations

**Q2 : Pourquoi utilise-t-on un ASN dans la plage 64512-65534 ?**

> Cette plage contient les **ASN privés** (comme les IPs privées RFC1918).
>
> - Plage privée : 64512-65534 (16 bits) ou 4200000000-4294967294 (32 bits)
> - Utilisables en interne sans enregistrement auprès d'un RIR
> - Parfaits pour les connexions VPN et Interconnect privées
> - Les ASN publics (1-64511) doivent être achetés/alloués officiellement

---

### Exercice 3.4.3

**Q1 : Quelle est la différence entre `DEFAULT` et `CUSTOM` pour advertisement-mode ?**

> | Mode | Comportement |
> |------|-------------|
> | **DEFAULT** | Annonce automatiquement toutes les plages des sous-réseaux du VPC |
> | **CUSTOM** | Vous choisissez exactement quoi annoncer (sous-réseaux + plages personnalisées) |
>
> CUSTOM permet d'ajouter des plages qui n'existent pas encore dans vos sous-réseaux (planification) ou d'exclure certains sous-réseaux des annonces.

**Q2 : Pourquoi voudrait-on annoncer des plages supplémentaires ?**

> Cas d'usage :
> 1. **Agrégation** : Annoncer un /16 au lieu de plusieurs /24 pour simplifier les tables de routage
> 2. **Planification** : Annoncer des plages réservées pour de futurs sous-réseaux
> 3. **Services managés** : Annoncer les plages de Cloud SQL, GKE, etc. vers on-premise
> 4. **Abstraction** : Cacher la structure interne du réseau aux partenaires externes

---

## Lab 3.5 : Cloud NAT - Configuration et monitoring

### Exercice 3.5.4

**Q1 : L'IP publique vue par les serveurs externes est-elle l'IP de la VM ?**

> **Non**, l'IP vue par les serveurs externes est l'**IP du Cloud NAT**, pas celle de la VM.
>
> La VM n'a pas d'IP externe (`--no-address`). Cloud NAT effectue la translation :
> - IP source sortante : IP NAT (ex: 34.76.x.x)
> - IP source réelle de la VM : IP privée (ex: 10.1.0.10)
>
> C'est le principe même du NAT : masquer les IPs internes.

**Q2 : Plusieurs VMs partagent-elles la même IP NAT ?**

> **Oui**, par défaut toutes les VMs d'une région partagent les mêmes IPs NAT.
>
> Cloud NAT utilise le **PAT (Port Address Translation)** :
> - Chaque VM obtient un pool de ports sur l'IP NAT
> - Minimum 64 ports par VM par défaut
> - Une IP NAT peut servir ~1000 VMs (64000 ports / 64 ports par VM)
>
> Ajoutez plus d'IPs NAT si vous avez beaucoup de VMs ou de connexions.

---

## Lab 3.6 : Private Google Access

### Exercice 3.6.4

**Q1 : Private Google Access permet-il d'accéder à github.com ?**

> **Non**, PGA ne permet PAS d'accéder à github.com ni à aucun site Internet tiers.
>
> PGA permet uniquement d'accéder aux :
> - APIs Google Cloud (storage.googleapis.com, bigquery.googleapis.com...)
> - Services Google (packages.cloud.google.com, gcr.io...)
>
> Pour github.com, npm, pypi, etc., vous avez besoin de Cloud NAT.

**Q2 : Peut-on combiner Cloud NAT et Private Google Access ?**

> **Oui**, c'est même la configuration recommandée pour les VMs backend.
>
> Combinaison :
> - **PGA** : Accès aux APIs Google via le réseau interne Google (gratuit, rapide)
> - **Cloud NAT** : Accès aux services tiers sur Internet (facturé)
>
> Le trafic vers les APIs Google n'utilise pas Cloud NAT quand PGA est activé.

**Q3 : PGA utilise-t-il la route par défaut (0.0.0.0/0) ?**

> **Non**, PGA utilise des routes spéciales vers les plages Google.
>
> Quand PGA est activé, le trafic vers les domaines *.googleapis.com est routé via des routes internes spéciales, pas via la route 0.0.0.0/0.
>
> C'est pourquoi PGA fonctionne même si vous supprimez la route par défaut.

---

## Lab 3.7 : Cloud DNS - Zones privées

### Exercice 3.7.3

**Q1 : La zone privée est-elle accessible depuis Internet ?**

> **Non**, une zone privée n'est jamais accessible depuis Internet.
>
> - Visibilité : uniquement les VPC listés dans la configuration
> - Les requêtes DNS depuis Internet ne peuvent pas résoudre ces noms
> - C'est l'intérêt : séparer le DNS interne du DNS public

**Q2 : Quel serveur DNS résout ces requêtes ?**

> Le serveur DNS interne de GCP à l'adresse **169.254.169.254** (metadata server).
>
> Ce serveur :
> - Est automatiquement configuré sur chaque VM
> - Résout les zones privées associées au VPC de la VM
> - Résout aussi le DNS interne automatique (*.internal)
> - Forward les autres requêtes vers les DNS publics

---

## Lab 3.8 : Cloud DNS - Zones publiques et forwarding

### Exercice 3.8.4

**Q1 : Quand utiliserait-on une zone de forwarding ?**

> Cas d'usage d'une **zone de forwarding** :
>
> 1. **Résolution hybride** : Résoudre les noms du datacenter on-premise depuis GCP
>    - Zone : corp.local
>    - Forwarding vers : DNS on-premise (192.168.1.53)
>
> 2. **DNS d'entreprise centralisé** : Utiliser un DNS existant pour certains domaines
>
> 3. **Split-horizon DNS** : Résolution différente selon qu'on est dans GCP ou ailleurs

**Q2 : Quelle est la différence entre une zone de forwarding et une politique DNS ?**

> | Aspect | Zone de Forwarding | Politique DNS |
> |--------|-------------------|---------------|
> | Portée | Un domaine spécifique (ex: corp.local) | Tout le trafic DNS du VPC |
> | Usage | Forward vers DNS on-premise pour CE domaine | Remplacer le DNS par défaut pour TOUT |
> | Granularité | Fine (par domaine) | Globale (tout ou rien) |
> | Cas typique | Résolution hybride | Utiliser uniquement un DNS d'entreprise |

---

# Corrigé du Quizz du Module 3

**1. Quelle règle s'applique en premier pour choisir une route ?**
- a. La priorité
- **b. Le longest prefix match** ✅
- c. L'ordre de création

> Le **longest prefix match** (correspondance de préfixe la plus longue) s'applique toujours en premier.
>
> La priorité n'est consultée que si plusieurs routes ont exactement la même destination (même masque). L'ordre de création n'est jamais un critère.

---

**2. Peut-on supprimer une route de sous-réseau ?**

> **Non**, une route de sous-réseau ne peut pas être supprimée directement.
>
> Elle est créée automatiquement avec le sous-réseau et supprimée uniquement quand le sous-réseau lui-même est supprimé. C'est une protection pour éviter de casser la connectivité.

---

**3. Quel service permet à une VM sans IP externe d'accéder à Internet ?**

> **Cloud NAT** (Network Address Translation)
>
> Cloud NAT permet aux VMs sans IP externe d'initier des connexions sortantes vers Internet. Le trafic sortant utilise les IPs du pool NAT.

---

**4. Quel composant est requis pour configurer Cloud NAT ?**

> Un **Cloud Router** est requis pour configurer Cloud NAT.
>
> Bien que Cloud NAT n'utilise pas BGP, il s'appuie sur l'infrastructure Cloud Router pour sa configuration. La commande est `gcloud compute routers nats create`.

---

**5. Quelle est la différence entre une zone DNS publique et privée ?**

> | Zone Publique | Zone Privée |
> |--------------|-------------|
> | Accessible depuis Internet | Accessible uniquement depuis les VPC autorisés |
> | Résolution mondiale | Résolution interne uniquement |
> | Nécessite un domaine que vous possédez | Peut utiliser n'importe quel nom (même fictif) |
> | Pour les sites/services publics | Pour les ressources internes |

---

**6. Que signifie BYOIP ?**

> **BYOIP** = **Bring Your Own IP**
>
> C'est la possibilité d'utiliser vos propres blocs d'adresses IP publiques dans GCP au lieu d'utiliser des IPs fournies par Google.
>
> Avantages :
> - Conserver vos IPs lors d'une migration cloud
> - Maintenir la réputation IP (email, SEO)
> - Éviter de changer les configurations chez les partenaires

---

**7. Private Google Access permet-il d'accéder à Internet ?**

> **Non**, Private Google Access ne permet PAS d'accéder à Internet.
>
> PGA permet uniquement d'accéder aux **APIs et services Google** (Cloud Storage, BigQuery, etc.) sans IP externe.
>
> Pour l'accès Internet général, utilisez Cloud NAT.

---

**8. Quel protocole utilise Cloud Router pour apprendre des routes dynamiquement ?**

> Cloud Router utilise le protocole **BGP** (Border Gateway Protocol).
>
> BGP est le protocole standard de routage inter-domaines :
> - Utilisé sur Internet pour l'échange de routes entre opérateurs
> - Cloud Router établit des sessions BGP avec vos équipements (VPN, routeurs on-premise)
> - Les routes sont apprises et annoncées dynamiquement

---

# Questions de réflexion supplémentaires

**Q1 : Pourquoi ne peut-on pas avoir deux routes avec même destination et même priorité vers des next-hops différents pour faire du load balancing ?**

> GCP ne supporte pas l'ECMP (Equal-Cost Multi-Path) au niveau des routes VPC.
>
> Raisons :
> - Complexité de gestion des sessions TCP (paquets d'une même connexion pourraient prendre des chemins différents)
> - Le load balancing est géré par d'autres services (Cloud Load Balancing)
> - Les routes sont déterministes pour la prévisibilité
>
> Pour le load balancing, utilisez un Internal Load Balancer comme next-hop.

**Q2 : Quelle est la différence entre `--can-ip-forward` sur une VM et une route personnalisée ?**

> Ce sont deux concepts complémentaires :
>
> | `--can-ip-forward` | Route personnalisée |
> |-------------------|---------------------|
> | Permission sur la VM | Directive dans la table de routage |
> | "Cette VM peut transférer des paquets qui ne lui sont pas destinés" | "Envoie les paquets vers X à cette VM" |
> | Sécurité (désactivé par défaut pour éviter le spoofing) | Routage (où envoyer le trafic) |
>
> Les deux sont nécessaires pour qu'une appliance fonctionne :
> 1. La route envoie le trafic vers l'appliance
> 2. `--can-ip-forward` autorise l'appliance à le transmettre

**Q3 : Comment diagnostiquer un problème de routage dans GCP ?**

> Étapes de diagnostic :
>
> 1. **Vérifier les routes** :
>    ```bash
>    gcloud compute routes list --filter="network=VPC_NAME"
>    ```
>
> 2. **Utiliser Connectivity Tests** :
>    ```bash
>    gcloud network-management connectivity-tests create test-name \
>        --source-instance=VM1 --destination-instance=VM2
>    ```
>
> 3. **Vérifier les règles de pare-feu** :
>    ```bash
>    gcloud compute firewall-rules list --filter="network=VPC_NAME"
>    ```
>
> 4. **Vérifier les tags** :
>    ```bash
>    gcloud compute instances describe VM_NAME --format="get(tags.items)"
>    ```
>
> 5. **Tester depuis la VM** :
>    ```bash
>    traceroute DESTINATION
>    ping DESTINATION
>    ```
>
> 6. **Consulter les logs VPC Flow** (si activés)

**Q4 : Cloud NAT vs NAT Instance : quelles différences ?**

> | Aspect | Cloud NAT | NAT Instance (VM) |
> |--------|-----------|-------------------|
> | Gestion | Managé par Google | Vous gérez la VM |
> | Haute disponibilité | Intégrée automatiquement | À configurer (instance group) |
> | Performance | Scalabilité automatique | Limitée par le type de VM |
> | Coût | Facturation NAT + egress | Coût VM + egress |
> | Maintenance | Aucune | Patches, sécurité, monitoring |
> | Configuration | Simple (gcloud) | Complexe (iptables, routing) |
>
> **Recommandation** : Utilisez Cloud NAT sauf cas très spécifiques nécessitant un contrôle total.
