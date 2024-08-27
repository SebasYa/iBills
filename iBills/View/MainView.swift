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
                // Show Auth verification
                AuthenticationView(viewModel: authViewModel)
            } else {
                // "Show error message"
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
                    // Perform any additional actions if the authentication state changes
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
