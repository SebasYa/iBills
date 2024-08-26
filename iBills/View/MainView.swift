//
//  MainView.swift
//  iBills
//
//  Created by Sebastian Yanni on 05/08/2024.
//

import SwiftUI

struct MainView: View {

    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        if authViewModel.isAuthenticated {
                VStack {
                    TabView {
                        HomeView()
                            .tabItem {
                                Label("Home", systemImage: "house.fill")
                            }
                        
                        BalanceView()
                            .tabItem {
                                Label("Balance", systemImage: "book.pages.fill")
                            }
                        
                        GraphView()
                            .tabItem {
                                Label("Gráfico", systemImage: "chart.xyaxis.line")
                            }
                    }
                }
        } else if authViewModel.showAuthView {
                // Mostrar la vista de autenticación
                AuthenticationView(viewModel: authViewModel)
            } else {
                // Mostrar un mensaje de error o una opción para abrir Configuración
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
                .onChange(of: authViewModel.isAuthenticated) { _, newValue in
                    // Realiza cualquier acción adicional si el estado de autenticación cambia
                    if newValue {
                        authViewModel.showAuthView = false
                    }
                }
            }
    }
}




#Preview {
    MainView()
}
