import SwiftUI

struct PartieView: View {
    @ObservedObject var partie: Partie
    let retourMenu: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            barreSuperieure
            indicateurDeTour
            PlateauView(partie: partie)
                .padding(.horizontal, 8)
            Spacer(minLength: 8)
        }
        .padding(16)
        .overlay(alignment: .center) {
            if partie.terminee {
                bandeauFinDePartie
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: partie.terminee)
    }

    private var barreSuperieure: some View {
        HStack {
            Button(action: retourMenu) {
                Label("Menu", systemImage: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.08), in: Capsule())
            }
            .buttonStyle(.plain)
            Spacer()
            ScoreView(partie: partie)
            Spacer()
            Button {
                withAnimation { partie.rejouer() }
            } label: {
                Label("Rejouer", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.08), in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var indicateurDeTour: some View {
        HStack(spacing: 10) {
            if partie.terminee {
                EmptyView()
            } else if partie.iaReflechit {
                ProgressView()
                    .tint(.white)
                Text("L'ordinateur réfléchit…")
            } else {
                JetonView(joueur: partie.joueurCourant)
                    .frame(width: 24, height: 24)
                Text(nomDuTour)
            }
        }
        .font(.title3.weight(.medium))
        .foregroundStyle(.white.opacity(0.85))
        .frame(height: 32)
    }

    private var nomDuTour: String {
        if partie.niveauIA != nil {
            return partie.joueurCourant == .rouge ? "À vous de jouer" : "À l'ordinateur"
        }
        return "Au tour de \(partie.joueurCourant.nom)"
    }

    private var bandeauFinDePartie: some View {
        VStack(spacing: 18) {
            if let gagnant = partie.gagnant {
                JetonView(joueur: gagnant)
                    .frame(width: 56, height: 56)
                Text(titreVictoire(gagnant))
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            } else {
                Text("Match nul !")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            HStack(spacing: 14) {
                Button {
                    withAnimation { partie.rejouer() }
                } label: {
                    Label("Rejouer", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(.white, in: Capsule())
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
                Button(action: retourMenu) {
                    Label("Menu", systemImage: "house.fill")
                        .font(.headline)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.15), in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(36)
        .background(.black.opacity(0.78), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.5), radius: 30, y: 12)
    }

    private func titreVictoire(_ gagnant: Joueur) -> String {
        if partie.niveauIA != nil {
            return gagnant == .rouge ? "Vous gagnez !" : "L'ordinateur gagne !"
        }
        return "\(gagnant.nom) gagne !"
    }
}
