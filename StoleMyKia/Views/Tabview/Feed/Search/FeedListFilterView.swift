//
//  FeedListFilterView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import SwiftUI

struct FeedListFilterView: View {
    
    @Binding var filterSelection: ReportType
    
    var body: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer()
                    ForEach(ReportType.allCases) { type in
                        FilterCellView(selection: $filterSelection, type: type)
                    }
                    Spacer()
                }
            }
        }
        .background(.white)
    }
}

fileprivate struct FilterCellView: View {
    
    @Binding var selection: ReportType
    
    let type: ReportType
    
    var body: some View {
        Text(type.rawValue)
            .font(.system(size: 17).weight(.bold))
            .foregroundColor(type == selection ? .white : .black)
            .padding(10)
            .background(selection == type ? Color(uiColor: type.annotationColor) : .clear)
            .clipShape(Capsule())
            .overlay {
                if !(selection == type) {
                    Capsule()
                        .stroke(.gray.opacity(0.35), lineWidth: 0.75)
                }
            }
            .padding(.vertical)
            .onTapGesture {
                select()
            }
    }
    
    func select() {
        UIImpactFeedbackGenerator().impactOccurred(intensity: 5)
        withAnimation {
            selection = type
        }
    }
}

struct FeedListFilterView_Previews: PreviewProvider {
    static var previews: some View {
        FeedListFilterView(filterSelection: .constant(.stolen))
    }
}
