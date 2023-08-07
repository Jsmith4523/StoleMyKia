//
//  UserViewTabSelectionView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/16/23.
//

import SwiftUI

enum UserTabViewSelection: CaseIterable, Identifiable {
    
    case reports, bookmarks
    
    var id: String {
        self.title
    }
    
    var title: String {
        switch self {
        case .reports:
            return "Reports"
        case .bookmarks:
            return "Bookmarks"
        }
    }
    
    var symbol: String {
        switch self {
        case .reports:
            return "tray"
        case .bookmarks:
            return "bookmark"
        }
    }
}

struct UserViewTabSelectionView: View {
    
    @Binding var selection: UserTabViewSelection
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                ForEach(UserTabViewSelection.allCases) { selection in
                    Label {
                        Text(selection.title)
                    } icon: {
                        Image(systemName: selection.symbol)
                    }
                    .font(.system(size: 17))
                    .foregroundColor(self.selection == selection ? Color(uiColor: .label) : .gray)
                    .onTapGesture {
                        self.changeSelection(to: selection)
                    }
                    Spacer()
                }
            }
            .padding([.top, .horizontal])
            .padding(.bottom, 10)
            Divider()
        }
        .onChange(of: selection) { _ in
            UIImpactFeedbackGenerator().impactOccurred(intensity: 5)
        }
    }
    
    private func changeSelection(to selection: UserTabViewSelection) {
        withAnimation {
            self.selection = selection
        }
    }
}

struct UserViewTabSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UserViewTabSelectionView(selection: .constant(.reports))
    }
}
