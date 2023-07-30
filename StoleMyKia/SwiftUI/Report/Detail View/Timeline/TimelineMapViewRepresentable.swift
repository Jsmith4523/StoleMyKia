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
    
    enum TimelineMapViewSheetMode: Identifiable {
        case list
        case report(Report)
        
        var id: String {
            switch self {
            case .list:
                return "List"
            case .report(_):
                return "Report"
            }
        }
    }
    
    enum TimelineAlertMode: String, Error {
        case error = "There was an error with that request. Please try again later."
        case originalReportNoLongerExist = "Sorry, the original report is no longer avaliable."
        case noLongerExist = "Sorry, this report no longer unavaliable."
        case noUpdates = "Not updates have been made yet."
    }
    
    @Published var isShowingTimelineListView = false
    @Published private(set) var isLoading = false
    @Published private(set) var reports = [Report]() {
        didSet {
            setupMapForUpdateReports()
        }
    }
    @Published private(set) var report: Report?
    
    @Published var showAlert = false
    @Published var alertReportError: TimelineAlertMode? {
        didSet {
            presentAlert()
        }
    }
    
    ///The report the users selected from the map
    @Published var mapViewSheetMode: TimelineMapViewSheetMode?
    
    ///The UUID of the report
    private var reportId: UUID!
    private var isOriginalReport: Bool!
    
    var mapView: MKMapView?
    
    weak private var timelineMapViewDelegate: TimelineMapViewDelegate?
        
    func setDelegate(_ delegate: TimelineMapViewDelegate) {
        self.timelineMapViewDelegate = delegate
    }
    
    /// Fetch reports that are updates to this report or its parent.
    /// - Parameter role: The role of the report.
    @MainActor
    func getUpdates(_ report: Report) async {
        do {
            self.isLoading = true
            self.report = report
            self.reportId = report.id
            self.isOriginalReport = report.role.hasParent
            
            var reports = [Report]()
            
            let originalReport = report
               
            //Check if the report still exists in Firestore Database
            guard try await ReportManager.manager.reportDoesExist(originalReport.id) else { throw ReportManagerError.doesNotExist }
            
            guard let updates = try await timelineMapViewDelegate?.getTimelineUpdates(for: originalReport), !(updates.isEmpty) else {
                throw TimelineAlertMode.noUpdates
            }

            reports.append(originalReport)
            reports.append(contentsOf: updates)
            self.reports = reports.sorted(by: >)
            self.isLoading = false
        }
        catch ReportManagerError.doesNotExist {
            DispatchQueue.main.async {
                self.alertReportError = self.isOriginalReport ? .noLongerExist : .originalReportNoLongerExist
            }
        }
        catch TimelineAlertMode.noUpdates {
            DispatchQueue.main.async {
                self.alertReportError = .noUpdates
            }
        }
        catch {
            print(error.localizedDescription)
            DispatchQueue.main.async {
                self.alertReportError = .error
            }
        }
    }
    
    func refreshForNewUpdates() async {
        guard let report else { return }
        await getUpdates(report)
    }
    
    ///Setups the map to display overlays and annotations.
    private func setupMapForUpdateReports() {
        DispatchQueue.main.async {
            if let mapView = self.mapView {
                mapView.removeAnnotations(mapView.annotations)
                mapView.removeOverlays(mapView.overlays)
                let annotations = self.reports.sorted(by: >).map({ReportAnnotation(report: $0)})
                let polyline = MKPolyline(coordinates: annotations.map({$0.coordinate}), count: annotations.count)
                mapView.addAnnotations(annotations)
                mapView.addOverlay(polyline)
                mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: .init(top: 65, left: 75, bottom: 65, right: 75), animated: true)
                mapView.isUserInteractionEnabled = true
            }
            self.isLoading = false
        }
    }
    
    func setRegionToReport(location: Location) {
        mapView?.setRegion(location.region, animated: true)
    }
    
    private func presentAlert() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        self.isLoading = false
        self.showAlert = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
            
        if let annotation = annotation as? ReportAnnotation {
            let annotationView = ReportTimelineAnnotationView(annotation: annotation)
            let calloutView = TimelineAnnotationViewCallout(report: annotation.report, selectedReportId: reportId)
            calloutView.setDelegate(self)
            annotationView.canShowCallout = true
            annotationView.detailCalloutAccessoryView = calloutView
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let overlay = MKPolylineRenderer(polyline: polyline)
            overlay.strokeColor = .systemBlue
            overlay.lineWidth = 2.5
            overlay.lineJoin = .miter
            return overlay
        }
        
        return MKOverlayRenderer()
    }
    
    deinit {
        timelineMapViewDelegate = nil
        print("Dead: TimelineMapViewCoordinator")
    }
}

//MARK: - TimelineAnnotationViewCalloutDelegate
extension TimelineMapViewCoordinator: TimelineAnnotationViewCalloutDelegate {
    func didSelectReport(_ report: Report) {
        self.mapViewSheetMode = .report(report)
    }
}

protocol TimelineMapViewDelegate: AnyObject {
    func getTimelineUpdates(for report: Report) async throws -> [Report]
}
