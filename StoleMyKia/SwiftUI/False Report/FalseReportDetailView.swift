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
    
    let reportId: UUID
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                switch loadingStatus {
                case .loading:
                    loadingView
                case .loaded(let falseReport):
                    Text("")
                case .error:
                    ErrorView()
                }
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
    
    private var loadingView: some View {
        VStack {
            Spacer()
                .frame(height: 120)
            ProgressView()
        }
    }
    
    private func fetchFalseReportDetails() async {
        
    }
}

//#Preview {
//    FalseReportDetailView(falseReportId: UUID())
//        .preferredColorScheme(.dark)
//}
