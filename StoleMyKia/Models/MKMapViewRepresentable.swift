//
//  MapViewRep.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 4/10/23.
//

import Combine
import Foundation
import UIKit
import SwiftUI
import MapKit

class MKMapViewController: UIViewController {
    
    private let mapView = MKMapView()
    private var cancellable = Set<AnyCancellable>()
    
    weak private var annotationCalloutDelegate: AnnotationCalloutDelegate?
    weak private var reportAnnotationDelegate: ReportAnnotationDelegate?
    
    private var viewModel: ReportsViewModel
    
    init(viewModel: ReportsViewModel) {
        self.viewModel = viewModel
        self.reportAnnotationDelegate = viewModel
                
        super.init(nibName: nil, bundle: .main)
                
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        view.addSubview(mapView)
        
        mapView.frame = view.frame
        
        mapView.delegate = self
        mapView.register(ReportsClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.register(ReportAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        updateLegalAndAppleMapsLogo()
    }
    
//    private func beginMonitoringSheetSize() {
//        viewModel.$mapSheetMode
//            .sink { [weak self] newMode in
//                self?.updateLegalAndAppleMapsLogo(newMode)
//            }
//            .store(in: &cancellable)
//    }
    
    
    private func updateLegalAndAppleMapsLogo() {
        mapView.layoutMargins.bottom = Mode.interactive.layoutSize.mapsAndLegalOffset
        //mapView.layoutMargins.top = mode.layoutSize.mapTopMarginOffset
    }
}

extension MKMapViewController: ReportsDelegate {
    func reportsDelegate(didDeleteReport report: Report) {
        mapView.removeAnnotation(report)
    }
    
    func reportsDelegate(didReceieveReports reports: [Report]) {
        mapView.createAnnotations(reports)
    }
}

extension MKMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        guard let annotation = annotation as? ReportAnnotation else { return nil}
        
        let annotationView = ReportAnnotationView(annotation: annotation, reuseIdentifier: annotation.report.type)
        annotationView.setCalloutDelegate(self)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        switch annotation {
        case let reportsClusterAnnotation as ReportClusterAnnotation:
            UIImpactFeedbackGenerator().impactOccurred(intensity: 7)
            self.reportAnnotationDelegate?.didSelectCluster(reportsClusterAnnotation.reportAnnotations.map({$0.report}))
            mapView.deselectAnnotation(reportsClusterAnnotation, animated: false)
        case let userAnnotation as MKUserLocation:
            mapView.deselectAnnotation(userAnnotation, animated: false)
        default:
            return
        }
    }
    
    func moveToCenter(for coordinates: CLLocationCoordinate2D?) {
        if let coordinates {
            //mapView.setCenter(coordinates, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        ReportClusterAnnotation(memberAnnotations: memberAnnotations)
    }
}

extension MKMapViewController: AnnotationCalloutDelegate {
    func annotationCallout(annotation: ReportAnnotation) {
       self.reportAnnotationDelegate?.didSelectReport(annotation.report)
    }
}

struct MKMapViewRepresentable: UIViewControllerRepresentable {
    
    @EnvironmentObject var reportsModel: ReportsViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        MKMapViewController(viewModel: reportsModel)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    typealias UIViewControllerType = UIViewController

}
