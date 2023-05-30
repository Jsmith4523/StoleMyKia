//
//  UserBookmarkedReportsView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 5/29/23.
//

import SwiftUI

struct UserBookmarkedReportsView: View {
    
    @State private var boomarkedReports = [Report]()
    
    @State private var selectedBookmarkReport: Report?
    
    var body: some View {
        switch boomarkedReports.isEmpty {
        case true:
            NoBookmarkView()
        case false:
            list
        }
    }
    
    var list: some View {
        VStack {
            ForEach(boomarkedReports) { report in
                ReportCellView(report: report)
                    .onTapGesture {
                        selectedBookmarkReport = report
                    }
            }
        }
    }
    
    func getBookmarkReports() {
        
    }
}

struct UserBookmarkedReportsView_Previews: PreviewProvider {
    static var previews: some View {
        UserBookmarkedReportsView()
    }
}
