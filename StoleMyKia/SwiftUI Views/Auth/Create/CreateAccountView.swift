//
//  CreateAccountView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/19/23.
//

import SwiftUI

struct CreateAccountView: View {
    
    @State private var phoneNumber = ""
    
    var body: some View {
        NavigationController(backgroundColor: Color("auth-background")) {
            ZStack {
                Color("auth-background").ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        
                    }
                }
            }
            .tint(.white)
        }
        .ignoresSafeArea()
    }
}

//#Preview {
//    CreateAccountView()
//}

//struct CreateAccountView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateAccountView()
//    }
//}
