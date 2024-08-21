//
//  Workplace.swift
//  GPXWorkshop
//
//  Created by Kyuhyun Park on 8/20/24.
//

import Foundation
import MapKit

class Workplace {
    
    weak var mapView: MKMapView!
    weak var undoManager: UndoManager!
 
    private var polylines: Set<MKPolyline> = []
    private var selectedPolylines: Set<MKPolyline> = []

    func dumpDebugInfo() {
        print("---")
        print("polylines: \(polylines.count)")
    }

    func importGPX(from data: Data) throws {
        let polylines = try MKPolyline.polylines(from: data)
        append(polylines)
    }
    
    func importGPX(from urls: [URL], complete: @escaping () -> Void) {
        Task { [unowned self] in
            let newPolylines = try await MKPolyline.polylines(from: urls)
            Task { @MainActor in
                self.append(newPolylines)
                complete()
            }
        }
    }
    
    func exportGPX() {
        print("Export GPX")
    }
    
    @objc func append(_ polylines: [MKPolyline]) {
        print("in workplace \(String(describing: undoManager))")
        undoManager?.registerUndo(withTarget: self, selector: #selector(delete), object: polylines)
        polylines.forEach { polyline in
            self.polylines.insert(polyline)
            mapView.addOverlay(polyline)
        }
        zoomToFitAllOverlays()
    }
    
    @objc func delete(_ polylines: [MKPolyline]) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(append), object: polylines)
        polylines.forEach { polyline in
            self.polylines.remove(polyline)
            mapView.removeOverlay(polyline)
        }
    }

    func zoomToFitAllOverlays() {
        var zoomRect = MKMapRect.null
        mapView.overlays.forEach { overlay in
            zoomRect = zoomRect.union(overlay.boundingMapRect)
        }
        if !zoomRect.isNull {
            let edgePadding = NSEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
            mapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: false)
        }
    }

    func isSelected(_ polyline: MKPolyline) -> Bool {
        return selectedPolylines.contains(polyline)
    }
    
    @objc func select(_ polyline: MKPolyline) {
        undoManager.registerUndo(withTarget: self, selector: #selector(deselect), object: polyline)
        selectedPolylines.insert(polyline)
        mapView.removeOverlay(polyline)
        mapView.addOverlay(polyline)
    }
    
    @objc func deselect(_ polyline: MKPolyline) {
        undoManager.registerUndo(withTarget: self, selector: #selector(select(_:)), object: polyline)
        selectedPolylines.remove(polyline)
        mapView.removeOverlay(polyline)
        mapView.addOverlay(polyline)
    }

    @objc func selectAll(_ polylines: Set<MKPolyline>) {
        undoManager.registerUndo(withTarget: self, selector: #selector(deselectAll), object: nil)
        selectedPolylines = polylines
        for polyline in polylines {
            mapView.removeOverlay(polyline)
            mapView.addOverlay(polyline)
        }
    }
    
    @objc func deselectAll() {
        undoManager.registerUndo(withTarget: self, selector: #selector(selectAll), object: selectedPolylines)
        let polylines = selectedPolylines
        selectedPolylines.removeAll()
        for polyline in polylines {
            mapView.removeOverlay(polyline)
            mapView.addOverlay(polyline)
        }
    }

    func select(at point: NSPoint) {
        undoManager?.beginUndoGrouping()
        deselectAll()
        toggleSelection(at: point)
        undoManager?.endUndoGrouping()
    }
    
    func toggleSelection(at point: NSPoint) {
        if let closest = closestPolyline(from: point) {
            toggleSelection(closest)
        }
    }
    
    func toggleSelection(_ polyline: MKPolyline) {
        if isSelected(polyline) {
            deselect(polyline)
        } else {
            select(polyline)
        }
    }
    
    func closestPolyline(from point: NSPoint) -> MKPolyline? {
        let (mapPoint, tolerance) = mapPoint(at: point)
        var closest: MKPolyline?
        var minDistance: CLLocationDistance = .greatestFiniteMagnitude
        for polyline in polylines {
            let rect = polyline.boundingMapRect.insetBy(dx: -tolerance, dy: -tolerance)
            if !rect.contains(mapPoint) {
                continue
            }
            let distance = distance(from: mapPoint, to: polyline)
            if distance < tolerance, distance < minDistance {
                minDistance = distance
                closest = polyline
            }
        }
        return closest
    }

    func mapPoint(at point: NSPoint) -> (MKMapPoint, CLLocationDistance) {
        let limit = 10.0
        let p1 = MKMapPoint(mapView.convert(point, toCoordinateFrom: mapView))
        let p2 = MKMapPoint(mapView.convert(CGPoint(x: point.x + limit, y: point.y), toCoordinateFrom: mapView))
        let tolerance = p1.distance(to: p2)
        return (p1,tolerance)
    }
    
    @objc func insertSelected(_ polylines: Set<MKPolyline>) {
        undoManager.registerUndo(withTarget: self, selector: #selector(deleteSelected), object: nil)
        selectedPolylines = polylines
        polylines.forEach { polyline in
            self.polylines.insert(polyline)
            mapView.addOverlay(polyline)
        }
    }
    
    @objc func deleteSelected() {
        undoManager.registerUndo(withTarget: self, selector: #selector(insertSelected), object: selectedPolylines)
        selectedPolylines.forEach { polyline in
            self.polylines.remove(polyline)
            mapView.removeOverlay(polyline)
        }
        selectedPolylines.removeAll()
    }
}
