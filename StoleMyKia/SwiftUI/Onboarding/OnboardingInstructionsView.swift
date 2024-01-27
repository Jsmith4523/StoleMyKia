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
                .frame(height: 30)
            ScrollView {
                VStack(spacing: 55) {
                    VStack {
                        Spacer()
                            .frame(height: 85)
                        VStack(spacing: 50) {
                            VStack {
                                Text("How \(UIApplication.appName ?? "It all") works!")
                                    .font(.system(size: 25).weight(.heavy))
                            }
                            VStack(spacing: 30) {
                                titleBodyLabel("Reports", body: "When creating a report, you can include essential information about your report such as its type, details, vehicle information (license plate no., VIN, etc.), location, and more.", symbol: String.reportSymbolName)
                                titleBodyLabel("Updates", body: "If someone happens to locate your vehicle based upon your initial report, they can update it. An update is a report that contains the latest whereabouts of the vehicle you reported.", symbol: String.updateSymbolName)
                                titleBodyLabel("Notifications", body: "You'll receive immediate notifications regarding updates to reports you've uploaded. You can also customize what push notifications you would like to receive regarding reports happening in your desired location.", symbol: "antenna.radiowaves.left.and.right")
                                titleBodyLabel("Timeline Map", body: "The map graphically displays location information about the initial report and any associated updates (if available).", symbol: "map")
                                titleBodyLabel("Critical Alerts", body: "Critical alerts are only sent when updates are made to your initial report. If enabled, this setting overrides focus modes and other mute settings.", symbol: "exclamationmark.triangle.fill", symbolForegroundColor: .red)
                            }
                        }
                    }
                    VStack(spacing: 25) {
                        legalPrompt()
                            .font(.system(size: 15))
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
