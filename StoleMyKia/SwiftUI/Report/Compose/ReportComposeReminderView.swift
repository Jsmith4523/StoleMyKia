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
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 25)
                    VStack(spacing: 45) {
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.orange)
                            Text("Please Read Before You Post!")
                                .font(.system(size: 25).bold())
                        }
                        VStack(alignment: .leading, spacing: 15) {
                            bulletPoint("In the event of an emergency, before uploading this report, contact local authorities or 9-1-1. Local authorities do not actively monitor this application for reports.")
                            bulletPoint("If enabled, your exact location will be included with this report; and is visible to anyone viewing this report. Please be sure you want to include it.")
                            bulletPoint("We cannot guarantee that your vehicle will be safely recovered. We are not responsible for the loss or damages made to your vehicle.")
                            bulletPoint("If enabled, your exact location will be included with this report. Please ensure you want to include it.")
                        }
                        VStack {
                            Button {
                              postCompletion?()
                              dismiss()
                            } label: {
                                Text("Proceed")
                                    .authButtonStyle(background: .orange)
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
                .multilineTextAlignment(.center)
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
            Image(systemName: "circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
                .padding(.trailing, 5)
            Text(text)
                .font(.system(size: 17))
        }
        .multilineTextAlignment(.leading)
    }
}

#Preview {
    ReportComposeReminderView()
}
