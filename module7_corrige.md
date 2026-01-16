# Module 7 - Options de Connectivité Hybride
## Corrigé des Questions et du Quizz

---

# Corrigé des Questions des Labs

## Lab 7.1 : Cloud VPN HA - Configuration complète

### Exercice 7.1.9

**Q1 : Combien de "hops" montre le traceroute ? Pourquoi ?**

> Le traceroute montre généralement **1 à 2 hops** seulement.
>
> Explication :
> - Le tunnel VPN est une connexion logique point-à-point
> - Le trafic est encapsulé dans IPsec et traverse Internet de manière transparente
> - Du point de vue applicatif, le tunnel apparaît comme un lien direct
>
> Détail des hops possibles :
> ```
> Hop 1: Passerelle VPN locale (169.254.x.x - IP BGP)
> Hop 2: VM destination (192.168.0.10)
> ```
>
> Les routeurs Internet entre les deux extrémités du tunnel ne sont pas visibles car :
> - Le paquet original est encapsulé dans IPsec
> - Seuls les endpoints du tunnel décrément le TTL
> - Le traceroute ne "voit" que le tunnel comme un seul lien

**Q2 : Pourquoi avons-nous créé 4 tunnels au total ?**

> Nous avons créé **4 tunnels** pour assurer la haute disponibilité bidirectionnelle :
>
> ```
> Côté GCP:
> ├── tunnel-gcp-to-onprem-0 (Interface 0 → Interface 0)
> └── tunnel-gcp-to-onprem-1 (Interface 1 → Interface 1)
>
> Côté On-premise:
> ├── tunnel-onprem-to-gcp-0 (Interface 0 → Interface 0)
> └── tunnel-onprem-to-gcp-1 (Interface 1 → Interface 1)
> ```
>
> Raisons :
> 1. **Redondance** : Si une interface tombe, l'autre prend le relais
> 2. **HA VPN** : Chaque passerelle HA a 2 interfaces avec IPs distinctes
> 3. **SLA 99.99%** : Nécessite 2 tunnels minimum vers des interfaces distinctes
> 4. **ECMP** : Les 2 tunnels actifs permettent d'agréger la bande passante
>
> Note : Dans un scénario GCP ↔ GCP, les tunnels sont créés des deux côtés.
> Dans un scénario GCP ↔ équipement physique on-premise, seuls 2 tunnels côté GCP sont nécessaires (l'équipement on-premise gère son côté).

---

## Lab 7.3 : VPN Actif/Actif vs Actif/Passif

### Comparaison des modes

**Quand choisir Actif/Actif ?**

> Choisir **Actif/Actif (ECMP)** quand :
>
> ✅ Vous voulez maximiser la bande passante (agrégation des tunnels)
> ✅ Votre équipement on-premise supporte ECMP
> ✅ Vos applications tolèrent l'asymétrie de chemin
> ✅ Vous n'avez pas de firewall stateful sensible à l'ordre des paquets
>
> Avantages :
> - Bande passante théorique : 2 × 3 Gbps = ~6 Gbps
> - Utilisation optimale des ressources
> - Failover automatique sans perte de capacité

**Quand choisir Actif/Passif ?**

> Choisir **Actif/Passif** quand :
>
> ✅ Votre firewall on-premise est stateful et sensible à l'asymétrie
> ✅ Vous voulez simplifier le troubleshooting
> ✅ Un seul chemin doit être utilisé pour des raisons de coût
> ✅ Vous avez des exigences de conformité sur le chemin du trafic
>
> Configuration avec MED :
> ```
> Tunnel principal: MED = 100 (préféré)
> Tunnel backup:    MED = 200 (utilisé uniquement si principal down)
> ```

---

## Lab 7.4 : Failover et haute disponibilité VPN

### Temps de convergence

**Quels sont les facteurs influençant le temps de failover ?**

> Facteurs principaux :
>
> | Facteur | Impact | Valeur typique |
> |---------|--------|----------------|
> | Hold Timer BGP | Temps avant déclaration de panne | 60 secondes |
> | Keepalive BGP | Fréquence des messages | 20 secondes |
> | Nombre de routes | Temps de mise à jour | Quelques secondes |
> | BFD (si activé) | Détection rapide | <1 seconde |
>
> Temps de convergence typique :
> - **Sans BFD** : 30-90 secondes
> - **Avec BFD** : <3 secondes
>
> Recommandations :
> - Utiliser BFD si disponible sur l'équipement peer
> - Ne pas réduire les timers BGP de manière trop agressive
> - Avoir des tunnels sur des interfaces physiquement distinctes

---

## Lab 7.5 : Dedicated Interconnect

### Comparaison avec Partner Interconnect

**Quels sont les critères de choix entre Dedicated et Partner ?**

> | Critère | Dedicated | Partner |
> |---------|-----------|---------|
> | Présence colo Google | Requise | Non requise |
> | Bande passante min | 10 Gbps | 50 Mbps |
> | Bande passante max | 200 Gbps | 50 Gbps |
> | Délai provisioning | 4-8 semaines | 1-2 semaines |
> | Contrôle | Total | Via partenaire |
> | Coût | Plus élevé | Plus accessible |
>
> Règle simple :
> - **Dedicated** : Si vous êtes dans une colo Google ET avez besoin de >10 Gbps
> - **Partner** : Dans tous les autres cas

---

## Lab 7.8 : Network Connectivity Center

### Avantages de NCC

**Pourquoi utiliser NCC plutôt que des VPN point-à-point ?**

> Comparaison avec 10 sites :
>
> **Sans NCC (full mesh VPN)** :
> - Connexions nécessaires : n × (n-1) / 2 = 45 connexions
> - Configuration complexe
> - Maintenance difficile
> - Pas de visibilité centralisée
>
> **Avec NCC (hub-and-spoke)** :
> - Connexions nécessaires : n = 10 (une par site vers le hub)
> - Configuration simplifiée
> - Gestion centralisée
> - Connectivité transitive automatique
>
> Fonctionnalités NCC :
> - **Connectivité transitive** : Paris ↔ Hub ↔ Lyon (pas besoin de VPN direct Paris-Lyon)
> - **Routage centralisé** : Le hub gère l'échange de routes
> - **Multi-type** : Supporte VPN, Interconnect, Router Appliance
> - **site-to-site-data-transfer** : Active la communication entre spokes

---

# Corrigé du Quizz du Module 7

**1. Quelle est la bande passante maximale d'un tunnel Cloud VPN ?**
- a. 1 Gbps
- **b. 3 Gbps** ✅
- c. 10 Gbps

> Un tunnel Cloud VPN offre jusqu'à **3 Gbps** de bande passante.
>
> Pour obtenir plus :
> - Utiliser plusieurs tunnels avec ECMP
> - 2 tunnels × 3 Gbps = ~6 Gbps théoriques
> - Maximum pratique : ~8-10 tunnels (~24-30 Gbps)
>
> Si besoin de plus de bande passante, utiliser Cloud Interconnect.

---

**2. Quel type de VPN est recommandé pour la production ?**

> **HA VPN** est recommandé pour la production.
>
> Comparaison :
> | Aspect | Classic VPN | HA VPN |
> |--------|-------------|--------|
> | SLA | 99.9% | 99.99% |
> | Tunnels | 1 seul | 2 minimum |
> | Routage | Statique ou BGP | BGP obligatoire |
> | Status | Dépréciation annoncée | Recommandé |
>
> HA VPN garantit :
> - Redondance automatique
> - Failover sans intervention
> - SLA de disponibilité supérieur

---

**3. Quel protocole de routage est obligatoire avec HA VPN ?**

> **BGP (Border Gateway Protocol)** est obligatoire avec HA VPN.
>
> Raisons :
> - Échange dynamique des routes
> - Détection automatique des pannes
> - Failover sans configuration manuelle
> - Support ECMP pour la répartition de charge
>
> Cloud Router gère les sessions BGP et :
> - Annonce les sous-réseaux VPC automatiquement
> - Apprend les routes du peer
> - Installe les routes dans le VPC

---

**4. Quelle est la différence principale entre Dedicated et Partner Interconnect ?**

> La différence principale est le **mode de connexion physique** :
>
> **Dedicated Interconnect** :
> - Connexion physique DIRECTE à Google
> - Vous gérez le cross-connect dans la colocation
> - Nécessite présence dans une colo où Google est présent
> - Capacité : 10-200 Gbps
>
> **Partner Interconnect** :
> - Connexion VIA un partenaire télécom
> - Le partenaire gère la connexion physique
> - Accessible depuis n'importe où (via le réseau du partenaire)
> - Capacité : 50 Mbps - 50 Gbps
>
> En résumé : Dedicated = direct, Partner = indirect via un tiers.

---

**5. Pour atteindre un SLA de 99.99% avec Interconnect, combien de circuits minimum faut-il ?**

> Il faut **2 circuits dans des metros différents** pour atteindre 99.99%.
>
> Niveaux de SLA :
> | Configuration | SLA |
> |--------------|-----|
> | 1 circuit, 1 attachment | Aucun SLA |
> | 2 circuits, même metro | 99.9% |
> | 2 circuits, metros différents | 99.99% |
>
> Configuration 99.99% :
> ```
> Metro 1 (Paris)
> ├── Interconnect 1
> └── VLAN Attachment 1
>
> Metro 2 (Francfort)
> ├── Interconnect 2
> └── VLAN Attachment 2
>
> + Cloud Router avec routage global
> + BGP pour failover automatique
> ```

---

**6. Cross-Cloud Interconnect permet de se connecter à quels clouds ?**

> Cross-Cloud Interconnect supporte :
>
> - **AWS** (Amazon Web Services)
> - **Microsoft Azure**
> - **Oracle Cloud Infrastructure (OCI)**
> - **Alibaba Cloud**
>
> Caractéristiques :
> - Connexion dédiée entre clouds (pas via Internet)
> - Bande passante : 10-100 Gbps
> - Nécessite une colocation commune aux deux providers
> - Configuration BGP des deux côtés

---

**7. Quel service permet une connectivité transitive entre plusieurs sites via GCP ?**

> **Network Connectivity Center (NCC)** permet la connectivité transitive.
>
> Fonctionnement :
> ```
> Site A ──► Hub NCC ◄── Site B
>              │
>              ▼
>           Site C
>
> Résultat: A ↔ B ↔ C sans VPN direct entre eux
> ```
>
> Avantages :
> - Architecture hub-and-spoke simplifiée
> - Routage centralisé
> - Réduction du nombre de connexions
> - Gestion unifiée

---

**8. Classez par ordre croissant de coût : VPN, Dedicated Interconnect, Partner Interconnect.**

> Ordre croissant de coût :
>
> 1. **Cloud VPN** (~100-300€/mois)
>    - Coût le plus bas
>    - Idéal pour dev/test, PME, faible bande passante
>
> 2. **Partner Interconnect** (~500-1500€/mois pour 1 Gbps)
>    - Coût intermédiaire
>    - Bon compromis performance/prix
>
> 3. **Dedicated Interconnect** (~2000-5000€/mois pour 10 Gbps)
>    - Coût le plus élevé
>    - Pour grandes entreprises, workloads critiques
>
> Note : Les coûts varient selon la région, la capacité, et le volume de trafic.
> Le trafic via Interconnect bénéficie de tarifs réduits par rapport au trafic Internet.

---

# Questions de réflexion supplémentaires

**Q1 : Une entreprise a 3 sites (Paris, Lyon, Marseille) et veut les connecter à GCP. Chaque site a besoin de 500 Mbps. Quelle architecture recommandez-vous ?**

> Architecture recommandée : **Cloud VPN HA avec Network Connectivity Center**
>
> Raisons :
> - 500 Mbps < 3 Gbps : VPN suffisant
> - 3 sites : NCC simplifie la gestion
> - Coût optimisé vs Interconnect
>
> Configuration :
> ```
> Site Paris ──VPN──► 
>                      Hub NCC (GCP)
> Site Lyon ──VPN──►       │
>                          │
> Site Marseille ──VPN──►  │
>                          ▼
>                    VPC Production
> ```
>
> Avantages :
> - Les 3 sites communiquent entre eux via le hub
> - Failover automatique via BGP
> - Coût : ~300€/mois × 3 sites = ~900€/mois

---

**Q2 : Comment sécuriser davantage une connexion Cloud Interconnect ?**

> Options de sécurisation pour Interconnect :
>
> 1. **MACsec (Layer 2)**
>    - Chiffrement au niveau liaison
>    - Disponible sur Dedicated Interconnect
>    - Protège contre l'écoute sur le cross-connect
>
> 2. **VPN over Interconnect**
>    - Tunnels IPsec sur l'Interconnect
>    - Double protection : Interconnect privé + chiffrement VPN
>    - Recommandé pour données très sensibles
>
> 3. **Firewall rules**
>    - Restreindre le trafic autorisé via l'Interconnect
>    - N'autoriser que les plages IP spécifiques
>
> 4. **Cloud Armor / Cloud IDS**
>    - Détection d'intrusion sur le trafic
>    - Protection contre les attaques
>
> 5. **VPC Service Controls**
>    - Périmètre de sécurité pour les données
>    - Empêche l'exfiltration
>
> Recommandation production :
> ```
> Interconnect + MACsec + VPN (IPsec) + Firewall rules + VPC-SC
> ```

---

**Q3 : Votre VPN fonctionne mais les performances sont mauvaises. Comment diagnostiquer ?**

> Checklist de diagnostic VPN :
>
> 1. **Vérifier la MTU**
>    ```bash
>    # Tester avec différentes tailles de paquet
>    ping -M do -s 1400 DESTINATION
>    ping -M do -s 1300 DESTINATION
>    ```
>    - MTU recommandée : 1460 (pour éviter fragmentation)
>    - Configurer sur les VMs et l'équipement on-premise
>
> 2. **Vérifier la latence de base**
>    ```bash
>    # Mesurer la latence Internet entre les endpoints
>    mtr PEER_VPN_IP
>    ```
>    - VPN ne peut pas être plus rapide que le chemin Internet
>
> 3. **Vérifier le routage**
>    ```bash
>    gcloud compute routes list --filter="network:VPC"
>    ```
>    - Vérifier que le trafic passe par le bon tunnel
>    - Vérifier les priorités si Actif/Passif
>
> 4. **Vérifier les métriques**
>    - Cloud Console > Hybrid Connectivity > VPN
>    - Métriques : bytes_sent, bytes_received, dropped_packets
>
> 5. **Vérifier les sessions BGP**
>    ```bash
>    gcloud compute routers get-status ROUTER --region=REGION
>    ```
>    - Status doit être ESTABLISHED
>    - Vérifier les routes apprises
>
> 6. **Tester la bande passante**
>    ```bash
>    # Installer iperf3 des deux côtés
>    iperf3 -s  # Serveur
>    iperf3 -c DESTINATION  # Client
>    ```
>    - Comparer avec la bande passante attendue (3 Gbps max/tunnel)

---

**Q4 : Quelle est la différence entre un VLAN attachment et un tunnel VPN ?**

> | Aspect | VLAN Attachment (Interconnect) | Tunnel VPN |
> |--------|-------------------------------|------------|
> | Couche | Layer 2/3 | Layer 3 (IPsec) |
> | Support | Connexion physique Interconnect | Internet |
> | Chiffrement | Optionnel (MACsec) | Natif (IPsec) |
> | Bande passante | Jusqu'à 200 Gbps | Jusqu'à 3 Gbps |
> | Latence | Très faible (privé) | Variable (Internet) |
> | Configuration | VLAN ID + BGP | IKE + BGP |
>
> VLAN Attachment :
> - C'est la "terminaison logique" d'un Interconnect
> - Permet de connecter l'Interconnect à un VPC via Cloud Router
> - Peut avoir plusieurs attachments sur un seul Interconnect (multi-VPC)
>
> Tunnel VPN :
> - Connexion chiffrée point-à-point
> - Traverse Internet
> - Plus simple à déployer, moins performant

---

**Q5 : Comment planifier une migration de VPN vers Interconnect sans interruption ?**

> Plan de migration VPN → Interconnect :
>
> **Phase 1 : Préparation (2-4 semaines)**
> - Commander l'Interconnect (Dedicated ou Partner)
> - Attendre le provisioning
> - Ne pas toucher au VPN existant
>
> **Phase 2 : Configuration parallèle**
> ```
> Situation initiale:
> On-premise ══VPN══► GCP
>
> Après ajout Interconnect:
> On-premise ══VPN══════════► GCP
>            ══Interconnect══► 
> ```
> - Configurer l'Interconnect en parallèle
> - Établir BGP sur les deux chemins
> - Les routes VPN et Interconnect coexistent
>
> **Phase 3 : Basculement progressif**
> - Ajuster les priorités BGP (MED)
> - Donner la priorité à l'Interconnect
> ```bash
> # Sur le peer Interconnect
> gcloud compute routers update-bgp-peer ROUTER \
>     --peer-name=peer-interconnect \
>     --advertised-route-priority=100  # Priorité haute
>
> # Sur le peer VPN
> gcloud compute routers update-bgp-peer ROUTER \
>     --peer-name=peer-vpn \
>     --advertised-route-priority=200  # Priorité basse (backup)
> ```
>
> **Phase 4 : Validation**
> - Vérifier que le trafic passe par l'Interconnect
> - Tester les performances
> - Garder le VPN en backup pendant quelques semaines
>
> **Phase 5 : Décommissionnement VPN**
> - Une fois validé, supprimer le VPN
> - Garder la configuration documentée (rollback possible)
