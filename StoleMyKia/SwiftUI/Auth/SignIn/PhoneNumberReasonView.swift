//
//  PhoneNumberReasonView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/12/23.
//

import SwiftUI

struct PhoneNumberReasonView: View {
    var body: some View {
        NavigationView {
            HostingView(statusBarStyle: .lightContent) {
                VStack(spacing: 15) {
                    Text("Why must I provide my phone number?")
                        .font(.system(size: 21).bold())
                    Text("Your phone number is used to securly monitor users")
                }
                .multilineTextAlignment(.center)
                .padding()
            }
        }
    }
}

struct PhoneNumberReasonView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhoneNumberReasonView()
        }
    }
}
