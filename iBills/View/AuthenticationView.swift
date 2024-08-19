//
//  AuthenticationView.swift
//  iBills
//
//  Created by Sebastian Yanni on 16/08/2024.
//

import SwiftUI
import LocalAuthentication

struct AuthenticationView: View {
    @Binding var isAuthenticated: Bool
    @Binding var showAuthView: Bool
    @Binding var authErrorMessage: String
    
    @State private var failedAttempts: Int = 0
    @State private var context = LAContext()
    let maxFailedAttempts = 1
    
    var body: some View {
        VStack {
            Image(systemName: "faceid")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundStyle(.blue)
                .padding()
            
            Text("Autenticación Requerida")
                .foregroundStyle(.blue)
                .font(.headline)
                .padding()
            Button("Autenticar con Face ID") {
                authenticate()
            }
            .padding()
            
            if !authErrorMessage.isEmpty {
                Text(authErrorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            authenticate()
        }
    }
    
    func authenticate() {
        let reason = "Por favor, autentícate para acceder a la app."
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    isAuthenticated = true
                    showAuthView = false
                } else {
                    failedAttempts += 1
                    if failedAttempts >= maxFailedAttempts {
                        // Mostrar un mensaje o alertar que se intentará con código de acceso
                        authErrorMessage = "Demasiados intentos fallidos. Autenticando con código de acceso..."
                        authenticateWithPasscode()
                    } else {
                        authErrorMessage = "Face ID falló. Inténtalo de nuevo."
                    }
                }
            }
        }
    }
    
    func authenticateWithPasscode() {
        let reason = "Face ID falló. Ingresa tu código de acceso para continuar."
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    isAuthenticated = true
                    showAuthView = false
                } else {
                    authErrorMessage = "La autenticación falló."
                }
            }
        }
    }
}

#Preview {
    AuthenticationView(
        isAuthenticated: .constant(false),
        showAuthView: .constant(true),
        authErrorMessage: .constant("")
    )
}
