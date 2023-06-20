//
//  ReportErrorView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/12/23.
//

import SwiftUI

struct ReportErrorView: View {
    
    let fetchErrorReason: FetchReportError
    
    var refreshCompletion: (()->Void)? = nil
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 25) {
                Image(systemName: fetchErrorReason.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                VStack(spacing: 10) {
                    Text(fetchErrorReason.title)
                        .font(.system(size: 25).weight(.bold))
                    Text(fetchErrorReason.rawValue)
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
            }
            .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}

struct ReportErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ReportErrorView(fetchErrorReason: .unavaliable)
    }
}
