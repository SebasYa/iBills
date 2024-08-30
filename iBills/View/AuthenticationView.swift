//
//  AuthenticationView.swift
//  iBills
//
//

import SwiftUI

struct AuthenticationView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    
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
                viewModel.authenticate()
            }
            .padding()
            
            if !viewModel.authErrorMessage.isEmpty {
                Text(viewModel.authErrorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            viewModel.authenticate()
        }
    }
}

#Preview {
    AuthenticationView(viewModel: AuthenticationViewModel())
}
