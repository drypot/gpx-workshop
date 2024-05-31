//
//  LocationObserverTestView.swift
//  GPXWorkshop
//
//  Created by drypot on 2024-04-14.
//

import SwiftUI
import Combine
import CoreLocation

struct LocationObserverTestView: View {
    
    @ObservedObject var observer: LocationObserver
    
    var body: some View {
        let statusDesc = string(from: observer.authorizationStatus)
        let locationDesc = string(from: observer.currentLocation)
        let errorDesc = observer.error?.localizedDescription ?? ""
        print("---")
        print("status: \(statusDesc)")
        print("location: \(locationDesc)")
        print("error: \(errorDesc)")
        
        return VStack {
            Button("request current location") {
                observer.requestLocation()
            }
        }
        .padding()
        .onAppear {
            observer.requestAuthorization()
        }
    }
    
    func string(from location: CLLocation?) -> String  {
        if let location {
            "\(location.coordinate.latitude) \(location.coordinate.longitude)"
        } else {
            "nil"
        }
    }
 
    func string(from status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            "not determined"
        case .restricted:
            "restricted"
        case .denied:
            "denied"
        case .authorizedAlways, .authorizedWhenInUse:
            "authorized"
        @unknown default:
            "auth unknown"
        }
    }
    
}

#Preview {
    LocationObserverTestView(observer: LocationObserver())
}
