//
//  UserReportsSkeletonView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/20/23.
//

import SwiftUI

struct UserReportsSkeletonView: View {
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0...10, id: \.self) { _ in
                    userReportSkeletonCellView()
                    Divider()
                }
            }
        }
    }
    
    
    @ViewBuilder
    func userReportSkeletonCellView() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("                     ")
                    .font(.system(size: 19))
                VStack(alignment: .leading, spacing: 2) {
                    Text("                   ")
                        .font(.system(size: 19).weight(.heavy))
                    HStack {
                        Text("             ")
                    }
                    .font(.system(size: 15))
                    Text("                  ")
                        .font(.system(size: 15.75))
                        .foregroundColor(.gray)
                    HStack(spacing: 4) {
                        Text("         ")
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                }
            }
            Spacer()
            Image(uiImage: .vehiclePlaceholder)
                .resizable()
                .scaledToFill()
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .redacted(reason: .placeholder)
        .multilineTextAlignment(.leading)
        .padding()
    }
}

#Preview {
    UserReportsSkeletonView()
}
