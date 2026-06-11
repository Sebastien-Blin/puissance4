import SwiftUI

struct MenuView: View {
    let demarrer: (NiveauIA?) -> Void

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 18) {
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { index in
                        JetonView(joueur: index % 2 == 0 ? .rouge : .jaune)
                            .frame(width: 34, height: 34)
                    }
                }
                Text("PUISSANCE 4")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .kerning(2)
                Text("Alignez quatre jetons pour gagner")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.55))
            }

            VStack(spacing: 14) {
                BoutonMenu(
                    titre: "Deux joueurs",
                    sousTitre: "Sur le même iPad, chacun son tour",
                    symbole: "person.2.fill",
                    teinte: .green
                ) { demarrer(nil) }

                BoutonMenu(
                    titre: "Ordinateur · facile",
                    sousTitre: "L'IA pare au plus pressé",
                    symbole: "tortoise.fill",
                    teinte: .cyan
                ) { demarrer(.facile) }

                BoutonMenu(
                    titre: "Ordinateur · difficile",
                    sousTitre: "Minimax : elle anticipe vos pièges",
                    symbole: "hare.fill",
                    teinte: .orange
                ) { demarrer(.difficile) }
            }
            .frame(maxWidth: 460)

            Spacer()
            Spacer()
        }
        .padding(32)
    }
}
