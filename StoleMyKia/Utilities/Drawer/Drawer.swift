//
//  Drawer.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/8/23.
//

import Foundation
import SwiftUI

enum Mode {
    case interactive, full
    
    static private var interactiveSize: Double {
        (UIScreen.main.bounds.height / 1.23)
    }
    
    static var fullSize: Double {
        (UIScreen.main.bounds.height / 5.5)
    }
    
    var size: CGFloat {
        switch self {
        case .interactive:
            return Self.interactiveSize
        case .full:
            return Self.fullSize
        }
    }
    
    var layoutSize: MapViewLayoutSize {
        switch self {
        case .interactive:
            return .interactive
        case .full:
            return .full
        }
    }
    
    enum MapViewLayoutSize {
        case interactive, full
        
        var mapsAndLegalOffset: CGFloat {
            switch self {
            case .interactive:
                return Mode.interactiveSize / 10
            case .full:
                return UIScreen.main.bounds.height / 1.48
            }
        }
        
        var mapTopMarginOffset: CGFloat {
            switch self {
            case .interactive:
                return -95
            case .full:
                return -40
            }
        }
    }
}

struct InteractiveDrawer<Content: View>: View {
        
    @Binding var mode: Mode
    
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(.gray.opacity(0.5))
                .frame(width: 65, height: 5)
                .padding(.top)
            content()
        }
        .gesture(
            DragGesture()
                .onChanged {
                    if $0.translation.height < 0 {
                        withAnimation {
                            mode = .full
                        }
                    }
                }
        )
        .background(.white)
        .cornerRadius(25)
        .offset(y: mode.size)
        .animation(.spring(), value: 2)
        .background(Color.clear)
    }
}
//
//struct MyPreviewProvider9_Previews: PreviewProvider {
//    static var previews: some View {
//        InteractiveDrawer(mode: .constant(.interactive)) {
//            Color.orange
//        }
//    }
//}
