#!/bin/bash
# Lab 1.6 - Exercice 1.6.2 : Explorer les types d'enregistrements DNS
# Objectif : Découvrir les différents types de records DNS

set -e

echo "=== Lab 1.6 - Exercice 2 : Types d'enregistrements DNS ==="
echo ""

# Enregistrement A (IPv4)
echo "=== Enregistrement A (IPv4) ==="
dig google.com A +short
echo ""

# Enregistrement AAAA (IPv6)
echo "=== Enregistrement AAAA (IPv6) ==="
dig google.com AAAA +short
echo ""

# Enregistrement MX (serveurs mail)
echo "=== Enregistrement MX (Mail Exchange) ==="
dig google.com MX +short
echo ""

# Enregistrement NS (serveurs de noms)
echo "=== Enregistrement NS (Name Servers) ==="
dig google.com NS +short
echo ""

# Enregistrement TXT (SPF, DKIM, vérifications)
echo "=== Enregistrement TXT ==="
dig google.com TXT +short
echo ""

# Enregistrement CNAME (alias)
echo "=== Enregistrement CNAME (Canonical Name) ==="
dig www.github.com CNAME +short
echo ""

echo "Questions à considérer :"
echo "1. Combien d'adresses IP sont associées à google.com ?"
echo "   → Utilisez : dig google.com A"
echo ""
echo "2. Quels sont les serveurs mail de google.com ? Quelle est leur priorité ?"
echo "   → Le nombre avant le nom = priorité (plus petit = prioritaire)"
echo ""
echo "3. Qu'est-ce qu'un CNAME ? Donnez un exemple."
echo "   → C'est un alias : www.example.com → example.com"
echo ""
echo "💡 Types d'enregistrements courants :"
echo "   A     : IPv4 address"
echo "   AAAA  : IPv6 address"
echo "   MX    : Mail server"
echo "   NS    : Name server"
echo "   CNAME : Alias"
echo "   TXT   : Text record (SPF, DKIM, etc.)"
echo "   SOA   : Start of Authority"
