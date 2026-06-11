# Puissance 4

Jeu de Puissance 4 en deux déclinaisons :

- **`puissance4.py`** — version console en Python (interface `curses`,
  aucune dépendance externe).
- **`Puissance4.swiftpm/`** — application native iPad en SwiftUI.

## Version console

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

## Application iPad (SwiftUI)

Le dossier `Puissance4.swiftpm` est un projet d'app native :

- Plateau bleu à trous avec jetons brillants, chute animée avec rebond,
  pulsation de l'alignement gagnant, retours haptiques.
- Mêmes modes que la console : deux joueurs, IA facile, IA minimax
  (profondeur 7 — Swift le permet sans temps d'attente).
- Score de session, écran d'accueil, orientations portrait et paysage.

### Lancer sur iPad (sans Mac)

1. Installer l'app gratuite **Swift Playgrounds** depuis l'App Store.
2. Copier le dossier `Puissance4.swiftpm` sur l'iPad (iCloud Drive,
   AirDrop ou « Fichiers »).
3. L'ouvrir dans Swift Playgrounds et appuyer sur **Exécuter**.

### Lancer depuis un Mac

Ouvrir `Puissance4.swiftpm` avec Xcode, choisir un simulateur iPad (ou
votre iPad branché) et lancer avec ⌘R. Un compte Apple gratuit suffit
pour l'installer sur votre propre appareil.

## Règles

Chacun son tour, on fait tomber un jeton dans une des 7 colonnes. Le premier
à aligner 4 jetons (horizontalement, verticalement ou en diagonale) gagne.
Si la grille (6×7) est pleine sans alignement, la partie est nulle.
