//
//  OnboardingFinalView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/30/23.
//

import SwiftUI

struct OnboardingFinalView: View {
    
    enum FinalStepMode: Identifiable, CaseIterable {
        
        var id: Self { return self }
        
        case safetyView, instructionsView
        
        var title: String {
            switch self {
            case .safetyView:
                return "Safety"
            case .instructionsView:
                return "How It Works"
            }
        }
    }
    
    @State private var didReadSafety = false
    @State private var didReadHowTo = false
    @State private var finalStepMode: FinalStepMode?
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 85)
            VStack(spacing: 10) {
                Image(systemName: "book")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                Text("Last Step")
                    .font(.system(size: 25).weight(.heavy))
                Text("Before continuing, make sure to read over how to use the application safely and responsibly.")
                    .font(.system(size: 17))
            }
            Spacer()
            VStack {
                ForEach(FinalStepMode.allCases) { mode in
                    Button {
                        self.finalStepMode = mode
                    } label: {
                        Text(mode.title)
                            .authButtonStyle(background: .blue)
                    }
                }
            }
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .multilineTextAlignment(.center)
        .padding()
        .fullScreenCover(item: $finalStepMode) { mode in
            ZStack {
                switch mode {
                case .instructionsView:
                    OnboardingInstructionsView()
                        .onDisappear {
                            didReadHowTo.toggle()
                        }
                case .safetyView:
                    SafetyView()
                        .onDisappear {
                            didReadSafety.toggle()
                        }
                }
            }
        }
        .toolbar {
            if (didReadSafety && didReadHowTo) {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingFinalView()
    }
}
