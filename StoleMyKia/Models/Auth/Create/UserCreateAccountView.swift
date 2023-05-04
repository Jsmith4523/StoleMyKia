//
//  UserCreateAccountView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/25/23.
//

import SwiftUI

struct UserCreateAccountView: View {
    
    private enum AccountCreateFocus {
        case email
        case password
        case secured
    }
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var isLoading = false
    @State private var showPassword = false
    
    @State private var alertError = false
    @State private var pushToWelcomeView = false

    @ObservedObject var userModel: UserViewModel
    
    @Environment (\.dismiss) var dismiss
    
    @FocusState private var accCreationFocus: AccountCreateFocus?
    
    private var isSatisfied: Bool {
        email.isEmpty || password.isEmpty
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: 65)
                VStack(spacing: 22) {
                    Text("Sign Up")
                        .customTitleStyle()
                    Text("We only require your email and password to identify you. You're completely anonymous from other users for your safety and security")
                        .customSubtitleStyle()
                }
                Spacer()
                    .frame(height: 50)
                VStack(spacing: 10) {
                    TextField("Your Email", text: $email)
                        .loginTextFieldStyle()
                        .focused($accCreationFocus, equals: .email)
                    VStack(alignment: .leading) {
                        if showPassword {
                            TextField("Password", text: $password)
                                .loginTextFieldStyle()
                                .focused($accCreationFocus, equals: .password)
                        } else {
                            SecureField("Password", text: $password)
                                .loginTextFieldStyle()
                                .focused($accCreationFocus, equals: .secured)
                        }
                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .padding(10)
                        }
                    }
                    .keyboardType(.alphabet)
                    .autocorrectionDisabled()
                }
                Spacer()
                NavigationLink(isActive: $pushToWelcomeView) {
                    Color.green
                } label: {}
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if isLoading {
                    ProgressView()
                } else {
                    Button("Next") {
                        beginAccountCreation()
                    }
                    .disabled(isSatisfied)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .alert("Invalid", isPresented: $alertError) {
            Button("OK") {}
        } message: {
            Text("We were unable to create an account with the information provided. Perhaps you already have an active account?")
        }
    }
    
    func beginAccountCreation() {
        isLoading = true
        userModel.signUp(email: email, password: password) { status in
            guard let status, status == true else {
                self.alertError.toggle()
                isLoading = false
                return
            }
            self.pushToWelcomeView.toggle()
        }
        isLoading = false
    }
}
