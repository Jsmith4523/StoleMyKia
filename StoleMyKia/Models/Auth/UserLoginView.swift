//
//  UserLoginView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/25/23.
//

import SwiftUI

struct UserLoginView: View {
    
    private enum LoginFocus {
        case email
        case password
    }
    
    @State private var email = ""
    @State private var password = ""
    
    @ObservedObject var loginModel: LoginViewModel
    
    @FocusState private var loginFocus: LoginFocus?
    
    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
            VStack(alignment: .leading) {
                Spacer()
                    .frame(height: 100)
                Text("Welcome Back!")
                    .font(.system(size: 35).bold())
                    .padding(.horizontal)
                Spacer()
                    .frame(height: 100)
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .loginTextFieldStyle()
                        .focused($loginFocus, equals: .email)
                    SecureField("Password", text: $password)
                        .loginTextFieldStyle()
                        .focused($loginFocus, equals: .password)
                }
                .padding()
                Spacer()
            }
            .autocorrectionDisabled()
            .keyboardType(.default)
        }
    }
}

private extension View {
    
    func loginTextFieldStyle() -> some View {
        return self
            .padding()
            .background(Color(uiColor: .systemBackground))
            .overlay {
                Rectangle()
                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
            }
    }
}

struct UserLoginView_Previews: PreviewProvider {
    static var previews: some View {
        UserLoginView(loginModel: LoginViewModel())
    }
}
