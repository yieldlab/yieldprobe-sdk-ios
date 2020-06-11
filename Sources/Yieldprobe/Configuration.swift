//
//  Configuration.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 10.10.19.
//

import Foundation

/// Configuration for the Yieldprobe SDK.
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
    /// Default: `[:]`
    public var extraTargeting = [String: String]()
    
    /// Specify whether Yieldprobe should use personal information.
    ///
    /// If set to `false`, personal information such as geolocation, IDFA, device type, and connection
    /// type will not be sent over the network.
    ///
    /// Default: `true`
    public var personalizeAds = true
    
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
    public var useGeolocation = true
    
    /// Create a default `Configuration`.
    public init () {}
    
}
