//
//  VehicleImageView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/1/23.
//

import SwiftUI

struct VehicleImageView: View {
    
    let vehicleImage: UIImage?
    
    @State private var isShowingActivityController = false
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        CustomNavView(title: "2017 Hyundai Elantra", statusBarColor: .lightContent, backgroundColor: .black) {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    Spacer()
                    Image(uiImage: vehicleImage ?? .vehiclePlaceholder)
                        .resizable()
                        .scaledToFit()
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !(vehicleImage == nil) {
                        Button {
                            isShowingActivityController.toggle()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .tint(.white)
            .sheet(isPresented: $isShowingActivityController) {
                ActivityController(items: [vehicleImage!])
            }
        }
        .ignoresSafeArea()
    }
}

struct VehicleImageView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleImageView(vehicleImage: .vehiclePlaceholder)
    }
}
