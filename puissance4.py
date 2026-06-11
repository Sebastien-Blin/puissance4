#!/usr/bin/env python3
"""Puissance 4 en mode console.

Interface curses : plateau centré qui s'adapte à la taille du terminal
(redimensionnable en pleine partie), navigation aux flèches, jetons
colorés et animation de chute.
"""

import curses
import random
import time

LIGNES = 6
COLONNES = 7
VIDE = "."
JETONS = ("X", "O")
NOMS = {"X": "Rouge", "O": "Jaune"}

# ---------------------------------------------------------------------------
# Logique du jeu
# ---------------------------------------------------------------------------


def nouvelle_grille():
    return [[VIDE] * COLONNES for _ in range(LIGNES)]


def colonnes_jouables(grille):
    return [c for c in range(COLONNES) if grille[0][c] == VIDE]


def prochaine_ligne(grille, colonne):
    """Ligne où tomberait un jeton dans cette colonne, ou None si pleine."""
    for ligne in range(LIGNES - 1, -1, -1):
        if grille[ligne][colonne] == VIDE:
            return ligne
    return None


def jouer_coup(grille, colonne, jeton):
    ligne = prochaine_ligne(grille, colonne)
    if ligne is None:
        raise ValueError("colonne pleine")
    grille[ligne][colonne] = jeton
    return ligne


def annuler_coup(grille, colonne):
    for ligne in range(LIGNES):
        if grille[ligne][colonne] != VIDE:
            grille[ligne][colonne] = VIDE
            return


def positions_victoire(grille, jeton):
    """Les 4 cases gagnantes alignées par ce jeton, ou None."""
    directions = ((0, 1), (1, 0), (1, 1), (-1, 1))
    for l in range(LIGNES):
        for c in range(COLONNES):
            for dl, dc in directions:
                cases = [(l + i * dl, c + i * dc) for i in range(4)]
                if all(
                    0 <= a < LIGNES and 0 <= b < COLONNES and grille[a][b] == jeton
                    for a, b in cases
                ):
                    return cases
    return None


def victoire(grille, jeton):
    return positions_victoire(grille, jeton) is not None


def grille_pleine(grille):
    return not colonnes_jouables(grille)


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


# ---------------------------------------------------------------------------
# Interface curses
# ---------------------------------------------------------------------------

PAIRE_X = 1
PAIRE_O = 2
PAIRE_CADRE = 3
PAIRE_TITRE = 4
PAIRE_AIDE = 5

AIDE = "←/→ ou 1-7 : choisir · Entrée/Espace : jouer · q : quitter"


def init_interface(ecran):
    curses.curs_set(0)
    curses.use_default_colors()
    curses.init_pair(PAIRE_X, curses.COLOR_RED, -1)
    curses.init_pair(PAIRE_O, curses.COLOR_YELLOW, -1)
    curses.init_pair(PAIRE_CADRE, curses.COLOR_BLUE, -1)
    curses.init_pair(PAIRE_TITRE, curses.COLOR_CYAN, -1)
    curses.init_pair(PAIRE_AIDE, curses.COLOR_WHITE, -1)
    ecran.keypad(True)


def paire_jeton(jeton):
    return curses.color_pair(PAIRE_X if jeton == JETONS[0] else PAIRE_O)


def ecrire(ecran, y, x, texte, attr=0):
    """addstr qui ignore les écritures hors écran (bord de fenêtre)."""
    try:
        ecran.addstr(y, x, texte, attr)
    except curses.error:
        pass


def centrer(ecran, y, texte, attr=0):
    _, larg = ecran.getmaxyx()
    ecrire(ecran, y, max(0, (larg - len(texte)) // 2), texte, attr)


def geometrie(ecran):
    """Taille des cases et position du plateau, ou None si trop petit.

    Une case fait cw × ch caractères (bordures exclues) ; on garde de la
    place pour le titre, le curseur, les numéros, le statut et l'aide.
    Si la fenêtre est basse, `sep` passe à False : les séparateurs
    horizontaux entre les rangées sont supprimés pour gagner 5 lignes.
    """
    haut, larg = ecran.getmaxyx()
    cw = next((w for w in (11, 9, 7, 5, 3) if COLONNES * (w + 1) + 1 <= larg - 2), None)
    if cw is None:
        return None
    ch = (haut - 8) // LIGNES - 1
    ch = min(ch, max(1, cw // 2 - 1))
    if ch >= 1:
        if ch % 2 == 0:
            ch -= 1
        sep = True
    elif haut >= LIGNES + 8:
        ch, sep = 1, False
    else:
        return None
    largeur = COLONNES * (cw + 1) + 1
    hauteur = hauteur_plateau(ch, sep)
    x0 = (larg - largeur) // 2
    y0 = min(max(4, (haut - hauteur) // 2), haut - hauteur - 3)
    return cw, ch, y0, x0, sep


def hauteur_plateau(ch, sep):
    return LIGNES * (ch + 1) + 1 if sep else LIGNES + 2


def case_coords(geo, ligne, colonne):
    """Coin haut-gauche intérieur de la case (ligne, colonne)."""
    cw, ch, y0, x0, sep = geo
    y = y0 + ligne * (ch + 1) + 1 if sep else y0 + 1 + ligne
    return y, x0 + colonne * (cw + 1) + 1


def dessiner_jeton(ecran, geo, ligne, colonne, jeton):
    cw, ch = geo[0], geo[1]
    attr = paire_jeton(jeton) | curses.A_BOLD
    y, x_case = case_coords(geo, ligne, colonne)
    yc = y + (ch - 1) // 2
    if ch >= 3 and cw >= 7:
        iw = cw - 2
        for dy, motif in ((-1, "▄" * (iw - 2)), (0, "█" * iw), (1, "▀" * (iw - 2))):
            ecrire(ecran, yc + dy, x_case + (cw - len(motif)) // 2, motif, attr)
    else:
        ecrire(ecran, yc, x_case + (cw - 1) // 2, "●", attr)


def dessiner_plateau(ecran, grille, geo, masquees=()):
    cw, ch, y0, x0, sep = geo
    attr_cadre = curses.color_pair(PAIRE_CADRE)
    segment = "─" * cw
    hauteur = hauteur_plateau(ch, sep)
    for dy in range(hauteur):
        y = y0 + dy
        if dy == 0 or dy == hauteur - 1 or (sep and dy % (ch + 1) == 0):
            gauche, milieu, droite = (
                ("┌", "┬", "┐") if dy == 0
                else ("└", "┴", "┘") if dy == hauteur - 1
                else ("├", "┼", "┤")
            )
            ecrire(ecran, y, x0, gauche + milieu.join([segment] * COLONNES) + droite, attr_cadre)
        else:
            for c in range(COLONNES + 1):
                ecrire(ecran, y, x0 + c * (cw + 1), "│", attr_cadre)
    for l in range(LIGNES):
        for c in range(COLONNES):
            if grille[l][c] != VIDE and (l, c) not in masquees:
                dessiner_jeton(ecran, geo, l, c, grille[l][c])


def dessiner_tout(ecran, grille, geo, curseur=None, jeton=None, statut="", masquees=()):
    ecran.erase()
    haut, _ = ecran.getmaxyx()
    cw, ch, y0, x0, sep = geo
    if y0 >= 4:
        centrer(ecran, 1, "● P U I S S A N C E  4 ●", curses.color_pair(PAIRE_TITRE) | curses.A_BOLD)
    for c in range(COLONNES):
        xc = x0 + c * (cw + 1) + 1 + (cw - 1) // 2
        attr = curses.A_BOLD if c == curseur else curses.A_DIM
        ecrire(ecran, y0 - 1, xc, str(c + 1), attr)
    if curseur is not None and jeton is not None:
        xc = x0 + curseur * (cw + 1) + 1 + (cw - 1) // 2
        ecrire(ecran, y0 - 2, xc, "▼", paire_jeton(jeton) | curses.A_BOLD)
    dessiner_plateau(ecran, grille, geo, masquees)
    if statut:
        attr = (paire_jeton(jeton) if jeton else curses.color_pair(PAIRE_AIDE)) | curses.A_BOLD
        centrer(ecran, y0 + hauteur_plateau(ch, sep) + 1, statut, attr)
    centrer(ecran, haut - 1, AIDE, curses.color_pair(PAIRE_AIDE) | curses.A_DIM)
    ecran.refresh()


def attendre_taille(ecran):
    """Bloque tant que le terminal est trop petit ; renvoie une géométrie."""
    while True:
        geo = geometrie(ecran)
        if geo is not None:
            return geo
        ecran.erase()
        centrer(ecran, 1, "Fenêtre trop petite…", curses.A_BOLD)
        centrer(ecran, 2, "Agrandis le terminal (ou q pour quitter).")
        ecran.refresh()
        if ecran.getch() in (ord("q"), ord("Q")):
            raise SystemExit


def animer_chute(ecran, grille, geo, colonne, ligne_finale, jeton, statut):
    for l in range(ligne_finale + 1):
        dessiner_tout(ecran, grille, geo, None, jeton, statut)
        dessiner_jeton(ecran, geo, l, colonne, jeton)
        ecran.refresh()
        time.sleep(0.03)


def choisir_colonne(ecran, grille, jeton, curseur):
    """Sélection au clavier. Renvoie (colonne, curseur) ou (None, curseur)."""
    statut = f"● {NOMS[jeton]} : à toi de jouer"
    while True:
        geo = attendre_taille(ecran)
        dessiner_tout(ecran, grille, geo, curseur, jeton, statut)
        touche = ecran.getch()
        if touche in (ord("q"), ord("Q")):
            return None, curseur
        if touche == curses.KEY_LEFT:
            curseur = (curseur - 1) % COLONNES
        elif touche == curses.KEY_RIGHT:
            curseur = (curseur + 1) % COLONNES
        elif ord("1") <= touche <= ord(str(COLONNES)):
            curseur = touche - ord("1")
            if curseur in colonnes_jouables(grille):
                return curseur, curseur
        elif touche in (curses.KEY_ENTER, 10, 13, ord(" ")):
            if curseur in colonnes_jouables(grille):
                return curseur, curseur
            dessiner_tout(ecran, grille, geo, curseur, jeton, "Colonne pleine !")
            time.sleep(0.4)


def fin_de_partie(ecran, grille, gagnees, jeton, message):
    """Fait clignoter l'alignement gagnant ; renvoie 'r', 'm' ou None."""
    ecran.timeout(400)
    visibles = True
    try:
        while True:
            geo = attendre_taille(ecran)
            masquees = () if visibles or not gagnees else tuple(gagnees)
            dessiner_tout(ecran, grille, geo, None, jeton, message, masquees)
            visibles = not visibles
            touche = ecran.getch()
            if touche in (ord("r"), ord("R")):
                return "r"
            if touche in (ord("m"), ord("M")):
                return "m"
            if touche in (ord("q"), ord("Q")):
                return None
    finally:
        ecran.timeout(-1)


def partie(ecran, contre_ordinateur):
    """Joue une partie ; renvoie 'r' (rejouer), 'm' (menu) ou None (quitter)."""
    grille = nouvelle_grille()
    curseur = COLONNES // 2
    tour = 0
    while True:
        jeton = JETONS[tour % 2]
        if contre_ordinateur and jeton == JETONS[1]:
            geo = attendre_taille(ecran)
            dessiner_tout(ecran, grille, geo, None, jeton, "● L'ordinateur réfléchit…")
            time.sleep(0.5)
            colonne = coup_ordinateur(grille, jeton)
        else:
            colonne, curseur = choisir_colonne(ecran, grille, jeton, curseur)
            if colonne is None:
                return None
        ligne = prochaine_ligne(grille, colonne)
        geo = attendre_taille(ecran)
        animer_chute(ecran, grille, geo, colonne, ligne, jeton, "")
        grille[ligne][colonne] = jeton

        gagnees = positions_victoire(grille, jeton)
        if gagnees:
            if contre_ordinateur and jeton == JETONS[1]:
                message = "● L'ordinateur gagne ! — r rejouer · m menu · q quitter"
            else:
                message = f"● {NOMS[jeton]} gagne ! — r rejouer · m menu · q quitter"
            return fin_de_partie(ecran, grille, gagnees, jeton, message)
        if grille_pleine(grille):
            return fin_de_partie(ecran, grille, None, None, "Match nul ! — r rejouer · m menu · q quitter")
        tour += 1


def menu(ecran):
    """Écran d'accueil ; renvoie True (contre l'ordinateur), False ou None."""
    options = ("Joueur contre joueur", "Joueur contre ordinateur", "Quitter")
    selection = 0
    while True:
        haut, _ = ecran.getmaxyx()
        ecran.erase()
        y = max(1, haut // 2 - 4)
        centrer(ecran, y, "● P U I S S A N C E  4 ●", curses.color_pair(PAIRE_TITRE) | curses.A_BOLD)
        centrer(ecran, y + 1, "●  ●  ●  ●", curses.color_pair(PAIRE_X))
        for i, option in enumerate(options):
            attr = curses.A_REVERSE | curses.A_BOLD if i == selection else 0
            centrer(ecran, y + 3 + i, f"  {option}  ", attr)
        centrer(ecran, haut - 1, "↑/↓ : choisir · Entrée : valider · q : quitter",
                curses.color_pair(PAIRE_AIDE) | curses.A_DIM)
        ecran.refresh()
        touche = ecran.getch()
        if touche in (ord("q"), ord("Q")):
            return None
        if touche == curses.KEY_UP:
            selection = (selection - 1) % len(options)
        elif touche == curses.KEY_DOWN:
            selection = (selection + 1) % len(options)
        elif touche in (curses.KEY_ENTER, 10, 13, ord(" ")):
            if selection == 2:
                return None
            return selection == 1


def application(ecran):
    init_interface(ecran)
    while True:
        contre_ordinateur = menu(ecran)
        if contre_ordinateur is None:
            return
        while True:
            suite = partie(ecran, contre_ordinateur)
            if suite == "r":
                continue
            if suite == "m":
                break
            return


def main():
    try:
        curses.wrapper(application)
    except SystemExit:
        pass
    print("Merci d'avoir joué !")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nPartie interrompue. À bientôt !")
