//
//  PasswordResetCodeView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/27/23.
//

import SwiftUI

struct PasswordResetCodeView: View {
    
    let email: String
    
    @State private var verificationCode = ""
    
    @ObservedObject var loginModel: LoginViewModel
    
    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: 75)
                VStack(spacing: 25) {
                    Text("Verify Passcode")
                        .customTitleStyle()
                    Text("A verification code has been sent to \(email)")
                        .customSubtitleStyle()
                }
                Spacer()
                    .frame(height: 100)
                TextField("Verification Code", text: $verificationCode)
                    .loginTextFieldStyle()
                    .keyboardType(.numberPad)
                Spacer()
            }
            .padding()
        }
    }
}

struct PasswordResetCodeView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetCodeView(email: "johnny.applseed@icloud.com", loginModel: LoginViewModel())
    }
}
