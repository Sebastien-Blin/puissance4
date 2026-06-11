import SwiftUI

/// Le plateau bleu percé de trous, les jetons qui tombent et les
/// zones tactiles des colonnes.
struct PlateauView: View {
    @ObservedObject var partie: Partie

    var body: some View {
        GeometryReader { geometrie in
            let cote = min(
                geometrie.size.width / CGFloat(Grille.colonnes),
                geometrie.size.height / CGFloat(Grille.lignes + 1)
            )
            let largeur = cote * CGFloat(Grille.colonnes)
            let hauteur = cote * CGFloat(Grille.lignes)
            let origine = CGPoint(
                x: (geometrie.size.width - largeur) / 2,
                y: (geometrie.size.height - hauteur - cote * 0.4) / 2 + cote * 0.4
            )

            ZStack {
                // Panneau bleu
                RoundedRectangle(cornerRadius: cote * 0.3, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.plateauClair, .plateauSombre],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: largeur + cote * 0.3, height: hauteur + cote * 0.3)
                    .position(x: origine.x + largeur / 2, y: origine.y + hauteur / 2)
                    .shadow(color: .black.opacity(0.5), radius: 18, x: 0, y: 10)

                // Trous
                ForEach(0..<Grille.lignes, id: \.self) { ligne in
                    ForEach(0..<Grille.colonnes, id: \.self) { colonne in
                        Circle()
                            .fill(Color.trou)
                            .overlay(
                                Circle().strokeBorder(.black.opacity(0.5), lineWidth: 1.5)
                            )
                            .frame(width: cote * 0.82, height: cote * 0.82)
                            .position(centre(de: Position(ligne: ligne, colonne: colonne),
                                             origine: origine, cote: cote))
                    }
                }

                // Jetons posés
                ForEach(partie.jetons) { jeton in
                    JetonTombantView(
                        jeton: jeton,
                        gagnant: partie.estGagnante(jeton.position),
                        cote: cote,
                        cible: centre(de: jeton.position, origine: origine, cote: cote)
                    )
                }

                // Zones tactiles : une bande par colonne
                HStack(spacing: 0) {
                    ForEach(0..<Grille.colonnes, id: \.self) { colonne in
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { partie.jouerHumain(colonne: colonne) }
                    }
                }
                .frame(width: largeur, height: hauteur + cote)
                .position(x: origine.x + largeur / 2, y: origine.y + hauteur / 2 - cote / 2)
            }
        }
    }

    private func centre(de position: Position, origine: CGPoint, cote: CGFloat) -> CGPoint {
        CGPoint(
            x: origine.x + (CGFloat(position.colonne) + 0.5) * cote,
            y: origine.y + (CGFloat(position.ligne) + 0.5) * cote
        )
    }
}

/// Un jeton qui tombe depuis le haut du plateau jusqu'à sa case,
/// avec un rebond, puis une pulsation s'il fait partie de l'alignement gagnant.
struct JetonTombantView: View {
    let jeton: JetonPose
    let gagnant: Bool
    let cote: CGFloat
    let cible: CGPoint

    @State private var tombe = false
    @State private var pulse = false

    var body: some View {
        JetonView(joueur: jeton.joueur)
            .frame(width: cote * 0.78, height: cote * 0.78)
            .overlay(
                Circle()
                    .strokeBorder(.white, lineWidth: gagnant ? 3 : 0)
                    .opacity(gagnant ? (pulse ? 0.25 : 0.95) : 0)
            )
            .scaleEffect(gagnant && pulse ? 1.08 : 1.0)
            .position(x: cible.x, y: tombe ? cible.y : cible.y - cote * CGFloat(jeton.position.ligne + 2))
            .onAppear {
                withAnimation(.interpolatingSpring(stiffness: 130, damping: 13)) {
                    tombe = true
                }
            }
            .onChange(of: gagnant) { estGagnant in
                guard estGagnant else { return }
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}
