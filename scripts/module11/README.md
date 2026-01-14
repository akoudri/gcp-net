# Module 11 - Surveillance et Journalisation Réseau
## Scripts d'automatisation pour les labs

Ce répertoire contient tous les scripts bash pour automatiser les exercices du Module 11.

## Structure des scripts

### Lab 11.2 - VPC Flow Logs (Activation et configuration)
- `lab11.2_ex1_create-infrastructure.sh` - Créer le VPC et les VMs de test
- `lab11.2_ex2_enable-flow-logs-basic.sh` - Activer les Flow Logs (configuration basique)
- `lab11.2_ex3_configure-advanced-params.sh` - Configurer les paramètres avancés
- `lab11.2_ex4_apply-filter.sh` - Appliquer un filtre sur les logs
- `lab11.2_ex5_generate-traffic.sh` - Générer du trafic de test

### Lab 11.3 - VPC Flow Logs (Analyse et requêtes)
- `lab11.3_ex1_view-all-logs.sh` - Requêtes de base dans Cloud Logging
- `lab11.3_ex2_filter-by-protocol.sh` - Filtrer par protocole et port
- `lab11.3_ex3_identify-external-traffic.sh` - Identifier le trafic externe
- `lab11.3_ex4_analyze-volumes.sh` - Analyse de volumes
- `lab11.3_ex5_security-queries.sh` - Requêtes de sécurité

### Lab 11.4 - VPC Flow Logs (Export vers BigQuery)
- `lab11.4_ex1_create-bigquery-dataset.sh` - Créer le dataset BigQuery
- `lab11.4_ex2_create-log-sink.sh` - Créer le sink de logs
- `lab11.4_ex3_generate-traffic-wait.sh` - Générer du trafic et attendre l'export
- `lab11.4_ex4_query-bigquery.sh` - Requêtes SQL d'analyse
- `lab11.4_ex5_security-queries.sh` - Requêtes de sécurité avancées

### Lab 11.5 - Firewall Rules Logging
- `lab11.5_ex1_enable-logging-existing-rules.sh` - Activer le logging sur les règles existantes
- `lab11.5_ex2_create-deny-rule.sh` - Créer une règle DENY avec logging
- `lab11.5_ex3_test-and-analyze.sh` - Générer du trafic et analyser les logs

### Lab 11.6 - Packet Mirroring
- `lab11.6_ex1_create-collector-subnet.sh` - Créer le sous-réseau pour le collecteur
- `lab11.6_ex2_create-collector-instance.sh` - Créer l'instance collecteur
- `lab11.6_ex3_create-ilb-collector.sh` - Créer l'Internal Load Balancer
- `lab11.6_ex4_create-mirroring-policy.sh` - Créer la politique de Packet Mirroring
- `lab11.6_ex5_test-mirroring.sh` - Tester le Packet Mirroring

### Lab 11.7 - Cloud Monitoring (Métriques réseau)
- `lab11.7_ex1_list-metrics.sh` - Lister les métriques disponibles
- `lab11.7_ex2_query-metrics.sh` - Requêtes de métriques via CLI

### Lab 11.8 - Cloud Monitoring (Dashboards personnalisés)
- `lab11.8_ex1_create-dashboard.sh` - Créer un dashboard via JSON

### Lab 11.9 - Alerting (Configuration des alertes)
- `lab11.9_ex1_create-notification-channel.sh` - Créer un canal de notification
- `lab11.9_ex2_create-bandwidth-alert.sh` - Créer une alerte sur la bande passante

### Lab 11.10 - Network Intelligence Center
- `lab11.10_ex1_create-connectivity-tests.sh` - Connectivity Tests
- `lab11.10_ex2_firewall-insights.sh` - Firewall Insights

### Lab 11.11 - Optimisation des coûts d'observabilité
- `lab11.11_ex1_optimize-sampling.sh` - Optimiser le sampling
- `lab11.11_ex2_configure-filters.sh` - Configurer les filtres
- `lab11.11_ex3_configure-retention.sh` - Configurer la rétention

### Nettoyage
- `cleanup-module11.sh` - Supprimer toutes les ressources créées dans le Module 11

## Utilisation

### Exécution séquentielle recommandée

```bash
# Lab 11.2 - Infrastructure et Flow Logs
./lab11.2_ex1_create-infrastructure.sh
./lab11.2_ex2_enable-flow-logs-basic.sh
./lab11.2_ex3_configure-advanced-params.sh
./lab11.2_ex4_apply-filter.sh
./lab11.2_ex5_generate-traffic.sh

# Lab 11.3 - Analyse des logs
./lab11.3_ex1_view-all-logs.sh
./lab11.3_ex2_filter-by-protocol.sh
./lab11.3_ex3_identify-external-traffic.sh
./lab11.3_ex4_analyze-volumes.sh
./lab11.3_ex5_security-queries.sh

# Lab 11.4 - Export BigQuery
./lab11.4_ex1_create-bigquery-dataset.sh
./lab11.4_ex2_create-log-sink.sh
./lab11.4_ex3_generate-traffic-wait.sh
./lab11.4_ex4_query-bigquery.sh
./lab11.4_ex5_security-queries.sh

# Lab 11.5 - Firewall Logging
./lab11.5_ex1_enable-logging-existing-rules.sh
./lab11.5_ex2_create-deny-rule.sh
./lab11.5_ex3_test-and-analyze.sh

# Lab 11.6 - Packet Mirroring
./lab11.6_ex1_create-collector-subnet.sh
./lab11.6_ex2_create-collector-instance.sh
./lab11.6_ex3_create-ilb-collector.sh
./lab11.6_ex4_create-mirroring-policy.sh
./lab11.6_ex5_test-mirroring.sh

# Lab 11.7 - Métriques réseau
./lab11.7_ex1_list-metrics.sh
./lab11.7_ex2_query-metrics.sh

# Lab 11.8 - Dashboards
./lab11.8_ex1_create-dashboard.sh

# Lab 11.9 - Alerting
./lab11.9_ex1_create-notification-channel.sh
./lab11.9_ex2_create-bandwidth-alert.sh

# Lab 11.10 - Network Intelligence Center
./lab11.10_ex1_create-connectivity-tests.sh
./lab11.10_ex2_firewall-insights.sh

# Lab 11.11 - Optimisation des coûts
./lab11.11_ex1_optimize-sampling.sh
./lab11.11_ex2_configure-filters.sh
./lab11.11_ex3_configure-retention.sh
```

### Nettoyage complet

```bash
# Supprimer toutes les ressources créées
./cleanup-module11.sh
```

## Notes importantes

- Tous les scripts utilisent `set -e` pour arrêter l'exécution en cas d'erreur
- Les scripts incluent des messages de progression et des vérifications
- La région par défaut est `europe-west1`
- Les scripts sont conçus pour être idempotents quand possible
- Certains scripts nécessitent un temps d'attente (Flow Logs, BigQuery export)

## Prérequis

- Projet GCP avec facturation activée
- Droits IAM nécessaires :
  - `roles/logging.admin`
  - `roles/monitoring.admin`
  - `roles/compute.networkAdmin`
  - `roles/bigquery.admin`
- APIs activées :
  - Compute Engine API
  - Cloud Logging API
  - Cloud Monitoring API
  - BigQuery API
  - Network Management API

## Dépannage

Si un script échoue :
1. Vérifiez les messages d'erreur
2. Assurez-vous que les prérequis sont remplis
3. Vérifiez que les ressources des labs précédents existent
4. Consultez la documentation GCP pour plus de détails

## Total des scripts : 34

- 33 scripts d'exercices
- 1 script de nettoyage
