//
//  ApplicationProgressView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 7/17/23.
//

import SwiftUI

struct ApplicationProgressView: View {
    var body: some View {
        ZStack {
            ApplicationLauchScreen()
                .ignoresSafeArea()
                .statusBarHidden()
        }
    }
}

fileprivate struct ApplicationLauchScreen: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let storyboard = UIStoryboard(name: "Launch Screen", bundle: .main)
        if let vc = storyboard.instantiateInitialViewController() {
            return vc
        }
        
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController

}

struct MyPreviewProvider69Nice_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationProgressView()
    }
}
