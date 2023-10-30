//
//  SearchResultsEmptyView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/28/23.
//

import SwiftUI

struct SearchResultsEmptyView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 100)
            VStack(spacing: 20) {
                Image(systemName: "archivebox")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text("We couldn't find anything from that request!")
                    .font(.system(size: 17))
            }
        }
        .foregroundColor(.gray)
        .multilineTextAlignment(.center)
        .padding()
    }
}

#Preview {
    ScrollView {
        SearchResultsEmptyView()
    }
}
