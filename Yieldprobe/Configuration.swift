//
//  Configuration.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 10.10.19.
//

import Foundation

public struct Configuration {
    
    /// Specify the app name to be transmitted to Yieldprobe.
    ///
    /// Default: `nil`
    public var appName: String?
    
    /// Specify a bundle ID to be transmitted to Yieldprobe.
    ///
    /// Default: `nil`
    public var bundleID: String?
    
    /// Additional targeting information that will be present the each bid probe request.
    ///
    /// Default: Empty.
    public var extraTargeting: [String: String]
    
    /// Specify whether Yieldprobe should use personal information.
    ///
    /// If set to `false`, personal information such as geolocation, IDFA, device type, and connection
    /// type will not be sent over the network.
    ///
    /// Default: `true`
    public var personalizeAds: Bool
    
    /// Specify the app store URL for this app.
    ///
    /// If set, Yieldprobe will include this information in the request to allow for better targeting.
    ///
    /// Default: `nil`
    public var storeURL: URL?
    
    /// Specify whether Yieldprobe should use Geolocation data.
    ///
    /// If `false`, Yieldprobe will not try to access geolocation information, even if it is available to the
    /// application. If `true`, Yieldprobe will try to access geolocation information only if the app already
    /// has access to it. Yieldprobe will not cause location permission prompts in your application.
    ///
    /// Default: `true`
    public var useGeolocation: Bool
    
    public init (appName: String? = nil,
                 bundleID: String? = nil,
                 storeURL: URL? = nil,
                 personalizeAds: Bool = true,
                 useGeolocation: Bool = true,
                 extraTargeting: [String: String] = [:])
    {
        self.appName = appName
        self.bundleID = bundleID
        self.extraTargeting = extraTargeting
        self.personalizeAds = personalizeAds
        self.storeURL = storeURL
        self.useGeolocation = useGeolocation
    }
    
}

@objc(YLDConfiguration)
public class _ObjCConfiguration: NSObject {
    
    
    /// Specify the app name to be transmitted to Yieldprobe.
    ///
    /// Default: `nil`
    @available(swift, obsoleted: 1.0,
               message: "This is Objective-C compatibility API only.")
    @objc
    public var appName: String? {
        get {
            configuration.appName
        }
        set {
            configuration.appName = newValue
        }
    }
    
    /// Specify a bundle ID to be transmitted to Yieldprobe.
    ///
    /// Default: `nil`
    @available(swift, obsoleted: 1.0,
               message: "This is Objective-C compatibility API only.")
    @objc
    public var bundleID: String? {
        get {
            configuration.bundleID
        }
        set {
            configuration.bundleID = newValue
        }
    }
    
    /// Additional targeting information that will be present the each bid probe request.
    ///
    /// Default: Empty.
    @available(swift, obsoleted: 1.0,
               message: "This is Objective-C compatibility API only.")
    @objc
    public var extraTargeting: [String: String] {
        get {
            configuration.extraTargeting
        }
        set {
            configuration.extraTargeting = newValue
        }
    }
    
    /// Specify whether Yieldprobe should use personal information.
    ///
    /// If set to `NO`, personal information such as geolocation, IDFA, device type, and connection
    /// type will not be sent over the network.
    ///
    /// Default: `YES`
    @available(swift, obsoleted: 1.0,
               message: "This is Objective-C compatibility API only.")
    @objc
    public var personalizeAds: Bool {
        get {
            configuration.personalizeAds
        }
        set {
            configuration.personalizeAds = newValue
        }
    }
    
    /// Specify the app store URL for this app.
    ///
    /// If set, Yieldprobe will include this information in the request to allow for better targeting.
    ///
    /// Default: `nil`
    @available(swift, obsoleted: 1.0,
               message: "This is Objective-C compatibility API only.")
    @objc
    public var storeURL: URL? {
        get {
            configuration.storeURL
        }
        set {
            configuration.storeURL = newValue
        }
    }
    
    /// Specify whether Yieldprobe should use Geolocation data.
    ///
    /// If `NO`, Yieldprobe will not try to access geolocation information, even if it is available to the
    /// application. If `YES`, Yieldprobe will try to access geolocation information only if the app already
    /// has access to it. Yieldprobe will not cause location permission prompts in your application.
    ///
    /// Default: `YES`
    @available(swift, obsoleted: 1.0,
               message: "This is Objective-C compatibility API only.")
    @objc
    public var useGeolocation: Bool {
        get {
            configuration.useGeolocation
        }
        set {
            configuration.useGeolocation = newValue
        }
    }
    
    var configuration = Configuration()
    
    /// Create a new configuration.
    @available(swift, obsoleted: 1.0)
    public override init() { }
    
}

extension Yieldprobe {
    
    @available(swift, obsoleted: 1.0,
               message: "This is Objective-C compatibility API only.")
    @objc(configure:)
    public func configure(using configuration: _ObjCConfiguration) {
        configure(using: configuration.configuration)
    }
    
}
