//
//  TimelineMapListSkeletonView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/13/23.
//

import SwiftUI

struct TimelineMapListSkeletonView: View {
    var body: some View {
        VStack {
            ForEach(0...5, id: \.self) { _ in
                TimelineMapSkeletonCellView()
                Divider()
            }
        }
    }
}

fileprivate struct TimelineMapSkeletonCellView: View {
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("          ")
                    .font(.system(size: 16))
                Text("                                       ")
                    .font(.system(size: 18))
                Text("         ")
                    .font(.system(size: 14))
            }
            Spacer()
        }
        .redacted(reason: .placeholder)
        .padding(.horizontal)
    }
}

//#Preview {
//    TimelineMapListSkeletonView()
//}
