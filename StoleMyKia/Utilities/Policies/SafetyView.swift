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
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 25)
                    VStack(spacing: 50) {
                        VStack(spacing: 10) {
                            Image(systemName: "checkerboard.shield")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 55, height: 55)
                                .foregroundColor(.green)
                            Text("Be Safe")
                                .font(.system(size: 21).weight(.heavy))
                        }
                        Text("Safety comes first when using \(UIApplication.appName ?? "this application")! Please read through how you can stay safe whilst using this application:")
                            .multilineTextAlignment(.center)
                        
                        HStack {
                            VStack(spacing: 40) {
                                titleBodyLabel("1) Do not use this application whilst driving.", body: "If you are in the event of an emergency with a vehicle, safely pull over your vehicle and operate as such.")
                                titleBodyLabel("3) Never approach a potentially dangerous situation.", body: "If you believe someone is attempting to break in or steal a vehicle, do not approach or engage with the individual. Stay a safe distance and contact local authorities.")
                            }
                            Spacer()
                        }
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    func titleBodyLabel(_ title: String, body: String) -> some View {
        HStack {
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
}

#Preview {
    SafetyView()
}
