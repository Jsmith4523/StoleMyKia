//
//  VehicleImageView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/22/23.
//

import SwiftUI

struct VehicleImageView: View {
    
    @State private var scaleFactor: CGFloat = 1.0
    @State private var location: CGPoint = CGPoint(x: 50, y: 50)
    @GestureState private var startLocation: CGPoint? = nil // 1
    
    @State private var proxyX: CGFloat = 0
    @State private var proxyY: CGFloat = 0
    
    @State private var isShowingImagePickerController = false
    
    @Binding var vehicleImage: UIImage?
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                activityController
                GeometryReader { proxy in
                    Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scaleFactor)
                        .position(location)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if scaleFactor > 1.0 {
                                        var newLocation = startLocation ?? location // 3
                                        newLocation.x += value.translation.width
                                        newLocation.y += value.translation.height
                                        self.location = newLocation
                                    }
                                }
                                .updating($startLocation) { (value, startLocation, transaction) in
                                    if scaleFactor > 1.0 {
                                        startLocation = startLocation ?? location // 2
                                    }
                                }
                            
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    if value > 1.0 && value <= 3.0  {
                                        self.scaleFactor = value
                                    }
                                }
                                .onEnded { value in
                                    if value <= 1.1 {
                                        resetGestures()
                                    }
                                }
                        )
                        .onAppear {
                            self.proxyX = proxy.size.width / 2
                            self.proxyY = proxy.size.height / 2
                            self.location = .init(x: proxy.size.width / 2, y: proxy.size.height / 2)
                        }
                }
                .frame(width: UIScreen.main.bounds.width)
            }
            .disabled(vehicleImage.isNil())
            .onChange(of: scaleFactor) { newValue in
                if newValue <= 1.0 {
                    resetGestures()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.system(size: 18).bold())
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                }
            }
            .onTapGesture(count: 2) {
                resetGestures()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var activityController: some View {
        ZStack {
            if !(vehicleImage.isNil()) {
                ZStack {
                    
                }
                .activityController(isPresented: $isShowingImagePickerController, activityItems: [UIImage.vehiclePlaceholder])
            }
        }
    }
    
    private func resetGestures() {
        withAnimation {
            scaleFactor = 1.0
            location = .init(x: proxyX, y: proxyY)
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

struct VehicleImageView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleImageView(vehicleImage: .constant(nil))
    }
}
