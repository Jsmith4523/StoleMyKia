//
//  SkeletonLoadingListView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/5/23.
//

import SwiftUI

struct ReportsSkeletonLoadingListView: View {
    var body: some View {
        VStack {
            ForEach(0...6, id: \.self) { Int in
                SkeletonLoadingCellView()
            }
        }
    }
}

struct SkeletonLoadingListView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsSkeletonLoadingListView()
    }
}
