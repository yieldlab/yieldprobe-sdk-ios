//
//  Yieldprobe.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 01.10.19.
//

import Foundation

/// The Yieldprobe SDK.
///
/// Use this class to request bids from Yieldprobe.
@available(swift, introduced: 5.0)
public class Yieldprobe: NSObject {
    
    // MARK: Types
    
    typealias Error = BidError
    
    // MARK: Class Properties
    
    /// Yieldprobe Singleton
    ///
    /// Use this instance to communicate with the Yieldprobe API.
    @objc(sharedInstance)
    public static let shared = Yieldprobe()
    
    static let defaultClient: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    
    // MARK: Properties
    
    private(set) var appNameDecorator: AppNameDecorator
    
    private(set) var appStoreDecorator: AppStoreDecorator
    
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
    
    /// Yieldprobe SDK Version
    ///
    /// This property will return the version of the current Yieldprobe iOS SDK.
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
        appStoreDecorator = AppStoreDecorator(configuration: configuration)
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
        appStoreDecorator.configuration = configuration
        bundleIDDecorator.configuration = configuration
        connectivity.configuration = configuration
        deviceTypeDecorator.configuration = configuration
        extraTargetingDecorator.configuration = configuration
        idfaDecorator.configuration = configuration
        locationDecorator.configuration = configuration
        locationDecorator.wrapped.configuration = configuration
    }
    
    // MARK: Bid Requests
    
    /// Request a Bid from Yieldprobe for the specified ad slot ID.
    ///
    /// This method will perform an HTTP request to fetch the most recent bid for the ad slot identified by `slotID`.
    ///
    /// - Parameters:
    ///   - slotID: The ad slot ID used to request a bid.
    ///   - timeout: (*optional*) The maximum time interval to deliver an ad.
    ///   - queue: (*optional*) The target DispatchQueue for the completion handler.
    ///   - completionHandler: The code that will be invoked when a request was either successful or failed. Parameters:
    ///     - result: The result of the bid. Use `try result.get()` to access the bid and handle any errors thrown.
    public func probe (slot slotID: Int,
                       timeout: TimeInterval? = nil,
                       queue: DispatchQueue? = nil,
                       completionHandler: @escaping (Result<Bid,Swift.Error>) -> Void)
    {
        probe(slots: [slotID], timeout: timeout, queue: queue) { result in
            completionHandler(result.tryMap {
                guard let result = $0.first else {
                    throw BidError.noFill
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
                    throw BidError.noSlot
                })
            }
        }
        
        guard slots.count <= 10 else {
            return queue.async {
                completionHandler(Result {
                    throw BidError.tooManySlots
                })
            }
        }
        
        let baseURL = URL(string: "https://ad.yieldlab.net/yp/?content=json&pvid=true&sdk=1")!
        let url = baseURL
            .appendingPathComponent(slots.map(String.init(_:)).joined(separator: ","))
            .decorate(appNameDecorator, appStoreDecorator, bundleIDDecorator, cacheBuster, connectivity, consent, deviceTypeDecorator, extraTargetingDecorator, locationDecorator, idfaDecorator)
        _ = http.get(url: url, timeout: timeout) { result in
            let result = Result<[Bid],Swift.Error> {
                let reply = try result.get()
                
                if let http = reply.response as? HTTPURLResponse {
                    if http.statusCode != 200 {
                        let message = HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
                        throw BidError.httpError(statusCode: http.statusCode,
                                                 localizedMessage: message)
                    }
                    let contentType = http.allHeaderFields["Content-Type"] as? String
                    if contentType != "application/json;charset=UTF-8" {
                        throw BidError.unsupportedContentType(contentType)
                    }
                }
                
                let jsonBids = try JSONSerialization.jsonObject(with: reply.data, options: [])
                guard let bids = jsonBids as? [[String: Any]] else {
                    throw BidError.unsupportedFormat
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

/// Turn an Objective-C completion handler into a modern one using Swift 5's result type.
private func modernize<Success>(_ legacy: @escaping (Success?, Swift.Error?) -> Void)
    -> (Result<Success,Error>) -> Void
{
    return { result in
        do {
            let bid = try result.get()
            return legacy(bid, nil)
        } catch {
            return legacy(nil, error)
        }
    }
}

extension Yieldprobe {
    
    // MARK: - Objective-C Compatibility
    
    /// Request a bid for a specific ad slot ID.
    ///
    /// @slotID: Sliff.
    ///
    /// - Parameters:
    ///   - slotID: The ad slot ID for the bid request.
    ///   - queue: The target queue for `completionHandler`.
    ///   - completionHandler: The block to be invoked when the request is complete. Parameters:
    ///       - bid: Successful requests will pass an instance of `YLDBid`.
    ///       - error: Faild requests will pass an instance of `NSError`.
    ///
    /// Note: `Yieldprobe` will always provide `nil` for exactly one of the two completion handler
    /// arguments.
    @available(swift, obsoleted: 1.0,
               message: "This is Objective-C compatibility API only.")
    @objc
    public func probe (slot slotID: Int,
                       queue: DispatchQueue,
                       completionHandler: @escaping (Bid?,Swift.Error?) -> Void)
    {
        probe(slot: slotID, queue: queue, completionHandler: modernize(completionHandler))
    }
    
    /// Probe for a bid.
    ///
    /// This method is just a convenient replacement for `-probeWithSlot:queue:completionHandler:`.
    /// The `completionHandler` will be called on the main queue.
    ///
    /// Note: `Yieldprobe` will always provide `nil` for exactly one of the two completion handler
    /// arguments.
    @available(swift, obsoleted: 1.0,
               message: "This is Objective-C compatibility API only.")
    @objc
    public func probe (slot slotID: Int,
                       completionHandler: @escaping (Bid?,Swift.Error?) -> Void)
    {
        probe(slot: slotID, queue: nil, completionHandler: modernize(completionHandler))
    }
    
}
