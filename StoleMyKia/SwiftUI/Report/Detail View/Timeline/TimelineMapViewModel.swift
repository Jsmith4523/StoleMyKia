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
    
    @Published private(set) var isLoading = false
    @Published private(set) var timelineListMode: TimelineListViewMode = .loading
    
    @Published var selectedReport: Report! {
        didSet {
            if (selectedReport == nil) {
                self.deselectAnnotation()
            }
        }
    }
    
    weak var mapView: MKMapView?
    
    override init() {
        super.init()
        //setupMapViewForGesture()
    }
    
//    private func setupMapViewForGesture() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
//            if let mapView = self?.mapView {
//                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self?.mapTapGestureRecognized(_:)))
//                mapView.addGestureRecognizer(tapGesture)
//            }
//        }
//    }
    
    func getUpdatesForReport(_ id: UUID) async throws {
        self.reportId = id
        self.timelineListMode = .loading
        self.isLoading = true
        
        do {
            guard try await ReportManager.manager.reportDoesExist(id) else {
                self.timelineListMode = .noLongerAvaliable
                self.isLoading = false
                self.removeAllAnnotations()
                return
            }
            
            guard let initialReport = try await ReportManager.manager.fetchSingleReport(id) else {
                self.removeAllAnnotations()
                throw TimelineMapViewError.fetchError
            }
            
            var reports = try await ReportManager.manager.fetchUpdates(id)
            
            reports.append(initialReport)
            reports.sort(by: >)
            
            self.createReportAnnotations(reports)
            self.isLoading = false
            
            if reports.filter({!($0.id == initialReport.id)}).isEmpty {
                self.timelineListMode = .empty
            } else {
                self.timelineListMode = .loaded(reports)
            }
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
                    mapView.setVisibleMapRect(overlay.boundingMapRect, edgePadding: TimelineDiscloseCircle.discloseLocationEdgePadding, animated: true)
                    self.selectedReport = report
                }
            }
        }
    }
    
    private func removeAllAnnotations() {
        guard let mapView else { return }
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    private func deselectAnnotation() {
        if let mapView {
            if let selectedAnnotation = mapView.selectedAnnotations.first {
                mapView.deselectAnnotation(selectedAnnotation, animated: true)
            }
        }
    }
    
    func moveToUsersLocation() {
        guard let userLocation = CLLocationManager.shared.usersCurrentLocation else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        let userLocationRegion = MKCoordinateRegion(center: userLocation, span: .init(latitudeDelta: 0.0010, longitudeDelta: 0.010))
        mapView?.setRegion(userLocationRegion, animated: false)
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
            polylineRenderer.lineWidth = timelinePolyline.strokeWidth
            polylineRenderer.lineDashPattern = timelinePolyline.dashPattern
            polylineRenderer.lineJoin = .miter
            overlayRenderer = polylineRenderer
        }
        
        if let timelineCircle = overlay as? TimelineDiscloseCircle {
            let circleRenderer = MKCircleRenderer(circle: timelineCircle)
            circleRenderer.fillColor = timelineCircle.fillColor
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
                .map({
                    let circle = TimelineDiscloseCircle(center: $0.location.coordinates, radius: $0.role.discloseRadiusSize)
                    circle.report = $0
                    return circle
                })
            
            mapView.addOverlays(circleOverlays)
            mapView.addAnnotations(annotations)
            
            var timelinePolylines = [TimelinePolyline]()
            
            for i in 0..<reports.count-1 {
                let firstReport = reports[i]
                let secondReport = reports[i+1]
                let reports = [firstReport, secondReport]
                let timelinePolyline = TimelinePolyline(coordinates: reports.map({$0.location.coordinates}), count: reports.count)
                timelinePolyline.reports = reports
                timelinePolylines.append(timelinePolyline)
            }
            
            mapView.addOverlays(timelinePolylines, level: .aboveLabels)
            
            if let latestTimelineRect = timelinePolylines.latestTimelineRect() {
                mapView.setVisibleMapRect(latestTimelineRect, edgePadding: TimelinePolyline.edgePadding, animated: false)
            } else {
                if (annotations.count == 1) {
                    mapView.setRegion(annotations.first!.region, animated: false)
                } else if (circleOverlays.count == 1) {
                    mapView.setVisibleMapRect(circleOverlays.first!.boundingMapRect, edgePadding: TimelineDiscloseCircle.discloseLocationEdgePadding, animated: false)
                }
            }
        }
    }
    
    //    @objc
    //    private func mapTapGestureRecognized(_ gesture: UITapGestureRecognizer) {
    //        if let mapView {
    //            let gestureLocation = gesture.location(in: mapView)
    //            let coordinate = mapView.convert(gestureLocation, toCoordinateFrom: mapView)
    //            
    //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    //                
    //                var circleOverlays = [TimelineDiscloseCircle]()
    //                
    //                let tapLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    //                
    //                guard (mapView.selectedAnnotations.isEmpty) else { return }
    //                
    //                for overlay in mapView.overlays {
    //                    if let overlay = overlay as? TimelineDiscloseCircle {
    //                        let distance = overlay.coordinate.location.distance(from: tapLocation)
    //                        if distance <= overlay.radius {
    //                            overlay.distanceFromTapGesture = Int(distance)
    //                            circleOverlays.append(overlay)
    //                        }
    //                    }
    //                }
    //                
    //                if (circleOverlays.count == 1) {
    //                    if let firstCircle = circleOverlays.first {
    //                        self.selectAnnotation(firstCircle.report)
    //                    }
    //                } else {
    //                    if let bestCircle = circleOverlays.sorted(by: {$0.distanceFromTapGesture < $1.distanceFromTapGesture}).first {
    //                        self.selectAnnotation(bestCircle.report)
    //                    }
    //                }
    //            }
    //        }
}


extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
