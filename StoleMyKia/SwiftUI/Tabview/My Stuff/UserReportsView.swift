//
//  UserReportsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/3/23.
//

import SwiftUI

struct UserReportsView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var reportsVM: ReportsViewModel
    
    var body: some View {
        ScrollView {
            
        }
    }
}

struct UserReportsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserReportsView()
                .environmentObject(ReportsViewModel())
        }
    }
}
