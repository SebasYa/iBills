//
//  AuthenticationView.swift
//  iBills
//
//  Created by Sebastian Yanni.
//

import SwiftUI

struct AuthenticationView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        VStack {
            
            Spacer()
                .padding(.top, 40)
            
            Text("Autenticación Requerida")
                .font(.title)
                .foregroundStyle(.blue)
                .font(.headline)
                .padding()
            Spacer()
            
            
            Image(systemName: "faceid")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundStyle(.blue)
                .padding()
            
            Button(action: {
                viewModel.authenticate()
            }) {
                Text("Autenticar con Face ID")
                    .font(.callout)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            
            if !viewModel.authErrorMessage.isEmpty {
                Text(viewModel.authErrorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
                .padding(.bottom)
            
        }
        .onAppear {
            viewModel.authenticate()
        }
    }
}

#Preview {
    AuthenticationView(viewModel: AuthenticationViewModel())
}
