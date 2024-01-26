//
//  VehicleImageView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/22/23.
//

import SwiftUI

struct VehicleImageView: View {
    
    @State private var amount: CGFloat = 0.0
    
    @State private var isShowingActivityController = false
    
    @Binding var vehicleImage: UIImage?
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                activityController
                Color.black.ignoresSafeArea()
                VStack {
                    Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1 + amount)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    if (value - 1) > 0 {
                                        amount = value - 1
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.spring) {
                                        amount = 0
                                    }
                                }
                        )
                }
                .frame(width: UIScreen.main.bounds.width)
            }
            .disabled(vehicleImage.isNil())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingActivityController.toggle()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                    .disabled(vehicleImage.isNil())
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var activityController: some View {
        ZStack {
            if let vehicleImage {
                ZStack {
                    
                }
                .activityController(isPresented: $isShowingActivityController, activityItems: [vehicleImage])
            }
        }
    }
}

struct VehicleImageView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleImageView(vehicleImage: .constant(.vehiclePlaceholder))
    }
}
