//
//  NoReportsAvaliableView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct NoReportsAvaliableView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 185)
            VStack(spacing: 12) {
                Image(systemName: "archivebox")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                VStack(spacing: 7) {
                    Text("Look's like there's nothing to report here...")
                        .font(.system(size: 19).bold())
                    Text("You can refresh by pulling this screen down.")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

struct NoReportsAvaliableView_Previews: PreviewProvider {
    static var previews: some View {
        NoReportsAvaliableView()
    }
}
