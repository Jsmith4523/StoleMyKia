//
//  ApplicationAuthView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/17/23.
//

import SwiftUI

struct ApplicationAuthView: View {
    
    @State private var isShowingCreateAccountView = false
    @State private var phoneNumber = ""
    
    @EnvironmentObject var firebaseAuthVM: FirebaseAuthViewModel
    
    var body: some View {
        HostingView(statusBarStyle: .lightContent) {
            NavigationView {
                ZStack {
                    Color("auth-background").ignoresSafeArea()
                    VStack {
                        Spacer()
                        VStack {
                            Button {
                                isShowingCreateAccountView.toggle()
                            } label: {
                                Text("Create Account")
                                    .authViewButtonStyle(backgroundColor: .gray.opacity(0.20), foregroundColor: .white)
                            }
                            NavigationLink {
                                
                            } label: {
                                Text("Login")
                                    .authViewButtonStyle(backgroundColor: .white, foregroundColor: .black)
                            }
                        }
                    }
                    .padding()
                }
            }
            .customSheetView(isPresented: $isShowingCreateAccountView, detents: [.large()], cornerRadius: 25) {
                
            }
        }
        .ignoresSafeArea()
    }
}

private extension Text {
    
    func authViewButtonStyle(backgroundColor: Color, foregroundColor: Color = .black) -> some View {
        return self
            .font(.system(size: 16).bold())
            .foregroundColor(foregroundColor)
            .padding(17)
            .frame(width: 315)
            .background(backgroundColor)
            .cornerRadius(15)
            .shadow(radius: 0.5)
    }
}


struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationAuthView()
            .environmentObject(FirebaseAuthViewModel())
    }
}

//#Preview {
//    ApplicationAuthView()
//}
