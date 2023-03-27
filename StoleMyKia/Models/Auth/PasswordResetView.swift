//
//  PasswordResetView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/26/23.
//

import SwiftUI

struct PasswordResetView: View {
    
    @ObservedObject var loginModel: LoginViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
            VStack {
                VStack {
                    Spacer()
                        .frame(height: 55)
                    Text("Forgot Password")
                        .font(.system(size: 32).bold())
                    Spacer()
                        .frame(height: 20)
                    Text("Please enter your email so we can verify who you are")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PasswordResetView(loginModel: LoginViewModel())
        }
    }
}
