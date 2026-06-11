# Puissance 4

Jeu de Puissance 4 en mode console, écrit en Python (aucune dépendance externe).

## Lancer le jeu

```bash
python3 puissance4.py
```

## Modes de jeu

- **Joueur contre joueur** : deux joueurs s'affrontent sur le même clavier.
- **Joueur contre ordinateur** : l'IA gagne quand elle le peut, bloque vos alignements et privilégie le centre.

## Règles

Chacun son tour, on fait tomber un jeton dans une des 7 colonnes. Le premier
à aligner 4 jetons (horizontalement, verticalement ou en diagonale) gagne.
Si la grille (6×7) est pleine sans alignement, la partie est nulle.
