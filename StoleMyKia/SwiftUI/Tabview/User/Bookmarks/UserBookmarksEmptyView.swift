//
//  UserBookmarksEmptyView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/8/23.
//

import SwiftUI

struct UserBookmarksEmptyView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 200)
            VStack(spacing: 8) {
                Image(systemName: UserTabViewSelection.bookmarks.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                Text("Your bookmarks are empty")
                    .font(.system(size: 22).bold())
                Text("Start by bookmarking any reports you find interesting.")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

struct UserBookmarksEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        UserBookmarksEmptyView()
    }
}
