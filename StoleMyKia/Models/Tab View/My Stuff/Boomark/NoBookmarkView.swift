//
//  NoBookmarkView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/29/23.
//

import SwiftUI

struct NoBookmarkView: View {
    var body: some View {
        VStack(spacing: 20) {
            UserAccountViewSelection.bookmark.indicator
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .foregroundColor(.brand)
            Text("Bookmarked reports will appear here")
                .font(.system(size: 21).weight(.heavy))
            Text("Reports you've bookmarked will show here.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

struct NoBookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        NoBookmarkView()
    }
}
