# Module 1 - Travaux Pratiques Réseau

---

## Vue d'ensemble

### Objectifs pédagogiques
Ces travaux pratiques permettront aux apprenants de :
- Visualiser concrètement le fonctionnement des différentes couches réseau
- Manipuler les outils de diagnostic essentiels
- Comprendre l'encapsulation et la désencapsulation des données
- Acquérir des réflexes de troubleshooting réseau

### Outils utilisés

| Outil | Couche principale | Plateforme | Usage |
|-------|-------------------|------------|-------|
| Packet Tracer | Toutes | Windows/Linux/Mac | Simulation réseau complète |
| Wireshark | 2-7 | Windows/Linux/Mac | Capture et analyse de trames |
| tcpdump | 2-7 | Linux/Mac | Capture en ligne de commande |
| arp | 2 | Windows/Linux | Table ARP, résolution MAC |
| ip / ifconfig | 2-3 | Linux | Configuration interfaces |
| route / ip route | 3 | Linux | Tables de routage |
| ping | 3 (ICMP) | Windows/Linux | Test de connectivité |
| traceroute / tracert | 3 | Windows/Linux | Traçage de chemin |
| ss / netstat | 4 | Linux/Windows | Connexions TCP/UDP |
| lsof | 4 | Linux/Mac | Fichiers/ports ouverts |
| nc (netcat) | 4 | Linux/Mac | Test connexions TCP/UDP |
| dig / nslookup | 7 (DNS) | Windows/Linux | Résolution DNS |
| curl | 7 (HTTP) | Windows/Linux | Requêtes HTTP |

### Prérequis techniques
- VM Linux (Ubuntu 22.04+ recommandé) ou WSL2 sur Windows
- Wireshark installé avec droits de capture
- Packet Tracer (compte Cisco Networking Academy gratuit)
- Accès root/sudo pour certaines commandes

---

## Lab 1.1 : Exploration des interfaces réseau (Couche 2-3)

### Objectifs
- Identifier les interfaces réseau de la machine
- Comprendre les adresses MAC et IP
- Visualiser la configuration réseau

### Exercices

#### Exercice 1.1.1 : Lister les interfaces réseau

```bash
# Linux - Méthode moderne (iproute2)
ip link show

# Linux - Méthode classique
ifconfig -a

# Windows (PowerShell)
Get-NetAdapter
ipconfig /all
```

**Questions :**
1. Combien d'interfaces réseau avez-vous ? Lesquelles sont actives ?
2. Quelle est l'adresse MAC de votre interface principale ?
3. Qu'est-ce que l'interface `lo` (loopback) ?

#### Exercice 1.1.2 : Examiner la configuration IP

```bash
# Afficher les adresses IP
ip addr show

# Afficher uniquement IPv4
ip -4 addr show

# Afficher uniquement IPv6
ip -6 addr show
```

**Questions :**
1. Quelle est votre adresse IP privée ? Dans quelle classe/plage se trouve-t-elle ?
2. Quel est le masque de sous-réseau (notation CIDR et décimale) ?
3. Avez-vous une adresse IPv6 ? De quel type (link-local, global) ?

#### Exercice 1.1.3 : Identifier la passerelle par défaut

```bash
# Linux
ip route show
# ou
route -n

# Windows
route print
```

**Questions :**
1. Quelle est l'adresse de votre passerelle par défaut ?
2. Que signifie la route `default via X.X.X.X` ?
3. Identifiez les routes vers vos sous-réseaux locaux.

---

## Lab 1.2 : La table ARP et la résolution d'adresses (Couche 2)

### Objectifs
- Comprendre le rôle du protocole ARP
- Observer la table ARP et son fonctionnement
- Capturer des requêtes/réponses ARP avec Wireshark

### Contexte théorique
ARP (Address Resolution Protocol) fait le lien entre les adresses IP (couche 3) et les adresses MAC (couche 2). Sans ARP, impossible d'envoyer une trame Ethernet !

### Exercices

#### Exercice 1.2.1 : Consulter la table ARP

```bash
# Linux
ip neigh show
# ou (ancienne méthode)
arp -a

# Windows
arp -a
```

**Questions :**
1. Quelles entrées sont présentes dans votre table ARP ?
2. Trouvez-vous l'adresse MAC de votre passerelle ?
3. Que signifient les états REACHABLE, STALE, DELAY ?

#### Exercice 1.2.2 : Observer ARP en action avec Wireshark

```bash
# 1. Vider la table ARP
sudo ip neigh flush all

# 2. Lancer Wireshark avec filtre : arp

# 3. Effectuer un ping vers la passerelle
ping -c 1 <IP_PASSERELLE>

# 4. Observer les paquets ARP dans Wireshark
```

**Analyse Wireshark :**
- Identifiez la requête ARP (Who has X.X.X.X? Tell Y.Y.Y.Y)
- Identifiez la réponse ARP (X.X.X.X is at AA:BB:CC:DD:EE:FF)
- Notez les adresses MAC source et destination de la trame

**Questions :**
1. Quelle est l'adresse MAC de destination d'une requête ARP ? Pourquoi ?
2. Combien de temps les entrées ARP restent-elles en cache ?
3. Que se passe-t-il si l'hôte cible n'existe pas ?

#### Exercice 1.2.3 : ARP pour une IP hors du sous-réseau local

```bash
# Vider le cache ARP
sudo ip neigh flush all

# Lancer Wireshark (filtre: arp)

# Ping vers une IP externe (ex: 8.8.8.8)
ping -c 1 8.8.8.8

# Observer les requêtes ARP
```

**Questions :**
1. Vers quelle IP la requête ARP est-elle envoyée ? Pourquoi ?
2. Expliquez pourquoi on ne fait pas ARP directement vers 8.8.8.8.


---

## Lab 1.3 : Analyse de trames Ethernet et paquets IP (Couches 2-3)

### Objectifs
- Décortiquer une trame Ethernet complète
- Identifier les en-têtes IP
- Comprendre l'encapsulation

### Exercices

#### Exercice 1.3.1 : Capturer et analyser une trame ICMP (ping)

```bash
# Lancer Wireshark avec filtre : icmp

# Effectuer un ping
ping -c 3 8.8.8.8
```

**Analyse dans Wireshark :**
Pour chaque paquet ICMP Echo Request, identifiez :

**Couche 2 - Trame Ethernet :**
- Adresse MAC destination
- Adresse MAC source  
- EtherType (devrait être 0x0800 pour IPv4)

**Couche 3 - Paquet IP :**
- Version (4 ou 6)
- IHL (Internet Header Length)
- Total Length
- TTL (Time To Live)
- Protocol (1 = ICMP)
- Adresse IP source
- Adresse IP destination
- Checksum

**Couche ICMP :**
- Type (8 = Echo Request, 0 = Echo Reply)
- Code
- Checksum
- Identifier et Sequence Number

#### Exercice 1.3.2 : Observer la fragmentation IP

```bash
# Envoyer un paquet plus grand que la MTU standard
# -s spécifie la taille des données (hors en-têtes)
ping -c 1 -s 3000 8.8.8.8

# Dans Wireshark, observer les fragments
# Filtre : ip.flags.mf == 1 || ip.frag_offset > 0
```

**Questions :**
1. En combien de fragments le paquet a-t-il été divisé ?
2. Quel est le Fragment Offset de chaque fragment ?
3. Comment le destinataire sait-il que c'est le dernier fragment ?

#### Exercice 1.3.3 : Comprendre le TTL et son décrémentation

```bash
# Lancer Wireshark (filtre: icmp)

# Envoyer des pings avec différents TTL
ping -c 1 -t 1 8.8.8.8    # TTL = 1
ping -c 1 -t 5 8.8.8.8    # TTL = 5
ping -c 1 -t 64 8.8.8.8   # TTL = 64 (défaut Linux)
```

**Questions :**
1. Que se passe-t-il quand le TTL expire ?
2. Quel message ICMP est retourné (Type et Code) ?
3. Qui envoie ce message ?

---

## Lab 1.4 : Traceroute - Comprendre le chemin des paquets (Couche 3)

### Objectifs
- Comprendre le fonctionnement de traceroute
- Identifier les routeurs intermédiaires
- Analyser les temps de latence

### Contexte théorique
Traceroute exploite le TTL et les messages ICMP "Time Exceeded" pour découvrir le chemin réseau.

### Exercices

#### Exercice 1.4.1 : Traceroute basique

```bash
# Linux (utilise UDP par défaut)
traceroute google.com

# Linux (utilise ICMP comme Windows)
traceroute -I google.com

# Windows
tracert google.com
```

**Questions :**
1. Combien de sauts (hops) jusqu'à la destination ?
2. Quels routeurs identifiez-vous (FAI, backbone...) ?
3. Que signifient les `* * *` ?

#### Exercice 1.4.2 : Observer traceroute dans Wireshark

```bash
# Lancer Wireshark avec filtre : icmp || udp.port == 33434

# Exécuter traceroute
traceroute -n 8.8.8.8
```

**Analyse :**
1. Observez les paquets UDP/ICMP avec TTL=1, puis TTL=2, etc.
2. Observez les réponses ICMP "Time-to-live exceeded"
3. Notez l'adresse source de chaque réponse (= adresse du routeur)

#### Exercice 1.4.3 : Comparer les chemins

```bash
# Tracer vers plusieurs destinations
traceroute google.fr
traceroute cloudflare.com
traceroute amazon.com

# Comparer les premiers sauts (devraient être identiques)
```

**Questions :**
1. Les premiers sauts sont-ils les mêmes ? Pourquoi ?
2. À partir de quel saut les chemins divergent-ils ?

#### Exercice 1.4.4 (Bonus) : MTR - traceroute continu

```bash
# Installer mtr si nécessaire
sudo apt install mtr

# Lancer mtr
mtr google.com

# Observer les statistiques en temps réel
```

---

## Lab 1.5 : TCP vs UDP en pratique (Couche 4)

### Objectifs
- Observer les différences entre TCP et UDP
- Comprendre le 3-way handshake TCP
- Analyser les ports et les connexions

### Exercices

#### Exercice 1.5.1 : Le 3-way handshake TCP

```bash
# Lancer Wireshark avec filtre : tcp.port == 80

# Établir une connexion HTTP
curl -I http://example.com
```

**Analyse du handshake :**
1. **SYN** : Client → Serveur (Flags: SYN, Seq=0)
2. **SYN-ACK** : Serveur → Client (Flags: SYN,ACK, Seq=0, Ack=1)
3. **ACK** : Client → Serveur (Flags: ACK, Seq=1, Ack=1)

**Questions :**
1. Quels sont les numéros de séquence initiaux (ISN) ?
2. Combien de paquets pour établir la connexion ?
3. Observez la fermeture (FIN, FIN-ACK ou RST)

#### Exercice 1.5.2 : Comparaison TCP vs UDP avec netcat

**Terminal 1 - Serveur TCP :**
```bash
nc -l -p 12345
```

**Terminal 2 - Client TCP :**
```bash
nc localhost 12345
# Tapez du texte et observez dans Wireshark
```

**Terminal 1 - Serveur UDP :**
```bash
nc -u -l -p 12346
```

**Terminal 2 - Client UDP :**
```bash
nc -u localhost 12346
# Tapez du texte et observez dans Wireshark
```

**Wireshark - Comparer :**
- Filtre TCP : `tcp.port == 12345`
- Filtre UDP : `udp.port == 12346`

**Questions :**
1. Y a-t-il un handshake pour UDP ?
2. Observez les numéros de séquence TCP - comment évoluent-ils ?
3. Quelle est la taille des en-têtes TCP vs UDP ?

#### Exercice 1.5.3 : Observer les connexions avec ss/netstat

```bash
# Lancer un serveur web simple
python3 -m http.server 8080 &

# Observer les connexions (Linux)
ss -tuln                    # Ports en écoute
ss -tun                     # Connexions établies
ss -tun state established   # Seulement les établies

# Windows
netstat -an | findstr LISTENING
netstat -an | findstr ESTABLISHED
```

**Questions :**
1. Quels ports sont en écoute sur votre machine ?
2. Dans quel état se trouve une connexion TCP en attente ?
3. Que signifient les états LISTEN, ESTABLISHED, TIME_WAIT ?

#### Exercice 1.5.4 : Identifier les processus avec lsof

```bash
# Trouver quel processus utilise un port
sudo lsof -i :22        # Port SSH
sudo lsof -i :80        # Port HTTP
sudo lsof -i :8080      # Notre serveur Python

# Lister toutes les connexions réseau d'un processus
sudo lsof -i -a -p <PID>
```

---

## Lab 1.6 : DNS - La résolution de noms (Couche 7)

### Objectifs
- Comprendre le fonctionnement du DNS
- Utiliser dig et nslookup
- Analyser les requêtes DNS dans Wireshark

### Exercices

#### Exercice 1.6.1 : Résolution DNS basique

```bash
# Avec dig (recommandé)
dig google.com

# Avec nslookup
nslookup google.com

# Résolution inverse (IP → nom)
dig -x 8.8.8.8
```

**Analyse de la sortie dig :**
- QUESTION SECTION : la requête envoyée
- ANSWER SECTION : la réponse
- Query time : temps de résolution
- SERVER : serveur DNS utilisé

#### Exercice 1.6.2 : Explorer les types d'enregistrements

```bash
# Enregistrement A (IPv4)
dig google.com A

# Enregistrement AAAA (IPv6)
dig google.com AAAA

# Enregistrement MX (serveurs mail)
dig google.com MX

# Enregistrement NS (serveurs de noms)
dig google.com NS

# Enregistrement TXT (SPF, DKIM, vérifications)
dig google.com TXT

# Enregistrement CNAME (alias)
dig www.github.com CNAME

# Tous les enregistrements
dig google.com ANY
```

**Questions :**
1. Combien d'adresses IP sont associées à google.com ?
2. Quels sont les serveurs mail de google.com ? Quel est leur priorité ?
3. Qu'est-ce qu'un CNAME ? Donnez un exemple.

#### Exercice 1.6.3 : Tracer la résolution DNS complète

```bash
# Résolution itérative depuis les serveurs racine
dig +trace google.com
```

**Analyse :**
1. Serveurs racine (.)
2. Serveurs TLD (.com)
3. Serveurs autoritaires (google.com)
4. Réponse finale

#### Exercice 1.6.4 : Observer DNS dans Wireshark

```bash
# Vider le cache DNS
# Linux
sudo systemd-resolve --flush-caches
# ou
sudo resolvectl flush-caches

# Windows
ipconfig /flushdns

# Lancer Wireshark avec filtre : dns

# Effectuer des résolutions
dig example.com
dig amazon.fr
```

**Analyse Wireshark :**
- Port utilisé (UDP 53)
- Structure de la requête DNS
- Structure de la réponse DNS
- Transaction ID (pour corréler requête/réponse)

#### Exercice 1.6.5 : Tester différents serveurs DNS

```bash
# Utiliser le DNS de Google
dig @8.8.8.8 google.com

# Utiliser le DNS de Cloudflare
dig @1.1.1.1 google.com

# Utiliser le DNS de Quad9
dig @9.9.9.9 google.com

# Comparer les temps de réponse
dig @8.8.8.8 google.com | grep "Query time"
dig @1.1.1.1 google.com | grep "Query time"
```

---

## Lab 1.7 : Simulation réseau avec Packet Tracer (Toutes couches)

### Objectifs
- Construire une topologie réseau complète
- Configurer routeurs et switches
- Observer le flux de données à travers les couches

### Prérequis
- Cisco Packet Tracer installé (gratuit via Cisco Networking Academy)
- Compte NetAcad créé

### Exercice 1.7.1 : Topologie de base (2 réseaux)

**Construire la topologie :**
```
[PC1] ----[Switch1]----[Router]----[Switch2]----[PC2]
10.0.1.0/24                                10.0.2.0/24
```

**Configuration :**

1. **Placer les équipements** :
   - 2 PC (End Devices > PC)
   - 2 Switches 2960 (Network Devices > Switches)
   - 1 Router 2911 (Network Devices > Routers)

2. **Connecter avec des câbles** :
   - PC vers Switch : Copper Straight-Through
   - Switch vers Router : Copper Straight-Through

3. **Configurer PC1** :
   - IP : 10.0.1.10
   - Masque : 255.255.255.0
   - Passerelle : 10.0.1.1

4. **Configurer PC2** :
   - IP : 10.0.2.10
   - Masque : 255.255.255.0
   - Passerelle : 10.0.2.1

5. **Configurer le Router** (CLI) :
```
enable
configure terminal

interface GigabitEthernet0/0
ip address 10.0.1.1 255.255.255.0
no shutdown
exit

interface GigabitEthernet0/1
ip address 10.0.2.1 255.255.255.0
no shutdown
exit
```

6. **Tester** :
   - Ping de PC1 vers PC2
   - Utiliser le mode Simulation pour observer les paquets

### Exercice 1.7.2 : Observer l'encapsulation

**En mode Simulation :**
1. Cliquer sur "Simulation" (en bas à droite)
2. Filtrer sur ICMP
3. Lancer un ping de PC1 vers PC2
4. Cliquer sur l'enveloppe à chaque étape

**Observer à chaque hop :**
- Couche 2 : adresses MAC qui changent
- Couche 3 : adresses IP qui restent identiques
- Le routeur décapsule et ré-encapsule

**Questions :**
1. L'adresse MAC source change-t-elle quand le paquet traverse le routeur ?
2. L'adresse IP source change-t-elle ?
3. Expliquez pourquoi.

### Exercice 1.7.3 : Ajouter un serveur DNS et HTTP

**Étendre la topologie :**
```
[PC1]----[Switch1]----[Router]----[Switch2]----[Server]
                                               DNS + HTTP
```

**Configurer le serveur :**
1. Ajouter un Server
2. Onglet Services > DNS :
   - Activer DNS
   - Ajouter : `www.lab.local` → IP du serveur
3. Onglet Services > HTTP :
   - Activer HTTP
   - Personnaliser la page index.html

**Configurer PC1 :**
- DNS Server : IP du serveur

**Tester :**
1. Depuis PC1, ouvrir Web Browser
2. Accéder à `http://www.lab.local`
3. En mode Simulation, observer :
   - La requête DNS (UDP 53)
   - La réponse DNS
   - La requête HTTP (TCP 80)
   - Le 3-way handshake
   - La réponse HTTP

### Exercice 1.7.4 : Topologie multi-routeurs

**Construire :**
```
[PC1]--[SW1]--[R1]--[R2]--[R3]--[SW2]--[PC2]
10.0.1.0/24   |     |     |         10.0.4.0/24
           10.0.10.0/30  10.0.20.0/30
```

**Configurer le routage statique sur chaque routeur** et observer :
- Le chemin des paquets
- La décrémentation du TTL
- Les tables de routage (`show ip route`)

---

## Lab 1.8 : Synthèse - Analyse d'une requête HTTP complète

### Objectifs
- Consolider toutes les connaissances
- Suivre une requête de bout en bout
- Identifier chaque couche impliquée

### Exercice : Analyse complète d'une requête web

```bash
# 1. Vider tous les caches
sudo ip neigh flush all                    # ARP
sudo systemd-resolve --flush-caches        # DNS

# 2. Lancer Wireshark sans filtre (ou filtre: arp || dns || tcp.port == 80)

# 3. Effectuer une requête HTTP
curl -v http://example.com
```

**Identifier dans Wireshark (dans l'ordre chronologique) :**

| Étape | Protocole | Couche | Description |
|-------|-----------|--------|-------------|
| 1 | DNS | 7 | Requête : "Quelle est l'IP de example.com ?" |
| 2 | DNS | 7 | Réponse : "93.184.216.34" |
| 3 | ARP | 2 | Requête : "Quelle est la MAC de ma passerelle ?" |
| 4 | ARP | 2 | Réponse : "AA:BB:CC:DD:EE:FF" |
| 5 | TCP SYN | 4 | Initiation connexion vers port 80 |
| 6 | TCP SYN-ACK | 4 | Acceptation par le serveur |
| 7 | TCP ACK | 4 | Confirmation, connexion établie |
| 8 | HTTP GET | 7 | Requête de la page |
| 9 | HTTP 200 OK | 7 | Réponse avec le contenu |
| 10 | TCP FIN | 4 | Fermeture de connexion |

**Pour chaque paquet, noter :**
- Adresses MAC (source, destination)
- Adresses IP (source, destination)
- Ports (source, destination)
- Taille du paquet
- Flags TCP (si applicable)

---

## Annexe A : Aide-mémoire des commandes

### Linux - Couche 2 (Liaison)
```bash
ip link show                    # Lister les interfaces
ip link set eth0 up/down        # Activer/désactiver interface
ip neigh show                   # Table ARP
arp -a                          # Table ARP (legacy)
```

### Linux - Couche 3 (Réseau)
```bash
ip addr show                    # Adresses IP
ip route show                   # Table de routage
ping -c 4 <IP>                  # Test connectivité
traceroute <IP>                 # Tracer le chemin
mtr <IP>                        # Traceroute continu
```

### Linux - Couche 4 (Transport)
```bash
ss -tuln                        # Ports en écoute
ss -tun                         # Connexions actives
ss -s                           # Statistiques
netstat -an                     # (legacy) Connexions
lsof -i :<port>                 # Processus sur un port
nc -l -p <port>                 # Serveur netcat
nc <ip> <port>                  # Client netcat
```

### Linux - Couche 7 (Application)
```bash
dig <domaine>                   # Résolution DNS
dig @<serveur> <domaine>        # DNS via serveur spécifique
dig +trace <domaine>            # Trace complète
nslookup <domaine>              # Résolution DNS (legacy)
curl -v <url>                   # Requête HTTP verbose
curl -I <url>                   # Headers seulement
```

### Wireshark - Filtres utiles
```
# Par protocole
arp
icmp
dns
http
tcp
udp

# Par adresse
ip.addr == 192.168.1.1
ip.src == 192.168.1.1
ip.dst == 8.8.8.8
eth.addr == aa:bb:cc:dd:ee:ff

# Par port
tcp.port == 80
udp.port == 53
tcp.dstport == 443

# Combinaisons
tcp.port == 80 && ip.addr == 93.184.216.34
dns || arp || icmp
tcp.flags.syn == 1 && tcp.flags.ack == 0
```

---

## Annexe B : Questions de réflexion pour évaluation

### Couche 2 - Liaison
1. Pourquoi a-t-on besoin d'ARP si on a déjà les adresses IP ?
2. Que se passe-t-il si deux machines ont la même adresse MAC ?
3. Comment un switch sait-il sur quel port envoyer une trame ?

### Couche 3 - Réseau
1. Pourquoi le TTL est-il nécessaire ?
2. Comment un routeur décide-t-il où envoyer un paquet ?
3. Quelle est la différence entre routage statique et dynamique ?

### Couche 4 - Transport
1. Quand utiliser TCP plutôt qu'UDP ?
2. Que se passe-t-il si un segment TCP est perdu ?
3. Pourquoi y a-t-il des numéros de ports ?

### Couche 7 - Application
1. Pourquoi le DNS utilise-t-il UDP plutôt que TCP (généralement) ?
2. Quel est l'avantage d'avoir plusieurs serveurs DNS ?
3. Que se passe-t-il si le cache DNS contient une entrée obsolète ?

### Transversales
1. Tracez le chemin complet d'un paquet depuis `curl http://example.com` jusqu'à l'affichage de la réponse.
2. Pourquoi l'adresse MAC change à chaque routeur mais pas l'adresse IP ?
3. Comment le NAT affecte-t-il les couches 3 et 4 ?

---

## Annexe C : Ressources complémentaires

### Documentation
- Wireshark User Guide : https://www.wireshark.org/docs/wsug_html/
- Cisco Packet Tracer Tutorials : https://www.netacad.com/courses/packet-tracer
- Linux ip command : https://man7.org/linux/man-pages/man8/ip.8.html

### Vidéos recommandées
- "Wireshark Tutorial for Beginners" - David Bombal
- "TCP/IP and Subnet Mastering" - Practical Networking
- "Packet Tracer Labs" - Jeremy's IT Lab

### Challenges pratiques
- TryHackMe - Network Fundamentals
- Hack The Box - Starting Point (networking)
- PentesterLab - Network exercises
