//
//  NotificationSkeletonProgressView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/18/23.
//

import SwiftUI

struct NotificationSkeletonProgressView: View {
    var body: some View {
        VStack {
            ForEach(0...8, id: \.self) { _ in
                NotificationSkeletonProgressCellView()
            }
        }
    }
}

fileprivate struct NotificationSkeletonProgressCellView: View {
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("             ")
                    Text("                                                               ")
                }
            }
            Spacer()
        }
        .padding()
        .redacted(reason: .placeholder)
        .multilineTextAlignment(.leading)
    }
}


struct NotificationSkeletonProgressView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSkeletonProgressView()
    }
}
