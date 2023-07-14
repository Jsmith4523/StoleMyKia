//
//  DetailMapView.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 6/10/23.
//

import Foundation
import MapKit
import SwiftUI

///This map is used to show the original report and updates over time
struct TimelineMapViewRepresentabe: UIViewRepresentable {
    
    @ObservedObject var timelineMapCoordinator: TimelineMapViewCoordinator

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        timelineMapCoordinator.mapView = mapView
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isPitchEnabled = false
        mapView.mapType = .mutedStandard
        mapView.tintColor = .systemBlue
        
        //Disabling user interaction until report updates are fetched and visible within the map
        mapView.isUserInteractionEnabled = false
        
        mapView.register(ReportTimelineAnnotationView.self, forAnnotationViewWithReuseIdentifier: ReportAnnotation.reusableID)
    
        return mapView
    }
    
    func makeCoordinator() -> TimelineMapViewCoordinator {
        timelineMapCoordinator
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}

final class TimelineMapViewCoordinator: NSObject, MKMapViewDelegate, ObservableObject {
    
    enum TimelineAlertMode: String {
        case error = "There was an error with that request. Please try again later."
        case originalReportNoLongerExist = "Sorry, the original report is no longer avaliable."
        case noLongerExist = "Sorry, this report no longer unavaliable."
        case noUpdates = "Not updates have been made yet."
    }
        
    @Published private var reports = [Report]() {
        didSet {
           setupMapForUpdateReports()
        }
    }
    
    @Published var showAlert = false
    @Published var alertReportError: TimelineAlertMode? {
        didSet {
            self.showAlert = true
        }
    }
    
    @Published var selectedUpdateReport: Report?
    
    ///The UUID of the selected report
    private var reportId: UUID!
    private var isOriginalReport: Bool!
    
    var mapView: MKMapView?
    weak private var timelineMapViewDelegate: TimelineMapViewDelegate?
        
    func setDelegate(_ delegate: TimelineMapViewDelegate) {
        self.timelineMapViewDelegate = delegate
    }
    
    override init() {
        super.init()
    }
    
    /// Fetch reports that are updates to this report or its parent.
    /// - Parameter role: The role of the report.
    func getUpdates(report: Report) async {
        do {
            self.reportId = report.id
            self.isOriginalReport = report.role.hasParent
            
            var reports = [Report?]()
            
            //Fetching the original report
            let originalReport = try await ReportManager.manager.fetchSingleReport(report.role.associatedValue)
            reports.append(originalReport)
            
            //Then fetching the updates to the original report
            guard let updateReports = try await timelineMapViewDelegate?.getTimelineUpdates(role: report.role) else {
                return
            }
            
            guard !(updateReports.isEmpty) else {
                DispatchQueue.main.async {
                    self.alertReportError = .noUpdates
                }
                return
            }
            
            reports.append(contentsOf: updateReports)
            
            //Some reports may be nil on arrival...
            self.reports = reports.compactMap({$0})
        }
        catch ReportManagerError.doesNotExist {
            DispatchQueue.main.async {
                self.alertReportError = self.isOriginalReport ? .noLongerExist : .originalReportNoLongerExist
            }
        }
        catch {
            DispatchQueue.main.async {
                self.alertReportError = .error
            }
        }
    }
    
    ///Setups the map for fetched reports
    private func setupMapForUpdateReports() {
        for report in reports.sorted(by: >) {
            mapView?.addAnnotation(ReportAnnotation(report: report))
        }
        
        let coordinates = reports.map { $0.location.coordinates }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView?.addOverlay(polyline)
        mapView?.setVisibleMapRect(polyline.boundingMapRect, edgePadding: .init(top: 25, left: 75, bottom: 45, right: 75), animated: true)
        
        mapView?.isUserInteractionEnabled = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
            
        if let annotation = annotation as? ReportAnnotation {
            let annotationView = ReportTimelineAnnotationView(annotation: annotation)
            annotationView.leftCalloutAccessoryView = nil
            annotationView.canShowCallout = true
            annotationView.detailCalloutAccessoryView = TimelineAnnotationViewCallout(report: annotation.report, timelineMapViewCoordinator: self, selectedReportId: reportId)
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .systemTeal
            lineRenderer.lineWidth = 3.5
            lineRenderer.lineDashPhase = 0.5
            return lineRenderer
        }
        
        return MKOverlayRenderer()
    }
}

protocol TimelineMapViewDelegate: AnyObject {
    func getTimelineUpdates(role: ReportRole) async throws -> [Report]
}
