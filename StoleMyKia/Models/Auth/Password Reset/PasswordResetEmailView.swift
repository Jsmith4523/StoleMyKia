//
//  PasswordResetView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/26/23.
//

import SwiftUI

struct PasswordResetEmailView: View {
    
    @State private var email = ""
    
    @State private var isLoading = false
    @State private var alertError = false
    
    @State private var pushToPasscodeVerificationView = false
    
    @ObservedObject var loginModel: LoginViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
            VStack {
                VStack {
                    Spacer()
                        .frame(height: 55)
                    VStack {
                        Text("Forgot Password")
                            .customTitleStyle()
                        Spacer()
                            .frame(height: 20)
                        Text("Please enter your email")
                            .customSubtitleStyle()
                    }
                    Spacer()
                        .frame(height: 105)
                    TextField("Your Email", text: $email)
                        .loginTextFieldStyle()
                    
                    Spacer()
                }
                Spacer()
                NavigationLink(isActive: $pushToPasscodeVerificationView) {
                    PasswordResetCodeView(email: email, loginModel: loginModel)
                } label: {}
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
        .keyboardType(.alphabet)
        .autocorrectionDisabled()
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
                        sendPassResetCode()
                    }
                    .disabled(email.isEmpty)
                }
            }
        }
        .alert("Email not found", isPresented: $alertError) {
            Button("OK") {}
        } message: {
            Text("You have either entered your email incorrectly or you do not have an active account.")
        }
    }
    
    func sendPassResetCode() {
        guard !(email.isEmpty) else {
            return
        }
        loginModel.sendResetPasswordLink(to: email) { status in
            guard let status, !(status == false) else {
                self.alertError.toggle()
                return
            }
            self.pushToPasscodeVerificationView.toggle()
        }
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PasswordResetEmailView(loginModel: LoginViewModel())
        }
    }
}
