//
//  NoUserReportsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/28/23.
//

import SwiftUI

struct NoUserReportsView: View {
    var body: some View {
        VStack(spacing: 20) {
            UserAccountViewSelection.userReports.indicator
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .foregroundColor(.brand)
            Text("Your reports will show here")
                .font(.system(size: 21).weight(.heavy))
            Text("When comes the time, any reports you've made will show here.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

struct NoUserReportsView_Previews: PreviewProvider {
    static var previews: some View {
        NoUserReportsView()
    }
}
