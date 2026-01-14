#!/bin/bash
# Lab 9.11 - Scénario intégrateur : Protection complète
# Objectif : Déployer une politique de sécurité Cloud Armor complète

set -e

POLICY_NAME="policy-complete"

echo "=========================================="
echo "  DÉPLOIEMENT POLITIQUE CLOUD ARMOR"
echo "=========================================="
echo ""

# ===== CRÉER LA POLITIQUE =====
echo ">>> Création de la politique..."
gcloud compute security-policies create $POLICY_NAME \
    --description="Politique de sécurité complète"

echo ""
# ===== RÈGLES DE PRIORITÉ HAUTE (10-99): AUTORISATIONS EXPLICITES =====
echo ">>> Règles d'autorisation..."

# Autoriser Googlebot
gcloud compute security-policies rules create 10 \
    --security-policy=$POLICY_NAME \
    --expression="origin.ip.matches(getNamedIpList('sourceiplist-google-crawlers'))" \
    --action=allow \
    --description="Autoriser Googlebot"

echo ""
# ===== RÈGLES DE BLOCAGE IP (100-199) =====
echo ">>> Règles de blocage IP..."

# Bloquer IPs blacklistées manuelles
gcloud compute security-policies rules create 100 \
    --security-policy=$POLICY_NAME \
    --src-ip-ranges="198.51.100.0/24,203.0.113.0/24" \
    --action=deny-403 \
    --description="IPs blacklistées manuelles"

# Bloquer Tor
gcloud compute security-policies rules create 150 \
    --security-policy=$POLICY_NAME \
    --expression="evaluateThreatIntelligence('iplist-tor-exit-nodes')" \
    --action=deny-403 \
    --description="Bloquer Tor"

# Bloquer IPs malveillantes connues
gcloud compute security-policies rules create 160 \
    --security-policy=$POLICY_NAME \
    --expression="evaluateThreatIntelligence('iplist-known-malicious-ips')" \
    --action=deny-403 \
    --description="IPs malveillantes"

echo ""
# ===== RÈGLES GÉOGRAPHIQUES (200-299) =====
echo ">>> Règles géographiques..."
echo "    (Commenté pour ce lab - décommentez si nécessaire)"

# Exemple: Autoriser uniquement certains pays
# gcloud compute security-policies rules create 200 \
#     --security-policy=$POLICY_NAME \
#     --expression="origin.region_code != 'FR' && origin.region_code != 'BE'" \
#     --action=deny-403 \
#     --description="Autoriser FR, BE uniquement"

echo ""
# ===== RÈGLES D'ACCÈS (300-399) =====
echo ">>> Règles d'accès..."

# Bloquer /admin
gcloud compute security-policies rules create 300 \
    --security-policy=$POLICY_NAME \
    --expression="request.path.startsWith('/admin')" \
    --action=deny-403 \
    --description="Bloquer /admin"

echo ""
# ===== RATE LIMITING (500-599) =====
echo ">>> Règles de rate limiting..."

# Rate limit global
gcloud compute security-policies rules create 500 \
    --security-policy=$POLICY_NAME \
    --src-ip-ranges="0.0.0.0/0" \
    --action=throttle \
    --rate-limit-threshold-count=100 \
    --rate-limit-threshold-interval-sec=60 \
    --conform-action=allow \
    --exceed-action=deny-429 \
    --enforce-on-key=IP \
    --description="Rate limit: 100 req/min par IP"

# Rate limit login
gcloud compute security-policies rules create 510 \
    --security-policy=$POLICY_NAME \
    --expression="request.path == '/api/login' || request.path == '/login'" \
    --action=rate-based-ban \
    --rate-limit-threshold-count=5 \
    --rate-limit-threshold-interval-sec=60 \
    --ban-duration-sec=300 \
    --conform-action=allow \
    --exceed-action=deny-403 \
    --enforce-on-key=IP \
    --description="Login: 5 tentatives/min, ban 5min"

echo ""
# ===== WAF RULES (1000-1999) =====
echo ">>> Règles WAF..."

# SQLi
gcloud compute security-policies rules create 1000 \
    --security-policy=$POLICY_NAME \
    --expression="evaluatePreconfiguredWaf('sqli-v33-stable', {'sensitivity': 2})" \
    --action=deny-403 \
    --description="WAF: SQL Injection"

# XSS
gcloud compute security-policies rules create 1100 \
    --security-policy=$POLICY_NAME \
    --expression="evaluatePreconfiguredWaf('xss-v33-stable', {'sensitivity': 2})" \
    --action=deny-403 \
    --description="WAF: XSS"

# LFI
gcloud compute security-policies rules create 1200 \
    --security-policy=$POLICY_NAME \
    --expression="evaluatePreconfiguredWaf('lfi-v33-stable')" \
    --action=deny-403 \
    --description="WAF: Local File Inclusion"

# RFI
gcloud compute security-policies rules create 1300 \
    --security-policy=$POLICY_NAME \
    --expression="evaluatePreconfiguredWaf('rfi-v33-stable')" \
    --action=deny-403 \
    --description="WAF: Remote File Inclusion"

# RCE
gcloud compute security-policies rules create 1400 \
    --security-policy=$POLICY_NAME \
    --expression="evaluatePreconfiguredWaf('rce-v33-stable')" \
    --action=deny-403 \
    --description="WAF: Remote Code Execution"

# Scanner detection
gcloud compute security-policies rules create 1500 \
    --security-policy=$POLICY_NAME \
    --expression="evaluatePreconfiguredWaf('scannerdetection-v33-stable')" \
    --action=deny-403 \
    --description="WAF: Scanner Detection"

echo ""
# ===== ATTACHER AU BACKEND =====
echo ">>> Attachement au backend..."
gcloud compute backend-services update backend-web \
    --security-policy=$POLICY_NAME \
    --global

echo ""
echo "=========================================="
echo "  DÉPLOIEMENT TERMINÉ"
echo "=========================================="
echo ""

# Afficher le récapitulatif
echo "=== Récapitulatif des règles ==="
gcloud compute security-policies rules list \
    --security-policy=$POLICY_NAME \
    --format="table(priority,action,description)"

echo ""
echo "La politique complète est maintenant active sur le backend service."
