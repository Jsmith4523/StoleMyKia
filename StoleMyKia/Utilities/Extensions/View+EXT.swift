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
    
    func infoHiddenLabel() -> some View {
        Label("Sensitive Information is abbreviated to others", systemImage: "info.circle")
            .font(.system(size: 16).weight(.medium))
            .foregroundColor(.blue)
    }
    
    func titleBodyLabel(_ title: String, body: String, symbol: String? = nil, symbolForegroundColor symbolColor: Color = Color(uiColor: .label)) -> some View {
        HStack {
            if let symbol {
                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(symbolColor)
                    .padding(.trailing, 10)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 18).weight(.heavy))
                Text(body)
                    .font(.system(size: 14.5))
            }
            .multilineTextAlignment(.leading)
            Spacer()
        }
    }
    
    func hideNavigationTitle() -> some View {
        return self
            .navigationBarTitleDisplayMode(.inline)
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
    
    func privacyPolicy(isPresented: Binding<Bool>) -> some View {
        return self
            .safari(isPresented: isPresented, url: URL.privacyPolicy)
    }
    
    func termsAndConditions(isPresented: Binding<Bool>) -> some View {
        return self
            .safari(isPresented: isPresented, url: URL.termsAndService)
    }
    
    func twitterSupport(isPresented: Binding<Bool>) -> some View {
        return self
            .safari(isPresented: isPresented, url: URL.twitterSupportURL)
    }
}
