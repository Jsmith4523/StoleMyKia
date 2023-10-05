//
//  ReportSkeletonView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/27/23.
//

import SwiftUI

struct ReportSkeletonView: View {
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Image(uiImage: .vehiclePlaceholder)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width, height: 300)
                        .clipped()
                    VStack(spacing: 30) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("             ")
                                    .font(.system(size: 18))
                                Spacer()
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                VStack(alignment: .leading, spacing: 7) {
                                    Text("       ")
                                        .font(.system(size: 25).weight(.heavy))
                                    HStack {
                                        Text("     ")
                                        Divider()
                                        Text("        ")
                                        Divider()
                                        Text("            ")
                                    }
                                    .frame(height: 20)
                                    .font(.system(size: 19))
                                    .foregroundColor(.gray)
                                    VStack(alignment: .leading) {
                                        Text("         ")
                                    }
                                    .font(.system(size: 17))
                                }
                                Text("                                                                                                                                                                                ")
                                    .font(.system(size: 16))
                                    .lineSpacing(2)
                            }
                        }
                    }
                    .padding()
                }
            }
            Spacer()
        }
        .redacted(reason: .placeholder)
        .disabled(true)
    }
}

struct ReportSkeletonView_Previews: PreviewProvider {
    static var previews: some View {
        ReportSkeletonView()
    }
}
