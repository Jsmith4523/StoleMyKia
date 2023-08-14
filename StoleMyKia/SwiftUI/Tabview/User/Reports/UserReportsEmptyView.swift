//
//  UserReportsEmptyView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 8/8/23.
//

import SwiftUI

struct UserReportsEmptyView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 200)
            VStack(spacing: 8) {
                Image(systemName: UserTabViewSelection.reports.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                Text("Your reports are empty")
                    .font(.system(size: 22).bold())
                Text("They will appear here alongside any updates you've made to existing reports.")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

struct UserReportsEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        UserReportsEmptyView()
    }
}
