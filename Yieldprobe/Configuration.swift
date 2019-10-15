//
//  Configuration.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 10.10.19.
//

import Foundation

public struct Configuration {
    
    /// Specify whether Yieldprobe should use Geolocation data.
    ///
    /// If `false`, Yieldprobe will not try to access geolocation information, even if it is available to the
    /// application. If `true`, Yieldprobe will try to access geolocation information only if the app already
    /// has access to it. Yieldprobe will not cause location permission prompts in your application.
    ///
    /// Default: `true`
    var useGeolocation: Bool
    
    /// Specify whether Yieldprobe should use personal information.
    ///
    /// If set to `false`, personal information such as geolocation, IDFA, device type, and connection
    /// type will not be sent over the network.
    ///
    /// Default: `true`
    var personalizeAds: Bool
    
    public init (personalizeAds: Bool = true,
                 useGeolocation: Bool = true)
    {
        self.personalizeAds = personalizeAds
        self.useGeolocation = useGeolocation
    }
    
}
