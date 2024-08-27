//
//  AuthenticationViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni on 22/08/2024.
//

import SwiftUI
import LocalAuthentication

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var showAuthView: Bool = true
    @Published var authErrorMessage: String = ""
    @Published var failedAttempts: Int = 0
    
    private var context = LAContext()
    private let maxFailedAttempts = 1
    
    // Function to handle biometric authentication
    func authenticate() {
        let reason = "Por favor, autentícate para acceder a la app."
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthenticated = true
                    self?.showAuthView = false
                } else {
                    self?.failedAttempts += 1
                    if let self = self, self.failedAttempts >= self.maxFailedAttempts {
                        self.authErrorMessage = "Demasiados intentos fallidos. Autenticando con código de acceso..."
                        self.authenticateWithPasscode()
                    } else {
                        self?.authErrorMessage = "Face ID falló. Inténtalo de nuevo."
                    }
                }
            }
        }
    }
    
    // Function to handle passcode authentication
    private func authenticateWithPasscode() {
        let reason = "Face ID falló. Ingresa tu código de acceso para continuar."
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthenticated = true
                    self?.showAuthView = false
                } else {
                    self?.authErrorMessage = "La autenticación falló."
                }
            }
        }
    }
}
