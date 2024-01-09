//
//  SignInCodeVerificationView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/4/23.
//

import SwiftUI

struct SignInCodeVerificationView: View {
    
    @State private var isShowingEmailComposeView = false
    
    @State private var isLoading = false
    @State private var alertErrorResendingVerificationCode = false
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
                    Text("We just sent a verification code to \(ApplicationFormats.authPhoneNumberFormat(phoneNumber, parentheses: true) ?? "the provided phone number"). Check your messages")
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
        .alert("Verification Error", isPresented: $alertErrorVerificationCode) {
            Button("OK") {}
            Button("Resend Code") { resendVerificationCode() }
            Button("Contact Support") { isShowingEmailComposeView.toggle() }
                .canSendEmail()
        } message: {
            Text("Ensure that your verification is correct and try again. If this issue persist, contact support and try again.")
        }
        .alert("Unable to resend verification code", isPresented: $alertErrorResendingVerificationCode) {
            Button("OK") {}
        } message: {
            Text("An issue occurred resending your verification code. Please try again later")
        }
        .emailComposerView(isPresented: $isShowingEmailComposeView, composeMode: .issue)
    }
    
    private func beginVerifyingSmsCode() {
        Task {
            isLoading = true
            do {
                try await firebaseAuthVM.verifyCode(verificationCode, phoneNumber: phoneNumber)
                self.isLoading = false
            } catch {
                isLoading = false
                alertErrorVerificationCode.toggle()
            }
        }
    }
    
    private func resendVerificationCode() {
        Task {
            do {
                isLoading = true
                try await firebaseAuthVM.authWithPhoneNumber(phoneNumber)
                self.isLoading = false
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                self.alertErrorResendingVerificationCode = true
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                isLoading = false
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
