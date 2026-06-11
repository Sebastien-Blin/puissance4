import SwiftUI

@main
struct Puissance4App: App {
    var body: some Scene {
        WindowGroup {
            RacineView()
        }
    }
}

struct RacineView: View {
    @State private var partie: Partie?

    var body: some View {
        ZStack {
            FondView()
            if let partie {
                PartieView(partie: partie) {
                    withAnimation(.easeInOut(duration: 0.3)) { self.partie = nil }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                MenuView { niveau in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        partie = Partie(niveauIA: niveau)
                    }
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .preferredColorScheme(.dark)
    }
}

/// Dégradé de fond commun à tous les écrans.
struct FondView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.07, green: 0.10, blue: 0.22),
                Color(red: 0.03, green: 0.05, blue: 0.12)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
