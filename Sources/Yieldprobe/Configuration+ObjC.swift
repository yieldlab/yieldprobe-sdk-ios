//
//  Configuration+ObjC.swift
//  Test Host
//
//  Created by Sven Herzberg on 06.06.20.
//

import Foundation

/// Configuration for Yieldprobe
///
/// This is a type bridge
@objc(YLDConfiguration)
public class YLDConfiguration: NSObject {
    
    
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
    
    var configuration: Configuration
    
    /// Create a new configuration.
    @available(swift, obsoleted: 1.0,
               message: "This is Objective-C compatibility API only.")
    public override init() {
        self.configuration = Configuration()
    }
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    /// Copy the object.
    ///
    /// See: [`NSObject.copy()`](https://developer.apple.com/documentation/objectivec/nsobject/1418807-copy).
    public override func copy() -> Any {
        YLDConfiguration(configuration: configuration)
    }
    
}

extension Yieldprobe {
    
    @available(swift, obsoleted: 1.0,
               message: "This is Objective-C compatibility API only.")
    @objc(configure:)
    public func configure(using configuration: YLDConfiguration) {
        configure(using: configuration.configuration)
    }
    
}
