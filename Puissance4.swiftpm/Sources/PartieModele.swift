import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Un jeton posé sur le plateau, identifiable pour animer son apparition.
struct JetonPose: Identifiable, Equatable {
    let id = UUID()
    let joueur: Joueur
    let position: Position
}

@MainActor
final class Partie: ObservableObject {
    @Published private(set) var grille = Grille()
    @Published private(set) var jetons: [JetonPose] = []
    @Published private(set) var joueurCourant: Joueur = .rouge
    @Published private(set) var casesGagnantes: [Position]?
    @Published private(set) var matchNul = false
    @Published private(set) var iaReflechit = false
    @Published private(set) var scores: [Joueur: Int] = [.rouge: 0, .jaune: 0]
    @Published private(set) var nuls = 0

    let niveauIA: NiveauIA?

    init(niveauIA: NiveauIA?) {
        self.niveauIA = niveauIA
    }

    var terminee: Bool { casesGagnantes != nil || matchNul }
    var gagnant: Joueur? { casesGagnantes != nil ? joueurCourant : nil }

    var auTourDeLHumain: Bool {
        !terminee && !iaReflechit && (niveauIA == nil || joueurCourant == .rouge)
    }

    func estGagnante(_ position: Position) -> Bool {
        casesGagnantes?.contains(position) ?? false
    }

    /// Coup demandé par une pression sur une colonne.
    func jouerHumain(colonne: Int) {
        guard auTourDeLHumain else { return }
        poser(colonne: colonne)
    }

    func rejouer() {
        grille = Grille()
        jetons = []
        casesGagnantes = nil
        matchNul = false
        iaReflechit = false
        joueurCourant = .rouge
    }

    private func poser(colonne: Int) {
        guard !terminee, let ligne = grille.jouer(colonne: colonne, joueur: joueurCourant) else {
            Haptique.erreur()
            return
        }
        jetons.append(JetonPose(joueur: joueurCourant, position: Position(ligne: ligne, colonne: colonne)))
        Haptique.impact()

        if let gagnantes = grille.positionsVictoire(joueurCourant) {
            casesGagnantes = gagnantes
            scores[joueurCourant, default: 0] += 1
            Haptique.succes()
            return
        }
        if grille.estPleine {
            matchNul = true
            nuls += 1
            return
        }
        joueurCourant = joueurCourant.oppose
        if niveauIA != nil && joueurCourant == .jaune {
            faireJouerIA()
        }
    }

    private func faireJouerIA() {
        guard let niveau = niveauIA else { return }
        iaReflechit = true
        let grilleCopiee = grille
        Task { [weak self] in
            async let calcul = Task.detached(priority: .userInitiated) {
                IA.coup(grille: grilleCopiee, joueur: .jaune, niveau: niveau)
            }.value
            // Laisse l'animation de chute du joueur se terminer
            try? await Task.sleep(nanoseconds: 600_000_000)
            let colonne = await calcul
            guard let self, self.iaReflechit else { return }
            self.iaReflechit = false
            self.poser(colonne: colonne)
        }
    }
}

/// Retours haptiques, sans effet hors iOS (pour la compilation de test sur Mac).
enum Haptique {
    static func impact() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }

    static func succes() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    static func erreur() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        #endif
    }
}
