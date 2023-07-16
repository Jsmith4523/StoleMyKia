//
//  SearchView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/15/23.
//

import SwiftUI

struct SearchView: View {
        
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userModel: UserViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                
            }
            .navigationTitle(ApplicationTabViewSelection.search.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    reportsVM.isShowingLicensePlateScannerView.toggle()
                } label: {
                   Image(systemName: "camera")
                }
            }
            .fullScreenCover(isPresented: $reportsVM.isShowingLicensePlateScannerView) {
                LicensePlateScannerView()
                    .environmentObject(reportsVM)
            }
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(ReportsViewModel())
}
