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
        VStack {
            Color(uiColor: .systemBackground)
                .frame(height: 50)
            ScrollView {
                VStack(spacing: 75) {
                    VStack {
                        Spacer()
                            .frame(height: 85)
                        VStack(spacing: 50) {
                            Text("How the application works!")
                                .font(.system(size: 30).weight(.heavy))
                            VStack(spacing: 30) {
                                titleBodyLabel("Reports", body: "You can include essential information about your report, such as its type, details, vehicle information (license number, VIN, etc.), location, and more.", symbol: String.reportSymbolName)
                                titleBodyLabel("Notifications", body: "When posting a report or update, users subscribed to the report type within your device's current location will receive notifications, and vice versa. \(UIApplication.appName ?? "The application") may use location services in order to tailor notifications on reports that are made less than two mile of your desired and current location. These notifications will only override certain device mute settings.", symbol: "antenna.radiowaves.left.and.right")
                                titleBodyLabel("Updates", body: "You'll receive notifications if someone updates an initial report you uploaded. An update may include information such as the incident type, details, location, and more.", symbol: String.updateSymbolName)
                                titleBodyLabel("Timeline Map", body: "The map graphically displays location information about the initial report and any associated updates (if available).", symbol: "map")
                                titleBodyLabel("Critical Alerts", body: "Critical alerts are only sent when updates are made to your initial report. If enabled, this setting overrides focus modes and other mute settings.", symbol: "exclamationmark.triangle.fill", symbolForegroundColor: .red)
                            }
                        }
                    }
                    VStack(spacing: 25) {
                        legalPrompt()
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .authButtonStyle()
                        }
                    }
                }
                .padding()
            }
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
