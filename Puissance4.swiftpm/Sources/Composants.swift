import SwiftUI

extension Joueur {
    var couleur: Color {
        self == .rouge ? Color(red: 0.91, green: 0.26, blue: 0.21)
                       : Color(red: 0.99, green: 0.76, blue: 0.03)
    }

    var couleurSombre: Color {
        self == .rouge ? Color(red: 0.55, green: 0.10, blue: 0.08)
                       : Color(red: 0.65, green: 0.45, blue: 0.0)
    }
}

extension Color {
    static let plateauClair = Color(red: 0.16, green: 0.36, blue: 0.85)
    static let plateauSombre = Color(red: 0.08, green: 0.18, blue: 0.55)
    static let trou = Color(red: 0.02, green: 0.04, blue: 0.10)
}

/// Jeton brillant, avec un reflet en haut à gauche pour l'effet 3D.
struct JetonView: View {
    let joueur: Joueur

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [joueur.couleur.opacity(0.95), joueur.couleur, joueur.couleurSombre],
                    center: .init(x: 0.35, y: 0.3),
                    startRadius: 1,
                    endRadius: 60
                )
            )
            .overlay(
                Circle()
                    .strokeBorder(joueur.couleurSombre.opacity(0.6), lineWidth: 1.5)
            )
            .overlay(
                Circle()
                    .fill(Color.white.opacity(0.35))
                    .scaleEffect(0.25)
                    .offset(x: -8, y: -10)
                    .blur(radius: 3)
            )
            .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 2)
    }
}

/// Bouton du menu : icône + texte sur une capsule translucide.
struct BoutonMenu: View {
    let titre: String
    let sousTitre: String
    let symbole: String
    let teinte: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: symbole)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(teinte)
                    .frame(width: 44, height: 44)
                    .background(teinte.opacity(0.18), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(titre)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(sousTitre)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Affichage du score de la session : Rouge — Jaune (et nuls).
struct ScoreView: View {
    @ObservedObject var partie: Partie

    var body: some View {
        HStack(spacing: 14) {
            HStack(spacing: 8) {
                JetonView(joueur: .rouge).frame(width: 22, height: 22)
                Text("\(partie.scores[.rouge, default: 0])")
                    .font(.title3.weight(.bold).monospacedDigit())
            }
            Text("—")
                .foregroundStyle(.white.opacity(0.4))
            HStack(spacing: 8) {
                Text("\(partie.scores[.jaune, default: 0])")
                    .font(.title3.weight(.bold).monospacedDigit())
                JetonView(joueur: .jaune).frame(width: 22, height: 22)
            }
            if partie.nuls > 0 {
                Text("nuls : \(partie.nuls)")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .background(.white.opacity(0.08), in: Capsule())
    }
}
