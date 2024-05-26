//
//  MapKitMapViewUsingNSKit.swift
//  DrypotGPX
//
//  Created by Kyuhyun Park on 5/24/24.
//

import Foundation
import SwiftUI
import MapKit

struct SegmentsView: NSViewRepresentable {

    @ObservedObject var segments: SegmentsViewModel
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: SegmentsView

        init(_ parent: SegmentsView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let segments = parent.segments
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                if segments.isSelectedSegment(polyline) {
                    renderer.strokeColor = .red
                } else {
                    renderer.strokeColor = .blue
                }
                renderer.lineWidth = 3.0
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        @objc func handleTap(_ gesture: NSGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let tapPoint = gesture.location(in: mapView)
            
            let p1 = MKMapPoint(mapView.convert(tapPoint, toCoordinateFrom: mapView))
            let p2 = MKMapPoint(mapView.convert(CGPoint(x: tapPoint.x + 10, y: tapPoint.y), toCoordinateFrom: mapView))
            let tolerance = p1.distance(to: p2)

            if let closest = parent.segments.closestSegment(from: p1, tolerance: tolerance) {
                parent.segments.toggleSegmentSelection(closest)
            }
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeNSView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let tapGesture = NSClickGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }

    func updateNSView(_ mapView: MKMapView, context: Context) {
        segments.sync(with: mapView)
    }
}

#Preview {
    let segments = SegmentsViewModel()
    return SegmentsView(segments: segments)
}
