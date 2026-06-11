# Puissance 4

Jeu de Puissance 4 en mode console, écrit en Python (aucune dépendance
externe : l'interface utilise `curses`, fourni avec Python sous
macOS/Linux).

## Lancer le jeu

```bash
python3 puissance4.py
```

## Interface

- Plateau coloré centré à l'écran, avec animation de chute des jetons et
  clignotement de l'alignement gagnant.
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
- **Joueur contre ordinateur** : l'IA gagne quand elle le peut, bloque vos alignements et privilégie le centre.

## Règles

Chacun son tour, on fait tomber un jeton dans une des 7 colonnes. Le premier
à aligner 4 jetons (horizontalement, verticalement ou en diagonale) gagne.
Si la grille (6×7) est pleine sans alignement, la partie est nulle.
