//
//  MainMenuView.swift
//  smashsides
//
//  Created by Gabriel Medeiros Martins on 30/11/24.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        VStack {
            NavigationLink {
                GameView(mode: .Timed(seconds: 150))
            } label: {
                Text("Timed")
            }
            
            NavigationLink {
                GameView(mode: .Hittable(hits: 3))
            } label: {
                Text("Hittable")
            }
        }
    }
}

#Preview {
    NavigationStack {
        MainMenuView()
    }
}
