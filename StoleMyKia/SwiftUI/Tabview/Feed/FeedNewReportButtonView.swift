//
//  FeedNewReportButtonView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/25/23.
//

import SwiftUI

struct FeedNewReportButtonView: View {
    
    var backgroundColor: Color = .brand
    
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
                        .background(backgroundColor)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .padding()
                }
            }
            .sheet(isPresented: $isShowingNewReportView) {
                ReportComposeReportTypeView(isPresented: $isShowingNewReportView)
                    .environmentObject(reportsVM)
                    .environmentObject(userVM)
                    .environmentObject(ReportComposeViewModel())
            }
        }
    }
}

#Preview {
    FeedNewReportButtonView()
        .environmentObject(UserViewModel())
        .environmentObject(ReportsViewModel())
}
