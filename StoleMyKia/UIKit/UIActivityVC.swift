//
//  UIActivityVC.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/1/23.
//

import UIKit
import SwiftUI


struct ActivityController: UIViewControllerRepresentable {
    
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let ac = UIActivityVC(activityItems: items, applicationActivities: nil)
        return ac
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
    typealias UIViewControllerType = UIActivityViewController
}

class UIActivityVC: UIActivityViewController {
        
    override init(activityItems: [Any], applicationActivities: [UIActivity]?) {
        super.init(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let currentViewController = UIWindow().rootViewController else {
            return
        }
        
        currentViewController.present(self, animated: true)
    }
}
