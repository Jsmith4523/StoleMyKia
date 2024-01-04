//
//  SearchReportTypeFilterView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/28/23.
//

import SwiftUI

struct SearchReportTypeFilterView: View {
    
    @Binding var reportType: ReportType?
        
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 5)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer()
                    HStack(spacing: 10) {
                        ForEach(ReportType.allCases.sorted(by: <)) { type in
                            ReportTypeCellView(type: type, isSelected: reportType == type)
                                .onTapGesture {
                                    if self.reportType == type {
                                        self.reportType = nil
                                    } else {
                                        self.reportType = type
                                    }
                                }
                        }
                    }
                    Spacer()
                }
                .padding(6)
            }
            Divider()
        }
        .onChange(of: reportType) { _ in
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    private struct ReportTypeCellView: View {
        
        let type: ReportType
        let isSelected: Bool
        
        var body: some View {
            Text(type.rawValue)
                .foregroundColor(isSelected ? .white : Color(uiColor: .label))
                .font(.system(size: 17).weight(.heavy))
                .padding(8)
                .background(isSelected ? Color(uiColor: type.annotationColor).opacity(0.72) : Color.gray.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    SearchReportTypeFilterView(reportType: .constant(.attempt))
}
