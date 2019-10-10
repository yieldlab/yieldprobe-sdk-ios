//
//  Yieldprobe.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 01.10.19.
//

import Foundation

@available(swift, introduced: 5.0)
public class Yieldprobe: NSObject {
    
    // MARK: Class Properties
    
    public static let shared = Yieldprobe()
    
    static let defaultClient: HTTPClient = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    
    // MARK: Properties
    
    let cacheBuster = CacheBuster()
    
    let connectivity: ConnectivityDecorator
    
    let consent: ConsentDecorator
    
    let deviceTypeDecorator: DeviceTypeDecorator
    
    let http: HTTPClient
    
    let idfaDecorator: IDFADecorator
    
    let locationDecorator: LocationDecorator
    
    public var sdkVersion: String {
        Bundle(for: Self.self)
            .object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    // MARK: Object Life-Cycle
    
    init (http: HTTPClient = Yieldprobe.defaultClient,
          connectivitySource: ConnectivitySource? = nil,
          consentSource: ConsentSource? = nil,
          device: Device? = nil,
          idfa: IDFASource? = nil,
          locationSource: LocationSource.Type? = nil)
    {
        self.http = http
        connectivity = ConnectivityDecorator(source: connectivitySource)
        consent = ConsentDecorator(consentSource: consentSource)
        deviceTypeDecorator = DeviceTypeDecorator(device: device)
        idfaDecorator = IDFADecorator(source: idfa)
        
        let configuration = Configuration()
        locationDecorator = LocationDecorator(locationSource: locationSource,
                                              configuration: configuration)
    }
    
    // MARK: Bid Requests
    
    public func probe (slot slotID: Int, completionHandler: @escaping () -> Void) {
        let baseURL = URL(string: "https://ad.yieldlab.net/yp/?content=json&pvid=true")!
        let url = baseURL
            .appendingPathComponent("\(slotID)")
            .decorate(cacheBuster, connectivity, consent, deviceTypeDecorator, locationDecorator, idfaDecorator)
        http.get(url: url) { result in
            fatalError()
        }
    }
    
}
