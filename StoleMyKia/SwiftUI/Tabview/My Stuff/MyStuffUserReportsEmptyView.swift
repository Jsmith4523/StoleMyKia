//
//  ReportsEmptyView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/20/23.
//

import SwiftUI

struct MyStuffUserReportsEmptyView: View {
    
    enum MyStuffSelection {
        case myReports, bookmarks
        
        var symbol: String {
            switch self {
            case .myReports:
                return MyStuffView.MyStuffRoute.reports.symbol
            case .bookmarks:
                return MyStuffView.MyStuffRoute.bookmarks.symbol
            }
        }
        
        var description: String {
            switch self {
            case .myReports:
                return "Reports that you submit will appear here."
            case .bookmarks:
                return "Reports that you bookmark will appear here."
            }
        }
    }
    
    let selection: MyStuffSelection
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 250)
            VStack(spacing: 15) {
                Image(systemName: selection.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text(selection.description)
                    .font(.system(size: 20).weight(.bold))
            }
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

#Preview {
    MyStuffUserReportsEmptyView(selection: .myReports)
}
