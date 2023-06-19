//
//  UserAccountSettings.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/19/23.
//

import SwiftUI

struct UserAccountSettings: View {
    
    @EnvironmentObject var userModel: UserViewModel
    
    var body: some View {
        Form {
            Section {
                LabeledContent("Member Since", value: userModel.getUserDisplayName())
                LabeledContent("Phone Number", value: userModel.accountPhoneNumber())
                LabeledContent("My Vehicle", value: userModel.userPersonalVehicle())
            } header: {
                Text("Details")
            } footer: {
                Text("Details such as your phone number cannot be changed for security purposes. If you want to use a new phone number, you must create a new account. You cannot create a new account with a existing phone number.")
            }
            
            Button {
                
            } label: {
                Label("Sign out", systemImage: "door.right.hand.open")
            }
            
            Section {
                Button(role: .destructive) {
                    
                } label: {
                    Label("Delete Account", systemImage: "trash")
                        .foregroundColor(.red)
                }
            } header: {
                Text("Permanent Decision")
            } footer: {
                Text("Once you delete your account, this change CANNOT be reversed. All of your reports, updates, and bookmarks will be permanently deleted as well.")
            }
        }
        .navigationBarTitle("Account")
    }
}

struct UserAccountSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserAccountSettings()
                .environmentObject(UserViewModel())
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
