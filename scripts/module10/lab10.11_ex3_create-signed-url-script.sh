#!/bin/bash
# Lab 10.11 - Exercice 10.11.3 : Script Python pour générer des Signed URLs
# Objectif : Créer un script Python pour générer des URLs signées

set -e

echo "=== Lab 10.11 - Exercice 3 : Script Python pour Signed URLs ==="
echo ""

# Créer le script de génération
echo "Création du script generate_signed_url.py..."
cat > generate_signed_url.py << 'PYTHON'
#!/usr/bin/env python3
"""Génère une Signed URL pour Cloud CDN."""

import argparse
import base64
import datetime
import hashlib
import hmac

def sign_url(url: str, key_name: str, key: bytes, expiration: datetime.datetime) -> str:
    """Génère une Signed URL.

    Args:
        url: URL de base à signer
        key_name: Nom de la clé
        key: Clé de signature (bytes)
        expiration: Date/heure d'expiration

    Returns:
        URL signée
    """
    # Timestamp Unix
    expiration_timestamp = int(expiration.timestamp())

    # URL à signer
    url_to_sign = f"{url}{'&' if '?' in url else '?'}Expires={expiration_timestamp}&KeyName={key_name}"

    # Signature HMAC-SHA1
    signature = hmac.new(
        key,
        url_to_sign.encode('utf-8'),
        hashlib.sha1
    ).digest()

    # Encoder la signature en base64 URL-safe
    encoded_signature = base64.urlsafe_b64encode(signature).decode('utf-8')

    return f"{url_to_sign}&Signature={encoded_signature}"

def main():
    parser = argparse.ArgumentParser(description='Génère une Signed URL Cloud CDN')
    parser.add_argument('--url', required=True, help='URL à signer')
    parser.add_argument('--key-name', required=True, help='Nom de la clé')
    parser.add_argument('--key-file', required=True, help='Fichier contenant la clé')
    parser.add_argument('--expires-in', type=int, default=3600, help='Durée de validité en secondes')

    args = parser.parse_args()

    # Lire la clé
    with open(args.key_file, 'r') as f:
        key = base64.urlsafe_b64decode(f.read().strip())

    # Calculer l'expiration
    expiration = datetime.datetime.utcnow() + datetime.timedelta(seconds=args.expires_in)

    # Générer l'URL signée
    signed_url = sign_url(args.url, args.key_name, key, expiration)

    print(f"URL signée (valide {args.expires_in}s):")
    print(signed_url)

if __name__ == '__main__':
    main()
PYTHON

chmod +x generate_signed_url.py

echo ""
echo "Script créé avec succès : generate_signed_url.py"
echo ""
echo "=== Utilisation ==="
echo "python3 generate_signed_url.py \\"
echo "  --url='http://\$LB_IP/static/style.css' \\"
echo "  --key-name=key-v1 \\"
echo "  --key-file=cdn-signing-key.txt \\"
echo "  --expires-in=300"
echo ""
echo "Options :"
echo "  --url : URL à protéger"
echo "  --key-name : Nom de la clé (ex: key-v1)"
echo "  --key-file : Fichier contenant la clé"
echo "  --expires-in : Durée de validité en secondes (défaut: 3600)"
