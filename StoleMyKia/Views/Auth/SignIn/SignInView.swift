//
//  SignInView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/12/23.
//

import SwiftUI

struct SignInView: View {
        
    @State private var phoneNumber = ""
    
    @FocusState private var isFocusedOnPhoneNumber: Bool
    
    @EnvironmentObject var userModel: UserViewModel
    
    var body: some View {
        NavigationView {
            HostingView(statusBarStyle: .lightContent) {
                ZStack(alignment: .center) {
                    Color.brand.ignoresSafeArea()
                    VStack(spacing: 75) {
                        Spacer()
                            .frame(height: 60)
                        Image(systemName: "car")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                        VStack(spacing: 15) {
                            TextField(text: $phoneNumber) {
                                Text("Enter Phone Number")
                                    .foregroundColor(.white)
                            }
                            .phoneNumberTextField()
                            .keyboardType(.numberPad)
                            NavigationLink {
                                
                            } label: {
                                Text("Text Me")
                                    .loginViewButtonStyle()
                            }
                        }
                        Spacer()
                        HStack {
                            Button {
                                
                            } label: {
                                Text("New Account")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .frame(width: 350)
                    .padding()
                }
            }
            .ignoresSafeArea()
            .tint(.white)
        }
    }
}

private extension Text {
    
    func loginViewButtonStyle() -> some View {
        return self
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .foregroundColor(.brand)
            .font(.system(size: 17).bold())
            .clipShape(Capsule())
    }
}

private extension TextField {
    
    func phoneNumberTextField() -> some View {
        return self
            .foregroundColor(.white)
            .font(.system(size: 16))
            .padding()
            .background(Color.gray.opacity(0.2))
            .clipShape(Capsule())
            
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(UserViewModel())
    }
}
