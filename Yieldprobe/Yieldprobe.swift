//
//  Yieldprobe.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 01.10.19.
//

import Foundation

@available(swift, introduced: 5.0)
public class Yieldprobe: NSObject {
    
    // MARK: Types
    
    enum Error: Swift.Error, Equatable {
        /// The app did not request a single advertising slot.
        case noSlot
        
        /// The app requested more than 10 ad slots.
        case tooManySlots
        
        /// An HTTP error occurred.
        case httpError(statusCode: Int, localizedMessage: String)
    }

    // MARK: Class Properties
    
    public static let shared = Yieldprobe()
    
    static let defaultClient: HTTPClient = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    
    // MARK: Properties
    
    let cacheBuster = CacheBuster()
    
    #if false
    var configuration: Configuration {
        locationDecorator.configuration
    }
    #endif
    
    private(set) var connectivity: PIIDDecoratorFilter<ConnectivityDecorator>
    
    let consent: ConsentDecorator
    
    private(set) var deviceTypeDecorator: PIIDDecoratorFilter<DeviceTypeDecorator>
    
    let http: HTTPClient
    
    private(set) var idfaDecorator: PIIDDecoratorFilter<IDFADecorator>
    
    private(set) var locationDecorator: PIIDDecoratorFilter<LocationDecorator>
    
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
        let configuration = Configuration()
        
        self.http = http
        let connectivity = ConnectivityDecorator(source: connectivitySource)
        self.connectivity = PIIDDecoratorFilter(configuration: configuration,
                                                wrapped: connectivity)
        consent = ConsentDecorator(consentSource: consentSource)
        let deviceTypeDecorator = DeviceTypeDecorator(device: device)
        self.deviceTypeDecorator = PIIDDecoratorFilter(configuration: configuration,
                                                       wrapped: deviceTypeDecorator)
        idfaDecorator = PIIDDecoratorFilter(configuration: configuration,
                                            wrapped: IDFADecorator(source: idfa))
        let locationDecorator = LocationDecorator(locationSource: locationSource,
                                                  configuration: configuration)
        self.locationDecorator = PIIDDecoratorFilter(configuration: configuration,
                                                     wrapped: locationDecorator)
    }
    
    func configure(using configuration: Configuration) {
        connectivity.configuration = configuration
        deviceTypeDecorator.configuration = configuration
        idfaDecorator.configuration = configuration
        locationDecorator.configuration = configuration
        locationDecorator.wrapped.configuration = configuration
    }
    
    // MARK: Bid Requests
    
    public func probe (slot slotID: Int, completionHandler: @escaping (Result<Bid,Swift.Error>) -> Void) {
        probe(slots: [slotID]) { result in
            completionHandler(result.map { _ in
                fatalError("Unimplemented")
            })
        }
    }
    
    func probe (slots: Set<Int>, completionHandler: @escaping (Result<[Bid],Swift.Error>) -> Void) {
        guard !slots.isEmpty else {
            return DispatchQueue.main.async {
                completionHandler(Result {
                    throw Yieldprobe.Error.noSlot
                })
            }
        }
        
        guard slots.count <= 10 else {
            return DispatchQueue.main.async {
                completionHandler(Result {
                    throw Yieldprobe.Error.tooManySlots
                })
            }
        }
        
        let baseURL = URL(string: "https://ad.yieldlab.net/yp/?content=json&pvid=true")!
        let url = baseURL
            .appendingPathComponent(slots.map(String.init(_:)).joined(separator: ","))
            .decorate(cacheBuster, connectivity, consent, deviceTypeDecorator, locationDecorator, idfaDecorator)
        http.get(url: url) { result in
            completionHandler(Result {
                let reply = try result.get()
                
                if let http = reply.response as? HTTPURLResponse {
                    if http.statusCode != 200 {
                        let message = HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
                        throw Error.httpError(statusCode: http.statusCode,
                                              localizedMessage: message)
                    }
                }
                
                fatalError("Unimplemented.")
            })
        }
    }
    
}
