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
            .sheet(isPresented: $reportsVM.isShowingLicensePlateScannerView) {
                LicensePlateScannerView()
                    .environmentObject(reportsVM)
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(ReportsViewModel())
            .environmentObject(UserViewModel())
    }
}
