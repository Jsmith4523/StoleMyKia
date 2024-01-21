//
//  SafetyView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/18/23.
//

import SwiftUI

struct SafetyView: View {
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Color(uiColor: .systemBackground)
                    .frame(height: 20)
                ScrollView {
                    VStack {
                        Spacer()
                            .frame(height: 25)
                        VStack(spacing: 35) {
                            VStack(spacing: 10) {
                                Image(systemName: "checkerboard.shield")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 55, height: 55)
                                    .foregroundColor(.green)
                                Text("Be Safe")
                                    .font(.system(size: 21).weight(.heavy))
                            }
                            Text("Safety comes first when using \(UIApplication.appName ?? "this application")! Please read through how you can stay safe when using this application:")
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                VStack(spacing: 40) {
                                    titleBodyLabel("Local Authorities do not actively monitor this application.", body: "If the event of an emergency, your report will not be sent to any authority. We advise that you contact authorities before using this application.")
                                    titleBodyLabel("Do not use this application whilst driving.", body: "If you are in the event of an emergency with a vehicle, safely pull over, and report the vehicle.")
                                    titleBodyLabel("Never approach a potentially dangerous situation.", body: "If you believe someone is attempting to break in or steal a vehicle, or see a vehicle traveling, never approach or engage with the individual(s). Stay a safe distance and contact local authorities before using this application.")
                                    titleBodyLabel("Never visit a location alone.", body: "If you are deciding to travel to the location of a report, proceed with caution. We advise that you inform local authorities of your visit or travel with an additional person to the location.")
                                    titleBodyLabel("Remember, you are anonymous.", body: "Other users cannot see any personal information besides your included phone number within a report you made (if enabled). Try to limit the amount of personal information within your reports.")
                                }
                                Spacer()
                            }
                        }
                        Spacer()
                            .frame(height: 50)
                        VStack(spacing: 25) {
                            legalPrompt()
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                                    .authButtonStyle(background: .green)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    SafetyView()
}
