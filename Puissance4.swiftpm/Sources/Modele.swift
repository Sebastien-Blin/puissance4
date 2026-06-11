// Logique du Puissance 4 : grille, détection de victoire et IA.
// Aucune dépendance UI, pour rester testable hors iOS.

enum Joueur: Equatable, Hashable {
    case rouge
    case jaune

    var oppose: Joueur { self == .rouge ? .jaune : .rouge }
    var nom: String { self == .rouge ? "Rouge" : "Jaune" }
}

struct Position: Hashable {
    let ligne: Int
    let colonne: Int
}

struct Grille {
    static let lignes = 6
    static let colonnes = 7

    private(set) var cases: [[Joueur?]] = Array(
        repeating: Array(repeating: nil, count: Grille.colonnes),
        count: Grille.lignes
    )

    subscript(ligne: Int, colonne: Int) -> Joueur? {
        cases[ligne][colonne]
    }

    var colonnesJouables: [Int] {
        (0..<Grille.colonnes).filter { cases[0][$0] == nil }
    }

    var estPleine: Bool { colonnesJouables.isEmpty }

    func prochaineLigne(colonne: Int) -> Int? {
        for ligne in stride(from: Grille.lignes - 1, through: 0, by: -1)
        where cases[ligne][colonne] == nil {
            return ligne
        }
        return nil
    }

    @discardableResult
    mutating func jouer(colonne: Int, joueur: Joueur) -> Int? {
        guard let ligne = prochaineLigne(colonne: colonne) else { return nil }
        cases[ligne][colonne] = joueur
        return ligne
    }

    mutating func annuler(colonne: Int) {
        for ligne in 0..<Grille.lignes where cases[ligne][colonne] != nil {
            cases[ligne][colonne] = nil
            return
        }
    }

    /// Les 4 cases gagnantes alignées par ce joueur, ou nil.
    func positionsVictoire(_ joueur: Joueur) -> [Position]? {
        let directions = [(0, 1), (1, 0), (1, 1), (-1, 1)]
        for ligne in 0..<Grille.lignes {
            for colonne in 0..<Grille.colonnes {
                for (dl, dc) in directions {
                    let positions = (0..<4).map {
                        Position(ligne: ligne + $0 * dl, colonne: colonne + $0 * dc)
                    }
                    let alignees = positions.allSatisfy {
                        (0..<Grille.lignes).contains($0.ligne)
                            && (0..<Grille.colonnes).contains($0.colonne)
                            && cases[$0.ligne][$0.colonne] == joueur
                    }
                    if alignees { return positions }
                }
            }
        }
        return nil
    }

    func victoire(_ joueur: Joueur) -> Bool {
        positionsVictoire(joueur) != nil
    }
}

enum NiveauIA: String, CaseIterable, Identifiable {
    case facile = "Facile"
    case difficile = "Difficile"

    var id: String { rawValue }
}

enum IA {
    static let profondeurMinimax = 7
    static let scoreVictoire = 1_000_000

    static func coup(grille: Grille, joueur: Joueur, niveau: NiveauIA) -> Int {
        switch niveau {
        case .facile:
            return coupFacile(grille: grille, joueur: joueur)
        case .difficile:
            return coupMinimax(grille: grille, joueur: joueur)
        }
    }

    /// IA simple : gagne si possible, bloque sinon, sinon joue au centre.
    static func coupFacile(grille: Grille, joueur: Joueur) -> Int {
        var grille = grille
        let jouables = grille.colonnesJouables

        for colonne in jouables {
            grille.jouer(colonne: colonne, joueur: joueur)
            let gagne = grille.victoire(joueur)
            grille.annuler(colonne: colonne)
            if gagne { return colonne }
        }
        for colonne in jouables {
            grille.jouer(colonne: colonne, joueur: joueur.oppose)
            let menace = grille.victoire(joueur.oppose)
            grille.annuler(colonne: colonne)
            if menace { return colonne }
        }
        let centre = Grille.colonnes / 2
        return jouables.min { lhs, rhs in
            (abs(lhs - centre), Int.random(in: 0...100)) < (abs(rhs - centre), Int.random(in: 0...100))
        } ?? centre
    }

    static func coupMinimax(grille: Grille, joueur: Joueur) -> Int {
        var grille = grille
        let (colonne, _) = minimax(
            grille: &grille,
            profondeur: profondeurMinimax,
            alpha: Int.min,
            beta: Int.max,
            maximise: true,
            joueurIA: joueur
        )
        return colonne ?? Grille.colonnes / 2
    }

    /// Tous les alignements de 4 cases du plateau.
    private static let fenetres: [[Position]] = {
        var resultat: [[Position]] = []
        for l in 0..<Grille.lignes {
            for c in 0...(Grille.colonnes - 4) {
                resultat.append((0..<4).map { Position(ligne: l, colonne: c + $0) })
            }
        }
        for l in 0...(Grille.lignes - 4) {
            for c in 0..<Grille.colonnes {
                resultat.append((0..<4).map { Position(ligne: l + $0, colonne: c) })
            }
        }
        for l in 0...(Grille.lignes - 4) {
            for c in 0...(Grille.colonnes - 4) {
                resultat.append((0..<4).map { Position(ligne: l + $0, colonne: c + $0) })
            }
        }
        for l in 3..<Grille.lignes {
            for c in 0...(Grille.colonnes - 4) {
                resultat.append((0..<4).map { Position(ligne: l - $0, colonne: c + $0) })
            }
        }
        return resultat
    }()

    /// Score heuristique du plateau du point de vue de `joueur`.
    static func evaluer(grille: Grille, joueur: Joueur) -> Int {
        var score = 0
        for fenetre in fenetres {
            var miens = 0, siens = 0, vides = 0
            for position in fenetre {
                switch grille[position.ligne, position.colonne] {
                case joueur: miens += 1
                case .some: siens += 1
                case nil: vides += 1
                }
            }
            if miens == 3 && vides == 1 { score += 50 }
            else if miens == 2 && vides == 2 { score += 10 }
            if siens == 3 && vides == 1 { score -= 80 }
            else if siens == 2 && vides == 2 { score -= 10 }
        }
        let centre = Grille.colonnes / 2
        for ligne in 0..<Grille.lignes where grille[ligne, centre] == joueur {
            score += 6
        }
        return score
    }

    /// Minimax avec élagage alpha-bêta. Les victoires proches valent plus
    /// que les lointaines pour conclure vite et retarder les défaites.
    private static func minimax(
        grille: inout Grille,
        profondeur: Int,
        alpha: Int,
        beta: Int,
        maximise: Bool,
        joueurIA: Joueur
    ) -> (colonne: Int?, score: Int) {
        if grille.victoire(joueurIA) {
            return (nil, scoreVictoire + profondeur)
        }
        if grille.victoire(joueurIA.oppose) {
            return (nil, -scoreVictoire - profondeur)
        }
        if grille.estPleine {
            return (nil, 0)
        }
        if profondeur == 0 {
            return (nil, evaluer(grille: grille, joueur: joueurIA))
        }

        let centre = Grille.colonnes / 2
        let jouables = grille.colonnesJouables
            .map { (colonne: $0, cle: (abs($0 - centre), Int.random(in: 0...100))) }
            .sorted { $0.cle < $1.cle }
            .map(\.colonne)

        let joueurCourant = maximise ? joueurIA : joueurIA.oppose
        var meilleureColonne = jouables[0]
        var meilleurScore = maximise ? Int.min : Int.max
        var alpha = alpha, beta = beta

        for colonne in jouables {
            grille.jouer(colonne: colonne, joueur: joueurCourant)
            let (_, score) = minimax(
                grille: &grille,
                profondeur: profondeur - 1,
                alpha: alpha,
                beta: beta,
                maximise: !maximise,
                joueurIA: joueurIA
            )
            grille.annuler(colonne: colonne)
            if maximise {
                if score > meilleurScore {
                    (meilleurScore, meilleureColonne) = (score, colonne)
                }
                alpha = max(alpha, meilleurScore)
            } else {
                if score < meilleurScore {
                    (meilleurScore, meilleureColonne) = (score, colonne)
                }
                beta = min(beta, meilleurScore)
            }
            if alpha >= beta { break }
        }
        return (meilleureColonne, meilleurScore)
    }
}
