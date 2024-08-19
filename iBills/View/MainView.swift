//
//  MainView.swift
//  iBills
//
//  Created by Sebastian Yanni on 05/08/2024.
//

import SwiftUI

struct MainView: View {
    @State private var isAuthenticated = false
    @State private var showAuthView = true
    @State private var authErrorMessage = ""
    
    
    var body: some View {
            if isAuthenticated {
                VStack {
                    TabView {
                        HomeView()
                            .tabItem {
                                Label("Home", systemImage: "house.fill")
                            }
                        GraphView()
                            .tabItem {
                                Label("Gráfico", systemImage: "chart.xyaxis.line")
                            }
                    }
                }
            } else if showAuthView {
                // Mostrar la vista de autenticación
                AuthenticationView(isAuthenticated: $isAuthenticated, showAuthView: $showAuthView, authErrorMessage: $authErrorMessage)
            } else {
                // Mostrar un mensaje de error o una opción para abrir Configuración
                VStack {
                    Text("Se necesita autorización para acceder a la app.")
                        .foregroundColor(.red)
                    if !authErrorMessage.isEmpty {
                        Text(authErrorMessage)
                            .foregroundColor(.gray)
                    }
                    Button("Abrir Configuración") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding()
                }
                .onChange(of: isAuthenticated) { _, newValue in
                    // Realiza cualquier acción adicional si el estado de autenticación cambia
                    if newValue {
                        showAuthView = false
                    }
                }
            }
    }
}




#Preview {
    MainView()
}
