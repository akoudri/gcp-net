# Module 6 - Cloud DNS
## Corrigé des Questions et du Quizz

---

# Corrigé des Questions des Labs

## Lab 6.1 : Zones privées - Configuration de base

### Exercice 6.1.6

**Q1 : Quel serveur DNS est configuré sur les VMs GCP ?**

> Le serveur DNS configuré sur les VMs GCP est **169.254.169.254** (metadata server).
>
> Vérification dans `/etc/resolv.conf` :
> ```
> nameserver 169.254.169.254
> search c.PROJECT_ID.internal. google.internal.
> ```
>
> Ce serveur metadata :
> - Est accessible depuis toutes les VMs GCP
> - Fournit la résolution DNS pour les zones privées Cloud DNS
> - Résout les noms DNS internes automatiques GCP
> - Transfère les requêtes vers les serveurs DNS appropriés
> - Ne nécessite aucune configuration de pare-feu (lien local)

**Q2 : Pourquoi utiliser un CNAME plutôt qu'un second enregistrement A ?**

> Avantages du CNAME par rapport à un second enregistrement A :
>
> | Aspect | CNAME | Second enregistrement A |
> |--------|-------|------------------------|
> | Maintenance | Une seule IP à mettre à jour | Deux IPs à maintenir |
> | Consistance | Toujours synchronisé avec la cible | Peut diverger si oublié |
> | Flexibilité | Peut pointer vers un autre domaine | Limité aux IPs |
> | Cas d'usage | Alias, sous-domaines | Load balancing DNS |
>
> Exemple :
> - `www.lab.internal` → CNAME → `vm1.lab.internal` → A → `10.0.0.10`
> - Si l'IP de vm1 change, seul l'enregistrement A de vm1 doit être mis à jour
> - `www` suivra automatiquement
>
> **Limitation CNAME** : Ne peut pas coexister avec d'autres enregistrements pour le même nom (sauf DNSSEC).

---

## Lab 6.4 : Forwarding DNS vers on-premise

### Exercice 6.4.6

**Q1 : Pourquoi le forwarding utilise-t-il le routage privé pour les IPs RFC 1918 ?**

> Cloud DNS utilise automatiquement le **routage privé** pour les IPs RFC 1918 (10.x.x.x, 172.16.x.x, 192.168.x.x) car :
>
> 1. **Ces IPs ne sont pas routables sur Internet** : Elles nécessitent un chemin privé (VPN/Interconnect)
>
> 2. **Sécurité** : Le trafic DNS reste dans le réseau privé, pas exposé sur Internet
>
> 3. **Détection automatique** : GCP reconnaît les IPs privées et route via le réseau interne
>
> Pour forcer le routage public (IPs publiques), il faut utiliser l'option explicite dans la configuration de forwarding.
>
> ```
> Routage privé (par défaut pour RFC 1918):
> VM GCP → VPN/Interconnect → Serveur DNS on-premise (192.168.1.53)
>
> Routage public (pour IPs publiques):
> VM GCP → Internet → Serveur DNS externe (8.8.8.8)
> ```

**Q2 : Que se passe-t-il si le serveur DNS cible est injoignable ?**

> Si le serveur DNS cible est injoignable :
>
> 1. **Timeout** : Cloud DNS attend une réponse pendant un délai configuré
>
> 2. **Retry** : Tentatives de retry vers les autres serveurs cibles (si plusieurs configurés)
>
> 3. **SERVFAIL** : Si tous les serveurs échouent, retourne un code SERVFAIL au client
>
> 4. **Pas de fallback** : Cloud DNS ne bascule PAS automatiquement vers un DNS public
>
> **Bonnes pratiques** :
> - Configurer plusieurs serveurs DNS cibles pour la redondance
> - Monitorer la disponibilité des serveurs DNS
> - Avoir des alertes sur les échecs de résolution
>
> ```bash
> # Configurer plusieurs cibles pour la redondance
> --forwarding-targets="192.168.1.53,192.168.1.54"
> ```

---

## Lab 6.6 : Peering DNS entre VPC

### Exercice 6.6.5

**Q1 : La VM spoke peut-elle faire un ping vers api.services.internal ?**

> **Non**, la VM spoke ne peut probablement PAS faire un ping vers api.services.internal.
>
> Le **peering DNS** permet uniquement la **résolution de noms**, pas la connectivité réseau.
>
> Pour que le ping fonctionne, il faudrait également :
> 1. Un **VPC Peering** entre vpc-spoke et vpc-hub
> 2. Ou un **Shared VPC** avec les deux projets
> 3. Ou une autre forme de connectivité réseau (VPN, etc.)
>
> ```
> Peering DNS seul:
> VM spoke → nslookup api.services.internal → ✅ 10.10.0.10
> VM spoke → ping api.services.internal → ❌ Network unreachable
>
> Peering DNS + VPC Peering:
> VM spoke → nslookup api.services.internal → ✅ 10.10.0.10
> VM spoke → ping api.services.internal → ✅ Reply from 10.10.0.10
> ```

**Q2 : Quelle est la différence entre peering DNS et peering VPC ?**

> | Aspect | Peering DNS | VPC Peering |
> |--------|-------------|-------------|
> | **Fonction** | Résolution de noms | Connectivité réseau |
> | **Trafic** | DNS uniquement (port 53) | Tout le trafic IP |
> | **Configuration** | Par zone DNS | Par VPC |
> | **Transitivité** | Non | Non |
> | **Routes** | Pas d'échange de routes | Échange de routes |
> | **Cas d'usage** | DNS centralisé | Communication inter-VPC |
>
> **Combinaison courante** :
> Pour une architecture hub-and-spoke complète, vous avez besoin des deux :
> - Peering DNS : Pour que les spokes résolvent les noms du hub
> - VPC Peering : Pour que les spokes communiquent avec le hub

---

## Lab 6.9 : Split-horizon DNS

### Exercice 6.9.5 - Priorité des zones

**Pourquoi la zone privée a-t-elle priorité sur la zone publique ?**

> C'est par **conception** de Cloud DNS pour des raisons de sécurité et de contrôle :
>
> 1. **Contrôle local** : L'administrateur du VPC peut décider ce que voient ses VMs
>
> 2. **Sécurité** : Empêche l'exposition accidentelle de services internes
>
> 3. **Performance** : Évite les requêtes externes inutiles
>
> 4. **Flexibilité** : Permet le split-horizon natif
>
> **Ordre de résolution** :
> ```
> 1. Zones privées attachées au VPC          [PRIORITÉ HAUTE]
> 2. Zones de peering DNS
> 3. Zones de forwarding
> 4. DNS interne automatique GCP
> 5. Résolution publique (Internet)          [PRIORITÉ BASSE]
> ```
>
> **Conséquence pratique** :
> Si vous créez une zone privée `google.com.` dans votre VPC, les VMs de ce VPC ne pourront plus accéder à Google via DNS !

---

# Corrigé du Quizz du Module 6

**1. Quel est le SLA de disponibilité de Cloud DNS ?**
- a. 99.9%
- b. 99.99%
- **c. 100%** ✅

> Cloud DNS est le **seul service GCP avec un SLA de 100%**.
>
> Caractéristiques qui permettent ce SLA :
> - Réseau Anycast mondial
> - Infrastructure distribuée
> - Réplication automatique
> - Aucune maintenance planifiée affectant la disponibilité
>
> Note : Ce SLA s'applique aux zones hébergées, pas aux zones de forwarding qui dépendent des serveurs cibles.

---

**2. Une zone privée peut-elle être associée à plusieurs VPC ?**

> **Oui**, une zone privée peut être associée à plusieurs VPC.
>
> ```bash
> # Créer une zone avec plusieurs VPC
> gcloud dns managed-zones create zone-shared \
>     --dns-name="shared.internal." \
>     --visibility=private \
>     --networks=vpc-prod,vpc-dev,vpc-staging
>
> # Ou mettre à jour une zone existante
> gcloud dns managed-zones update zone-shared \
>     --networks=vpc-prod,vpc-dev,vpc-staging,vpc-new
> ```
>
> Cas d'usage :
> - Services partagés entre environnements
> - DNS centralisé pour plusieurs VPC
> - Éviter la duplication des enregistrements

---

**3. Quel type de zone permet de transférer les requêtes vers un DNS on-premise ?**

> Une **zone de forwarding** (forwarding zone) permet de transférer les requêtes vers un DNS on-premise.
>
> ```bash
> gcloud dns managed-zones create zone-forward-onprem \
>     --dns-name="corp.local." \
>     --visibility=private \
>     --networks=mon-vpc \
>     --forwarding-targets="192.168.1.53,192.168.1.54"
> ```
>
> Fonctionnement :
> - Les requêtes pour `*.corp.local` sont transférées vers les serveurs spécifiés
> - Utilise le routage privé pour les IPs RFC 1918
> - Nécessite une connectivité VPN/Interconnect

---

**4. À quoi sert le peering DNS ?**

> Le **peering DNS** permet de résoudre des noms d'une zone privée d'un autre VPC.
>
> Cas d'usage :
> - Architecture hub-and-spoke avec DNS centralisé
> - Partager des zones DNS entre VPC sans les dupliquer
> - Séparation des environnements avec DNS centralisé
>
> ```bash
> # Dans le VPC spoke, créer un peering vers le hub
> gcloud dns managed-zones create peering-to-hub \
>     --dns-name="services.internal." \
>     --visibility=private \
>     --networks=vpc-spoke \
>     --target-network=vpc-hub
> ```
>
> **Important** : Le peering DNS concerne UNIQUEMENT la résolution DNS, pas la connectivité réseau.

---

**5. Que permet DNSSEC ?**
- a. Chiffrer les requêtes DNS
- **b. Authentifier les réponses DNS** ✅
- c. Accélérer la résolution DNS

> DNSSEC permet d'**authentifier les réponses DNS** (vérifier qu'elles n'ont pas été falsifiées).
>
> Ce que DNSSEC fait :
> - Signe cryptographiquement les enregistrements DNS
> - Permet de vérifier l'intégrité des réponses
> - Crée une chaîne de confiance depuis la racine DNS
>
> Ce que DNSSEC ne fait PAS :
> - ❌ Chiffrer les requêtes (pour ça, utiliser DNS-over-HTTPS ou DNS-over-TLS)
> - ❌ Accélérer la résolution (ajoute même un léger overhead)
> - ❌ Cacher le contenu des requêtes

---

**6. Dans un split-horizon, quelle zone a la priorité pour les VMs du VPC ?**

> La **zone privée** a priorité sur la zone publique pour les VMs du VPC.
>
> Ordre de résolution :
> 1. Zone privée attachée au VPC → **PRIORITÉ**
> 2. Zone publique (via Internet)
>
> Exemple :
> - Zone publique `example.com` : api.example.com → 35.x.x.x
> - Zone privée `example.com` : api.example.com → 10.0.0.50
>
> Résultat :
> - VM du VPC → résout vers 10.0.0.50 (zone privée)
> - Client Internet → résout vers 35.x.x.x (zone publique)

---

**7. Quel type de routing policy permet de distribuer le trafic avec des poids ?**

> Le **Weighted Round Robin (WRR)** permet de distribuer le trafic avec des poids.
>
> ```bash
> gcloud dns record-sets create "app.example.com." \
>     --zone=zone-public \
>     --type=A \
>     --ttl=60 \
>     --routing-policy-type=WRR \
>     --routing-policy-data="0.8=10.0.0.1;0.2=10.0.0.2"
> ```
>
> Dans cet exemple :
> - 80% du trafic vers 10.0.0.1
> - 20% du trafic vers 10.0.0.2
>
> Cas d'usage :
> - Canary deployments
> - Migration progressive
> - A/B testing

---

**8. Comment les serveurs on-premise peuvent-ils résoudre des noms via Cloud DNS ?**

> Les serveurs on-premise peuvent résoudre des noms via Cloud DNS grâce à l'**Inbound DNS Forwarding**.
>
> Configuration :
> ```bash
> # 1. Activer l'inbound forwarding
> gcloud dns policies create policy-inbound \
>     --networks=mon-vpc \
>     --enable-inbound-forwarding
>
> # 2. Récupérer les adresses de forwarding
> gcloud compute addresses list --filter="purpose=DNS_RESOLVER"
> ```
>
> Ensuite, configurer les serveurs DNS on-premise pour transférer vers ces adresses via VPN/Interconnect.
>
> Flux :
> ```
> Serveur on-premise → DNS on-prem → VPN/Interconnect → 
>     Inbound Forwarder (10.x.x.2) → Cloud DNS → Réponse
> ```

---

# Questions de réflexion supplémentaires

**Q1 : Une entreprise a plusieurs VPC (prod, dev, staging) et veut centraliser la gestion DNS. Quelle architecture recommandez-vous ?**

> Architecture recommandée : **Hub DNS centralisé avec peering DNS**
>
> ```
>                     VPC Hub (DNS)
>                    ┌─────────────────┐
>                    │ Zone: *.internal│
>                    │ Zone: corp.local│
>                    │ (forwarding)    │
>                    └────────┬────────┘
>                             │
>        ┌────────────────────┼────────────────────┐
>        │                    │                    │
>        ▼                    ▼                    ▼
>    VPC Prod            VPC Dev             VPC Staging
>    (peering DNS)       (peering DNS)       (peering DNS)
> ```
>
> Avantages :
> - Une seule zone à maintenir
> - Cohérence des enregistrements
> - Gestion centralisée par l'équipe plateforme
> - Les équipes applicatives n'ont pas à gérer le DNS
>
> Configuration :
> 1. Créer les zones dans le VPC Hub
> 2. Créer des zones de peering DNS dans chaque VPC spoke
> 3. (Optionnel) Ajouter un VPC Peering pour la connectivité réseau

---

**Q2 : Comment détecter et analyser les tentatives d'exfiltration de données via DNS ?**

> Stratégie de détection :
>
> 1. **Activer le DNS Logging** :
>    ```bash
>    gcloud dns policies create policy-security \
>        --networks=mon-vpc \
>        --enable-logging
>    ```
>
> 2. **Analyser les patterns suspects** :
>    - Requêtes vers des domaines inhabituels
>    - Volume élevé de requêtes TXT
>    - Noms de domaine avec des sous-domaines très longs (données encodées)
>    - Requêtes vers des domaines récemment créés
>
> 3. **Requête d'analyse dans Cloud Logging** :
>    ```
>    resource.type="dns_query"
>    jsonPayload.queryType="TXT"
>    ```
>
> 4. **Alertes Cloud Monitoring** :
>    - Volume de requêtes DNS anormalement élevé
>    - Requêtes vers des domaines sur liste noire
>    - Patterns d'exfiltration connus
>
> 5. **Intégration SIEM** :
>    - Exporter les logs vers Chronicle, Splunk, etc.
>    - Corréler avec d'autres événements de sécurité

---

**Q3 : Quelle est la différence entre une zone de forwarding et une politique DNS avec serveurs alternatifs ?**

> | Aspect | Zone de Forwarding | Politique DNS (serveurs alternatifs) |
> |--------|-------------------|--------------------------------------|
> | **Portée** | Un domaine spécifique | TOUT le trafic DNS du VPC |
> | **Exemple** | corp.local → DNS on-prem | Toutes requêtes → DNS on-prem |
> | **Granularité** | Fine (par domaine) | Globale |
> | **Cas d'usage** | Résoudre un domaine on-premise | Remplacer le DNS GCP par le vôtre |
> | **Fallback** | Autres zones pour autres domaines | Pas de fallback vers DNS GCP |
>
> **Zone de forwarding** (recommandé pour la plupart des cas) :
> ```bash
> # Seules les requêtes pour corp.local vont vers le DNS on-prem
> gcloud dns managed-zones create forward-corp \
>     --dns-name="corp.local." \
>     --forwarding-targets="192.168.1.53"
> ```
>
> **Politique DNS avec serveurs alternatifs** :
> ```bash
> # TOUTES les requêtes vont vers les serveurs alternatifs
> gcloud dns policies create policy-custom \
>     --networks=mon-vpc \
>     --alternative-name-servers="192.168.1.53,192.168.1.54"
> ```

---

**Q4 : Comment gérer les conflits de noms DNS entre zones ?**

> Les conflits sont résolus par l'**ordre de priorité** de Cloud DNS :
>
> 1. **Zone privée la plus spécifique** gagne
>    - Zone `api.example.com` a priorité sur zone `example.com`
>
> 2. **À spécificité égale**, la zone privée attachée au VPC gagne sur :
>    - Peering DNS
>    - Forwarding
>    - DNS public
>
> **Bonnes pratiques pour éviter les conflits** :
>
> 1. **Convention de nommage claire** :
>    - `prod.internal.` pour production
>    - `dev.internal.` pour développement
>    - Éviter les domaines publics pour le DNS privé
>
> 2. **Documentation** :
>    - Maintenir un registre de toutes les zones DNS
>    - Documenter les VPC attachés à chaque zone
>
> 3. **Vérification avant création** :
>    ```bash
>    # Lister toutes les zones existantes
>    gcloud dns managed-zones list
>    
>    # Vérifier si un domaine existe déjà
>    gcloud dns managed-zones list --filter="dnsName:example.com"
>    ```

---

**Q5 : Comment migrer d'un DNS on-premise vers Cloud DNS ?**

> Plan de migration en phases :
>
> **Phase 1 : Préparation**
> - Inventorier toutes les zones et enregistrements on-premise
> - Identifier les dépendances (applications, services)
> - Planifier le découpage par zone
>
> **Phase 2 : Configuration parallèle**
> ```bash
> # Créer les zones dans Cloud DNS
> gcloud dns managed-zones create zone-migree \
>     --dns-name="example.com." \
>     --visibility=private \
>     --networks=mon-vpc
>
> # Importer les enregistrements
> gcloud dns record-sets import fichier-zone.zone \
>     --zone=zone-migree \
>     --zone-file-format
> ```
>
> **Phase 3 : Tests**
> - Tester la résolution depuis les VMs GCP
> - Vérifier les enregistrements critiques
> - Valider avec les équipes applicatives
>
> **Phase 4 : Basculement progressif**
> - Configurer l'inbound forwarding pour permettre aux serveurs on-premise de résoudre via Cloud DNS
> - Migrer les applications par lots
> - Monitorer les erreurs DNS
>
> **Phase 5 : Décommissionnement**
> - Une fois tous les clients migrés, supprimer les zones on-premise
> - Supprimer les zones de forwarding devenues inutiles
