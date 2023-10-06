//
//  SignInCodeVerificationView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/4/23.
//

import SwiftUI

struct SignInCodeVerificationView: View {
    
    @State private var isLoading = false
    @State private var alertErrorVerificationCode = false
    @State private var verificationCode = ""
    
    let phoneNumber: String
    
    @EnvironmentObject var firebaseAuthVM: FirebaseAuthViewModel
    
    private var isSatisfied: Bool {
        guard (verificationCode.range(of: ".*[^0-9].*", options: .regularExpression) == nil), verificationCode.count == 6 else { return false }
        return true
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 35) {
                Image(systemName: "paperplane")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                VStack(spacing: 10) {
                    Text("Verification Code Sent!")
                        .font(.system(size: 21).weight(.heavy))
                    Text("We just sent a verification code to \(ApplicationFormats.authPhoneNumberFormat(phoneNumber, parentheses: true) ?? "you"). Check your messages.")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                TextField("Verification Code", text: $verificationCode)
                    .authTextFieldStyle()
            }
            Spacer()
            if isSatisfied {
                Button {
                    beginVerifyingSmsCode()
                } label: {
                    Text("Verify")
                        .authButtonStyle()
                }
            }
            Spacer()
                .frame(height: 15)
        }
        .padding()
        .multilineTextAlignment(.center)
        .navigationTitle("Verification Code")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if isLoading {
                    ProgressView()
                }
            }
        }
        .disabled(isLoading)
        .alert("Cannot verify SMS Code", isPresented: $alertErrorVerificationCode) {
            Button("OK") {}
        } message: {
            Text("Unfortunately, we could not verify the provided SMS code. If the code has been sent too many times to the provided phone number, a cooldown of up to 30 minutes is applied. If this issue persist, please contact support.")
        }
    }
    
    private func beginVerifyingSmsCode() {
        Task {
            isLoading = true
            do {
                try await firebaseAuthVM.verifyCode(verificationCode)
                self.isLoading = false
            } catch {
                isLoading = false
                alertErrorVerificationCode.toggle()
            }
        }
    }
}

struct SignInCodeVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        SignInCodeVerificationView(phoneNumber: "202-280-3866")
            .environmentObject(FirebaseAuthViewModel())
    }
}
