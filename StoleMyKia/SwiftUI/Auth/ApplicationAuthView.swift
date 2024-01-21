//
//  ApplicationAuthView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/17/23.
//

import SwiftUI
import MessageUI

enum ApplicationPolicyViewMode: CaseIterable, Identifiable {
    
    var id: Self { self }
    
    case safety, privacyPolicy, termsOfUse, disclaimer
}

struct ApplicationAuthView: View {
    
    @State private var policyViewMode: ApplicationPolicyViewMode?
    
    @State private var isShowingEmailComposeView = false
            
    @EnvironmentObject var firebaseAuthVM: FirebaseAuthViewModel
    @Environment (\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
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
                            Text("Join")
                                .authButtonStyle()
                        }
                        Spacer()
                            .frame(height: 10)
                        VStack(spacing: 15) {
                            HStack {
                                HStack {
                                    Button {
                                        isShowingEmailComposeView.toggle()
                                    } label: {
                                        Text("Need Help?")
                                    }
                                    Capsule()
                                        .frame(width: 0.65, height: 15)
                                }
                                .canSendEmail()
                            
                                Button {
                                    self.policyViewMode = .safety
                                } label: {
                                    Label("Safety", systemImage: "shield")
                                }
                                Capsule()
                                    .frame(width: 0.65, height: 15)
                                Menu {
                                    Button {
                                        self.policyViewMode = .privacyPolicy
                                    } label: {
                                        Text("Privacy Policy")
                                    }
                                    Button {
                                        self.policyViewMode = .termsOfUse
                                    } label: {
                                        Text("Terms of Use")
                                    }
                                    Button {
                                        self.policyViewMode = .disclaimer
                                    } label: {
                                        Text("Disclaimers")
                                    }
                                } label: {
                                    Text("Legal and Policy")
                                }
                            }
                            if let applicationVersion = UIApplication.appVersion {
                                Text("Version \(applicationVersion)")
                            }
                        }
                        .font(.system(size: 13))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            .navigationTitle("Start")
            .navigationBarTitleDisplayMode(.inline)
            .emailComposerView(isPresented: $isShowingEmailComposeView)
            .hideNavigationTitle()
            .fullScreenCover(item: self.$policyViewMode) { mode in
                switch mode {
                case .privacyPolicy:
                    PrivacyPolicyView()
                        .ignoresSafeArea()
                case .safety:
                    SafetyView()
                case .termsOfUse:
                    TermsOfServiceView()
                        .ignoresSafeArea()
                case .disclaimer:
                    DisclaimerView()
                        .ignoresSafeArea()
                }
            }
        }
        .multilineTextAlignment(.center)
        .tint(Color(uiColor: .label))
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
