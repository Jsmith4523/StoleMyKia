//
//  Search.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/26/23.
//

import SwiftUI

struct SearchView: View {
    
    @State private var isShowingScannerView = false
    @State private var pushToResultsView = false
    
    @StateObject private var searchVM = SearchViewModel()
    @ObservedObject var reportsVM: ReportsViewModel
    @ObservedObject var userVM: UserViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                ZStack(alignment: .bottomTrailing) {
                    VStack {
                        Spacer()
                        VStack(spacing: 25) {
                            Image(systemName: ApplicationTabViewSelection.search.symbol)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                            Text("Start searching for reports or information you have regarding a vehicle.")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                        }
                        .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                .padding()
                NavigationLink("", isActive: $pushToResultsView) {
                    SearchResultsView()
                        .environmentObject(searchVM)
                        .environmentObject(reportsVM)
                        .environmentObject(userVM)
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchVM.search, placement: .automatic, prompt: "License Plate, VIN, Description, etc.")
            .onSubmit(of: .search) {
                guard !(searchVM.search.allSatisfy({$0.isWhitespace})) else { return }
                pushToResultsView.toggle()
            }
        }
    }
}

#Preview {
    SearchView(reportsVM: ReportsViewModel(), userVM: UserViewModel())
}
