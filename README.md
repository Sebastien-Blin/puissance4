# Puissance 4

Jeu de Puissance 4 en mode console, écrit en Python (aucune dépendance
externe : l'interface utilise `curses`, fourni avec Python sous
macOS/Linux).

## Lancer le jeu

```bash
python3 puissance4.py
```

## Interface

- Plateau bleu plein percé de trous sombres, comme le vrai jeu, centré à
  l'écran ; les jetons tombent avec une accélération et un petit flash à
  l'atterrissage, et l'alignement gagnant clignote.
- Score de la session (victoires de chaque joueur, nuls) affiché sous le
  titre, remis à zéro au retour au menu.
- S'adapte en direct à la taille du terminal : les cases grossissent dans
  une grande fenêtre, et un mode compact prend le relais dans une petite.

## Contrôles

| Touche | Action |
|---|---|
| ← / → ou 1-7 | choisir une colonne |
| Entrée / Espace | lâcher le jeton |
| ↑ / ↓ | naviguer dans le menu |
| r / m / q | rejouer / menu / quitter (fin de partie) |

## Modes de jeu

- **Joueur contre joueur** : deux joueurs s'affrontent sur le même clavier.
- **Ordinateur — facile** : l'IA gagne quand elle le peut, bloque vos
  alignements et privilégie le centre, sans anticiper plus loin.
- **Ordinateur — difficile** : IA minimax avec élagage alpha-bêta
  (profondeur 6). Elle anticipe les coups suivants, prépare des doubles
  menaces et évalue les positions (alignements ouverts, contrôle du
  centre). Comptez jusqu'à ~2 s de réflexion par coup.

## Règles

Chacun son tour, on fait tomber un jeton dans une des 7 colonnes. Le premier
à aligner 4 jetons (horizontalement, verticalement ou en diagonale) gagne.
Si la grille (6×7) est pleine sans alignement, la partie est nulle.
