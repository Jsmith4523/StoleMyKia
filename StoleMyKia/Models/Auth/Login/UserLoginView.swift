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
    
    @State private var isLoading = false
    @State private var alertError = false
    
    @ObservedObject var loginModel: LoginViewModel
    
    @FocusState private var loginFocus: LoginFocus?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                VStack {
                    Spacer()
                        .frame(height: 35)
                    Text("Welcome")
                        .customTitleStyle()
                    Spacer()
                        .frame(height: 10)
                    Text("Let's fight crime!")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                        .frame(height: 70)
                    VStack(spacing: 20) {
                        VStack(spacing: 20) {
                            TextField("Email", text: $email)
                                .loginTextFieldStyle()
                                .focused($loginFocus, equals: .email)
                            SecureField("Password", text: $password)
                                .loginTextFieldStyle()
                                .focused($loginFocus, equals: .password)
                        }
                        HStack {
                            NavigationLink {
                                PasswordResetEmailView(loginModel: loginModel)
                            } label: {
                                Text("Forgot Password?")
                                    .font(.system(size: 14))
                            }
                            Divider()
                            NavigationLink {
                                UserCreateAccountView(loginModel: loginModel)
                            } label: {
                                Text("Create Account")
                                    .font(.system(size: 14))
                            }
                        }
                        .frame(height: 15)
                    }
                    .padding()
                    Spacer()
                    if isLoading {
                        ProgressView()
                    } else {
                        Button {
                            beginLogin()
                        } label: {
                            Text("Login")
                                .padding()
                                .frame(width: 300)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    Spacer()
                }
                .autocorrectionDisabled()
                .keyboardType(.alphabet)
            }
            .alert("Unable to login", isPresented: $alertError) {
                Button("Okay"){}
            } message: {
                Text("Make sure the information you're entering is correct and try again.")
            }
        }
    }
    
    private func beginLogin() {
        guard !(email.isEmpty) else {
            self.loginFocus = .email
            return
        }
        guard !(password.isEmpty) else {
            self.loginFocus = .password
            return
        }
        isLoading = true
        loginModel.signIn(email: email, password: password) { result in
            guard result == nil else {
                self.alertError = true
                return
            }
        }
        isLoading = false
    }
}

struct UserLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserLoginView(loginModel: LoginViewModel())
        }
    }
}
