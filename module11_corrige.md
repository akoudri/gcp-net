# Module 11 - Surveillance et Journalisation Réseau
## Corrigé des Questions et du Quizz

---

# Corrigé des Questions des Labs

## Lab 11.2 : VPC Flow Logs - Configuration

### Paramètres de configuration

**Q : Comment choisir les paramètres de Flow Logs ?**

> Le choix des paramètres dépend du cas d'usage et du budget :
>
> | Environnement | Sampling | Intervalle | Metadata | Coût relatif |
> |---------------|----------|------------|----------|--------------|
> | **Production critique** | 0.5 - 1.0 | 5-30s | INCLUDE_ALL | Élevé |
> | **Production standard** | 0.1 - 0.5 | 1-5min | INCLUDE_ALL | Moyen |
> | **Dev/Test** | 0.1 | 5-15min | CUSTOM | Faible |
> | **Investigation temporaire** | 1.0 | 5s | INCLUDE_ALL | Très élevé |
>
> Recommandations :
> - Commencer avec un sampling bas (0.1-0.5)
> - Augmenter temporairement pour les investigations
> - Utiliser les filtres pour réduire le volume
> - Exporter vers BigQuery pour l'analyse long terme

---

## Lab 11.3 : Analyse des Flow Logs

### Structure des logs

**Q : Que signifie le champ "reporter" dans les Flow Logs ?**

> Le champ `reporter` indique le point de capture du flux :
>
> | Valeur | Signification |
> |--------|---------------|
> | **SRC** | Capturé du point de vue de la VM source |
> | **DEST** | Capturé du point de vue de la VM destination |
>
> Implications :
> - Un même flux peut générer 2 logs (SRC et DEST)
> - Utile pour distinguer trafic entrant vs sortant
> - Pour le trafic intra-VPC : les deux points de vue
> - Pour le trafic externe : uniquement un point de vue
>
> Requête pour éviter les doublons :
> ```sql
> WHERE jsonPayload.reporter = "SRC"
> ```

---

## Lab 11.5 : Firewall Rules Logging

### VPC Flow Logs vs Firewall Logs

**Q : Quand utiliser VPC Flow Logs vs Firewall Rules Logging ?**

> | Besoin | Outil recommandé |
> |--------|------------------|
> | Volume de trafic (bytes, packets) | VPC Flow Logs |
> | Durée des connexions | VPC Flow Logs |
> | Top destinations par volume | VPC Flow Logs |
> | Pourquoi connexion bloquée ? | Firewall Logs |
> | Quelle règle a autorisé ce trafic ? | Firewall Logs |
> | Audit des tentatives d'accès | Firewall Logs |
> | Analyse statistique des flux | VPC Flow Logs |
> | Validation des règles de pare-feu | Firewall Logs |
>
> Recommandation : Utiliser les deux ensemble pour une visibilité complète.

---

## Lab 11.6 : Packet Mirroring

### VPC Flow Logs vs Packet Mirroring

**Q : Quelle est la différence entre VPC Flow Logs et Packet Mirroring ?**

> | Aspect | VPC Flow Logs | Packet Mirroring |
> |--------|---------------|------------------|
> | **Données** | Métadonnées uniquement | Paquets complets |
> | **Payload** | Non | Oui |
> | **Volume** | Léger | Important |
> | **Coût** | Modéré | Élevé |
> | **Analyse** | Statistiques, patterns | Contenu, forensics |
> | **Outils** | Cloud Logging, BigQuery | IDS, Wireshark, SIEM |
> | **Cas d'usage** | Monitoring, audit | Forensics, IDS/IPS |
>
> Flow Logs : "Qui parle à qui, quand, combien"
> Packet Mirroring : "Qu'est-ce qui est dit"

---

## Lab 11.10 : Network Intelligence Center

### Outils disponibles

**Q : Quels sont les outils de Network Intelligence Center ?**

> | Outil | Fonction | Cas d'usage |
> |-------|----------|-------------|
> | **Network Topology** | Visualisation graphique | Comprendre l'architecture |
> | **Connectivity Tests** | Diagnostic de connectivité | Dépannage "pourquoi ça ne marche pas" |
> | **Firewall Insights** | Analyse des règles de pare-feu | Optimisation, sécurité |
> | **Network Analyzer** | Détection de misconfigurations | Audit, bonnes pratiques |
> | **Performance Dashboard** | Métriques latence/perte | Planification multi-régions |
>
> Workflow typique de dépannage :
> 1. **Connectivity Tests** : Identifier où le problème se situe
> 2. **Network Analyzer** : Vérifier les misconfigurations
> 3. **Firewall Insights** : Valider les règles de pare-feu
> 4. **Network Topology** : Visualiser le chemin complet

---

# Corrigé du Quizz du Module 11

**1. Que capturent les VPC Flow Logs ?**

> **b. Les métadonnées des flux réseau** ✅
>
> Les VPC Flow Logs capturent :
> - IPs source et destination
> - Ports source et destination
> - Protocole (TCP, UDP, ICMP)
> - Bytes et packets envoyés
> - Timestamps (start_time, end_time)
> - Métadonnées enrichies (VM names, VPC, localisation géographique)
>
> Ce qu'ils ne capturent PAS :
> - Le contenu des paquets (payload)
> - Le trafic vers les metadata servers (169.254.169.254)
> - Certains trafics internes GCP

---

**2. Quelle est la différence entre VPC Flow Logs et Packet Mirroring ?**

> | VPC Flow Logs | Packet Mirroring |
> |---------------|------------------|
> | Métadonnées uniquement | Paquets complets (payload inclus) |
> | Léger, modéré en coût | Volume important, coût élevé |
> | Analyse avec Cloud Logging/BigQuery | Analyse avec IDS, Wireshark, SIEM |
> | Monitoring, audit, statistiques | Forensics, détection d'intrusion |
>
> **VPC Flow Logs** : Pour savoir "qui parle à qui"
> **Packet Mirroring** : Pour inspecter "ce qui est dit"

---

**3. Quel paramètre contrôle le pourcentage de flux capturés par Flow Logs ?**

> Le paramètre **`--logging-flow-sampling`** contrôle le pourcentage de flux capturés.
>
> ```bash
> gcloud compute networks subnets update SUBNET \
>     --region=REGION \
>     --logging-flow-sampling=0.5  # 50% des flux
> ```
>
> Valeurs :
> - `1.0` : 100% des flux (complet mais coûteux)
> - `0.5` : 50% des flux (bon compromis)
> - `0.1` : 10% des flux (économique)
> - `0.0` : Désactivé

---

**4. Quel outil permet de diagnostiquer pourquoi une connexion échoue ?**

> **Connectivity Tests** (Network Intelligence Center) permet de diagnostiquer pourquoi une connexion échoue.
>
> ```bash
> gcloud network-management connectivity-tests create test-name \
>     --source-instance=INSTANCE \
>     --destination-instance=INSTANCE \
>     --protocol=TCP \
>     --destination-port=80
> ```
>
> Connectivity Tests simule le chemin d'un paquet et identifie :
> - Les règles de pare-feu appliquées
> - Les routes utilisées
> - Le point de blocage éventuel
>
> Résultats possibles :
> - **REACHABLE** : Connectivité OK
> - **UNREACHABLE** : Bloqué quelque part
> - **AMBIGUOUS** : Résultat incertain
> - **UNDETERMINED** : Impossible à déterminer

---

**5. Que détecte Firewall Insights ?**

> Firewall Insights détecte plusieurs types de problèmes :
>
> | Type d'insight | Description |
> |----------------|-------------|
> | **Shadowed rules** | Règles masquées par d'autres (jamais utilisées) |
> | **Overly permissive rules** | Règles trop larges (0.0.0.0/0) |
> | **Unused rules** | Règles sans trafic correspondant |
> | **Deny rules with hits** | Règles de blocage actives |
> | **Allow rules with hits** | Règles d'autorisation actives |
>
> Exemple de règle "shadowed" :
> ```
> Règle A: Priority 100, ALLOW TCP:22 from 0.0.0.0/0
> Règle B: Priority 200, ALLOW TCP:22 from 10.0.0.0/8  ← SHADOWED
> ```
> La règle B ne sera jamais utilisée car A est plus prioritaire et plus large.

---

**6. Où configurer les alertes sur les métriques réseau ?**

> Les alertes se configurent dans **Cloud Monitoring** (anciennement Stackdriver).
>
> Méthode :
> 1. Console : Monitoring → Alerting → Create Policy
> 2. CLI : `gcloud alpha monitoring policies create`
>
> Composants d'une alerte :
> - **Condition** : Métrique + seuil + durée
> - **Notification channel** : Email, Slack, PagerDuty, etc.
> - **Documentation** : Runbook, contexte
>
> Exemple :
> ```bash
> gcloud alpha monitoring policies create \
>     --display-name="High Latency Alert" \
>     --condition-filter='metric.type="loadbalancing.googleapis.com/https/total_latencies"' \
>     --condition-threshold-value=500 \
>     --notification-channels=CHANNEL_ID
> ```

---

**7. Quel composant de Network Intelligence Center visualise l'architecture réseau ?**

> **Network Topology** visualise l'architecture réseau.
>
> Fonctionnalités :
> - Vue graphique des VPCs, sous-réseaux, VMs
> - Flux de trafic entre ressources
> - Connexions VPN et Interconnect
> - Peerings VPC
> - Filtrage par projet, VPC, région
>
> Accès : Console GCP → Network Intelligence Center → Network Topology

---

**8. Comment réduire les coûts des VPC Flow Logs ?**

> Plusieurs stratégies pour réduire les coûts :
>
> **1. Réduire le sampling**
> ```bash
> gcloud compute networks subnets update SUBNET \
>     --logging-flow-sampling=0.1  # 10% au lieu de 100%
> ```
>
> **2. Augmenter l'intervalle d'agrégation**
> ```bash
> gcloud compute networks subnets update SUBNET \
>     --logging-aggregation-interval=INTERVAL_10_MIN
> ```
>
> **3. Utiliser des filtres**
> ```bash
> gcloud compute networks subnets update SUBNET \
>     --logging-filter-expr='dest_port == 80 || dest_port == 443'
> ```
>
> **4. Réduire la rétention**
> ```bash
> gcloud logging buckets update _Default \
>     --retention-days=30
> ```
>
> **5. Désactiver sur les sous-réseaux non critiques**
>
> Impact sur les coûts :
> | Configuration | Coût relatif |
> |---------------|--------------|
> | Sampling 1.0, 5s | $5-20/VM/mois |
> | Sampling 0.5, 1min | $1-5/VM/mois |
> | Sampling 0.1, 5min | $0.1-0.5/VM/mois |

---

# Questions de réflexion supplémentaires

**Q1 : Comment concevoir une stratégie d'observabilité réseau complète ?**

> Stratégie d'observabilité en couches :
>
> ```
> COUCHE 1: LOGS (Détails)
> ├── VPC Flow Logs (métadonnées des flux)
> ├── Firewall Rules Logging (décisions pare-feu)
> ├── Load Balancer Logs (requêtes HTTP)
> └── Export vers BigQuery (analyse long terme)
>
> COUCHE 2: MÉTRIQUES (Agrégation)
> ├── Cloud Monitoring (métriques temps réel)
> ├── Dashboards personnalisés
> └── Métriques custom si nécessaire
>
> COUCHE 3: ALERTES (Proactivité)
> ├── Alertes de disponibilité (critique)
> ├── Alertes de performance (warning)
> └── Alertes de sécurité (info/warning)
>
> COUCHE 4: DIAGNOSTIC (Investigation)
> ├── Connectivity Tests
> ├── Firewall Insights
> ├── Network Analyzer
> └── Packet Mirroring (forensics)
> ```
>
> Bonnes pratiques :
> - Activer les Flow Logs sur tous les sous-réseaux de production
> - Créer des alertes AVANT les incidents
> - Documenter les runbooks pour chaque alerte
> - Revoir régulièrement les Firewall Insights
> - Exporter vers BigQuery pour l'analyse historique

---

**Q2 : Comment détecter une exfiltration de données avec les Flow Logs ?**

> Indicateurs d'exfiltration potentielle :
>
> **1. Volume sortant anormal**
> ```sql
> SELECT 
>     jsonPayload.src_instance.vm_name,
>     SUM(CAST(jsonPayload.bytes_sent AS INT64)) AS total_bytes
> FROM flow_logs
> WHERE 
>     jsonPayload.reporter = "SRC"
>     AND jsonPayload.dest_location.country IS NOT NULL
> GROUP BY vm_name
> HAVING total_bytes > 1073741824  -- > 1 GB
> ```
>
> **2. Connexions vers des destinations inhabituelles**
> ```sql
> SELECT dest_location.country, COUNT(*) 
> FROM flow_logs
> WHERE dest_location.country NOT IN ('FR', 'DE', 'US', 'GB')
> GROUP BY country
> ```
>
> **3. Transferts à des heures inhabituelles**
> ```sql
> SELECT EXTRACT(HOUR FROM timestamp) AS hour, SUM(bytes_sent)
> FROM flow_logs
> WHERE EXTRACT(HOUR FROM timestamp) NOT BETWEEN 8 AND 20
> GROUP BY hour
> ```
>
> **4. Alertes automatiques**
> - Alerte si egress > baseline + 300%
> - Alerte si connexions vers pays inhabituels
> - Alerte si gros transferts hors heures ouvrées

---

**Q3 : Comment optimiser les règles de pare-feu avec Firewall Insights ?**

> Processus d'optimisation :
>
> **1. Activer le Firewall Logging** sur toutes les règles
>
> **2. Attendre 1-2 semaines** de données
>
> **3. Analyser Firewall Insights** :
> ```bash
> gcloud recommender insights list \
>     --insight-type=google.compute.firewall.Insight \
>     --location=global
> ```
>
> **4. Actions par type d'insight** :
>
> | Insight | Action |
> |---------|--------|
> | **Shadowed rules** | Supprimer ou ajuster la priorité |
> | **Overly permissive** | Restreindre les plages IP/ports |
> | **Unused rules** | Valider puis supprimer |
> | **Deny with hits** | Documenter, surveiller |
>
> **5. Valider les changements** avec Connectivity Tests avant d'appliquer

---

**Q4 : Quelles métriques surveiller pour chaque composant réseau ?**

> | Composant | Métriques critiques | Seuils suggérés |
> |-----------|---------------------|-----------------|
> | **VPN** | tunnel_established | 0 = DOWN (critique) |
> | | dropped_packets | > 0.1% (warning) |
> | **Load Balancer** | total_latencies p95 | > 500ms (warning) |
> | | 5xx count | > 1% (critique) |
> | | healthy_backends | < 50% (critique) |
> | **Cloud NAT** | port_usage | > 80% (warning) |
> | | dropped_packets | > 0 (warning) |
> | **Interconnect** | circuit_status | != UP (critique) |
> | | capacity_usage | > 80% (warning) |
> | **CDN** | cache_hit_ratio | < 80% (warning) |
> | **VM** | sent/received_bytes | > baseline + 200% |

---

**Q5 : Comment configurer une rétention de logs économique ?**

> Architecture de rétention en 3 tiers :
>
> ```
> ┌─────────────────────────────────────────────────────────────────┐
> │ TIER 1: Cloud Logging (30 jours)                               │
> │ • Accès rapide, requêtes interactives                          │
> │ • Coût: $0.50/GiB                                              │
> └─────────────────────────────────────────────────────────────────┘
>                              │
>                              ▼ Export continu
> ┌─────────────────────────────────────────────────────────────────┐
> │ TIER 2: BigQuery (1-2 ans)                                     │
> │ • Requêtes SQL, analyse                                        │
> │ • Coût: $0.02/GB stockage + $5/TB requêtes                     │
> └─────────────────────────────────────────────────────────────────┘
>                              │
>                              ▼ Export périodique
> ┌─────────────────────────────────────────────────────────────────┐
> │ TIER 3: Cloud Storage Coldline (5+ ans)                        │
> │ • Archivage compliance                                         │
> │ • Coût: $0.004/GB/mois                                         │
> └─────────────────────────────────────────────────────────────────┘
> ```
>
> Configuration :
> ```bash
> # Tier 1: Réduire la rétention Cloud Logging
> gcloud logging buckets update _Default --retention-days=30
>
> # Tier 2: Export vers BigQuery
> gcloud logging sinks create to-bigquery \
>     bigquery.googleapis.com/projects/PROJECT/datasets/logs
>
> # Tier 3: Export vers GCS Coldline
> gsutil mb -c coldline gs://PROJECT-logs-archive
> ```
