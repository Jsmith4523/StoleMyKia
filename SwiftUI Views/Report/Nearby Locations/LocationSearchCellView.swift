//
//  LocationSearchCellView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/23/23.
//

import SwiftUI

struct LocationSearchCellView: View {
        
    let location: Location
    var isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(location.name ?? "")
                    .font(.system(size: 16).bold())
                Text(location.address ?? "")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                Text(location.distanceFromUser)
                    .font(.system(size: 13.75))
                    .foregroundColor(.gray)
                if isSelected {
                    Text("Selected")
                        .font(.system(size: 13).bold())
                        .foregroundColor(.green)
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            
        }
    }
}
//
//#Preview {
//    LocationSearchCellView(location: , isSelected: <#Bool#>)
//}
