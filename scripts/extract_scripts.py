#!/usr/bin/env python3
"""
Script d'extraction automatique des scripts bash depuis les fichiers markdown
Convertit les blocs de code des labs en fichiers .sh exécutables
"""

import re
import os
import sys
from pathlib import Path

def extract_lab_scripts(markdown_file, output_dir):
    """
    Extrait les scripts bash d'un fichier markdown et les sauvegarde
    """
    with open(markdown_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Patterns pour identifier les labs et exercices
    lab_pattern = r'^## Lab (\d+)\.(\d+) : (.+?)$'
    exercise_pattern = r'^#### Exercice (\d+)\.(\d+)\.(\d+) : (.+?)$'
    code_block_pattern = r'```bash\n(.*?)```'

    scripts_created = []

    # Parcourir le contenu ligne par ligne
    lines = content.split('\n')
    current_lab = None
    current_exercise = None

    i = 0
    while i < len(lines):
        line = lines[i]

        # Détecter un nouveau lab
        lab_match = re.match(lab_pattern, line)
        if lab_match:
            module_num, lab_num, lab_title = lab_match.groups()
            current_lab = (module_num, lab_num, lab_title)
            i += 1
            continue

        # Détecter un nouvel exercice
        exercise_match = re.match(exercise_pattern, line)
        if exercise_match:
            mod_num, lab_num, ex_num, ex_title = exercise_match.groups()
            current_exercise = (mod_num, lab_num, ex_num, ex_title)

            # Chercher le prochain bloc de code bash
            j = i + 1
            code_start = None
            while j < len(lines) and j < i + 50:  # Chercher dans les 50 prochaines lignes
                if lines[j].strip() == '```bash':
                    code_start = j + 1
                    break
                j += 1

            if code_start:
                # Extraire le code jusqu'au ```
                code_lines = []
                j = code_start
                while j < len(lines) and lines[j].strip() != '```':
                    code_lines.append(lines[j])
                    j += 1

                if code_lines:
                    code_content = '\n'.join(code_lines)

                    # Générer le nom du fichier selon la convention
                    # lab2.1_ex1_description.sh
                    ex_desc = slugify(ex_title)
                    script_name = f"lab{lab_num}.{ex_num}_{ex_desc}.sh"
                    script_path = output_dir / script_name

                    # Créer le script avec header
                    script_content = generate_script_header(
                        mod_num, lab_num, ex_num, ex_title
                    ) + code_content + "\n"

                    # Sauvegarder le script
                    with open(script_path, 'w', encoding='utf-8') as f:
                        f.write(script_content)

                    # Rendre exécutable
                    os.chmod(script_path, 0o755)

                    scripts_created.append(script_name)
                    print(f"  ✓ Créé: {script_name}")

            i = j if code_start else i + 1
            continue

        i += 1

    return scripts_created

def slugify(text):
    """Convertit un titre en slug pour nom de fichier"""
    # Supprimer les accents et caractères spéciaux
    text = text.lower()
    text = re.sub(r'[àáâãäå]', 'a', text)
    text = re.sub(r'[èéêë]', 'e', text)
    text = re.sub(r'[ìíîï]', 'i', text)
    text = re.sub(r'[òóôõö]', 'o', text)
    text = re.sub(r'[ùúûü]', 'u', text)
    text = re.sub(r'[ç]', 'c', text)
    text = re.sub(r'[^a-z0-9]+', '-', text)
    text = re.sub(r'-+', '-', text)
    text = text.strip('-')
    return text[:50]  # Limiter la longueur

def generate_script_header(module, lab, exercise, title):
    """Génère l'en-tête d'un script"""
    return f"""#!/bin/bash
# Lab {module}.{lab} - Exercice {module}.{lab}.{exercise} : {title}

set -e

echo "=== Lab {module}.{lab} - Exercice {exercise} : {title} ==="
echo ""

"""

def main():
    base_dir = Path(__file__).parent.parent

    # Modules à traiter
    modules = range(1, 12)  # Modules 1 à 11

    for module_num in modules:
        markdown_file = base_dir / f"module{module_num}_labs.md"
        output_dir = Path(__file__).parent / f"module{module_num}"

        if not markdown_file.exists():
            print(f"⚠  Fichier non trouvé: {markdown_file}")
            continue

        print(f"\n=== Module {module_num} ===")
        output_dir.mkdir(exist_ok=True)

        scripts = extract_lab_scripts(markdown_file, output_dir)
        print(f"  Total: {len(scripts)} scripts créés")

if __name__ == "__main__":
    main()
