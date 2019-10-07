//
//  LocationDecorator.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import CoreLocation
import Foundation
import UIKit

protocol Application {
    
    var applicationState: UIApplication.State { get }
    
}

extension UIApplication: Application { }

protocol LocationSource {
    
    var location: CLLocation? { get }
    
    init()
    
    static func authorizationStatus () -> CLAuthorizationStatus
    
    static func locationServicesEnabled () -> Bool
    
}

struct LocationDecorator: URLDecorator {
    
    let application: Application
    
    let locationSource: LocationSource.Type
    
    init (application: Application? = nil,
          locationSource: LocationSource.Type? = nil)
    {
        self.application = application ?? UIApplication.shared
        self.locationSource = locationSource ?? CLLocationManager.self
    }
    
    func currentLocation () -> CLLocation? {
        guard locationSource.locationServicesEnabled() else {
            return nil
        }
        
        switch locationSource.authorizationStatus() {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            if application.applicationState == .background {
                return nil
            }
        case .denied, .notDetermined, .restricted:
            fallthrough
        @unknown default:
            return nil
        }
        
        return locationSource.init().location.flatMap {
            $0.horizontalAccuracy >= 0 ? $0 : nil
        }
    }
    
    func decorate(_ subject: URL) -> URL {
        guard let location = currentLocation() else {
            return subject
        }
        
        return URLComponents(url: subject, resolvingAgainstBaseURL: true)!
            .transformQueryItems { input in
                input + [
                    URLQueryItem(name: "lat", value: "\(location.coordinate.latitude)"),
                    URLQueryItem(name: "lng", value: "\(location.coordinate.longitude)")
                ]
            }.url!
    }
    
}
