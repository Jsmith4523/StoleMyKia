//
//  StretchRefreshButton.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/29/23.
//

import SwiftUI

struct StretchRefreshButton: View {
    
    @State private var refreshing = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack {
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.frame(in: .global).minY < 0 ? 0 :  geo.frame(in: .global).minY > 250 ? 25 : (geo.frame(in: .global).minY / 10), height: geo.frame(in: .global).minY < 0 ? 0 :  geo.frame(in: .global).minY > 250 ? 25 : (geo.frame(in: .global).minY / 10))
                        .padding()
                        .background(refreshing ? Color.brand : Color(uiColor: .secondarySystemBackground))
                        .clipShape(Circle())
                        .bold()
                        .foregroundColor(refreshing ? .white : .brand)
                        .padding()
                    Spacer()
                }
            }
            .onChange(of: geo.frame(in: .global).minY) { newValue in
                if newValue > 250 {
                    if !refreshing {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                    
                    withAnimation {
                        refreshing = true
                    }
                }
            }
        }
        .frame(height: 50)
    }
}

struct StretchRefreshButton_Previews: PreviewProvider {
    static var previews: some View {
        StretchRefreshButton()
    }
}
