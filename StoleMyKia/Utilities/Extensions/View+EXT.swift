//
//  View+EXT.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 3/15/23.
//

import Foundation
import SwiftUI
import UIKit

extension UINavigationController {
    
    open override func viewWillLayoutSubviews() {
        //Customizing UINavigationBar back button
        super.viewDidLayoutSubviews()
        self.navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}

extension Text {
    
    func customTitleStyle() -> some View {
        return self
            .font(.system(size: 32).bold())
            .multilineTextAlignment(.center)
    }
    
    func customSubtitleStyle() -> some View {
        return self
            .font(.system(size: 16))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
    }
}

extension View {
    
    func hideNavigationTitle() -> some View {
        return self
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("")
                }
            }
    }
    
    func loginTextFieldStyle() -> some View {
        return self
            .padding()
            .background(Color(uiColor: .systemBackground))
            .overlay {
                Rectangle()
                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
            }
    }
    
    //TODO: Crete privacy policy
    func privacyPolicy(isPresented: Binding<Bool>) -> some View {
        return self
            .safari(isPresented: isPresented, url: URL(string: "https://www.google.com")!)
    }
    
    func twitterSupport(isPresented: Binding<Bool>) -> some View {
        return self
            .safari(isPresented: isPresented, url: URL.twitterSupportURL)
    }
}
