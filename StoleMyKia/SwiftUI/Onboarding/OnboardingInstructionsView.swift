//
//  OnboardingInstructionsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/19/23.
//

import SwiftUI

struct OnboardingInstructionsView: View {
        
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 75) {
                VStack {
                    Spacer()
                        .frame(height: 85)
                    VStack(spacing: 50) {
                        Text("How the application works!")
                            .font(.system(size: 30).weight(.heavy))
                        VStack(spacing: 30) {
                            titleBodyLabel("Reports", body: "Each report offers vital details about the vehicle incident, including vehicle identification (make, model, color, license plate, and VIN), incident type (e.g., stolen, carjacking), and location information. Additional relevant details are also included for a comprehensive overview.", symbol: String.reportSymbolName)
                            titleBodyLabel("Updates", body: "If someone possesses information about a vehicle you've reported, they can contribute to your report by providing details such as the type of update, location, and additional information relevant to the update. This collaborative feature allows for more comprehensive reporting on the vehicle in question.", symbol: String.updateSymbolName)
                            titleBodyLabel("Timeline Map", body: "The timeline map visually illustrates the progression of updates to an initial report using an interactive graphical map interface. It includes annotations and circles (when location information is disclosed) to indicate the geographical context of each update, whether it pertains to the initial report or a subsequent event.", symbol: "map")
                            titleBodyLabel("Notifications", body: "Your notification settings dictate that you will receive notifications for reports within your specified notification radius. These notifications are limited to reports you've subscribed to.", symbol: "app.badge")
                            titleBodyLabel("Critical Notifications", body: "Critical notifications will be sent only when your report receives updates.", symbol: "exclamationmark.triangle.fill", symbolForegroundColor: .red)
                        }
                    }
                }
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .authButtonStyle()
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    NavigationView {
        OnboardingInstructionsView()
    }
}
