#!/usr/bin/env python3
"""Puissance 4 en mode console.

Deux modes de jeu :
  - joueur contre joueur
  - joueur contre ordinateur (IA simple)
"""

import random

LIGNES = 6
COLONNES = 7
VIDE = "."
JETONS = ("X", "O")
COULEURS = {"X": "\033[91mX\033[0m", "O": "\033[93mO\033[0m", VIDE: VIDE}


def nouvelle_grille():
    return [[VIDE] * COLONNES for _ in range(LIGNES)]


def afficher(grille):
    print()
    print("  " + "   ".join(str(c + 1) for c in range(COLONNES)))
    print("+" + "---+" * COLONNES)
    for ligne in grille:
        print("| " + " | ".join(COULEURS[case] for case in ligne) + " |")
        print("+" + "---+" * COLONNES)
    print()


def colonnes_jouables(grille):
    return [c for c in range(COLONNES) if grille[0][c] == VIDE]


def jouer_coup(grille, colonne, jeton):
    """Fait tomber le jeton dans la colonne et renvoie la ligne atteinte."""
    for ligne in range(LIGNES - 1, -1, -1):
        if grille[ligne][colonne] == VIDE:
            grille[ligne][colonne] = jeton
            return ligne
    raise ValueError("colonne pleine")


def annuler_coup(grille, colonne):
    for ligne in range(LIGNES):
        if grille[ligne][colonne] != VIDE:
            grille[ligne][colonne] = VIDE
            return


def victoire(grille, jeton):
    # Horizontales
    for l in range(LIGNES):
        for c in range(COLONNES - 3):
            if all(grille[l][c + i] == jeton for i in range(4)):
                return True
    # Verticales
    for l in range(LIGNES - 3):
        for c in range(COLONNES):
            if all(grille[l + i][c] == jeton for i in range(4)):
                return True
    # Diagonales descendantes
    for l in range(LIGNES - 3):
        for c in range(COLONNES - 3):
            if all(grille[l + i][c + i] == jeton for i in range(4)):
                return True
    # Diagonales montantes
    for l in range(3, LIGNES):
        for c in range(COLONNES - 3):
            if all(grille[l - i][c + i] == jeton for i in range(4)):
                return True
    return False


def grille_pleine(grille):
    return not colonnes_jouables(grille)


def demander_colonne(grille, jeton):
    while True:
        saisie = input(f"Joueur {jeton}, choisis une colonne (1-{COLONNES}) : ").strip()
        if not saisie.isdigit():
            print("Entre un numéro de colonne.")
            continue
        colonne = int(saisie) - 1
        if colonne not in range(COLONNES):
            print(f"La colonne doit être entre 1 et {COLONNES}.")
            continue
        if colonne not in colonnes_jouables(grille):
            print("Cette colonne est pleine.")
            continue
        return colonne


def coup_ordinateur(grille, jeton):
    """IA simple : gagne si possible, bloque sinon, sinon joue au centre."""
    adversaire = JETONS[0] if jeton == JETONS[1] else JETONS[1]
    jouables = colonnes_jouables(grille)

    # Gagner immédiatement
    for colonne in jouables:
        jouer_coup(grille, colonne, jeton)
        gagnant = victoire(grille, jeton)
        annuler_coup(grille, colonne)
        if gagnant:
            return colonne

    # Bloquer l'adversaire
    for colonne in jouables:
        jouer_coup(grille, colonne, adversaire)
        menace = victoire(grille, adversaire)
        annuler_coup(grille, colonne)
        if menace:
            return colonne

    # Préférer les colonnes centrales
    centre = COLONNES // 2
    return min(jouables, key=lambda c: (abs(c - centre), random.random()))


def partie(contre_ordinateur):
    grille = nouvelle_grille()
    tour = 0
    while True:
        afficher(grille)
        jeton = JETONS[tour % 2]
        if contre_ordinateur and jeton == JETONS[1]:
            colonne = coup_ordinateur(grille, jeton)
            print(f"L'ordinateur joue la colonne {colonne + 1}.")
        else:
            colonne = demander_colonne(grille, jeton)
        jouer_coup(grille, colonne, jeton)

        if victoire(grille, jeton):
            afficher(grille)
            if contre_ordinateur and jeton == JETONS[1]:
                print("L'ordinateur a gagné !")
            else:
                print(f"Le joueur {jeton} a gagné ! 🎉")
            return
        if grille_pleine(grille):
            afficher(grille)
            print("Match nul !")
            return
        tour += 1


def main():
    print("=== PUISSANCE 4 ===")
    print("1. Joueur contre joueur")
    print("2. Joueur contre ordinateur")
    while True:
        choix = input("Mode de jeu (1 ou 2) : ").strip()
        if choix in ("1", "2"):
            break
        print("Choisis 1 ou 2.")

    while True:
        partie(contre_ordinateur=choix == "2")
        rejouer = input("Rejouer ? (o/n) : ").strip().lower()
        if rejouer != "o":
            print("Merci d'avoir joué !")
            break


if __name__ == "__main__":
    try:
        main()
    except (KeyboardInterrupt, EOFError):
        print("\nPartie interrompue. À bientôt !")
