//
//  PrivacyPolicyView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/18/23.
//

import Foundation
import SwiftUI

struct PrivacyPolicyView: View {
    
    var body: some View {
        SafariView(url: .privacyPolicy)
            .edgesIgnoringSafeArea(.bottom)
    }
}

struct TermsOfServiceView: View {
    
    var body: some View {
        SafariView(url: .termsAndService)
            .edgesIgnoringSafeArea(.bottom)
    }
}

struct DisclaimerView: View {
    
    var body: some View {
        SafariView(url: .disclaimerUrl)
            .ignoresSafeArea()
    }
}
