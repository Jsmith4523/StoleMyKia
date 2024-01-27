//
//  SignInCodeVerificationView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/4/23.
//

import SwiftUI

struct SignInCodeVerificationView: View {
    
    private enum AlertReason {
        case verificationError
        case userBanned
        case userDisabled
        
        var title: String {
            switch self {
            case .verificationError:
                return "Verification Error"
            case .userBanned:
                return "You have been BANNED!👨🏽‍⚖️"
            case .userDisabled:
                return "Your account is disabled"
            }
        }
        
        var description: String {
            switch self {
            case .verificationError:
                return "Ensure that your verification code is correct and try again. If this issue persist, contact support."
            case .userBanned:
                return "Your account is permanently banned due to breaking one or more app guidelines. If you think this is an error, please contact support."
            case .userDisabled:
                return "Your account is currently disabled. If you think this is an error, please contact support."
            }
        }
    }
    
    @State private var isShowingEmailComposeView = false
    
    @State private var isLoading = false
    @State private var alertErrorResendingVerificationCode = false
    @State private var verificationCode = ""
    
    @State private var alertReason: AlertReason = .verificationError
    @State private var alertErrorVerificationCode = false
    
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
        .alert(alertReason.title, isPresented: $alertErrorVerificationCode) {
            Button("OK") {}
            //FIXME: Resending verification code does not work
//            if alertReason == .verificationError {
//                Button("Resend Code") { resendVerificationCode() }
//            }
            Button("Contact Support") { isShowingEmailComposeView.toggle() }
                .canSendEmail()
        } message: {
            Text(alertReason.description)
        }
        .alert("Unable to resend verification code", isPresented: $alertErrorResendingVerificationCode) {
            Button("OK") {}
        } message: {
            Text("An issue occurred resending a new verification code. Please try again later.")
        }
        .emailComposerView(isPresented: $isShowingEmailComposeView, composeMode: .issue)
    }
    
    private func beginVerifyingSmsCode() {
        Task {
            isLoading = true
            do {
                try await firebaseAuthVM.verifyCode(verificationCode, phoneNumber: phoneNumber)
                self.isLoading = false
            } catch let error as FirebaseAuthManager.FirebaseAuthManagerError {
                isLoading = false
                switch error {
                case .userBanned:
                    alertReason = .userBanned
                case .userDisabled:
                    alertReason = .userDisabled
                default:
                    alertReason = .verificationError
                }
                alertErrorVerificationCode.toggle()
            }
            catch {
                DispatchQueue.main.async {
                    isLoading = false
                    alertReason = .verificationError
                    alertErrorVerificationCode.toggle()
                }
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
