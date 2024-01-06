//
//  CustomTabViewPicker.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 1/4/24.
//

import SwiftUI

protocol CustomTabViewPickerSource: Identifiable, CaseIterable, Hashable {
    var title: String { get }
}

struct CustomTabViewPicker<S: CustomTabViewPickerSource>: View {
    
    @Binding var selection: S
    
    let sources: [S]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(sources) { source in
                pickerSourceCellView(source)
                    .onTapGesture {
                        self.selection = source
                    }
            }
        }
        .frame(height: 50)
        .onChange(of: selection) { _ in
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    @ViewBuilder 
    func pickerSourceCellView(_ source: S) -> some View {
        VStack {
            Spacer()
            Text(source.title)
                .foregroundColor(selection == source ? Color(uiColor: .label) : .gray)
                .font(.system(size: 17).weight(.bold))
            Spacer()
                .frame(height: 15)
            Rectangle()
                .fill(selection == source ? Color(uiColor: .label) : .clear)
                .frame(height: 2.25)
        }
        .frame(width: (UIScreen.main.bounds.width / CGFloat(sources.count)))
    }
}

fileprivate enum TestPickerSource: CustomTabViewPickerSource {
    case caseOne, caseTwo
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .caseOne:
            return "General"
        case .caseTwo:
            return "Nearby"
        }
    }
}

#Preview {
    CustomTabViewPicker(selection: .constant(.caseOne), sources: TestPickerSource.allCases)
}
