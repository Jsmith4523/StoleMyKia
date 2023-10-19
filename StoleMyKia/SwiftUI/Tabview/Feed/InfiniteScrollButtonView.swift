//
//  InfiniteScrollButtonView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/17/23.
//

import SwiftUI

struct InfiniteScrollButtonView: View {
    
    @State private var infiniteScrollStatus: InfiniteScrollStatus = .error
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        ZStack {
            Text(infiniteScrollStatus.title)
                .font(.system(size: 20).bold())
                .foregroundColor(Color(uiColor: .systemBackground))
                .padding(10)
                .background(Color(uiColor: .label))
                .clipShape(RoundedRectangle(cornerRadius: 13))
                .padding()
        }
        .onReceive(reportsVM.$infiniteScrollStatus) { status in
            DispatchQueue.main.async {
                self.infiniteScrollStatus = status
            }
        }
    }
}
//
//#Preview {
//    InfiniteScrollButtonView()
//        .environmentObject(ReportsViewModel())
//}
