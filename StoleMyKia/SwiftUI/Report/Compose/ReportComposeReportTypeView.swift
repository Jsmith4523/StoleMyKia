//
//  ReportComposeReportTypeView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 12/20/23.
//

import SwiftUI

struct ReportComposeReportTypeView: View {
    
    @Binding var isPresented: Bool
    
    @EnvironmentObject var composeVM: ReportComposeViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var canPushToNextView: Bool = true
    
    var body: some View {
        NavigationStack {
            Form {
                ForEach(ReportType.allCases.sorted(by: <)) { type in
                    ReportComposeReportTypeCellView(reportType: type, isSelected: composeVM.reportType == type)
                        .onTapGesture {
                            self.composeVM.reportType = type
                        }
                }
            }
            .navigationTitle("Report Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if canPushToNextView {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink("Next") {
                            ReportComposeVehicleColorView()
                                .environmentObject(composeVM)
                        }
                    }
                }
            }
            .onChange(of: composeVM.reportType) { _ in
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            .onReceive(composeVM.$dismissView) { status in
                guard status else { return }
                self.isPresented = false
            }
        }
    }
}

struct ReportComposeReportTypeCellView: View {
    
    let reportType: ReportType
    var isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: reportType.annotationImage)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
            Spacer()
                .frame(width: 15)
            VStack(alignment: .leading) {
                Text(reportType.rawValue)
                    .font(.system(size: 16).bold())
                Text(reportType.description)
                    .font(.system(size: 12))
            }
            Spacer()
            if isSelected {
                Image.greenCheckMark
            }
        }
        .padding(.vertical, 10)
    }
}

extension Image {
    
    static var greenCheckMark: some View {
        Image(systemName: "checkmark")
            .resizable()
            .scaledToFit()
            .frame(width: 13, height: 13)
            .fontWeight(.bold)
            .foregroundColor(.green)
    }
}

#Preview {
    ReportComposeReportTypeView(isPresented: .constant(true))
        .environmentObject(ReportsViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(ReportComposeViewModel())
}
