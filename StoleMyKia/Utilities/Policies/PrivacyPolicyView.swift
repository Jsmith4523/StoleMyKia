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
        SafariView(url: URL(string: "https://www.google.com")!)
            .edgesIgnoringSafeArea(.bottom)
    }
}
