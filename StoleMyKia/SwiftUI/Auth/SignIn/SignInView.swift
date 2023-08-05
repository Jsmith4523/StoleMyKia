//
//  SignInView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/12/23.
//

import SwiftUI

struct SignInView: View {
        
    @State private var pushToVerificationCodeView = false
    @State private var isLoading = false
    
    @State private var phoneNumber = ""
        
    @EnvironmentObject var firebaseAuthVM: FirebaseAuthViewModel
    
    @FocusState var phoneNumberFocus: Bool
    
    private var isSatisfied: Bool {
        guard (phoneNumber.range(of: ".*[^0-9].*", options: .regularExpression) == nil), phoneNumber.count == 10 else { return false }
        return true
    }
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 65)
            VStack(spacing: 65) {
                VStack(spacing: 5) {
                    Spacer()
                        .frame(height: 5)
                    Text("Welcome Back!")
                        .font(.system(size: 27).weight(.heavy))
                    Text("Enter your phone number..")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                }
                TextField("Phone Number", text: $phoneNumber)
                    .authTextFieldStyle()
                    .focused($phoneNumberFocus)
                Spacer()
                if isSatisfied {
                    Button {
                        sendVerificationCode()
                    } label: {
                        Text("Send Code")
                            .authButtonStyle()
                    }
                }
                Spacer()
            }
            .padding()
            NavigationLink(isActive: $pushToVerificationCodeView) {
                SignInCodeVerificationView(phoneNumber: phoneNumber)
                    .environmentObject(firebaseAuthVM)
            } label: {}
                .disabled(true)
        }
        .navigationTitle("Phone Number")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("")
            }
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    phoneNumberFocus = false
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if isLoading {
                    ProgressView()
                }
            }
        }
    }
    
    func sendVerificationCode() {
        isLoading = true
        Task {
            do {
                guard let formattedPhoneNumber = ApplicationFormats.authPhoneNumberFormat(phoneNumber) else { return }
                try await firebaseAuthVM.authWithPhoneNumber(formattedPhoneNumber)
                isLoading = false
                pushToVerificationCodeView = true
            } catch {
                isLoading = false
                print(error.localizedDescription)
            }
        }
    }
}

extension View {
    
    func authTextFieldStyle() -> some View {
        return self
            .padding(15)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .keyboardType(.decimalPad)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignInView()
                .environmentObject(FirebaseAuthViewModel())
        }
    }
}
