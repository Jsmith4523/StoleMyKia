//
//  FeedNewReportButtonView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/25/23.
//

import SwiftUI

struct FeedNewReportButtonView: View {
    
    @State private var isShowingNewReportView = false
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Button {
                    isShowingNewReportView.toggle()
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .padding()
                        .background(Color.brand)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .padding()
                }
            }
            .sheet(isPresented: $isShowingNewReportView) {
                NewReportView()
                    .environmentObject(reportsVM)
                    .environmentObject(userVM)
            }
        }
    }
}

#Preview {
    FeedNewReportButtonView()
        .environmentObject(UserViewModel())
        .environmentObject(ReportsViewModel())
}
