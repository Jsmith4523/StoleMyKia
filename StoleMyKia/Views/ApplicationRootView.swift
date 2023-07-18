//
//  ApplicationRootView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/17/23.
//

import SwiftUI

struct ApplicationRootView: View {
    
    @EnvironmentObject var firebaseAuthModel: FirebaseAuthViewModel
    @StateObject private var userVM = UserViewModel()
    
    var body: some View {
        ZStack {
            switch userVM.rootViewLoadStatus {
            case .loading:
                ApplicationProgressView()
            case .loaded:
                ApplicationTabView()
                    .environmentObject(userVM)
            }
        }
        .onAppear {
            firebaseAuthModel.setDelegate(userVM)
        }
    }
}

#Preview {
    ApplicationRootView()
        .environmentObject(FirebaseAuthViewModel())
}
