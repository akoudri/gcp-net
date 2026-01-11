# Module 11 - Surveillance et Journalisation Réseau
## Travaux Pratiques Détaillés

---

## Vue d'ensemble

### Objectifs pédagogiques
Ces travaux pratiques permettront aux apprenants de :
- Activer et configurer les VPC Flow Logs
- Analyser le trafic réseau avec des requêtes avancées
- Configurer le Firewall Rules Logging
- Comprendre et mettre en place le Packet Mirroring
- Utiliser Cloud Monitoring pour les métriques réseau
- Créer des dashboards et des alertes proactives
- Maîtriser Network Intelligence Center
- Optimiser les coûts d'observabilité

### Prérequis
- Modules 1 à 10 complétés
- Projet GCP avec facturation activée
- Droits : roles/logging.admin, roles/monitoring.admin, roles/compute.networkAdmin
- Dataset BigQuery (pour l'export des logs)

### Labs proposés

| Lab | Titre | Durée | Difficulté |
|-----|-------|-------|------------|
| 11.1 | Enjeux de l'observabilité réseau | 20 min | ⭐ |
| 11.2 | VPC Flow Logs - Activation et configuration | 35 min | ⭐⭐ |
| 11.3 | VPC Flow Logs - Analyse et requêtes | 40 min | ⭐⭐ |
| 11.4 | VPC Flow Logs - Export vers BigQuery | 35 min | ⭐⭐ |
| 11.5 | Firewall Rules Logging | 30 min | ⭐⭐ |
| 11.6 | Packet Mirroring - Architecture et configuration | 45 min | ⭐⭐⭐ |
| 11.7 | Cloud Monitoring - Métriques réseau | 35 min | ⭐⭐ |
| 11.8 | Cloud Monitoring - Dashboards personnalisés | 35 min | ⭐⭐ |
| 11.9 | Alerting - Configuration des alertes | 40 min | ⭐⭐ |
| 11.10 | Network Intelligence Center | 40 min | ⭐⭐ |
| 11.11 | Optimisation des coûts d'observabilité | 25 min | ⭐⭐ |
| 11.12 | Scénario intégrateur - Observabilité complète | 50 min | ⭐⭐⭐ |

**Durée totale estimée : ~7h10**

---

## Lab 11.1 : Enjeux de l'observabilité réseau
**Durée : 20 minutes | Difficulté : ⭐**

### Objectifs
- Comprendre les enjeux de l'observabilité réseau
- Identifier les outils disponibles dans GCP
- Choisir le bon outil selon le cas d'usage

### Exercices

#### Exercice 11.1.1 : Enjeux de l'observabilité

```bash
cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════════╗
║                    ENJEUX DE L'OBSERVABILITÉ RÉSEAU                            ║
╠════════════════════════════════════════════════════════════════════════════════╣
║                                                                                ║
║  SÉCURITÉ                                                                      ║
║  ─────────────────────────────────────────────────────────────────────────────║
║  • Détecter les intrusions et tentatives d'attaque                            ║
║  • Identifier le trafic suspect ou anormal                                     ║
║  • Audit et conformité (PCI-DSS, HIPAA, RGPD)                                 ║
║  • Investigation forensique après incident                                     ║
║                                                                                ║
║  PERFORMANCE                                                                   ║
║  ─────────────────────────────────────────────────────────────────────────────║
║  • Identifier les goulots d'étranglement                                       ║
║  • Mesurer la latence entre services                                           ║
║  • Optimiser le routage du trafic                                              ║
║  • Planifier la capacité                                                       ║
║                                                                                ║
║  DÉPANNAGE                                                                     ║
║  ─────────────────────────────────────────────────────────────────────────────║
║  • Diagnostiquer les problèmes de connectivité                                 ║
║  • Identifier les règles de pare-feu bloquantes                                ║
║  • Valider les configurations réseau                                           ║
║  • Tracer le chemin des paquets                                                ║
║                                                                                ║
║  OPTIMISATION DES COÛTS                                                        ║
║  ─────────────────────────────────────────────────────────────────────────────║
║  • Identifier le trafic inutile ou excessif                                    ║
║  • Optimiser l'utilisation du NAT                                              ║
║  • Réduire le trafic inter-régions                                             ║
║  • Valider l'efficacité du CDN                                                 ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
EOF
```

#### Exercice 11.1.2 : Panorama des outils d'observabilité

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    OUTILS D'OBSERVABILITÉ RÉSEAU GCP
═══════════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────────┐
│                              LOGS                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│ VPC Flow Logs      │ Métadonnées des flux (IPs, ports, bytes)              │
│ Firewall Logs      │ Décisions du pare-feu (ALLOW/DENY)                    │
│ Load Balancer Logs │ Requêtes HTTP et réponses                             │
│ Cloud NAT Logs     │ Translations d'adresses                                │
│ Cloud Armor Logs   │ Décisions de sécurité WAF                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                            MÉTRIQUES                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│ Cloud Monitoring   │ Métriques VMs, LB, VPN, NAT, Interconnect             │
│ Dashboards         │ Visualisation temps réel                               │
│ Alerting           │ Notifications proactives                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                      INSPECTION APPROFONDIE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│ Packet Mirroring   │ Copie des paquets pour IDS/forensics                  │
│ Cloud IDS          │ Détection d'intrusion managée                         │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                    NETWORK INTELLIGENCE CENTER                              │
├─────────────────────────────────────────────────────────────────────────────┤
│ Network Topology   │ Visualisation de l'architecture                       │
│ Connectivity Tests │ Diagnostic de connectivité                            │
│ Firewall Insights  │ Optimisation des règles                               │
│ Network Analyzer   │ Détection des misconfigurations                       │
│ Performance Dashboard │ Latence et perte entre zones/régions               │
└─────────────────────────────────────────────────────────────────────────────┘
EOF
```

#### Exercice 11.1.3 : Choisir le bon outil

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    QUEL OUTIL POUR QUEL BESOIN ?
═══════════════════════════════════════════════════════════════════════════════

Besoin                              │ Outil recommandé
────────────────────────────────────┼────────────────────────────────────────
"Qui communique avec qui ?"         │ VPC Flow Logs
"Pourquoi ma connexion est bloquée?"│ Firewall Logs + Connectivity Tests
"Quelle est la latence du LB ?"     │ Cloud Monitoring + Dashboards
"Alerte si VPN tombe"               │ Cloud Monitoring Alerting
"Analyser le payload des paquets"   │ Packet Mirroring + IDS
"Visualiser mon architecture"       │ Network Topology
"Règles de FW inutiles ?"           │ Firewall Insights
"Erreurs de configuration ?"        │ Network Analyzer
"Performance inter-régions ?"       │ Performance Dashboard
"Requêtes SQL dans BigQuery"        │ VPC Flow Logs → BigQuery export
EOF
```

### Livrable
Documentation des enjeux et outils d'observabilité.

---

## Lab 11.2 : VPC Flow Logs - Activation et configuration
**Durée : 35 minutes | Difficulté : ⭐⭐**

### Objectifs
- Activer les VPC Flow Logs sur un sous-réseau
- Configurer les paramètres (sampling, intervalle, metadata)
- Comprendre l'impact sur les coûts

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              VPC Flow Logs                                  │
│                                                                             │
│   ┌─────────────┐        ┌─────────────┐        ┌─────────────┐            │
│   │   VM-A      │◄──────►│   VM-B      │◄──────►│  Internet   │            │
│   │ 10.0.1.10   │        │ 10.0.1.11   │        │             │            │
│   └─────────────┘        └─────────────┘        └─────────────┘            │
│          │                      │                      │                    │
│          └──────────────────────┴──────────────────────┘                    │
│                                 │                                           │
│                    ┌────────────▼────────────┐                              │
│                    │    Flow Logs Capture    │                              │
│                    │    (Métadonnées)        │                              │
│                    └────────────┬────────────┘                              │
│                                 │                                           │
│                    ┌────────────▼────────────┐                              │
│                    │    Cloud Logging        │                              │
│                    │                         │                              │
│                    │  ┌─────────────────┐    │                              │
│                    │  │    BigQuery     │    │   Export optionnel          │
│                    │  └─────────────────┘    │                              │
│                    └─────────────────────────┘                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Exercices

#### Exercice 11.2.1 : Créer l'infrastructure de test

```bash
# Variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

# Créer le VPC
gcloud compute networks create vpc-observability \
    --subnet-mode=custom

# Créer le sous-réseau SANS Flow Logs (on les activera après)
gcloud compute networks subnets create subnet-monitored \
    --network=vpc-observability \
    --region=$REGION \
    --range=10.0.1.0/24

# Règles de pare-feu
gcloud compute firewall-rules create vpc-obs-allow-internal \
    --network=vpc-observability \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=all \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create vpc-obs-allow-ssh \
    --network=vpc-observability \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20

gcloud compute firewall-rules create vpc-obs-allow-icmp \
    --network=vpc-observability \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=icmp \
    --source-ranges=0.0.0.0/0

# Créer deux VMs de test
for VM in vm-source vm-dest; do
    gcloud compute instances create $VM \
        --zone=$ZONE \
        --machine-type=e2-small \
        --network=vpc-observability \
        --subnet=subnet-monitored \
        --image-family=debian-11 \
        --image-project=debian-cloud \
        --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y nginx iperf3 tcpdump
systemctl start nginx'
done

echo "VMs créées. Récupération des IPs..."
VM_SOURCE_IP=$(gcloud compute instances describe vm-source --zone=$ZONE --format="get(networkInterfaces[0].networkIP)")
VM_DEST_IP=$(gcloud compute instances describe vm-dest --zone=$ZONE --format="get(networkInterfaces[0].networkIP)")
echo "vm-source: $VM_SOURCE_IP"
echo "vm-dest: $VM_DEST_IP"
```

#### Exercice 11.2.2 : Activer les VPC Flow Logs (configuration basique)

```bash
# Activer les Flow Logs avec les paramètres par défaut
gcloud compute networks subnets update subnet-monitored \
    --region=$REGION \
    --enable-flow-logs

# Vérifier l'activation
gcloud compute networks subnets describe subnet-monitored \
    --region=$REGION \
    --format="yaml(enableFlowLogs,logConfig)"
```

#### Exercice 11.2.3 : Configurer les paramètres avancés

```bash
# Comprendre les paramètres
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    PARAMÈTRES VPC FLOW LOGS
═══════════════════════════════════════════════════════════════════════════════

AGGREGATION INTERVAL (--logging-aggregation-interval)
──────────────────────────────────────────────────────────────────────────────
• INTERVAL_5_SEC   : Haute granularité, beaucoup de logs
• INTERVAL_30_SEC  : Bon compromis
• INTERVAL_1_MIN   : Standard
• INTERVAL_5_MIN   : Économique
• INTERVAL_10_MIN  : Très économique
• INTERVAL_15_MIN  : Minimum de logs

FLOW SAMPLING (--logging-flow-sampling)
──────────────────────────────────────────────────────────────────────────────
• 1.0 : 100% des flux capturés (complet mais coûteux)
• 0.5 : 50% des flux (bon compromis)
• 0.1 : 10% des flux (économique, analyse statistique)
• 0.0 : Désactivé

METADATA (--logging-metadata)
──────────────────────────────────────────────────────────────────────────────
• INCLUDE_ALL_METADATA : Toutes les métadonnées (VM names, VPC, etc.)
• EXCLUDE_ALL_METADATA : Uniquement les données de base
• CUSTOM_METADATA      : Sélection personnalisée

FILTER EXPRESSION (--logging-filter-expr)
──────────────────────────────────────────────────────────────────────────────
• Filtrer pour réduire le volume
• Exemples: src_ip, dest_ip, src_port, dest_port
EOF

# Configurer avec des paramètres optimisés pour la production
gcloud compute networks subnets update subnet-monitored \
    --region=$REGION \
    --logging-aggregation-interval=INTERVAL_30_SEC \
    --logging-flow-sampling=0.5 \
    --logging-metadata=INCLUDE_ALL_METADATA

# Vérifier la configuration
gcloud compute networks subnets describe subnet-monitored \
    --region=$REGION \
    --format="yaml(logConfig)"
```

#### Exercice 11.2.4 : Appliquer un filtre

```bash
# Capturer uniquement le trafic HTTP/HTTPS
gcloud compute networks subnets update subnet-monitored \
    --region=$REGION \
    --logging-filter-expr='dest_port == 80 || dest_port == 443 || src_port == 80 || src_port == 443'

# Ou capturer uniquement le trafic d'une VM spécifique
# gcloud compute networks subnets update subnet-monitored \
#     --region=$REGION \
#     --logging-filter-expr='src_ip == "10.0.1.10" || dest_ip == "10.0.1.10"'

# Supprimer le filtre (capturer tout)
gcloud compute networks subnets update subnet-monitored \
    --region=$REGION \
    --logging-filter-expr=""
```

#### Exercice 11.2.5 : Générer du trafic de test

```bash
# Se connecter à vm-source et générer du trafic
gcloud compute ssh vm-source --zone=$ZONE --tunnel-through-iap << EOF
# Trafic vers l'autre VM
ping -c 5 $VM_DEST_IP
curl -s http://$VM_DEST_IP

# Trafic vers Internet
curl -s https://www.google.com -o /dev/null
curl -s https://storage.googleapis.com -o /dev/null

# Test de bande passante (si iperf3 est installé sur vm-dest)
# iperf3 -c $VM_DEST_IP -t 10

echo "Trafic généré!"
EOF
```

### Livrable
VPC Flow Logs activés et configurés avec les paramètres appropriés.

---

## Lab 11.3 : VPC Flow Logs - Analyse et requêtes
**Durée : 40 minutes | Difficulté : ⭐⭐**

### Objectifs
- Comprendre la structure des logs
- Créer des requêtes d'analyse dans Cloud Logging
- Identifier les patterns de trafic

### Exercices

#### Exercice 11.3.1 : Structure des Flow Logs

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    STRUCTURE D'UN VPC FLOW LOG
═══════════════════════════════════════════════════════════════════════════════

{
  "connection": {
    "src_ip": "10.0.1.10",           // IP source
    "src_port": 52431,               // Port source
    "dest_ip": "35.190.0.1",         // IP destination
    "dest_port": 443,                // Port destination
    "protocol": 6                    // 6=TCP, 17=UDP, 1=ICMP
  },
  "bytes_sent": 15234,               // Octets envoyés
  "packets_sent": 42,                // Paquets envoyés
  "start_time": "2024-01-15T10:30:00Z",
  "end_time": "2024-01-15T10:30:05Z",
  "reporter": "SRC",                 // SRC ou DEST (point de capture)
  
  // Métadonnées enrichies (si INCLUDE_ALL_METADATA)
  "src_instance": {
    "vm_name": "vm-source",
    "project_id": "my-project",
    "zone": "europe-west1-b"
  },
  "dest_instance": {
    "vm_name": "vm-dest",
    "project_id": "my-project",
    "zone": "europe-west1-b"
  },
  "src_vpc": {
    "vpc_name": "vpc-observability",
    "project_id": "my-project"
  },
  "src_location": {                  // Pour les IPs externes
    "country": "US",
    "region": "California"
  }
}
EOF
```

#### Exercice 11.3.2 : Requêtes de base dans Cloud Logging

```bash
# Voir tous les Flow Logs
gcloud logging read 'resource.type="gce_subnetwork"' \
    --limit=10 \
    --format=json

# Trafic d'une VM spécifique
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.src_instance.vm_name="vm-source"
' --limit=20 --format="table(
    timestamp,
    jsonPayload.connection.dest_ip,
    jsonPayload.connection.dest_port,
    jsonPayload.bytes_sent
)"

# Trafic vers une VM spécifique
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.dest_instance.vm_name="vm-dest"
' --limit=20
```

#### Exercice 11.3.3 : Filtrer par protocole et port

```bash
# Trafic SSH (port 22)
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.connection.dest_port=22
' --limit=20

# Trafic HTTP/HTTPS
gcloud logging read '
resource.type="gce_subnetwork"
(jsonPayload.connection.dest_port=80 OR jsonPayload.connection.dest_port=443)
' --limit=20

# Trafic TCP uniquement (protocole 6)
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.connection.protocol=6
' --limit=20

# Trafic ICMP (protocole 1)
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.connection.protocol=1
' --limit=20
```

#### Exercice 11.3.4 : Identifier le trafic externe

```bash
# Trafic vers des IPs externes (non RFC1918)
gcloud logging read '
resource.type="gce_subnetwork"
NOT jsonPayload.connection.dest_ip=~"^10\."
NOT jsonPayload.connection.dest_ip=~"^172\.(1[6-9]|2[0-9]|3[0-1])\."
NOT jsonPayload.connection.dest_ip=~"^192\.168\."
' --limit=50

# Trafic par pays de destination
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.dest_location.country!=""
' --limit=50 --format="table(
    jsonPayload.dest_location.country,
    jsonPayload.connection.dest_ip,
    jsonPayload.bytes_sent
)"
```

#### Exercice 11.3.5 : Analyse de volumes

```bash
# Top destinations par bytes
gcloud logging read '
resource.type="gce_subnetwork"
' --limit=1000 --format="value(jsonPayload.connection.dest_ip,jsonPayload.bytes_sent)" \
| awk '{ip[$1]+=$2} END {for (i in ip) print ip[i], i}' \
| sort -rn \
| head -10

# Top sources par nombre de connexions
gcloud logging read '
resource.type="gce_subnetwork"
' --limit=1000 --format="value(jsonPayload.connection.src_ip)" \
| sort | uniq -c | sort -rn | head -10
```

#### Exercice 11.3.6 : Requêtes de sécurité

```bash
# Connexions vers de nombreux ports (potential port scan)
gcloud logging read '
resource.type="gce_subnetwork"
timestamp>="2024-01-15T00:00:00Z"
' --limit=5000 --format="value(jsonPayload.connection.src_ip,jsonPayload.connection.dest_port)" \
| sort | uniq | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -10

# Trafic sur des ports non standards
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.connection.dest_port>1024
jsonPayload.connection.dest_port!=3306
jsonPayload.connection.dest_port!=5432
jsonPayload.connection.dest_port!=6379
jsonPayload.connection.dest_port!=8080
jsonPayload.connection.dest_port!=8443
' --limit=50
```

### Livrable
Requêtes d'analyse des Flow Logs maîtrisées.

---

## Lab 11.4 : VPC Flow Logs - Export vers BigQuery
**Durée : 35 minutes | Difficulté : ⭐⭐**

### Objectifs
- Créer un sink vers BigQuery
- Analyser les logs avec SQL
- Créer des requêtes de sécurité avancées

### Exercices

#### Exercice 11.4.1 : Créer le dataset BigQuery

```bash
# Créer le dataset
bq mk --dataset --location=EU ${PROJECT_ID}:network_logs

# Vérifier
bq ls
```

#### Exercice 11.4.2 : Créer le sink de logs

```bash
# Créer le sink vers BigQuery
gcloud logging sinks create flow-logs-to-bq \
    bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/network_logs \
    --log-filter='resource.type="gce_subnetwork"'

# Récupérer le service account du sink
SINK_SA=$(gcloud logging sinks describe flow-logs-to-bq --format="get(writerIdentity)")
echo "Service Account du sink: $SINK_SA"

# Donner les droits au service account sur le dataset
bq add-iam-policy-binding \
    --member="$SINK_SA" \
    --role="roles/bigquery.dataEditor" \
    ${PROJECT_ID}:network_logs
```

#### Exercice 11.4.3 : Générer du trafic et attendre l'export

```bash
# Générer du trafic varié
gcloud compute ssh vm-source --zone=$ZONE --tunnel-through-iap << 'EOF'
# Trafic HTTP
for i in {1..20}; do
    curl -s http://vm-dest > /dev/null
    curl -s https://www.google.com > /dev/null
done

# Trafic vers différents services Google
curl -s https://storage.googleapis.com > /dev/null
curl -s https://bigquery.googleapis.com > /dev/null

# Ping
ping -c 10 vm-dest

echo "Trafic généré!"
EOF

echo "Attendre 5-10 minutes pour l'export vers BigQuery..."
```

#### Exercice 11.4.4 : Requêtes SQL d'analyse

```bash
# Vérifier que les données sont arrivées
bq query --use_legacy_sql=false '
SELECT COUNT(*) as total_flows
FROM `'${PROJECT_ID}'.network_logs.compute_googleapis_com_vpc_flows_*`
WHERE TIMESTAMP_TRUNC(_PARTITIONTIME, DAY) = TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)
'

# Top 10 destinations par volume
bq query --use_legacy_sql=false '
SELECT 
    jsonPayload.connection.dest_ip AS dest_ip,
    SUM(CAST(jsonPayload.bytes_sent AS INT64)) AS total_bytes,
    COUNT(*) AS flow_count
FROM `'${PROJECT_ID}'.network_logs.compute_googleapis_com_vpc_flows_*`
WHERE TIMESTAMP_TRUNC(_PARTITIONTIME, DAY) = TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY)
GROUP BY dest_ip
ORDER BY total_bytes DESC
LIMIT 10
'
```

#### Exercice 11.4.5 : Requêtes de sécurité avancées

```bash
# Détection de port scan (IPs connectées à >50 ports différents)
bq query --use_legacy_sql=false '
SELECT 
    jsonPayload.connection.src_ip AS source_ip,
    COUNT(DISTINCT jsonPayload.connection.dest_port) AS unique_ports,
    COUNT(*) AS connection_count
FROM `'${PROJECT_ID}'.network_logs.compute_googleapis_com_vpc_flows_*`
WHERE 
    _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
GROUP BY source_ip
HAVING unique_ports > 50
ORDER BY unique_ports DESC
'

# VMs avec trafic sortant anormal (>1GB/heure)
bq query --use_legacy_sql=false '
SELECT 
    jsonPayload.src_instance.vm_name AS vm_name,
    SUM(CAST(jsonPayload.bytes_sent AS INT64)) AS total_bytes,
    ROUND(SUM(CAST(jsonPayload.bytes_sent AS INT64)) / 1073741824, 2) AS gb_sent,
    COUNT(*) AS flow_count
FROM `'${PROJECT_ID}'.network_logs.compute_googleapis_com_vpc_flows_*`
WHERE 
    _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
    AND jsonPayload.reporter = "SRC"
    AND jsonPayload.dest_location.country IS NOT NULL
GROUP BY vm_name
HAVING total_bytes > 1073741824
ORDER BY total_bytes DESC
'

# Trafic vers des pays inhabituels
bq query --use_legacy_sql=false '
SELECT 
    jsonPayload.dest_location.country AS country,
    jsonPayload.connection.dest_ip AS dest_ip,
    SUM(CAST(jsonPayload.bytes_sent AS INT64)) AS total_bytes,
    COUNT(*) AS flow_count
FROM `'${PROJECT_ID}'.network_logs.compute_googleapis_com_vpc_flows_*`
WHERE 
    _PARTITIONTIME >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
    AND jsonPayload.dest_location.country NOT IN ("FR", "DE", "US", "GB", "NL", "BE")
    AND jsonPayload.dest_location.country IS NOT NULL
GROUP BY country, dest_ip
ORDER BY total_bytes DESC
LIMIT 20
'
```

### Livrable
Pipeline d'export vers BigQuery avec requêtes de sécurité.

---

## Lab 11.5 : Firewall Rules Logging
**Durée : 30 minutes | Difficulté : ⭐⭐**

### Objectifs
- Activer le logging sur les règles de pare-feu
- Analyser les décisions ALLOW/DENY
- Auditer les tentatives d'accès

### Exercices

#### Exercice 11.5.1 : Différence Flow Logs vs Firewall Logs

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                VPC FLOW LOGS vs FIREWALL RULES LOGGING
═══════════════════════════════════════════════════════════════════════════════

Aspect              │ VPC Flow Logs           │ Firewall Rules Logging
────────────────────┼─────────────────────────┼─────────────────────────────
Focus               │ Tout le trafic          │ Décisions du pare-feu
Niveau              │ Sous-réseau             │ Règle de pare-feu
Information         │ Volumes, durées         │ Règle appliquée, action
Sampling            │ Configurable (0-100%)   │ Pas d'échantillonnage
Action              │ Trafic passé            │ ALLOWED ou DENIED
Utilité             │ Analyse de flux         │ Audit de sécurité

Quand utiliser quoi:
• "Combien de GB vers Internet ?" → VPC Flow Logs
• "Pourquoi cette connexion est bloquée ?" → Firewall Logs
• "Quelle règle a autorisé ce trafic ?" → Firewall Logs
• "Top des destinations par volume" → VPC Flow Logs
EOF
```

#### Exercice 11.5.2 : Activer le logging sur les règles existantes

```bash
# Lister les règles de pare-feu
gcloud compute firewall-rules list \
    --filter="network:vpc-observability" \
    --format="table(name,direction,action,sourceRanges,allowed)"

# Activer le logging sur une règle ALLOW
gcloud compute firewall-rules update vpc-obs-allow-ssh \
    --enable-logging \
    --logging-metadata=INCLUDE_ALL_METADATA

# Activer le logging sur une règle ALLOW (ICMP)
gcloud compute firewall-rules update vpc-obs-allow-icmp \
    --enable-logging \
    --logging-metadata=INCLUDE_ALL_METADATA

# Vérifier
gcloud compute firewall-rules describe vpc-obs-allow-ssh \
    --format="yaml(logConfig)"
```

#### Exercice 11.5.3 : Créer une règle DENY avec logging

```bash
# Créer une règle pour bloquer un port spécifique (pour test)
gcloud compute firewall-rules create vpc-obs-deny-telnet \
    --network=vpc-observability \
    --action=DENY \
    --direction=INGRESS \
    --rules=tcp:23 \
    --source-ranges=0.0.0.0/0 \
    --priority=100 \
    --enable-logging \
    --logging-metadata=INCLUDE_ALL_METADATA \
    --description="Bloquer Telnet avec logging"
```

#### Exercice 11.5.4 : Générer du trafic et analyser les logs

```bash
# Générer du trafic qui sera logué
gcloud compute ssh vm-source --zone=$ZONE --tunnel-through-iap << 'EOF'
# Trafic autorisé (ALLOW)
ping -c 3 vm-dest
curl -s http://vm-dest

# Tenter une connexion Telnet (DENY)
timeout 2 nc -v vm-dest 23 || echo "Connexion Telnet bloquée (attendu)"
EOF

# Attendre quelques secondes
sleep 30

# Voir les logs ALLOWED
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.disposition="ALLOWED"
' --limit=20 --format="table(
    timestamp,
    jsonPayload.rule_details.reference,
    jsonPayload.connection.src_ip,
    jsonPayload.connection.dest_port
)"

# Voir les logs DENIED
gcloud logging read '
resource.type="gce_subnetwork"
jsonPayload.disposition="DENIED"
' --limit=20 --format=json
```

#### Exercice 11.5.5 : Structure des Firewall Logs

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    STRUCTURE D'UN FIREWALL LOG
═══════════════════════════════════════════════════════════════════════════════

{
  "connection": {
    "src_ip": "10.0.1.10",
    "src_port": 52431,
    "dest_ip": "10.0.1.11",
    "dest_port": 22,
    "protocol": 6
  },
  "disposition": "ALLOWED",           // ou "DENIED"
  "rule_details": {
    "reference": "network:vpc-obs/firewall:vpc-obs-allow-ssh",
    "priority": 1000,
    "action": "ALLOW",
    "direction": "INGRESS",
    "source_range": ["35.235.240.0/20"],
    "ip_port_info": [{"ip_protocol": "TCP", "port_range": ["22"]}]
  },
  "instance": {
    "vm_name": "vm-dest",
    "project_id": "my-project",
    "zone": "europe-west1-b"
  },
  "vpc": {
    "vpc_name": "vpc-observability"
  }
}
EOF
```

### Livrable
Firewall Rules Logging configuré et analysé.

---

## Lab 11.6 : Packet Mirroring - Architecture et configuration
**Durée : 45 minutes | Difficulté : ⭐⭐⭐**

### Objectifs
- Comprendre l'architecture Packet Mirroring
- Configurer un collecteur (ILB)
- Créer une politique de mirroring

### Architecture Packet Mirroring

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PACKET MIRRORING ARCHITECTURE                       │
│                                                                             │
│   Sources (VMs mirrorées)                      Collecteur                   │
│   ┌──────────────────────┐                     ┌──────────────────────┐     │
│   │   ┌─────────────┐    │                     │  Internal LB         │     │
│   │   │  VM-Prod-1  │────┼─────────────────────┼─►(Mirroring Collector)│     │
│   │   └─────────────┘    │     Copie des       │         │            │     │
│   │   ┌─────────────┐    │     paquets         │         ▼            │     │
│   │   │  VM-Prod-2  │────┼─────────────────────┼──►┌─────────────┐    │     │
│   │   └─────────────┘    │     (VXLAN/GRE)     │   │ Collector   │    │     │
│   │   ┌─────────────┐    │                     │   │ Instance    │    │     │
│   │   │  VM-Prod-3  │────┼─────────────────────┼──►│ (IDS/SIEM)  │    │     │
│   │   └─────────────┘    │                     │   └─────────────┘    │     │
│   └──────────────────────┘                     └──────────────────────┘     │
│                                                                             │
│   Filtres disponibles:                                                      │
│   • Sous-réseaux (--mirrored-subnets)                                       │
│   • Tags réseau (--mirrored-tags)                                           │
│   • Instances spécifiques (--mirrored-instances)                            │
│   • Plages CIDR (--filter-cidr-ranges)                                      │
│   • Protocoles (--filter-protocols)                                         │
│   • Direction (--filter-direction)                                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Exercices

#### Exercice 11.6.1 : Créer le sous-réseau pour le collecteur

```bash
# Sous-réseau pour le collecteur
gcloud compute networks subnets create subnet-collector \
    --network=vpc-observability \
    --region=$REGION \
    --range=10.0.10.0/24
```

#### Exercice 11.6.2 : Créer l'instance collecteur

```bash
# VM collecteur avec tcpdump préinstallé
gcloud compute instances create vm-collector \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network=vpc-observability \
    --subnet=subnet-collector \
    --tags=collector \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y tcpdump tshark
# Configurer l'interface pour recevoir le trafic mirroré
# Le trafic arrive encapsulé en VXLAN sur le port 4789
'

# Règle de pare-feu pour le collecteur
gcloud compute firewall-rules create vpc-obs-allow-mirroring \
    --network=vpc-observability \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=udp:4789 \
    --source-ranges=10.0.0.0/8 \
    --target-tags=collector

# Créer un Instance Group pour le collecteur
gcloud compute instance-groups unmanaged create ig-collector \
    --zone=$ZONE

gcloud compute instance-groups unmanaged add-instances ig-collector \
    --zone=$ZONE \
    --instances=vm-collector
```

#### Exercice 11.6.3 : Créer l'Internal Load Balancer (collecteur)

```bash
# Health check pour le collecteur
gcloud compute health-checks create tcp hc-collector \
    --port=4789 \
    --region=$REGION

# Backend service pour le collecteur
gcloud compute backend-services create collector-backend \
    --protocol=UDP \
    --health-checks=hc-collector \
    --health-checks-region=$REGION \
    --load-balancing-scheme=INTERNAL \
    --region=$REGION

# Ajouter le groupe d'instances
gcloud compute backend-services add-backend collector-backend \
    --instance-group=ig-collector \
    --instance-group-zone=$ZONE \
    --region=$REGION

# Forwarding rule pour le collecteur (avec flag is-mirroring-collector)
gcloud compute forwarding-rules create collector-ilb \
    --load-balancing-scheme=INTERNAL \
    --network=vpc-observability \
    --subnet=subnet-collector \
    --backend-service=collector-backend \
    --is-mirroring-collector \
    --ports=ALL \
    --region=$REGION

echo "ILB Collecteur créé"
```

#### Exercice 11.6.4 : Créer la politique de Packet Mirroring

```bash
# Créer la politique de mirroring
gcloud compute packet-mirrorings create mirror-policy-prod \
    --region=$REGION \
    --network=vpc-observability \
    --collector-ilb=collector-ilb \
    --mirrored-subnets=subnet-monitored \
    --filter-cidr-ranges=0.0.0.0/0 \
    --filter-protocols=tcp,udp,icmp \
    --filter-direction=BOTH

# Vérifier la politique
gcloud compute packet-mirrorings describe mirror-policy-prod \
    --region=$REGION

# Lister les politiques
gcloud compute packet-mirrorings list --region=$REGION
```

#### Exercice 11.6.5 : Tester le Packet Mirroring

```bash
# Sur le collecteur, démarrer la capture
gcloud compute ssh vm-collector --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "Démarrage de la capture tcpdump..."
sudo tcpdump -i any port 4789 -c 20 -nn
EOF

# Dans un autre terminal, générer du trafic
gcloud compute ssh vm-source --zone=$ZONE --tunnel-through-iap << 'EOF'
ping -c 5 vm-dest
curl -s http://vm-dest
EOF
```

### Livrable
Architecture Packet Mirroring fonctionnelle.

---

## Lab 11.7 : Cloud Monitoring - Métriques réseau
**Durée : 35 minutes | Difficulté : ⭐⭐**

### Objectifs
- Explorer les métriques réseau disponibles
- Créer des requêtes de métriques
- Comprendre les métriques clés

### Exercices

#### Exercice 11.7.1 : Métriques réseau disponibles

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    MÉTRIQUES RÉSEAU GCP
═══════════════════════════════════════════════════════════════════════════════

VPC / VM
──────────────────────────────────────────────────────────────────────────────
compute.googleapis.com/instance/network/received_bytes_count
compute.googleapis.com/instance/network/sent_bytes_count
compute.googleapis.com/instance/network/received_packets_count
compute.googleapis.com/instance/network/sent_packets_count

LOAD BALANCER
──────────────────────────────────────────────────────────────────────────────
loadbalancing.googleapis.com/https/request_count
loadbalancing.googleapis.com/https/total_latencies
loadbalancing.googleapis.com/https/backend_latencies
loadbalancing.googleapis.com/https/request_bytes_count
loadbalancing.googleapis.com/https/response_bytes_count

CLOUD NAT
──────────────────────────────────────────────────────────────────────────────
router.googleapis.com/nat/allocated_ports
router.googleapis.com/nat/port_usage
router.googleapis.com/nat/dropped_sent_packets_count
router.googleapis.com/nat/new_connections_count

VPN
──────────────────────────────────────────────────────────────────────────────
vpn.googleapis.com/tunnel_established
vpn.googleapis.com/sent_bytes_count
vpn.googleapis.com/received_bytes_count
vpn.googleapis.com/dropped_packets_count

INTERCONNECT
──────────────────────────────────────────────────────────────────────────────
interconnect.googleapis.com/link/received_bytes_count
interconnect.googleapis.com/link/sent_bytes_count
interconnect.googleapis.com/link/circuit_operational_status

CDN
──────────────────────────────────────────────────────────────────────────────
loadbalancing.googleapis.com/https/cdn/cache_hit_ratio
loadbalancing.googleapis.com/https/cdn/cache_fill_bytes_count
loadbalancing.googleapis.com/https/cdn/cache_hit_bytes_count
EOF
```

#### Exercice 11.7.2 : Lister les métriques disponibles

```bash
# Lister les métriques compute
gcloud monitoring metrics list --filter="metric.type:compute.googleapis.com/instance/network"

# Lister les métriques Load Balancer
gcloud monitoring metrics list --filter="metric.type:loadbalancing.googleapis.com"

# Lister les métriques VPN
gcloud monitoring metrics list --filter="metric.type:vpn.googleapis.com"
```

#### Exercice 11.7.3 : Requêtes de métriques via CLI

```bash
# Bytes envoyés par une VM (dernière heure)
gcloud monitoring time-series list \
    --filter='metric.type="compute.googleapis.com/instance/network/sent_bytes_count" AND resource.labels.instance_id="INSTANCE_ID"' \
    --start-time=$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
    --end-time=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Remplacer INSTANCE_ID par l'ID réel de la VM
INSTANCE_ID=$(gcloud compute instances describe vm-source --zone=$ZONE --format="get(id)")
echo "Instance ID: $INSTANCE_ID"
```

### Livrable
Compréhension des métriques réseau GCP.

---

## Lab 11.8 : Cloud Monitoring - Dashboards personnalisés
**Durée : 35 minutes | Difficulté : ⭐⭐**

### Objectifs
- Créer un dashboard réseau personnalisé
- Ajouter des widgets pertinents
- Visualiser les métriques clés

### Exercices

#### Exercice 11.8.1 : Créer un dashboard via JSON

```bash
# Créer le fichier de configuration du dashboard
cat > network-dashboard.json << 'EOF'
{
  "displayName": "Network Overview Dashboard",
  "mosaicLayout": {
    "columns": 12,
    "tiles": [
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Network Bytes Sent by VM",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"compute.googleapis.com/instance/network/sent_bytes_count\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_RATE",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": ["resource.label.instance_id"]
                  }
                }
              },
              "plotType": "LINE"
            }],
            "timeshiftDuration": "0s",
            "yAxis": {
              "label": "bytes/s",
              "scale": "LINEAR"
            }
          }
        }
      },
      {
        "xPos": 6,
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Network Bytes Received by VM",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"compute.googleapis.com/instance/network/received_bytes_count\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_RATE",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": ["resource.label.instance_id"]
                  }
                }
              },
              "plotType": "LINE"
            }],
            "yAxis": {
              "label": "bytes/s",
              "scale": "LINEAR"
            }
          }
        }
      },
      {
        "yPos": 4,
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Packets Sent",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"compute.googleapis.com/instance/network/sent_packets_count\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_RATE"
                  }
                }
              },
              "plotType": "LINE"
            }]
          }
        }
      },
      {
        "xPos": 6,
        "yPos": 4,
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Packets Received",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"compute.googleapis.com/instance/network/received_packets_count\"",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_RATE"
                  }
                }
              },
              "plotType": "LINE"
            }]
          }
        }
      }
    ]
  }
}
EOF

# Créer le dashboard
gcloud monitoring dashboards create --config-from-file=network-dashboard.json

# Lister les dashboards
gcloud monitoring dashboards list
```

#### Exercice 11.8.2 : Widgets recommandés

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    WIDGETS RECOMMANDÉS POUR UN DASHBOARD RÉSEAU
═══════════════════════════════════════════════════════════════════════════════

Widget                  │ Métrique                          │ Usage
────────────────────────┼───────────────────────────────────┼─────────────────
Bandwidth par VM        │ sent/received_bytes_count         │ Identifier les gros consommateurs
Latence LB (p50/p95/p99)│ https/total_latencies             │ Performance utilisateur
Erreurs LB              │ request_count par code HTTP       │ Santé des backends
VPN Tunnel Status       │ tunnel_established                │ Disponibilité hybride
NAT Port Usage          │ nat/port_usage                    │ Saturation NAT
CDN Hit Ratio           │ cdn/cache_hit_ratio               │ Efficacité du cache
Dropped Packets         │ dropped_packets_count             │ Problèmes de capacité
Backend Health          │ backend healthy count             │ État des backends
EOF
```

### Livrable
Dashboard de monitoring réseau personnalisé.

---

## Lab 11.9 : Alerting - Configuration des alertes
**Durée : 40 minutes | Difficulté : ⭐⭐**

### Objectifs
- Créer des canaux de notification
- Configurer des alertes proactives
- Définir les seuils appropriés

### Exercices

#### Exercice 11.9.1 : Créer un canal de notification

```bash
# Créer un canal email
gcloud alpha monitoring channels create \
    --display-name="Network Ops Email" \
    --type=email \
    --channel-labels=email_address=ops@example.com

# Lister les canaux
gcloud alpha monitoring channels list

# Récupérer l'ID du canal (pour les politiques d'alerte)
CHANNEL_ID=$(gcloud alpha monitoring channels list --format="get(name)" | head -1)
echo "Channel ID: $CHANNEL_ID"
```

#### Exercice 11.9.2 : Alertes recommandées

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    ALERTES RÉSEAU RECOMMANDÉES
═══════════════════════════════════════════════════════════════════════════════

DISPONIBILITÉ (Critique)
──────────────────────────────────────────────────────────────────────────────
• VPN Tunnel Down        │ tunnel_established == 0       │ Immédiat
• Interconnect Down      │ circuit_status != UP          │ Immédiat
• Backend Unhealthy      │ healthy_backends < 50%        │ 1 minute
• LB Error Rate          │ 5xx / total > 1%              │ 5 minutes

PERFORMANCE (Warning)
──────────────────────────────────────────────────────────────────────────────
• LB Latency High        │ p95 latency > 500ms           │ 5 minutes
• Backend Latency High   │ backend p95 > 200ms           │ 5 minutes
• CDN Hit Ratio Low      │ cache_hit_ratio < 80%         │ 15 minutes

CAPACITÉ (Warning)
──────────────────────────────────────────────────────────────────────────────
• NAT Port Exhaustion    │ port_usage > 80%              │ 5 minutes
• Bandwidth Threshold    │ bytes/sec > baseline          │ 5 minutes
• Interconnect Util High │ capacity_usage > 80%          │ 5 minutes

SÉCURITÉ (Info/Warning)
──────────────────────────────────────────────────────────────────────────────
• Firewall Denies Spike  │ denied > baseline + 200%      │ 5 minutes
• Unusual Egress         │ egress > baseline + 300%      │ 15 minutes
• Cloud Armor Blocks     │ blocked > 1000/min            │ 1 minute
EOF
```

#### Exercice 11.9.3 : Créer une alerte sur la bande passante

```bash
# Créer une politique d'alerte pour le trafic réseau élevé
cat > alert-bandwidth.json << EOF
{
  "displayName": "High Network Bandwidth Alert",
  "conditions": [
    {
      "displayName": "Bytes sent > 100MB/min",
      "conditionThreshold": {
        "filter": "metric.type=\"compute.googleapis.com/instance/network/sent_bytes_count\" resource.type=\"gce_instance\"",
        "aggregations": [
          {
            "alignmentPeriod": "60s",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "thresholdValue": 1747626,
        "duration": "300s",
        "trigger": {
          "count": 1
        }
      }
    }
  ],
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": ["$CHANNEL_ID"],
  "documentation": {
    "content": "Le trafic réseau sortant dépasse 100MB/min. Vérifier l'activité de la VM.",
    "mimeType": "text/markdown"
  }
}
EOF

# Créer la politique
gcloud alpha monitoring policies create --policy-from-file=alert-bandwidth.json
```

#### Exercice 11.9.4 : Créer une alerte sur les erreurs de pare-feu

```bash
# Alerte basée sur les logs (augmentation des DENIED)
cat > alert-firewall-denies.json << EOF
{
  "displayName": "Firewall Denies Spike Alert",
  "conditions": [
    {
      "displayName": "Firewall DENIED count spike",
      "conditionMatchedLog": {
        "filter": "resource.type=\"gce_subnetwork\" jsonPayload.disposition=\"DENIED\"",
        "labelExtractors": {}
      }
    }
  ],
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": ["$CHANNEL_ID"],
  "alertStrategy": {
    "notificationRateLimit": {
      "period": "300s"
    }
  }
}
EOF
```

### Livrable
Système d'alertes réseau configuré.

---

## Lab 11.10 : Network Intelligence Center
**Durée : 40 minutes | Difficulté : ⭐⭐**

### Objectifs
- Explorer Network Topology
- Utiliser Connectivity Tests
- Analyser Firewall Insights
- Utiliser Network Analyzer

### Exercices

#### Exercice 11.10.1 : Network Topology

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                        NETWORK TOPOLOGY
═══════════════════════════════════════════════════════════════════════════════

Network Topology permet de visualiser:
• L'architecture de vos VPCs
• Les flux de trafic entre ressources
• Les connexions VPN et Interconnect
• Les peerings VPC

Accès: Console GCP → Network Intelligence Center → Network Topology

Fonctionnalités:
• Vue graphique de l'architecture
• Filtrage par projet, VPC, région
• Détails des flux de trafic
• Export de la topologie
EOF

# Via l'API (pour lister les entités)
# Note: Network Topology est principalement une fonctionnalité de la Console
echo "Network Topology est accessible dans la Console GCP"
echo "Navigation: Console → Network Intelligence Center → Network Topology"
```

#### Exercice 11.10.2 : Connectivity Tests

```bash
# Créer un test de connectivité entre deux VMs
gcloud network-management connectivity-tests create test-source-to-dest \
    --source-instance=projects/${PROJECT_ID}/zones/${ZONE}/instances/vm-source \
    --destination-instance=projects/${PROJECT_ID}/zones/${ZONE}/instances/vm-dest \
    --destination-port=80 \
    --protocol=TCP

# Exécuter le test
gcloud network-management connectivity-tests rerun test-source-to-dest

# Voir les résultats
gcloud network-management connectivity-tests describe test-source-to-dest \
    --format="yaml(reachabilityDetails)"

# Créer un test vers Internet
gcloud network-management connectivity-tests create test-to-internet \
    --source-instance=projects/${PROJECT_ID}/zones/${ZONE}/instances/vm-source \
    --destination-ip-address=8.8.8.8 \
    --destination-port=443 \
    --protocol=TCP

# Lister tous les tests
gcloud network-management connectivity-tests list
```

#### Exercice 11.10.3 : Interpréter les résultats

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    RÉSULTATS CONNECTIVITY TESTS
═══════════════════════════════════════════════════════════════════════════════

Résultat          │ Signification
──────────────────┼────────────────────────────────────────────────────────────
REACHABLE         │ Connectivité OK, pas de blocage détecté
UNREACHABLE       │ Bloqué quelque part (firewall, route manquante, etc.)
AMBIGUOUS         │ Résultat incertain (vérifier la configuration)
UNDETERMINED      │ Impossible à déterminer (ressource managée, etc.)

Informations fournies:
• Chemin complet du paquet
• Règle de pare-feu appliquée
• Route utilisée
• Point de blocage éventuel
EOF
```

#### Exercice 11.10.4 : Firewall Insights

```bash
# Lister les insights de pare-feu
gcloud recommender insights list \
    --insight-type=google.compute.firewall.Insight \
    --location=global \
    --project=$PROJECT_ID \
    --format="table(name,insightSubtype,description)"

# Types d'insights:
# - SHADOWED_RULE: Règle masquée par une autre
# - OVERLY_PERMISSIVE: Règle trop large
# - UNUSED_ATTRIBUTE: Attribut non utilisé
# - REDUNDANT_RULE: Règle redondante
```

#### Exercice 11.10.5 : Network Analyzer

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                        NETWORK ANALYZER
═══════════════════════════════════════════════════════════════════════════════

Network Analyzer détecte automatiquement les problèmes de configuration:

Catégorie         │ Exemples de problèmes détectés
──────────────────┼────────────────────────────────────────────────────────────
Routing           │ Routes en conflit, blackhole routes
Firewall          │ Règles incohérentes
Load Balancer     │ Health checks mal configurés
VPN               │ Tunnels mal configurés
DNS               │ Zones en conflit
NAT               │ Configuration incomplète

Accès: Console → Network Intelligence Center → Network Analyzer
EOF

# Via l'API
gcloud network-management operations list
```

### Livrable
Maîtrise de Network Intelligence Center.

---

## Lab 11.11 : Optimisation des coûts d'observabilité
**Durée : 25 minutes | Difficulté : ⭐⭐**

### Objectifs
- Comprendre les sources de coûts
- Optimiser la configuration des Flow Logs
- Gérer la rétention des logs

### Exercices

#### Exercice 11.11.1 : Sources de coûts

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
                    COÛTS D'OBSERVABILITÉ RÉSEAU
═══════════════════════════════════════════════════════════════════════════════

Source              │ Facturation                │ Coût estimé (par VM/mois)
────────────────────┼────────────────────────────┼────────────────────────────
VPC Flow Logs       │ Volume de logs ingérés     │ 
  Sampling 1.0, 5s  │                            │ $5-20
  Sampling 0.5, 1min│                            │ $1-5
  Sampling 0.1, 5min│                            │ $0.1-0.5
────────────────────┼────────────────────────────┼────────────────────────────
Packet Mirroring    │ Trafic mirroré             │ $0.005-0.01/GB
────────────────────┼────────────────────────────┼────────────────────────────
Cloud Monitoring    │ Métriques custom, alertes  │ Inclus (limites gratuites)
────────────────────┼────────────────────────────┼────────────────────────────
Cloud Logging       │ Ingestion + stockage       │ $0.50/GiB ingéré
────────────────────┼────────────────────────────┼────────────────────────────
BigQuery export     │ Stockage + requêtes        │ $0.02/GB stockage
                    │                            │ $5/TB requêtes
EOF
```

#### Exercice 11.11.2 : Optimiser le sampling

```bash
# Configuration économique pour dev/test
gcloud compute networks subnets update subnet-monitored \
    --region=$REGION \
    --logging-flow-sampling=0.1 \
    --logging-aggregation-interval=INTERVAL_10_MIN

# Configuration équilibrée pour production standard
gcloud compute networks subnets update subnet-monitored \
    --region=$REGION \
    --logging-flow-sampling=0.5 \
    --logging-aggregation-interval=INTERVAL_1_MIN

# Configuration complète pour investigation temporaire
gcloud compute networks subnets update subnet-monitored \
    --region=$REGION \
    --logging-flow-sampling=1.0 \
    --logging-aggregation-interval=INTERVAL_30_SEC
```

#### Exercice 11.11.3 : Configurer les filtres

```bash
# Ne capturer que le trafic HTTP/HTTPS
gcloud compute networks subnets update subnet-monitored \
    --region=$REGION \
    --logging-filter-expr='dest_port == 80 || dest_port == 443'

# Ne capturer que le trafic externe
gcloud compute networks subnets update subnet-monitored \
    --region=$REGION \
    --logging-filter-expr='inIpRange(dest_ip, "10.0.0.0/8") == false'
```

#### Exercice 11.11.4 : Configurer la rétention

```bash
# Configurer la rétention du bucket de logs par défaut
gcloud logging buckets update _Default \
    --location=global \
    --retention-days=30

# Créer un sink d'archivage vers Cloud Storage (moins cher)
gsutil mb -l $REGION gs://${PROJECT_ID}-logs-archive

gcloud logging sinks create archive-old-logs \
    storage.googleapis.com/${PROJECT_ID}-logs-archive \
    --log-filter='resource.type="gce_subnetwork" timestamp<"TIMESTAMP_30_DAYS_AGO"'
```

### Livrable
Configuration optimisée pour les coûts.

---

## Lab 11.12 : Scénario intégrateur - Observabilité complète
**Durée : 50 minutes | Difficulté : ⭐⭐⭐**

### Objectifs
- Déployer une solution d'observabilité complète
- Combiner tous les outils
- Documenter la stratégie

### Architecture d'observabilité complète

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ARCHITECTURE D'OBSERVABILITÉ COMPLÈTE                    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                        SOURCES DE DONNÉES                           │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │  VPC Flow Logs     │  Firewall Logs    │  LB Logs    │  NAT Logs   │    │
│  │  (sampling 0.5)    │  (règles critiques)│             │             │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         CLOUD LOGGING                               │    │
│  │                         (rétention 30j)                             │    │
│  └──────────────┬──────────────────────────────────┬───────────────────┘    │
│                 │                                  │                        │
│                 ▼                                  ▼                        │
│  ┌──────────────────────────┐       ┌──────────────────────────────────┐    │
│  │       BigQuery           │       │      Cloud Monitoring            │    │
│  │  (analyse long terme)    │       │   (métriques + alertes)          │    │
│  │                          │       │                                  │    │
│  │  • Requêtes SQL          │       │  • Dashboard temps réel          │    │
│  │  • Détection anomalies   │       │  • Alertes proactives            │    │
│  │  • Reporting             │       │  • SLO monitoring                │    │
│  └──────────────────────────┘       └──────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    NETWORK INTELLIGENCE CENTER                      │    │
│  ├─────────────────────────────────────────────────────────────────────┤    │
│  │  Topology │ Connectivity Tests │ Firewall Insights │ Network Analyzer│   │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      PACKET MIRRORING (optionnel)                   │    │
│  │                      (IDS/Forensics si nécessaire)                  │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Checklist d'implémentation

```bash
cat << 'EOF'
═══════════════════════════════════════════════════════════════════════════════
              CHECKLIST OBSERVABILITÉ RÉSEAU COMPLÈTE
═══════════════════════════════════════════════════════════════════════════════

LOGGING
☐ VPC Flow Logs activés sur tous les sous-réseaux de production
  ☐ Sampling adapté à l'environnement (0.5 prod, 0.1 dev)
  ☐ Intervalle adapté (1min prod, 5min dev)
  ☐ Filtres si nécessaire pour réduire les coûts
☐ Firewall Logging activé sur les règles critiques
  ☐ Règles DENY
  ☐ Règles d'accès sensibles
☐ Export vers BigQuery configuré
  ☐ Dataset créé
  ☐ Sink configuré
  ☐ Requêtes de sécurité préparées

MONITORING
☐ Dashboard réseau créé
  ☐ Bandwidth par VM
  ☐ Latence LB
  ☐ Erreurs
  ☐ État des tunnels VPN
☐ Alertes configurées
  ☐ Disponibilité (VPN down, backends unhealthy)
  ☐ Performance (latence élevée)
  ☐ Sécurité (spike de denies)
☐ Canaux de notification testés

NETWORK INTELLIGENCE CENTER
☐ Connectivity Tests créés pour les chemins critiques
☐ Firewall Insights examiné (règles shadowed, overly permissive)
☐ Network Analyzer exécuté (pas de misconfigurations)

RÉTENTION & COÛTS
☐ Rétention configurée (30j Cloud Logging, BigQuery pour long terme)
☐ Archivage vers Cloud Storage pour les vieux logs
☐ Budget d'alerte configuré si nécessaire
EOF
```

### Livrable final
Solution d'observabilité réseau complète documentée.

---

## Script de nettoyage complet

```bash
#!/bin/bash
# Nettoyage Module 11

echo "=== Suppression Packet Mirroring ==="
gcloud compute packet-mirrorings delete mirror-policy-prod --region=europe-west1 --quiet 2>/dev/null
gcloud compute forwarding-rules delete collector-ilb --region=europe-west1 --quiet 2>/dev/null
gcloud compute backend-services delete collector-backend --region=europe-west1 --quiet 2>/dev/null
gcloud compute health-checks delete hc-collector --region=europe-west1 --quiet 2>/dev/null
gcloud compute instance-groups unmanaged delete ig-collector --zone=europe-west1-b --quiet 2>/dev/null

echo "=== Suppression des VMs ==="
for VM in vm-source vm-dest vm-collector; do
    gcloud compute instances delete $VM --zone=europe-west1-b --quiet 2>/dev/null
done

echo "=== Suppression Connectivity Tests ==="
gcloud network-management connectivity-tests delete test-source-to-dest --quiet 2>/dev/null
gcloud network-management connectivity-tests delete test-to-internet --quiet 2>/dev/null

echo "=== Suppression des sinks de logs ==="
gcloud logging sinks delete flow-logs-to-bq --quiet 2>/dev/null
gcloud logging sinks delete archive-old-logs --quiet 2>/dev/null

echo "=== Suppression BigQuery dataset ==="
bq rm -r -f ${PROJECT_ID}:network_logs 2>/dev/null

echo "=== Suppression des dashboards ==="
for DASHBOARD in $(gcloud monitoring dashboards list --format="get(name)" 2>/dev/null); do
    gcloud monitoring dashboards delete $DASHBOARD --quiet 2>/dev/null
done

echo "=== Suppression des alerting policies ==="
for POLICY in $(gcloud alpha monitoring policies list --format="get(name)" 2>/dev/null); do
    gcloud alpha monitoring policies delete $POLICY --quiet 2>/dev/null
done

echo "=== Suppression des règles de pare-feu ==="
for RULE in $(gcloud compute firewall-rules list --filter="network:vpc-observability" --format="get(name)" 2>/dev/null); do
    gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null
done

echo "=== Suppression des sous-réseaux ==="
for SUBNET in subnet-monitored subnet-collector; do
    gcloud compute networks subnets delete $SUBNET --region=europe-west1 --quiet 2>/dev/null
done

echo "=== Suppression du VPC ==="
gcloud compute networks delete vpc-observability --quiet 2>/dev/null

echo "=== Nettoyage terminé ==="
```

---

## Annexe : Commandes essentielles du Module 11

### VPC Flow Logs
```bash
# Activer
gcloud compute networks subnets update SUBNET --region=REGION --enable-flow-logs

# Configurer
gcloud compute networks subnets update SUBNET --region=REGION \
    --logging-aggregation-interval=INTERVAL_1_MIN \
    --logging-flow-sampling=0.5 \
    --logging-metadata=INCLUDE_ALL_METADATA
```

### Firewall Logging
```bash
# Activer
gcloud compute firewall-rules update RULE --enable-logging
```

### Cloud Logging Queries
```bash
# Flow logs
gcloud logging read 'resource.type="gce_subnetwork"' --limit=50

# Firewall denies
gcloud logging read 'jsonPayload.disposition="DENIED"' --limit=50
```

### Connectivity Tests
```bash
# Créer
gcloud network-management connectivity-tests create NAME \
    --source-instance=INSTANCE \
    --destination-instance=INSTANCE \
    --protocol=TCP --destination-port=80
```
