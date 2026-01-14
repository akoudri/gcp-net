# Module 1 - Travaux Pratiques Réseau
## Corrigé des Questions

---

# Lab 1.1 : Exploration des interfaces réseau

## Exercice 1.1.1 : Lister les interfaces réseau

**Q1 : Combien d'interfaces réseau avez-vous ? Lesquelles sont actives ?**

> Le nombre varie selon la machine, mais typiquement on trouve :
> - **lo** (loopback) : toujours présente, active (UP)
> - **eth0** ou **ens33** ou **enp0s3** : interface Ethernet principale
> - **wlan0** ou **wlp2s0** : interface Wi-Fi (si présente)
> - **docker0**, **virbr0** : interfaces virtuelles (si Docker/KVM installé)
> 
> Une interface est active si elle affiche `state UP` ou `<UP>` dans la sortie de `ip link show`.

**Q2 : Quelle est l'adresse MAC de votre interface principale ?**

> L'adresse MAC apparaît après `link/ether` dans la sortie de `ip link show`.
> Exemple : `link/ether 08:00:27:a5:b3:c2`
> 
> Format : 6 octets en hexadécimal séparés par des `:` ou `-`
> Les 3 premiers octets (OUI) identifient le fabricant.

**Q3 : Qu'est-ce que l'interface `lo` (loopback) ?**

> L'interface **loopback** est une interface virtuelle qui permet à la machine de communiquer avec elle-même.
> - Adresse IPv4 : `127.0.0.1` (ou toute adresse en `127.0.0.0/8`)
> - Adresse IPv6 : `::1`
> - Utilisée pour les communications locales (ex: un serveur web local)
> - Le trafic ne quitte jamais la machine
> - Toujours active, même sans connexion réseau

---

## Exercice 1.1.2 : Examiner la configuration IP

**Q1 : Quelle est votre adresse IP privée ? Dans quelle classe/plage se trouve-t-elle ?**

> Exemples courants :
> - `192.168.1.x` → Classe C privée (192.168.0.0/16)
> - `10.0.x.x` → Classe A privée (10.0.0.0/8)
> - `172.16.x.x` à `172.31.x.x` → Classe B privée (172.16.0.0/12)
> 
> Ces plages sont définies par la RFC 1918 et ne sont pas routables sur Internet.

**Q2 : Quel est le masque de sous-réseau (notation CIDR et décimale) ?**

> Exemples courants :
> | CIDR | Décimal | Hôtes disponibles |
> |------|---------|-------------------|
> | /24 | 255.255.255.0 | 254 |
> | /16 | 255.255.0.0 | 65 534 |
> | /8 | 255.0.0.0 | ~16 millions |
> 
> Le masque indique quelle partie de l'adresse identifie le réseau vs l'hôte.

**Q3 : Avez-vous une adresse IPv6 ? De quel type (link-local, global) ?**

> - **Link-local** : commence par `fe80::` - utilisable uniquement sur le lien local, non routable
> - **Global** : commence généralement par `2` ou `3` - routable sur Internet
> - **ULA (Unique Local Address)** : commence par `fc00::` ou `fd00::` - équivalent IPv6 des adresses privées
> 
> Les adresses link-local sont automatiquement générées (SLAAC) et toujours présentes.

---

## Exercice 1.1.3 : Identifier la passerelle par défaut

**Q1 : Quelle est l'adresse de votre passerelle par défaut ?**

> C'est l'adresse IP du routeur qui connecte votre réseau local à Internet.
> Typiquement : `192.168.1.1`, `192.168.0.1`, `10.0.0.1`, etc.
> 
> Elle apparaît dans la ligne `default via X.X.X.X` de `ip route show`.

**Q2 : Que signifie la route `default via X.X.X.X` ?**

> Cette route indique : "Pour toute destination qui ne correspond à aucune autre route plus spécifique, envoyer le paquet au routeur X.X.X.X".
> 
> - `default` = destination `0.0.0.0/0` (correspond à tout)
> - `via X.X.X.X` = le prochain saut (next-hop) est le routeur à cette adresse
> - C'est la "porte de sortie" vers Internet

**Q3 : Identifiez les routes vers vos sous-réseaux locaux.**

> Exemple de sortie `ip route show` :
> ```
> default via 192.168.1.1 dev eth0
> 192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.100
> ```
> 
> La ligne `192.168.1.0/24 dev eth0` signifie : "Pour atteindre le réseau 192.168.1.0/24, utiliser directement l'interface eth0 (pas besoin de passerelle, c'est le réseau local)".

---

# Lab 1.2 : La table ARP et la résolution d'adresses

## Exercice 1.2.1 : Consulter la table ARP

**Q1 : Quelles entrées sont présentes dans votre table ARP ?**

> On trouve typiquement :
> - L'adresse de la passerelle (routeur)
> - Les adresses des machines avec lesquelles on a communiqué récemment
> - Éventuellement des adresses multicast
> 
> Format : `IP → MAC (état)`

**Q2 : Trouvez-vous l'adresse MAC de votre passerelle ?**

> Oui, si vous avez communiqué avec Internet récemment. L'entrée ressemble à :
> ```
> 192.168.1.1 dev eth0 lladdr 00:1a:2b:3c:4d:5e REACHABLE
> ```
> C'est la MAC du routeur, pas celle de la destination finale sur Internet.

**Q3 : Que signifient les états REACHABLE, STALE, DELAY ?**

> | État | Signification |
> |------|---------------|
> | **REACHABLE** | Entrée valide, confirmée récemment (< 30s typiquement) |
> | **STALE** | Entrée potentiellement obsolète, sera revalidée au prochain usage |
> | **DELAY** | En attente de confirmation (probe envoyé) |
> | **PROBE** | Vérification en cours (ARP request envoyé) |
> | **FAILED** | La résolution a échoué (hôte injoignable) |
> | **PERMANENT** | Entrée statique, ne expire jamais |

---

## Exercice 1.2.2 : Observer ARP en action avec Wireshark

**Q1 : Quelle est l'adresse MAC de destination d'une requête ARP ? Pourquoi ?**

> L'adresse MAC de destination est **ff:ff:ff:ff:ff:ff** (broadcast).
> 
> Pourquoi ? Parce que l'émetteur ne connaît pas encore la MAC de la cible ! Il doit donc envoyer la requête à tout le monde sur le réseau local. Seule la machine possédant l'IP demandée répondra.

**Q2 : Combien de temps les entrées ARP restent-elles en cache ?**

> Par défaut sur Linux :
> - **REACHABLE** : environ 30 secondes après la dernière confirmation
> - **STALE** : peut rester plusieurs minutes avant d'être supprimée
> - Total typique : 1 à 5 minutes sans activité
> 
> Ces valeurs sont configurables via `/proc/sys/net/ipv4/neigh/default/`

**Q3 : Que se passe-t-il si l'hôte cible n'existe pas ?**

> - La requête ARP est envoyée en broadcast
> - Aucune réponse n'est reçue
> - Après plusieurs tentatives (3 par défaut), l'entrée passe en état FAILED
> - Le paquet IP original est abandonné (erreur "Host unreachable")

---

## Exercice 1.2.3 : ARP pour une IP hors du sous-réseau local

**Q1 : Vers quelle IP la requête ARP est-elle envoyée ? Pourquoi ?**

> La requête ARP est envoyée vers **l'adresse IP de la passerelle** (ex: 192.168.1.1), pas vers 8.8.8.8.
> 
> Pourquoi ? Parce que 8.8.8.8 n'est pas sur le même sous-réseau local. La machine sait (grâce au masque) qu'elle doit passer par le routeur. Elle a donc besoin de la MAC du routeur pour lui envoyer la trame.

**Q2 : Expliquez pourquoi on ne fait pas ARP directement vers 8.8.8.8.**

> ARP fonctionne uniquement au niveau du lien local (couche 2). 
> 
> - 8.8.8.8 est sur un autre réseau, potentiellement à des milliers de kilomètres
> - Les trames Ethernet ne traversent pas les routeurs (elles sont décapsulées/ré-encapsulées)
> - Chaque segment de réseau a ses propres adresses MAC
> - Le routeur agit comme intermédiaire : il reçoit la trame, extrait le paquet IP, et crée une nouvelle trame vers le prochain saut

---

# Lab 1.3 : Analyse de trames Ethernet et paquets IP

## Exercice 1.3.2 : Observer la fragmentation IP

**Q1 : En combien de fragments le paquet a-t-il été divisé ?**

> Pour un ping de 3000 octets avec une MTU de 1500 :
> - Données totales : 3000 octets + 8 octets en-tête ICMP = 3008 octets
> - Chaque fragment peut contenir : 1500 - 20 (en-tête IP) = 1480 octets de données
> - Nombre de fragments : ceil(3008 / 1480) = **3 fragments**
> 
> Fragment 1 : 1480 octets, Fragment 2 : 1480 octets, Fragment 3 : 48 octets

**Q2 : Quel est le Fragment Offset de chaque fragment ?**

> Le Fragment Offset est exprimé en unités de 8 octets :
> - Fragment 1 : Offset = 0
> - Fragment 2 : Offset = 1480/8 = 185
> - Fragment 3 : Offset = 2960/8 = 370
> 
> Dans Wireshark, vous verrez ces valeurs dans le champ "Fragment Offset".

**Q3 : Comment le destinataire sait-il que c'est le dernier fragment ?**

> Grâce au flag **MF (More Fragments)** dans l'en-tête IP :
> - MF = 1 : d'autres fragments suivent
> - MF = 0 : c'est le dernier fragment (ou un paquet non fragmenté)
> 
> Le dernier fragment a MF = 0 et un Fragment Offset > 0.

---

## Exercice 1.3.3 : Comprendre le TTL

**Q1 : Que se passe-t-il quand le TTL expire ?**

> Quand le TTL atteint 0 sur un routeur :
> 1. Le routeur **abandonne le paquet** (ne le transmet pas)
> 2. Le routeur **envoie un message ICMP "Time Exceeded"** à l'expéditeur original
> 3. Ce mécanisme empêche les paquets de boucler indéfiniment dans le réseau

**Q2 : Quel message ICMP est retourné (Type et Code) ?**

> - **Type 11** : Time Exceeded
> - **Code 0** : Time to Live exceeded in transit (TTL expiré pendant le routage)
> - Code 1 : Fragment Reassembly Time Exceeded (timeout de réassemblage)

**Q3 : Qui envoie ce message ?**

> Le **routeur** sur lequel le TTL est tombé à 0.
> 
> C'est exactement ce qu'exploite `traceroute` : en envoyant des paquets avec TTL=1, puis TTL=2, etc., on reçoit des réponses "Time Exceeded" de chaque routeur successif, révélant ainsi le chemin.

---

# Lab 1.4 : Traceroute

## Exercice 1.4.1 : Traceroute basique

**Q1 : Combien de sauts (hops) jusqu'à la destination ?**

> Varie selon la destination et le chemin, typiquement entre **8 et 20 sauts** pour une destination sur Internet.
> 
> Chaque ligne numérotée représente un routeur traversé.

**Q2 : Quels routeurs identifiez-vous (FAI, backbone...) ?**

> On peut généralement identifier :
> - **Sauts 1-2** : Routeur local, box FAI
> - **Sauts 3-5** : Infrastructure du FAI (noms contenant le nom du FAI)
> - **Sauts 6+** : Points d'échange (IX), backbones (noms comme "telia", "level3", "cogent")
> - **Derniers sauts** : Infrastructure de la destination (ex: "google", "cloudflare")
> 
> Les noms DNS des routeurs donnent souvent des indices sur leur localisation (par, fra, lon = Paris, Frankfurt, London).

**Q3 : Que signifient les `* * *` ?**

> Les astérisques indiquent qu'aucune réponse n'a été reçue pour ce saut. Causes possibles :
> - Le routeur **ne répond pas aux requêtes ICMP/UDP** (firewall, configuration)
> - Le routeur **rate-limite** les réponses ICMP
> - Perte de paquets sur le réseau
> - Le paquet de réponse a été filtré en retour
> 
> Ce n'est pas forcément un problème si les sauts suivants fonctionnent.

---

## Exercice 1.4.3 : Comparer les chemins

**Q1 : Les premiers sauts sont-ils les mêmes ? Pourquoi ?**

> **Oui**, les premiers sauts sont généralement identiques car ils représentent :
> - Votre passerelle locale
> - L'infrastructure de votre FAI
> 
> Le chemin ne diverge qu'à partir du point où le routage vers différentes destinations diffère (généralement au niveau des points de peering ou des backbones).

**Q2 : À partir de quel saut les chemins divergent-ils ?**

> Typiquement après **3 à 6 sauts**, quand le trafic quitte l'infrastructure de votre FAI pour rejoindre différents backbones ou points d'échange selon la destination.

---

# Lab 1.5 : TCP vs UDP en pratique

## Exercice 1.5.1 : Le 3-way handshake TCP

**Q1 : Quels sont les numéros de séquence initiaux (ISN) ?**

> Les ISN sont des **nombres aléatoires de 32 bits** choisis par chaque partie.
> 
> Exemples dans Wireshark :
> - Client ISN : 2847583921
> - Serveur ISN : 1039485762
> 
> Ils sont aléatoires pour des raisons de sécurité (éviter les attaques par prédiction de séquence).

**Q2 : Combien de paquets pour établir la connexion ?**

> **3 paquets** (d'où le nom "3-way handshake") :
> 1. SYN (Client → Serveur)
> 2. SYN-ACK (Serveur → Client)
> 3. ACK (Client → Serveur)
> 
> Après ces 3 paquets, la connexion est ESTABLISHED des deux côtés.

**Q3 : Observez la fermeture (FIN, FIN-ACK ou RST)**

> Fermeture normale (4 paquets) :
> 1. FIN (initiateur → autre)
> 2. ACK (autre → initiateur)
> 3. FIN (autre → initiateur)
> 4. ACK (initiateur → autre)
> 
> Ou fermeture combinée (3 paquets) : FIN → FIN-ACK → ACK
> 
> RST (Reset) : fermeture brutale, utilisée en cas d'erreur ou de refus de connexion.

---

## Exercice 1.5.2 : Comparaison TCP vs UDP

**Q1 : Y a-t-il un handshake pour UDP ?**

> **Non**, UDP est "connectionless" (sans connexion).
> 
> Les données sont envoyées directement sans établissement préalable. C'est plus rapide mais sans garantie de livraison.

**Q2 : Observez les numéros de séquence TCP - comment évoluent-ils ?**

> Le numéro de séquence **augmente du nombre d'octets de données envoyés**.
> 
> Exemple :
> - Paquet 1 : Seq=1000, 500 octets de données
> - Paquet 2 : Seq=1500, 500 octets de données
> - Paquet 3 : Seq=2000, etc.
> 
> Le numéro d'acquittement (ACK) indique le prochain octet attendu.

**Q3 : Quelle est la taille des en-têtes TCP vs UDP ?**

> | Protocole | Taille en-tête minimum | Taille avec options |
> |-----------|------------------------|---------------------|
> | **TCP** | 20 octets | Jusqu'à 60 octets |
> | **UDP** | 8 octets | 8 octets (pas d'options) |
> 
> TCP a plus d'overhead mais offre fiabilité, contrôle de flux et de congestion.

---

## Exercice 1.5.3 : Observer les connexions avec ss/netstat

**Q1 : Quels ports sont en écoute sur votre machine ?**

> Ports courants en écoute :
> - **22** : SSH
> - **53** : DNS (si serveur DNS local)
> - **80/443** : HTTP/HTTPS (si serveur web)
> - **631** : CUPS (impression)
> - **3306** : MySQL
> - **5432** : PostgreSQL

**Q2 : Dans quel état se trouve une connexion TCP en attente ?**

> **LISTEN** - Le socket attend des connexions entrantes sur ce port.
> 
> C'est l'état d'un serveur qui a fait `bind()` et `listen()` mais n'a pas encore accepté de connexion.

**Q3 : Que signifient les états LISTEN, ESTABLISHED, TIME_WAIT ?**

> | État | Description |
> |------|-------------|
> | **LISTEN** | Serveur en attente de connexions |
> | **SYN_SENT** | Client a envoyé SYN, attend SYN-ACK |
> | **SYN_RECEIVED** | Serveur a reçu SYN, envoyé SYN-ACK |
> | **ESTABLISHED** | Connexion active, données peuvent circuler |
> | **FIN_WAIT_1** | Initiateur de fermeture, a envoyé FIN |
> | **FIN_WAIT_2** | A reçu ACK du FIN, attend FIN de l'autre |
> | **TIME_WAIT** | Attend 2×MSL avant fermeture complète (évite confusion avec anciens paquets) |
> | **CLOSE_WAIT** | A reçu FIN, application doit fermer |
> | **LAST_ACK** | A envoyé FIN, attend dernier ACK |
> | **CLOSED** | Connexion terminée |

---

# Lab 1.6 : DNS - La résolution de noms

## Exercice 1.6.2 : Explorer les types d'enregistrements

**Q1 : Combien d'adresses IP sont associées à google.com ?**

> Généralement **plusieurs adresses** (4 à 6 typiquement) pour la répartition de charge.
> 
> Google utilise le DNS pour diriger les utilisateurs vers le datacenter le plus proche (Anycast/GeoDNS).

**Q2 : Quels sont les serveurs mail de google.com ? Quel est leur priorité ?**

> Exemple de réponse MX :
> ```
> google.com.  MX  5  gmail-smtp-in.l.google.com.
> google.com.  MX  10 alt1.gmail-smtp-in.l.google.com.
> google.com.  MX  20 alt2.gmail-smtp-in.l.google.com.
> ```
> 
> Le nombre (5, 10, 20) est la **priorité** : plus le chiffre est bas, plus le serveur est prioritaire. Les autres sont utilisés en cas d'indisponibilité.

**Q3 : Qu'est-ce qu'un CNAME ? Donnez un exemple.**

> **CNAME** (Canonical Name) = un alias qui pointe vers un autre nom de domaine.
> 
> Exemple :
> ```
> www.github.com.  CNAME  github.com.
> ```
> 
> Cela signifie que `www.github.com` est un alias pour `github.com`. La résolution continue avec le nom canonique.
> 
> Avantage : si l'IP change, on ne modifie qu'un seul enregistrement A.

---

## Exercice 1.6.4 : Observer DNS dans Wireshark

**Questions d'analyse :**

> **Port utilisé** : UDP 53 (TCP 53 pour les transferts de zone ou réponses > 512 octets)
> 
> **Structure requête DNS** :
> - Transaction ID (16 bits) : pour corréler requête/réponse
> - Flags : QR (Query/Response), Opcode, RD (Recursion Desired)
> - Questions : le nom demandé et le type (A, AAAA, MX...)
> 
> **Structure réponse DNS** :
> - Même Transaction ID
> - Flags : QR=1 (réponse), AA (Authoritative), RA (Recursion Available)
> - Answers : les enregistrements demandés avec TTL
> - Authority : serveurs autoritaires (optionnel)
> - Additional : enregistrements supplémentaires utiles

---

# Lab 1.7 : Simulation avec Packet Tracer

## Exercice 1.7.2 : Observer l'encapsulation

**Q1 : L'adresse MAC source change-t-elle quand le paquet traverse le routeur ?**

> **OUI**, l'adresse MAC change à chaque segment de réseau.
> 
> - Avant le routeur : MAC source = MAC de PC1
> - Après le routeur : MAC source = MAC de l'interface de sortie du routeur
> 
> Le routeur **décapsule** la trame (retire l'en-tête Ethernet), consulte l'en-tête IP pour le routage, puis **ré-encapsule** avec de nouvelles adresses MAC.

**Q2 : L'adresse IP source change-t-elle ?**

> **NON**, les adresses IP source et destination restent identiques de bout en bout.
> 
> (Exception : NAT modifie les adresses IP, mais ce n'est pas le cas ici)
> 
> C'est la différence fondamentale entre couche 2 (locale) et couche 3 (globale).

**Q3 : Expliquez pourquoi.**

> - **Couche 2 (MAC)** : Portée locale au segment réseau. Chaque lien a ses propres adresses MAC. Le routeur est un "intermédiaire" qui reçoit sur une interface et transmet sur une autre.
> 
> - **Couche 3 (IP)** : Portée globale (de bout en bout). L'adresse IP identifie l'hôte source et destination finale, peu importe le nombre de routeurs traversés.
> 
> Analogie : Sur une lettre postale, l'adresse de l'expéditeur et du destinataire ne changent pas, mais chaque bureau de poste intermédiaire manipule l'enveloppe différemment.

---

# Annexe B : Questions de réflexion - Réponses

## Couche 2 - Liaison

**Q1 : Pourquoi a-t-on besoin d'ARP si on a déjà les adresses IP ?**

> Les adresses IP sont des adresses **logiques** de couche 3, utilisées pour le routage global.
> 
> Mais pour envoyer physiquement une trame sur un réseau Ethernet, on a besoin de l'adresse **MAC** (couche 2).
> 
> ARP fait le pont entre les deux : "Je connais l'IP, quelle est la MAC correspondante ?"
> 
> Sans ARP, impossible de construire l'en-tête Ethernet de la trame.

**Q2 : Que se passe-t-il si deux machines ont la même adresse MAC ?**

> C'est un **conflit d'adresse MAC** (rare car les MAC sont censées être uniques) :
> - Les deux machines recevront le trafic destiné à cette MAC
> - Comportement imprévisible et intermittent
> - Problèmes de connectivité aléatoires
> - Le switch peut osciller entre ses deux ports pour cette MAC
> 
> En pratique, cela peut arriver avec des VMs mal configurées ou du MAC spoofing.

**Q3 : Comment un switch sait-il sur quel port envoyer une trame ?**

> Le switch maintient une **table MAC** (ou CAM table) qui associe adresses MAC ↔ ports.
> 
> Fonctionnement :
> 1. Quand une trame arrive, le switch note : "MAC source X est sur le port Y"
> 2. Pour transmettre, il cherche la MAC destination dans sa table
> 3. Si trouvée → envoie sur le port correspondant
> 4. Si non trouvée → **flood** (envoie sur tous les ports sauf celui d'origine)
> 
> La table est mise à jour dynamiquement et les entrées expirent après un timeout.

---

## Couche 3 - Réseau

**Q1 : Pourquoi le TTL est-il nécessaire ?**

> Le TTL empêche les paquets de **boucler indéfiniment** dans le réseau en cas d'erreur de routage.
> 
> Sans TTL :
> - Une boucle de routage consommerait infiniment de la bande passante
> - Les paquets ne seraient jamais délivrés ni supprimés
> - Le réseau serait rapidement saturé
> 
> Avec TTL :
> - Chaque routeur décrémente le TTL de 1
> - À 0, le paquet est abandonné
> - Un message ICMP "Time Exceeded" informe l'expéditeur

**Q2 : Comment un routeur décide-t-il où envoyer un paquet ?**

> Le routeur consulte sa **table de routage** et applique le **longest prefix match** :
> 
> 1. Compare l'IP destination avec toutes les entrées de la table
> 2. Sélectionne la route avec le masque le plus long (la plus spécifique)
> 3. Envoie le paquet vers le next-hop indiqué par cette route
> 4. Si aucune route ne correspond → utilise la route par défaut (0.0.0.0/0)
> 5. Si pas de route par défaut → abandonne le paquet (ICMP "Network Unreachable")

**Q3 : Quelle est la différence entre routage statique et dynamique ?**

> | Aspect | Routage statique | Routage dynamique |
> |--------|------------------|-------------------|
> | Configuration | Manuelle par l'admin | Automatique via protocole |
> | Adaptation | Aucune | S'adapte aux changements |
> | Protocoles | Aucun | OSPF, BGP, RIP, EIGRP... |
> | Overhead | Aucun | Consomme bande passante/CPU |
> | Scalabilité | Limitée | Excellente |
> | Cas d'usage | Petits réseaux, routes fixes | Grands réseaux, redondance |

---

## Couche 4 - Transport

**Q1 : Quand utiliser TCP plutôt qu'UDP ?**

> **Utiliser TCP quand** :
> - La fiabilité est essentielle (transfert de fichiers, email, web)
> - L'ordre des données compte
> - La perte de données est inacceptable
> - Exemples : HTTP, FTP, SMTP, SSH
> 
> **Utiliser UDP quand** :
> - La vitesse/latence prime sur la fiabilité
> - Quelques pertes sont tolérables
> - L'application gère elle-même la fiabilité si nécessaire
> - Exemples : DNS, streaming vidéo, VoIP, jeux en ligne

**Q2 : Que se passe-t-il si un segment TCP est perdu ?**

> Mécanisme de **retransmission** :
> 1. L'émetteur envoie un segment et démarre un timer (RTO - Retransmission Timeout)
> 2. Le récepteur envoie un ACK pour confirmer réception
> 3. Si l'ACK n'arrive pas avant le timeout → l'émetteur retransmet
> 4. Le récepteur utilise les numéros de séquence pour réordonner et dédupliquer
> 
> Mécanismes additionnels :
> - **Fast Retransmit** : 3 ACKs dupliqués déclenchent une retransmission immédiate
> - **SACK** (Selective ACK) : indique précisément quels segments manquent

**Q3 : Pourquoi y a-t-il des numéros de ports ?**

> Les ports permettent le **multiplexage** : plusieurs applications sur une même machine peuvent communiquer simultanément via une seule adresse IP.
> 
> - L'adresse IP identifie la **machine**
> - Le port identifie l'**application/service** sur cette machine
> 
> Analogie : L'IP est l'adresse d'un immeuble, le port est le numéro d'appartement.
> 
> Plages de ports :
> - 0-1023 : Well-known (privilégiés, réservés aux services standards)
> - 1024-49151 : Registered (enregistrés auprès de l'IANA)
> - 49152-65535 : Dynamic/Private (ports éphémères pour les clients)

---

## Couche 7 - Application

**Q1 : Pourquoi le DNS utilise-t-il UDP plutôt que TCP (généralement) ?**

> Raisons :
> - **Rapidité** : Pas de handshake, requête-réponse directe
> - **Légèreté** : En-tête UDP plus petit (8 vs 20+ octets)
> - **Simplicité** : Une question, une réponse
> - **Stateless** : Pas de connexion à maintenir
> 
> Le DNS utilise TCP quand :
> - La réponse dépasse 512 octets (EDNS0 repousse cette limite)
> - Transfert de zone (AXFR) entre serveurs DNS
> - DNSSEC avec signatures volumineuses

**Q2 : Quel est l'avantage d'avoir plusieurs serveurs DNS ?**

> - **Redondance** : Si un serveur tombe, les autres prennent le relais
> - **Performance** : Répartition de charge, latence réduite
> - **Résilience** : Protection contre les pannes et attaques DDoS
> - **Distribution géographique** : Réponse depuis le serveur le plus proche
> 
> C'est pourquoi on configure toujours au moins 2 serveurs DNS (primaire et secondaire).

**Q3 : Que se passe-t-il si le cache DNS contient une entrée obsolète ?**

> - L'utilisateur est dirigé vers une **ancienne adresse IP** (potentiellement invalide)
> - Comportements possibles : échec de connexion, accès à un mauvais serveur
> - Cas problématique : lors de migrations, les utilisateurs avec un cache obsolète n'accèdent pas au nouveau serveur
> 
> Solutions :
> - Attendre l'expiration du TTL
> - Vider le cache manuellement (`systemd-resolve --flush-caches`, `ipconfig /flushdns`)
> - Utiliser des TTL courts avant les migrations

---

## Questions transversales

**Q1 : Tracez le chemin complet d'un paquet depuis `curl http://example.com` jusqu'à l'affichage de la réponse.**

> 1. **Résolution DNS** (Couche 7)
>    - Client → Serveur DNS : "Quelle est l'IP de example.com ?"
>    - Serveur DNS → Client : "93.184.216.34"
> 
> 2. **Résolution ARP** (Couche 2)
>    - Client → Broadcast : "Qui a l'IP de ma passerelle ?"
>    - Passerelle → Client : "C'est moi, voici ma MAC"
> 
> 3. **Établissement TCP** (Couche 4)
>    - Client → Serveur : SYN
>    - Serveur → Client : SYN-ACK
>    - Client → Serveur : ACK
> 
> 4. **Requête HTTP** (Couche 7)
>    - Client → Serveur : "GET / HTTP/1.1"
> 
> 5. **Réponse HTTP** (Couche 7)
>    - Serveur → Client : "HTTP/1.1 200 OK" + contenu HTML
> 
> 6. **Fermeture TCP** (Couche 4)
>    - Échange de FIN/ACK
> 
> 7. **Affichage**
>    - L'application affiche le contenu reçu

**Q2 : Pourquoi l'adresse MAC change à chaque routeur mais pas l'adresse IP ?**

> **Adresse MAC** (Couche 2 - locale) :
> - Identifie les équipements sur un **segment réseau local**
> - N'a de sens qu'entre deux équipements directement connectés
> - Le routeur termine le segment et en commence un nouveau
> - Chaque segment a ses propres adresses MAC
> 
> **Adresse IP** (Couche 3 - globale) :
> - Identifie les équipements de manière **globale**
> - Utilisée pour le routage de bout en bout
> - Reste constante tout au long du trajet
> - Permet aux routeurs intermédiaires de savoir où envoyer le paquet
> 
> Le routeur agit comme un traducteur entre segments : il lit l'IP pour savoir où envoyer, puis utilise ARP pour trouver la MAC du prochain saut.

**Q3 : Comment le NAT affecte-t-il les couches 3 et 4 ?**

> **Couche 3 (IP)** :
> - NAT modifie l'**adresse IP source** des paquets sortants (IP privée → IP publique)
> - Modifie l'**adresse IP destination** des paquets entrants (IP publique → IP privée)
> - Recalcule le **checksum IP**
> 
> **Couche 4 (TCP/UDP)** :
> - PAT (Port Address Translation) modifie aussi les **numéros de port**
> - Permet à plusieurs hôtes privés de partager une seule IP publique
> - Recalcule le **checksum TCP/UDP**
> - Le NAT maintient une table de correspondance (IP:Port interne ↔ IP:Port externe)
> 
> Conséquences :
> - Les protocoles qui incluent les adresses IP dans les données (FTP, SIP) nécessitent un ALG (Application Layer Gateway)
> - Difficulté pour les connexions entrantes (besoin de port forwarding)
> - Problèmes avec IPsec en mode AH (qui authentifie l'en-tête IP)
