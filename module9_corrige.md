# Module 9 - Protection DDoS et Cloud Armor
## Corrigé des Questions et du Quizz

---

# Corrigé des Questions des Labs

## Lab 9.3 : Politique Cloud Armor de base

### Comprendre la priorité des règles

**Q : Comment fonctionne la priorité des règles ?**

> L'évaluation des règles suit ce processus :
>
> 1. Les règles sont ordonnées par **priorité croissante** (0 = plus haute priorité)
> 2. Chaque requête est comparée aux règles dans l'ordre
> 3. La **première règle qui matche** est appliquée
> 4. Si aucune règle ne matche, la règle par défaut (priorité 2147483647) s'applique
>
> Exemple :
> ```
> Requête: GET /admin?id=1 OR 1=1 depuis IP 198.51.100.10
>
> Évaluation:
> P100: src-ip=198.51.100.0/24 → MATCH! → Action: deny-403 → STOP
>
> Les règles P200, P1000 (WAF) ne sont jamais évaluées car P100 a matché.
> ```
>
> Bonnes pratiques de priorités :
> - 10-99 : Autorisations explicites (Googlebot, whitelist)
> - 100-199 : Blocages IP
> - 200-299 : Géolocalisation
> - 500-599 : Rate limiting
> - 1000-1999 : WAF
> - 2147483647 : Règle par défaut

---

## Lab 9.4 : Filtrage IP et géolocalisation

### Actions disponibles

**Q : Quelle est la différence entre deny-403 et deny-404 ?**

> | Action | Code HTTP | Message | Usage recommandé |
> |--------|-----------|---------|------------------|
> | deny-403 | 403 | Forbidden | Blocage explicite (l'attaquant sait qu'il est bloqué) |
> | deny-404 | 404 | Not Found | Masquer l'existence de la ressource |
> | deny-502 | 502 | Bad Gateway | Simuler une erreur backend |
>
> Recommandations :
> - **deny-403** : Pour les blocages IP, géolocalisation, rate limiting
> - **deny-404** : Pour cacher des endpoints sensibles (/admin, /api/internal)
> - **deny-502** : Rarement utilisé, peut confondre le monitoring

---

## Lab 9.6 : Règles WAF (OWASP)

### Niveaux de sensibilité

**Q : Comment choisir le niveau de sensibilité WAF ?**

> | Niveau | Sensibilité | Faux positifs | Couverture | Recommandation |
> |--------|-------------|---------------|------------|----------------|
> | 0 | Minimale | Très peu | Basique | Production critique sans tests préalables |
> | 1 | Faible | Peu | Bonne | Production standard |
> | **2** | **Moyenne** | **Modérés** | **Étendue** | **Recommandé pour commencer** |
> | 3 | Élevée | Plus nombreux | Maximale | Après optimisation |
> | 4 | Paranoïaque | Nombreux | Complète | Environnements très sensibles |
>
> Workflow recommandé :
> 1. Commencer en **sensibilité 2, mode Preview**
> 2. Observer les logs pendant 1-2 semaines
> 3. Identifier et exclure les règles causant des faux positifs
> 4. Passer en mode Enforce
> 5. Augmenter progressivement la sensibilité si nécessaire

### Exclusion de règles

**Q : Comment exclure une règle WAF qui cause des faux positifs ?**

> Utiliser le paramètre `opt_out_rule_ids` :
>
> ```bash
> --expression="evaluatePreconfiguredWaf('sqli-v33-stable', {
>     'sensitivity': 2,
>     'opt_out_rule_ids': [
>         'owasp-crs-v030301-id942260-sqli',
>         'owasp-crs-v030301-id942430-sqli'
>     ]
> })"
> ```
>
> Pour identifier les règles problématiques :
> 1. Consulter les logs Cloud Armor
> 2. Chercher le champ `preconfiguredExprIds`
> 3. Analyser si c'est un vrai positif ou faux positif
> 4. Exclure uniquement les règles causant des faux positifs légitimes

---

## Lab 9.7 : Rate Limiting

### Throttle vs Rate-based ban

**Q : Quand utiliser throttle vs rate-based ban ?**

> | Critère | Throttle | Rate-based ban |
> |---------|----------|----------------|
> | Comportement | Rejette l'excédent instantanément | Bannit l'IP pour une durée |
> | Agressivité | Modérée | Élevée |
> | Faux positifs | Moins impactant | Plus impactant |
> | Récupération | Immédiate | Après expiration du ban |
>
> Recommandations :
>
> **Throttle** pour :
> - Rate limiting général (protection de base)
> - Endpoints publics avec trafic légitime variable
> - Première ligne de défense
>
> **Rate-based ban** pour :
> - Endpoints sensibles (login, API auth)
> - Après détection de pattern d'attaque
> - Quand le throttle ne suffit pas
>
> Stratégie progressive :
> ```
> 1. Throttle à 100 req/min (avertissement)
> 2. Si dépassement persistant → Rate-based ban 5 min
> 3. Si récidive → Ban plus long ou blocage permanent
> ```

### Clés de regroupement

**Q : Quelle clé de regroupement (enforce-on-key) utiliser ?**

> | Clé | Regroupement par | Usage |
> |-----|------------------|-------|
> | **IP** | Adresse IP source | Le plus courant, protection générale |
> | ALL | Toutes requêtes | Limite globale (rare) |
> | HTTP_HEADER | Valeur d'un header | API key, Authorization |
> | XFF_IP | IP dans X-Forwarded-For | Derrière un proxy/CDN |
> | HTTP_COOKIE | Valeur d'un cookie | Session utilisateur |
> | HTTP_PATH | Chemin de requête | Par endpoint |
> | REGION_CODE | Pays d'origine | Limite par pays |
>
> Exemple pour une API :
> ```bash
> # Rate limit par API key (pas par IP)
> --enforce-on-key=HTTP_HEADER \
> --enforce-on-key-name=x-api-key
> ```

---

## Lab 9.8 : Mode Preview

### Workflow de validation

**Q : Pourquoi toujours commencer en mode Preview ?**

> Le mode Preview est essentiel car :
>
> 1. **Évite les interruptions de service** : Les faux positifs ne bloquent pas les utilisateurs légitimes
>
> 2. **Permet l'analyse** : Les logs montrent ce qui aurait été bloqué
>
> 3. **Optimisation itérative** : Ajuster les règles avant l'activation
>
> Workflow recommandé :
> ```
> ┌─────────────────────────────────────────────────────────────────┐
> │ 1. CRÉER EN PREVIEW                                            │
> │    gcloud ... --preview                                        │
> └─────────────────────────────────────────────────────────────────┘
>                              │
>                              ▼
> ┌─────────────────────────────────────────────────────────────────┐
> │ 2. OBSERVER (24-48h minimum)                                   │
> │    - Analyser les logs                                         │
> │    - Identifier les faux positifs                              │
> │    - Vérifier les vraies détections                            │
> └─────────────────────────────────────────────────────────────────┘
>                              │
>                              ▼
> ┌─────────────────────────────────────────────────────────────────┐
> │ 3. AJUSTER                                                     │
> │    - Exclure les règles problématiques                         │
> │    - Affiner les expressions                                   │
> │    - Ajuster la sensibilité                                    │
> └─────────────────────────────────────────────────────────────────┘
>                              │
>                              ▼
> ┌─────────────────────────────────────────────────────────────────┐
> │ 4. ACTIVER (ENFORCE)                                           │
> │    gcloud ... --no-preview                                     │
> └─────────────────────────────────────────────────────────────────┘
>                              │
>                              ▼
> ┌─────────────────────────────────────────────────────────────────┐
> │ 5. SURVEILLER                                                  │
> │    - Alertes sur les blocages                                  │
> │    - Révision régulière des logs                               │
> └─────────────────────────────────────────────────────────────────┘
> ```

---

# Corrigé du Quizz du Module 9

**1. Quelles sont les quatre couches de protection DDoS de Google Cloud ?**

> Les quatre couches de protection DDoS sont :
>
> 1. **Infrastructure Google** (automatique)
>    - Capacité de plusieurs Petabits/seconde
>    - Absorption des attaques volumétriques
>
> 2. **Edge Network** (automatique)
>    - Filtrage du trafic malveillant connu
>    - Anti-spoofing, validation des protocoles
>
> 3. **Load Balancing** (automatique)
>    - Distribution du trafic
>    - Protection contre les attaques TCP state
>
> 4. **Cloud Armor** (à configurer)
>    - WAF, règles personnalisées
>    - Rate limiting, Bot Management
>
> Les trois premières couches sont **automatiques**. Cloud Armor nécessite une configuration.

---

**2. Cloud Armor fonctionne avec quels types de Load Balancer ?**

> **b. Uniquement les Application Load Balancers (L7)** ✅
>
> Plus précisément, Cloud Armor fonctionne avec les **Load Balancers de type proxy** :
> - Global external Application LB ✅
> - Regional external Application LB ✅
> - Classic Application LB ✅
> - Global external proxy Network LB ✅
>
> Cloud Armor ne fonctionne **PAS** avec :
> - Network LB passthrough ❌ (pas de terminaison de connexion)
> - Internal LB ❌ (trafic interne uniquement)

---

**3. Quelle action permet de limiter le débit de requêtes ?**

> L'action **throttle** permet de limiter le débit de requêtes.
>
> ```bash
> --action=throttle \
> --rate-limit-threshold-count=100 \
> --rate-limit-threshold-interval-sec=60 \
> --conform-action=allow \
> --exceed-action=deny-429 \
> --enforce-on-key=IP
> ```
>
> Il existe aussi **rate-based-ban** qui bannit temporairement l'IP si le seuil est dépassé.

---

**4. Que signifie une priorité de 100 vs 1000 dans une règle Cloud Armor ?**

> La priorité **100** est **plus haute** que la priorité **1000**.
>
> - Plus le nombre est **bas**, plus la priorité est **haute**
> - La règle de priorité 100 sera évaluée **avant** la règle de priorité 1000
> - La première règle qui matche est appliquée, les suivantes sont ignorées
>
> Exemple :
> ```
> Priorité 100: DENY IP malveillante → Évaluée en premier
> Priorité 1000: WAF SQLi → Évaluée après (si P100 n'a pas matché)
> ```

---

**5. Quel mode permet de tester une règle sans bloquer le trafic ?**

> Le mode **Preview** (ou Dry Run) permet de tester une règle sans bloquer le trafic.
>
> ```bash
> # Créer en mode Preview
> gcloud compute security-policies rules create 1000 \
>     --security-policy=policy \
>     --expression="..." \
>     --action=deny-403 \
>     --preview
>
> # Passer en mode Enforce
> gcloud compute security-policies rules update 1000 \
>     --security-policy=policy \
>     --no-preview
> ```
>
> En mode Preview :
> - Les requêtes ne sont **pas bloquées**
> - Les logs montrent ce qui **aurait été** bloqué
> - Permet d'identifier les faux positifs avant activation

---

**6. Quelle fonctionnalité utilise le machine learning pour détecter les attaques ?**

> **Adaptive Protection** utilise le machine learning pour détecter les attaques.
>
> Fonctionnement :
> - Apprend le trafic normal pendant plusieurs jours
> - Détecte les anomalies (pics, patterns inhabituels)
> - Génère des alertes et suggestions de règles
> - Peut bloquer automatiquement (selon configuration)
>
> Activation :
> ```bash
> gcloud compute security-policies update policy \
>     --enable-layer7-ddos-defense \
>     --layer7-ddos-defense-rule-visibility=STANDARD
> ```
>
> ⚠️ Adaptive Protection nécessite **Managed Protection Plus** (abonnement payant).

---

**7. Citez deux règles WAF préconfigurées disponibles.**

> Exemples de règles WAF préconfigurées (OWASP ModSecurity Core Rule Set) :
>
> 1. **sqli-v33-stable** - Protection contre l'injection SQL
> 2. **xss-v33-stable** - Protection contre le Cross-Site Scripting
>
> Autres règles disponibles :
> - lfi-v33-stable (Local File Inclusion)
> - rfi-v33-stable (Remote File Inclusion)
> - rce-v33-stable (Remote Code Execution)
> - scanner-detection-v33-stable (Scanners de vulnérabilités)
> - protocol-attack-v33-stable (Attaques protocolaires)
> - php-v33-stable, java-v33-stable, nodejs-v33-stable (Spécifiques aux langages)

---

**8. Quelle est la différence entre une Backend Security Policy et une Edge Security Policy ?**

> | Aspect | Backend Security Policy | Edge Security Policy |
> |--------|------------------------|---------------------|
> | **Position** | Au niveau du Load Balancer | Au niveau du CDN (edge) |
> | **Timing** | Après le cache CDN | Avant le cache CDN |
> | **Fonctionnalités** | Complètes (WAF, CEL, Bot Management) | Limitées (IP, géo, basiques) |
> | **Usage** | Protection applicative | Filtrage précoce |
>
> **Edge Security Policy** :
> - Filtrage très précoce (avant que la requête n'atteigne le cache)
> - Protège le cache CDN contre la pollution
> - Réduit la charge sur les backends
> - Règles plus simples (pas de WAF)
>
> **Backend Security Policy** :
> - Filtrage complet avec toutes les fonctionnalités
> - WAF, expressions CEL avancées
> - Rate limiting par endpoint
> - Adaptive Protection, Bot Management
>
> Recommandation : Utiliser les deux en combinaison pour une protection en profondeur.

---

# Questions de réflexion supplémentaires

**Q1 : Comment protéger une API contre les abus ?**

> Stratégie de protection d'une API :
>
> 1. **Authentification** :
>    - Exiger un header x-api-key
>    - Valider le format du token
>    ```bash
>    --expression="request.path.startsWith('/api') && !request.headers['x-api-key'].matches('[a-zA-Z0-9]{32}')"
>    --action=deny-403
>    ```
>
> 2. **Rate limiting par API key** :
>    ```bash
>    --action=throttle \
>    --rate-limit-threshold-count=1000 \
>    --enforce-on-key=HTTP_HEADER \
>    --enforce-on-key-name=x-api-key
>    ```
>
> 3. **Rate limiting sur endpoints sensibles** :
>    - Login : 5 req/min
>    - Création : 10 req/min
>    - Lecture : 100 req/min
>
> 4. **WAF** :
>    - SQLi, XSS sur les paramètres
>    - Validation des payloads JSON
>
> 5. **Monitoring** :
>    - Alertes sur les patterns d'abus
>    - Dashboard de suivi par API key

---

**Q2 : Comment gérer une attaque DDoS en cours ?**

> Procédure de réponse à une attaque DDoS :
>
> 1. **Identifier l'attaque** :
>    - Type (volumétrique, applicative)
>    - Source (IPs, pays, patterns)
>    - Cibles (endpoints, pages)
>
> 2. **Actions immédiates** :
>    ```bash
>    # Bloquer les IPs sources identifiées
>    gcloud compute security-policies rules create 50 \
>        --security-policy=policy \
>        --src-ip-ranges="ATTACKER_IPS" \
>        --action=deny-403
>
>    # Réduire les seuils de rate limiting
>    gcloud compute security-policies rules update 500 \
>        --rate-limit-threshold-count=10
>    ```
>
> 3. **Activer les protections supplémentaires** :
>    - Adaptive Protection (si Managed Protection Plus)
>    - Règles géographiques temporaires
>    - reCAPTCHA sur les pages ciblées
>
> 4. **Communiquer** :
>    - Informer l'équipe
>    - Contacter Google DDoS Response Team (si MPP)
>
> 5. **Post-mortem** :
>    - Analyser les logs
>    - Améliorer les règles
>    - Documenter l'incident

---

**Q3 : Quelle est la structure de priorités recommandée ?**

> Structure de priorités recommandée :
>
> ```
> ┌─────────────────────────────────────────────────────────────────────────┐
> │ PRIORITÉ 10-99: AUTORISATIONS EXPLICITES                               │
> │   P10: Autoriser Googlebot (Named IP List)                             │
> │   P20: Autoriser les partenaires connus                                │
> └─────────────────────────────────────────────────────────────────────────┘
>
> ┌─────────────────────────────────────────────────────────────────────────┐
> │ PRIORITÉ 50-99: BLOCAGES BOTS                                          │
> │   P50: Bloquer bots malveillants (Bot Management)                      │
> └─────────────────────────────────────────────────────────────────────────┘
>
> ┌─────────────────────────────────────────────────────────────────────────┐
> │ PRIORITÉ 100-199: BLOCAGES IP                                          │
> │   P100: IPs blacklistées manuelles                                     │
> │   P150: Tor exit nodes (Threat Intel)                                  │
> │   P160: IPs malveillantes connues (Threat Intel)                       │
> └─────────────────────────────────────────────────────────────────────────┘
>
> ┌─────────────────────────────────────────────────────────────────────────┐
> │ PRIORITÉ 200-299: GÉOLOCALISATION                                      │
> │   P200: Bloquer pays non autorisés                                     │
> └─────────────────────────────────────────────────────────────────────────┘
>
> ┌─────────────────────────────────────────────────────────────────────────┐
> │ PRIORITÉ 300-499: RÈGLES D'ACCÈS                                       │
> │   P300: Bloquer /admin                                                 │
> │   P310: Exiger API key sur /api                                        │
> └─────────────────────────────────────────────────────────────────────────┘
>
> ┌─────────────────────────────────────────────────────────────────────────┐
> │ PRIORITÉ 500-999: RATE LIMITING                                        │
> │   P500: Rate limit global (100/min)                                    │
> │   P510: Rate limit login (5/min, ban)                                  │
> │   P520: Rate limit API (1000/min par key)                              │
> └─────────────────────────────────────────────────────────────────────────┘
>
> ┌─────────────────────────────────────────────────────────────────────────┐
> │ PRIORITÉ 1000-1999: WAF                                                │
> │   P1000: SQLi                                                          │
> │   P1100: XSS                                                           │
> │   P1200: LFI/RFI                                                       │
> │   P1300: RCE                                                           │
> │   P1500: Scanner detection                                             │
> └─────────────────────────────────────────────────────────────────────────┘
>
> ┌─────────────────────────────────────────────────────────────────────────┐
> │ PRIORITÉ 2000+: RÈGLES CUSTOM                                          │
> │   P2000: Règles métier spécifiques                                     │
> └─────────────────────────────────────────────────────────────────────────┘
>
> ┌─────────────────────────────────────────────────────────────────────────┐
> │ PRIORITÉ 2147483647: DÉFAUT                                            │
> │   Default: ALLOW (ou DENY selon contexte)                              │
> └─────────────────────────────────────────────────────────────────────────┘
> ```

---

**Q4 : Comment surveiller l'efficacité de Cloud Armor ?**

> Métriques et surveillance Cloud Armor :
>
> 1. **Dashboard Cloud Armor** (Console) :
>    - Requêtes autorisées/bloquées
>    - Top règles matchées
>    - Distribution géographique
>
> 2. **Métriques Cloud Monitoring** :
>    - `loadbalancing.googleapis.com/https/request_count` par outcome
>    - `loadbalancing.googleapis.com/https/backend_latencies`
>
> 3. **Alertes recommandées** :
>    ```
>    Métrique                        | Seuil        | Action
>    ────────────────────────────────┼──────────────┼─────────────────
>    Requêtes bloquées/min           | > 1000       | Investiguer
>    Nouvelles IPs bloquées/heure    | > 100        | Vérifier attaque
>    Alerte Adaptive Protection      | Toute        | Analyser immédiatement
>    Règle WAF matchée               | Pic soudain  | Vérifier faux positifs
>    ```
>
> 4. **Logs à surveiller** :
>    ```bash
>    # Requêtes bloquées
>    resource.type="http_load_balancer" AND
>    jsonPayload.enforcedSecurityPolicy.outcome="DENY"
>
>    # Alertes Adaptive Protection
>    resource.type="http_load_balancer" AND
>    jsonPayload.adaptiveProtection.autoDeployedRule=true
>    ```

---

**Q5 : Standard vs Managed Protection Plus - Comment choisir ?**

> | Critère | Standard | Managed Protection Plus |
> |---------|----------|------------------------|
> | **Coût** | ~$5/règle + $0.75/M req | ~$3000/mois (org) |
> | **WAF** | ✅ | ✅ |
> | **Rate limiting** | ✅ | ✅ |
> | **Adaptive Protection** | ❌ | ✅ |
> | **Bot Management** | ❌ | ✅ |
> | **DDoS Response Team** | ❌ | ✅ |
> | **Garantie facture DDoS** | ❌ | ✅ |
>
> Choisir **Standard** si :
> - Budget limité
> - Application non critique
> - Trafic prévisible
> - Équipe sécurité capable de répondre aux incidents
>
> Choisir **Managed Protection Plus** si :
> - Application critique (e-commerce, finance, santé)
> - Risque élevé d'attaques sophistiquées
> - Besoin de protection ML (Adaptive)
> - Besoin de support Google en cas d'attaque
> - Protection financière contre les coûts DDoS
