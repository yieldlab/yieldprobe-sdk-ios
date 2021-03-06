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
    
    var configuration: Configuration = Configuration()
    
    private(set) var connectivitySource: ConnectivitySource?
    
    private var consentSource: ConsentSource?
    
    private(set) var device: Device?
    
    let http: HTTPClient
    
    private(set) var idfaSource: IDFASource?
    
    private(set) var locationSource: LocationSource.Type?
    
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
        self.http = http ?? Yieldprobe.defaultClient
        self.connectivitySource = connectivitySource
        self.consentSource = consentSource
        self.device = device
        self.idfaSource = idfa
        self.locationSource = locationSource
    }
    
    /// Configure Yieldprobe
    ///
    /// Pass a `Configuration` to modify the behavior of Yieldprobe.
    public func configure(using configuration: Configuration) {
        self.configuration = configuration
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
            .decorate(URLDecorators.appName(from: configuration),
                      URLDecorators.appStoreURL(from: configuration),
                      URLDecorators.bundleID(from: configuration),
                      URLDecorators.cacheBuster(),
                      URLDecorators.personalize(if: configuration.personalizeAds,
                                                URLDecorators
                                                    .connectivity(from: connectivitySource)),
                      URLDecorators.consent(from: consentSource),
                      URLDecorators.personalize(if: configuration.personalizeAds,
                                                URLDecorators.type(of: device)),
                      URLDecorators.extraTargeting(from: configuration),
                      URLDecorators.personalize(if: configuration.personalizeAds,
                                                URLDecorators.idfa(from: idfaSource)),
                      URLDecorators.personalize(if: configuration.personalizeAds && configuration.useGeolocation,
                                                URLDecorators
                                                    .geolocation(from: locationSource)))
        http.get(url: url, timeout: timeout) { result in
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
