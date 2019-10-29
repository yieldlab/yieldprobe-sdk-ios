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
    
    public enum Error: Swift.Error, Equatable {
        /// The app did not request a single advertising slot.
        case noSlot
        
        /// The app requested more than 10 ad slots.
        case tooManySlots
        
        /// An HTTP error occurred.
        case httpError(statusCode: Int, localizedMessage: String)
        
        /// An unexpected value was encountered in the `Content-Type` header.
        case unsupportedContentType(String?)
        
        /// The format of the reponse could not be parsed.
        case unsupportedFormat
        
        /// No ad is available for this ad slot.
        case noFill
    }

    // MARK: Class Properties
    
    public static let shared = Yieldprobe()
    
    static let defaultClient: HTTPClient = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    
    // MARK: Properties
    
    private(set) var appNameDecorator: AppNameDecorator
    
    private(set) var bundleIDDecorator: BundleIDDecorator
    
    let cacheBuster = CacheBuster()
    
    #if false
    var configuration: Configuration {
        locationDecorator.configuration
    }
    #endif
    
    private(set) var connectivity: PIIDDecoratorFilter<ConnectivityDecorator>
    
    let consent: ConsentDecorator
    
    private(set) var deviceTypeDecorator: PIIDDecoratorFilter<DeviceTypeDecorator>
    
    private(set) var extraTargetingDecorator: ExtraTargetingDecorator
    
    let http: HTTPClient
    
    private(set) var idfaDecorator: PIIDDecoratorFilter<IDFADecorator>
    
    private(set) var locationDecorator: PIIDDecoratorFilter<LocationDecorator>
    
    public var sdkVersion: String {
        Bundle(for: Self.self)
            .object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    // MARK: Object Life-Cycle
    
    init (http: HTTPClient? = nil,
          connectivitySource: ConnectivitySource? = nil,
          consentSource: ConsentSource? = nil,
          device: Device? = nil,
          idfa: IDFASource? = nil,
          locationSource: LocationSource.Type? = nil)
    {
        let configuration = Configuration()
        
        appNameDecorator = AppNameDecorator(configuration: configuration)
        bundleIDDecorator = BundleIDDecorator(configuration: configuration)
        
        self.http = http ?? Yieldprobe.defaultClient
        let connectivity = ConnectivityDecorator(source: connectivitySource)
        self.connectivity = PIIDDecoratorFilter(configuration: configuration,
                                                wrapped: connectivity)
        consent = ConsentDecorator(consentSource: consentSource)
        let deviceTypeDecorator = DeviceTypeDecorator(device: device)
        self.deviceTypeDecorator = PIIDDecoratorFilter(configuration: configuration,
                                                       wrapped: deviceTypeDecorator)
        extraTargetingDecorator = ExtraTargetingDecorator(configuration: configuration)
        idfaDecorator = PIIDDecoratorFilter(configuration: configuration,
                                            wrapped: IDFADecorator(source: idfa))
        let locationDecorator = LocationDecorator(locationSource: locationSource,
                                                  configuration: configuration)
        self.locationDecorator = PIIDDecoratorFilter(configuration: configuration,
                                                     wrapped: locationDecorator)
    }
    
    public func configure(using configuration: Configuration) {
        appNameDecorator.configuration = configuration
        bundleIDDecorator.configuration = configuration
        connectivity.configuration = configuration
        deviceTypeDecorator.configuration = configuration
        extraTargetingDecorator.configuration = configuration
        idfaDecorator.configuration = configuration
        locationDecorator.configuration = configuration
        locationDecorator.wrapped.configuration = configuration
    }
    
    // MARK: Bid Requests
    
    public func probe (slot slotID: Int,
                       timeout: TimeInterval? = nil,
                       queue: DispatchQueue? = nil,
                       completionHandler: @escaping (Result<Bid,Swift.Error>) -> Void)
    {
        probe(slots: [slotID], timeout: timeout, queue: queue) { result in
            completionHandler(result.tryMap {
                guard let result = $0.first else {
                    throw Error.noFill
                }
                
                return result
            })
        }
    }
    
    func probe (slots: Set<Int>,
                timeout: TimeInterval? = nil,
                queue: DispatchQueue? = nil,
                completionHandler: @escaping (Result<[Bid],Swift.Error>) -> Void)
    {
        let queue = queue ?? .main
        let timeout = timeout ?? 5
        precondition(timeout >= 0, "\(#function): The timeout interval must be positive.")

        guard !slots.isEmpty else {
            return queue.async {
                completionHandler(Result {
                    throw Yieldprobe.Error.noSlot
                })
            }
        }
        
        guard slots.count <= 10 else {
            return queue.async {
                completionHandler(Result {
                    throw Yieldprobe.Error.tooManySlots
                })
            }
        }
        
        let baseURL = URL(string: "https://ad.yieldlab.net/yp/?content=json&pvid=true&sdk=1")!
        let url = baseURL
            .appendingPathComponent(slots.map(String.init(_:)).joined(separator: ","))
            .decorate(appNameDecorator, bundleIDDecorator, cacheBuster, connectivity, consent, deviceTypeDecorator, extraTargetingDecorator, locationDecorator, idfaDecorator)
        _ = http.get(url: url, timeout: timeout) { result in
            let result = Result<[Bid],Swift.Error> {
                let reply = try result.get()
                
                if let http = reply.response as? HTTPURLResponse {
                    if http.statusCode != 200 {
                        let message = HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
                        throw Error.httpError(statusCode: http.statusCode,
                                              localizedMessage: message)
                    }
                    let contentType = http.allHeaderFields["Content-Type"] as? String
                    if contentType != "application/json;charset=UTF-8" {
                        throw Error.unsupportedContentType(contentType)
                    }
                }
                
                let jsonBids = try JSONSerialization.jsonObject(with: reply.data, options: [])
                guard let bids = jsonBids as? [[String: Any]] else {
                    throw Error.unsupportedFormat
                }
                struct BidView: Decodable {
                    var id: Int
                    var price: Int?
                    var advertiser: String?
                    var curl: String?
                }
                let decoder = JSONDecoder()
                return try bids.map { bid -> Bid in
                    let data = try JSONSerialization.data(withJSONObject: bid, options: [])
                    let decoded = try decoder.decode(BidView.self, from: data)
                    return Bid(slotID: decoded.id,
                               customTargeting: bid)
                }
            }
            
            queue.async {
                completionHandler(result)
            }
        }
    }
    
}

extension Yieldprobe.Error: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .httpError(let statusCode, let localizedMessage):
            return "Server returned \(statusCode): \(localizedMessage)"
        case .noFill:
            return "No Bid available. Please try again later."
        case .noSlot:
            return "No ad slot provided."
        case .tooManySlots:
            return "Too many ad slots provided."
        case .unsupportedContentType(_):
            return "Server returned unexpected data format."
        case .unsupportedFormat:
            return "Server returned invalid data."
        }
    }
    
}
