//
//  FalseReportDetailView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/14/23.
//

import SwiftUI

struct FalseReportDetailView: View {
    
    private enum LoadingStatus {
        case loading, loaded(FalseReport), error
    }
    
    @State private var loadingStatus: LoadingStatus = .loading
    
    let falseReportId: UUID
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                }
            }
            .refreshable {
                await fetchFalseReportDetails()
            }
        }
    }
    
    
    private func fetchFalseReportDetails() async {
        
    }
}

//#Preview {
//    FalseReportDetailView(falseReportId: UUID())
//        .preferredColorScheme(.dark)
//}
