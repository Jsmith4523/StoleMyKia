//
//  ApplicationAuthView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/17/23.
//

import SwiftUI

struct ApplicationAuthView: View {
    
    @State private var isShowingCreateAccountView = false
    
    @EnvironmentObject var firebaseAuthVM: FirebaseAuthViewModel
    
    @Environment (\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    VStack(spacing: 30) {
                        Image(systemName: "car.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 115, height: 115)
                            .foregroundColor(colorScheme == .light ? .brand : .white)
                        Text("Help your community!")
                            .font(.system(size: 19))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(spacing: 20) {
                        NavigationLink {
                            SignInView()
                                .environmentObject(firebaseAuthVM)
                        } label: {
                            Text("Sign In")
                                .authButtonStyle()
                        }
                        NavigationLink {
                            
                        } label: {
                            Text("Join")
                                .padding()
                                .frame(width: 310)
                                .font(.system(size: 22).weight(.heavy))
                                .foregroundColor(Color(uiColor: .label))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("")
                }
            }
        }
        .multilineTextAlignment(.center)
        .tint(Color(uiColor: .label))
        .customSheetView(isPresented: $isShowingCreateAccountView, detents: [.large()], cornerRadius: 25) {
            
        }

    }
}

extension Text {
    func authButtonStyle() -> some View {
        return self
            .padding()
            .frame(width: 310)
            .font(.system(size: 22).weight(.heavy))
            .background(Color.brand)
            .foregroundColor(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}


struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationAuthView()
            .environmentObject(FirebaseAuthViewModel())
            .preferredColorScheme(.dark)
    }
}

//#Preview {
//    ApplicationAuthView()
//}
