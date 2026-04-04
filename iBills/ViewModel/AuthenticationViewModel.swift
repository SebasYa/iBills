//
//  AuthenticationViewModel.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showAuthView = true
    @Published var authErrorMessage = ""
    @Published var isAuthenticating = false

    private let authenticator: Authenticating

    init(authenticator: Authenticating = LocalAuthenticationService()) {
        self.authenticator = authenticator
    }

    func authenticate() {
        guard !isAuthenticating else {
            return
        }

        isAuthenticating = true

        Task {
            let result = await authenticator.authenticate()
            apply(result)
            isAuthenticating = false
        }
    }

    private func apply(_ result: AuthenticationResult) {
        switch result {
        case .authenticated:
            isAuthenticated = true
            showAuthView = false
            authErrorMessage = ""
        case let .failed(message, shouldOpenSettings):
            isAuthenticated = false
            showAuthView = !shouldOpenSettings
            authErrorMessage = message
        }
    }
}
