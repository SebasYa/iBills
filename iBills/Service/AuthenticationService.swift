//
//  AuthenticationService.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import Foundation
import LocalAuthentication

enum AuthenticationResult {
    case authenticated
    case failed(message: String, shouldOpenSettings: Bool)
}

protocol Authenticating {
    func authenticate() async -> AuthenticationResult
}

struct LocalAuthenticationService: Authenticating {
    private let contextFactory: () -> LAContext

    init(contextFactory: @escaping () -> LAContext = { LAContext() }) {
        self.contextFactory = contextFactory
    }

    func authenticate() async -> AuthenticationResult {
        let context = contextFactory()
        context.localizedCancelTitle = "Cancelar"

        var authError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) else {
            return .failed(
                message: errorMessage(for: authError),
                shouldOpenSettings: shouldSuggestSettings(for: authError as? LAError)
            )
        }

        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Por favor, autentícate para acceder a la app."
            ) { success, error in
                if success {
                    continuation.resume(returning: .authenticated)
                    return
                }

                let laError = error as? LAError
                continuation.resume(returning: .failed(
                    message: errorMessage(for: error as NSError?),
                    shouldOpenSettings: shouldSuggestSettings(for: laError)
                ))
            }
        }
    }

    private func shouldSuggestSettings(for error: LAError?) -> Bool {
        switch error?.code {
        case .biometryNotAvailable, .biometryNotEnrolled, .passcodeNotSet:
            true
        default:
            false
        }
    }

    private func errorMessage(for error: NSError?) -> String {
        guard let laError = error as? LAError else {
            return "No se pudo completar la autenticación."
        }

        switch laError.code {
        case .userCancel, .appCancel, .systemCancel:
            return "La autenticación fue cancelada."
        case .authenticationFailed:
            return "No se pudo verificar tu identidad. Inténtalo nuevamente."
        case .biometryNotEnrolled:
            return "No hay biometría configurada en el dispositivo."
        case .biometryNotAvailable:
            return "La autenticación biométrica no está disponible en este dispositivo."
        case .biometryLockout:
            return "La biometría está bloqueada temporalmente. Usa el código del dispositivo para continuar."
        case .passcodeNotSet:
            return "Debes configurar un código de acceso en el dispositivo para habilitar la autenticación."
        case .invalidContext:
            return "La autenticación no está disponible en este momento."
        case .userFallback:
            return "Usa el método de autenticación del dispositivo para continuar."
        default:
            return "No se pudo completar la autenticación."
        }
    }
}
