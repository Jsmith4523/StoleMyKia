//
//  ParkingMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/13/23.
//

import SwiftUI

struct ParkingMapView: View {
    
    @StateObject private var coordinator = ParkingMapViewCoordinator()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                ParkingMapViewRepresentable(coordinator: coordinator)
                    .ignoresSafeArea()
                headerButtons
            }
        }
    }
    
    private var headerButtons: some View {
        HStack {
            Button {
                
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding()
    }
}

struct ParkingMapView_Previews: PreviewProvider {
    static var previews: some View {
        ParkingMapView()
    }
}
