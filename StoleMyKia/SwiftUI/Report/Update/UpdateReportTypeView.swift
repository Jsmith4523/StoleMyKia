//
//  UpdateReportTypeView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 12/20/23.
//

import SwiftUI

struct UpdateReportTypeView: View {
    
    @State private var reportType: ReportType = .found
    
    let report: Report
    
    @EnvironmentObject var reportsVM: ReportsViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                ForEach(ReportType.updateCases.sorted(by: <)) { type in
                    UpdateReportTypeCellView(reportType: type, isSelected: self.reportType == type)
                        .onTapGesture {
                            self.reportType = type
                        }
                }
            }
            .navigationTitle("Update Report Type")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: reportType) { _ in
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Next") {
                        UpdateReportView(originalReport: report, updateReportType: $reportType)
                            .environmentObject(userVM)
                            .environmentObject(reportsVM)
                    }
                }
            }
        }
    }
    
    private struct UpdateReportTypeCellView: View {
        
        let reportType: ReportType
        let isSelected: Bool
        
        var body: some View {
            HStack {
                Image(systemName: reportType.annotationImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                VStack(alignment: .leading) {
                    Text(reportType.rawValue)
                        .font(.system(size: 15).bold())
                    Text(reportType.description)
                        .font(.system(size: 14))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 13, height: 13)
                        .bold()
                        .foregroundColor(.green)
                }
            }
            .padding(8)
        }
    }
}

#Preview {
    UpdateReportTypeView(report: [Report].testReports().first!)
        .environmentObject(UserViewModel())
        .environmentObject(ReportsViewModel())
}
