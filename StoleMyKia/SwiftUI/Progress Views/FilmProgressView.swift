//
//  FilmProgressView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 9/29/23.
//

import SwiftUI

struct FilmProgressView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
            ProgressView()
                .tint(.white)
        }
        .ignoresSafeArea()
    }
}

struct FilmProgressView_Previews: PreviewProvider {
    static var previews: some View {
        FilmProgressView()
    }
}
