//
//  ReportComposeVehicleColorView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/4/24.
//

import SwiftUI

struct ReportComposeVehicleColorView: View {
    
    @EnvironmentObject var composeVM: ReportComposeViewModel
    
    var body: some View {
        Form {
            ForEach(VehicleColor.allCases.sorted(by: <)) { color in
                vehicleColorCellView(color)
                    .onTapGesture {
                        self.composeVM.vehicleColor = color
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
            }
        }
        .navigationTitle("Vehicle Color")
        .toolbar {
            NavigationLink("Next") {
                ReportComposeVehicleModelView()
                    .environmentObject(composeVM)
            }
        }
    }
    
    @ViewBuilder
    private func vehicleColorCellView(_ color: VehicleColor) -> some View {
        HStack {
            color.color
                .frame(width: 25, height: 25)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(.gray, lineWidth: 0.25)
                }
            Text(color.rawValue)
                .font(.system(size: 20).bold())
            Spacer()
            if composeVM.vehicleColor == color {
                Image.greenCheckMark
            }
        }
        .padding(10)
    }
}

#Preview {
    ReportComposeVehicleColorView()
        .environmentObject(ReportComposeViewModel())
}
