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
        case error = "We weren't able to process that request. Please try again."
        case originalReportNoLongerExist = "The initial report is no longer available."
        case noLongerExist = "This report is no longer available."
        case noUpdates = "Unfortunately, no updates have been made yet!"
    }
    
    @Published var isShowingTimelineListView = false
    @Published private(set) var isLoading = false
    @Published private(set) var reports = [Report]() {
        didSet {
            setupMapView()
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
    
    weak var mapView: MKMapView?
    
    @MainActor
    func getUpdates(_ report: Report) async {
        do {
            self.isLoading = true
            self.report = report
            self.reportId = report.id
            self.isOriginalReport = report.role.hasParent
            
            //Check if the selected report still exists
            guard try await ReportManager.manager.reportDoesExist(report.id) else {
                throw ReportManagerError.error
            }
                                       
            //Check if the original report still exists
            guard try await ReportManager.manager.reportDoesExist(report.role.associatedValue) else {
                throw ReportManagerError.doesNotExist
            }
            
            guard let originalReport = try await ReportManager.manager.fetchSingleReport(report.role.associatedValue) else {
                throw ReportManagerError.error
            }
            
            guard let updates = try? await ReportManager.manager.fetchUpdates(report.role.associatedValue), !(updates.isEmpty) else {
                throw TimelineAlertMode.noUpdates
            }
            
            var reports = [Report]()
            reports.append(originalReport)
            reports.append(contentsOf: updates)
            
            //Filtering out false reports
            self.reports = reports.filter({!($0.isFalseReport)}).sorted(by: >)
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
    private func setupMapView() {
        DispatchQueue.main.async {
            if let mapView = self.mapView {
                mapView.removeAnnotations(mapView.annotations)
                mapView.removeOverlays(mapView.overlays)
                
                //Setting the index of reports that are updates
                //Filtering out reports that are false and should not visible display location
                let annotations = self.reports
                    .filter({!($0.isFalseReport)})
                    .filter({!($0.discloseLocation)})
                    .sorted(by: >)
                    .map({ReportAnnotation(report: $0)})
            
                let polyline = MKPolyline(coordinates: annotations.map({$0.coordinate}), count: annotations.count)
                mapView.addAnnotations(annotations)
                mapView.addOverlay(polyline)
                mapView.setVisibleMapRect(polyline.boundingMapRect,
                                          edgePadding: .init(top: 65, left: 75, bottom: 65, right: 75),
                                          animated: false)
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
        if let annotation = annotation as? ReportAnnotation {
            let reportAnnotationView = ReportTimelineAnnotationView(annotation: annotation)
            let calloutView = TimelineAnnotationViewCallout(report: annotation.report, selectedReportId: reportId, onSelect: didSelectReport(_:))
            reportAnnotationView.detailCalloutAccessoryView = calloutView
            reportAnnotationView.canShowCallout = true
            reportAnnotationView.displayPriority = .defaultHigh
            return reportAnnotationView
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
    
    func didSelectReport(_ report: Report) {
        self.mapViewSheetMode = .report(report)
    }
    
    deinit {
        print("Dead: TimelineMapViewCoordinator")
    }
}
