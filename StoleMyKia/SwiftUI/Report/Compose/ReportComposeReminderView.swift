//
//  NewReportReminderView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/21/23.
//

import SwiftUI

struct ReportComposeReminderView: View {
    
    var postCompletion: (()->())? = nil
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                VStack {
                    VStack(spacing: 45) {
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.orange)
                            Text("Before You Post...")
                                .font(.system(size: 25).weight(.heavy))
                        }
                        VStack(alignment: .leading, spacing: 15) {
                            bulletPoint("In the event of an emergency, before uploading this report, contact your local authorities and inform them of your situation. Emergency personnel do not actively monitor reports within this application.")
                            bulletPoint("Your device's current location will be tied with this report; and can be disclosed for privacy. Please ensure you are comfortable including your device's location.")
                            bulletPoint("The '\(UIApplication.appName ?? "application")' team is not responsible for any loss, damages, accidents, or any other unfortunate events involving persons and/or vehicles.")
                            bulletPoint("Uploading this report does not guarantee the vehicle you're reporting will be safely recovered; or would you receive phone calls and/or updates regarding your report (if enabled).")
                            bulletPoint(" If your report appears to be false or breaks other app guidelines, the '\(UIApplication.appName ?? "application")' team will evaluate and determine if such. Based upon our investigation, your account will be subject to a ban if required.")
                        }
                    }
                }
                .padding()
                .multilineTextAlignment(.center)
                
                Section {
                    Button {
                        confirm()
                    } label: {
                        HStack {
                            Spacer()
                            Text("I Agree")
                                .foregroundColor(.orange)
                                .font(.system(size: 22).weight(.medium))
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
        .onAppear {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }
    
    @ViewBuilder
    func bulletPoint(_ text: String) -> some View {
        HStack {
            Text("- \(text)")
                .font(.system(size: 15).weight(.medium))
        }
        .multilineTextAlignment(.leading)
    }
    
    private func confirm() {
        if let postCompletion {
            postCompletion()
            dismiss()
        }
    }
}

#Preview {
    ReportComposeReminderView()
}
