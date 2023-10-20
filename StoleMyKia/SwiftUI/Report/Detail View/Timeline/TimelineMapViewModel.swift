//
//  TimelineMapViewModel.swift
//  StoleMyKia
//
//  Created by Jaylen Smith on 10/13/23.
//

import Foundation
import MapKit

@MainActor
final class TimelineMapViewModel: NSObject, ObservableObject {
    
    enum TimelineMapViewError: Error {
        case doesNotExist
        case fetchError
    }
        
    @Published var isShowingListView = false
    @Published private(set) var reportId: UUID!
    
    @Published var selectedReport: Report! {
        didSet {
            if (selectedReport == nil) {
                self.deselectAnnotation()
            }
        }
    }
    
    @Published private(set) var isLoading = false
    @Published private(set) var timelineListMode: TimelineListViewMode = .loading
    
    weak var mapView: MKMapView?
    
    func getUpdatesForReport(_ id: UUID) async throws {
        self.reportId = id
        self.timelineListMode = .loading
        self.isLoading = true
        
        do {
            guard try await ReportManager.manager.reportDoesExist(id) else {
                throw TimelineMapViewError.doesNotExist
            }
            
            guard let initialReport = try await ReportManager.manager.fetchSingleReport(id) else {
                throw TimelineMapViewError.fetchError
            }
            
            var reports = try await ReportManager.manager.fetchUpdates(id)
            reports.append(initialReport)
            reports.sort(by: >)
            
            self.createReportAnnotations(reports)
            self.isLoading = false
            self.timelineListMode = .loaded(reports)
        } catch {
            self.isLoading = false
            self.timelineListMode = .error
            throw error
        }
    }
    
    func selectAnnotation(_ report: Report) {
        if let mapView {
            deselectAnnotation()
            if let annotation = mapView.annotations.first(where: {$0.coordinate == report.location.coordinates}) {
                mapView.selectAnnotation(annotation, animated: true)
            } else {
                if let overlay = mapView.overlays.first(where: {$0.coordinate == report.location.coordinates}) {
                    mapView.setVisibleMapRect(overlay.boundingMapRect, edgePadding: .init(top: 100, left: 75, bottom: 125, right: 75), animated: true)
                    self.selectedReport = report
                }
            }
        }
    }
    
    func deselectAnnotation() {
        if let mapView {
            if let selectedAnnotation = mapView.selectedAnnotations.first {
                mapView.deselectAnnotation(selectedAnnotation, animated: true)
            }
        }
    }
        
    deinit {
        mapView = nil
        print("Dead: TimelineMapViewCoordinator")
    }
}

//MARK: - MKMapViewDelegate
extension TimelineMapViewModel: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ReportAnnotation {
            let annotationView = ReportTimelineAnnotationView(annotation: annotation)
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        if let reportAnnotation = annotation as? ReportAnnotation {
            mapView.setRegion(reportAnnotation.selectedRegion, animated: true)
            DispatchQueue.main.async { [weak self] in
                self?.selectedReport = reportAnnotation.report
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var overlayRenderer: MKOverlayRenderer!
        
        if let timelinePolyline = overlay as? TimelinePolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: timelinePolyline)
            polylineRenderer.strokeColor = timelinePolyline.strokeColor
            polylineRenderer.lineWidth = 2.5
            polylineRenderer.lineDashPattern = timelinePolyline.dashPattern
            polylineRenderer.lineJoin = .miter
            overlayRenderer = polylineRenderer
        }
        
        if let timelineCircle = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: timelineCircle)
            circleRenderer.fillColor = MKCircle.discloseLocationFillColor
            overlayRenderer = circleRenderer
        }
            
        return overlayRenderer
    }
    
    private func createReportAnnotations(_ reports: [Report])  {
        if let mapView {
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
                        
            let annotations = reports
                .filter({!$0.isFalseReport})
                .filter({!$0.discloseLocation})
                .map({ReportAnnotation(report: $0)})
            
            let circleOverlays = reports
                .filter({!$0.isFalseReport})
                .filter({$0.discloseLocation})
                .map({MKCircle(center: $0.location.coordinates, radius: $0.role.discloseRadiusSize)})
            
            mapView.addOverlays(circleOverlays)
            mapView.addAnnotations(annotations)
            
            for i in 0..<reports.count-1 {
                print(i)
                print(i+1)
                let firstReport = reports[i]
                let secondReport = reports[i+1]
                let reports = [firstReport, secondReport]
                let timelinePolyline = TimelinePolyline(coordinates: reports.map({$0.location.coordinates}), count: reports.count)
                timelinePolyline.reports = reports
                mapView.addOverlay(timelinePolyline)
            }
        }
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
