//
//  ParkingMapViewRepresentable.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/13/23.
//

import Foundation
import UIKit
import SwiftUI
import MapKit

struct ParkingMapViewRepresentable: UIViewRepresentable {
    
    @ObservedObject var coordinator: ParkingMapViewCoordinator
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func makeCoordinator() -> ParkingMapViewCoordinator {
        coordinator
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    typealias UIViewType = MKMapView

}

final class ParkingMapViewCoordinator: NSObject, ObservableObject {
    
}

extension ParkingMapViewCoordinator: MKMapViewDelegate {
    
}

extension ParkingMapViewCoordinator: MKMapViewLayoutDelegate {
    func didChangeDetent(_ detent: UISheetPresentationController.Detent.Identifier) {
        print(detent.hashValue)
    }
}

struct ParkingMapViewDetailSheetView<C: View>: UIViewControllerRepresentable {
    
    private let parkingMapCoordinator: ParkingMapViewCoordinator
    private let rootView: () -> C
    
    init(mapViewCoordinator: ParkingMapViewCoordinator, view: @escaping () -> C) {
        self.rootView = view
        self.parkingMapCoordinator = mapViewCoordinator
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = ParkingMapDetailViewController(rootView: rootView())
        vc.setDelegate(parkingMapCoordinator)
        print("Coordinator set")
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    public class ParkingMapDetailViewController<C: View>: UIHostingController<C>, PresentationDetentDelegate {
        var detent: UISheetPresentationController.Detent.Identifier? {
            didSet {
                guard let detent else {
                    return
                }
                print("Changed")
                mapViewLayoutDelegate?.didChangeDetent(detent)
            }
        }
                
        private let presentationDetentManager = PresentationDetentManager()
        weak private var mapViewLayoutDelegate: MKMapViewLayoutDelegate?
                
        override init(rootView: C) {
            super.init(rootView: rootView)
            presentationDetentManager.setDelegate(self)
        }
        
        public override func viewDidLoad() {
            if let pc = sheetPresentationController {
                pc.detents = [.medium(), .large()]
                pc.delegate = presentationDetentManager
            }
        }
        
        func setDelegate(_ delegate: MKMapViewLayoutDelegate) {
            self.mapViewLayoutDelegate = delegate
        }
        
        @MainActor required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            mapViewLayoutDelegate = nil
            print("Dead: ParkingMapDetailViewController")
        }
        
        final private class PresentationDetentManager: NSObject, UISheetPresentationControllerDelegate {
            
            weak private var detentDelegate: PresentationDetentDelegate?
            
            func setDelegate(_ delegate: PresentationDetentDelegate) {
                self.detentDelegate = delegate
            }
        
//            func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
//                print("Fired")
//                guard let detentIdentifier = sheetPresentationController.selectedDetentIdentifier else {
//                    return
//                }
//                print("Did change")
//                detentDelegate?.detent = detentIdentifier
//            }
            
            deinit {
                detentDelegate = nil
                print("Dead: PresentationDetentManager")
            }
        }
    }
}

protocol MKMapViewLayoutDelegate: AnyObject {
    func didChangeDetent(_ detent: UISheetPresentationController.Detent.Identifier)
}

protocol PresentationDetentDelegate: AnyObject {
    var detent: UISheetPresentationController.Detent.Identifier? {get set}
}
