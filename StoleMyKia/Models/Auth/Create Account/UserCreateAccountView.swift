//
//  UserCreateAccountView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/25/23.
//

import SwiftUI

struct UserCreateAccountView: View {
    
    @State private var email = ""
    @State private var password = ""

    @ObservedObject var loginModel: LoginViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: 100)
                Text("Enter Your Information")
                    .customTitleStyle()
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct UserCreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserCreateAccountView(loginModel: LoginViewModel())
        }
    }
}
