//
//  UserUpdatesView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/29/23.
//

import SwiftUI

struct UserUpdatesView: View {
    
    @State private var updatedReports = [Report]()
    
    var body: some View {
        switch updatedReports.isEmpty {
        case true:
            NoUpdatesView()
        case false:
            list
        }
    }
    
    var list: some View {
        ForEach(updatedReports) { report in
            NavigationLink {
                
            } label: {
                ReportCellView(report: report)
            }
        }
    }
}

struct UserUpdatesView_Previews: PreviewProvider {
    static var previews: some View {
        UserUpdatesView()
    }
}
