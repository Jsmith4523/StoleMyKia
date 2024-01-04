//
//  ReportComposeVehicleYearView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/4/24.
//

import SwiftUI

struct ReportComposeVehicleYearView: View {
    
    @EnvironmentObject var composeVM: ReportComposeViewModel
    
    var body: some View {
        Form {
            ForEach(composeVM.vehicleModel.year.reversed(), id: \.self) { year in
                vehicleYearCellView(year)
                    .onTapGesture {
                        composeVM.vehicleYear = year
                    }
            }
        }
        .navigationTitle("\(composeVM.vehicleModel.rawValue)")
    }
    
    func vehicleYearCellView(_ year: Int) -> some View {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ""
        
        let numberString = numberFormatter.string(from: NSNumber(value: year)) ?? "\(year)"
        
        return HStack {
            Text(numberString)
                .font(.system(size: 20).bold())
            Spacer()
            if composeVM.vehicleYear == year {
                Image.greenCheckMark
            }
        }
        .padding(10)
    }
}

#Preview {
    NavigationStack {
        ReportComposeVehicleYearView()
            .environmentObject(ReportComposeViewModel())
    }
}
