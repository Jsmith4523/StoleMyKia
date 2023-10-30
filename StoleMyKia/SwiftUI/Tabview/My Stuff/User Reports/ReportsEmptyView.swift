//
//  ReportsEmptyView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/20/23.
//

import SwiftUI

struct ReportsEmptyView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 120)
            Text("Nothing available at the moment.")
                .font(.system(size: 17))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    ReportsEmptyView()
}
