//
//  MainView.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI

struct MainView: View {

    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        if authViewModel.isAuthenticated {
            ZStack {
                VStack {
                    ContentView()
                }
            }
        } else if authViewModel.showAuthView {
            AuthenticationView(viewModel: authViewModel)
        } else {
            VStack {
                Text("Se necesita autorización para acceder a la app.")
                    .foregroundColor(.red)
                if !authViewModel.authErrorMessage.isEmpty {
                    Text(authViewModel.authErrorMessage)
                        .foregroundColor(.gray)
                }
                Button("Abrir Configuración") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .padding()
            }
        }
    }
}




#Preview {
    MainView()
}
