# Yieldprobe for iOS

The module `Yieldprobe` provides an API to access the [Yieldprobe Optimization Service](https://www.yieldlab.com/publisher/#yield-optimisation).

* [API Reference](https://yieldlab.github.io/yieldprobe-sdk-ios/)

## Integration

1. Select your Xcode project in the sidebar
2. Select the project above the list of targets
3. Select the tab *“Swift Packages”*
4. Enter this value in the search bar `https://github.com/yieldlab/yieldprobe-sdk-ios.git`
5. Click *“Next”*
6. Select *“Version”* → *“Up to Next Major”* → *“1.0.0”* (Xcode will prefill *“< 2.0.0”* for you)
7. Click *“Next”*
8. In the list *“Choose package product and targets:”* make sure you add *“Yieldprobe, Library”* to your app target.
9. Import Yieldprobe into your code: `import Yieldprobe`
10. Start using the Yieldprobe API.

Yieldprobe works with full
[App Transport Security (ATS)](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html)
enabled. However, it's likely that other components require you to disable ATS. See the documentation of affected components for details.

## Configuration

```swift
// Configure the SDK
var config = Yielprobe.Configuration()
config.appName = "My App"
config.bundleID = "com.example.my-app"
config.personalizeAds = true // see data privacy section for details
Yieldprobe.shared.configure(using: config)
```

## Header Bidding

```swift
Yieldprobe.shared.probe(slot: <#adSlotID#>) { result in
    do {
        let bid = try result.get()
        let dfp = DFPRequest()
        dfp.customTargeting = try bid.customTargeting() 
        // TODO: Apply targeting to ad server request.
    } catch {
        // TODO: Handle errors like no bids, network failures, etc. 
    }
}
```

## Data Privacy

In order to comply with data privacy regulations, Yieldprobe provides a way to configure its behavior in certain ways:

1. Use `Configuration.personalizeAds` to specify whether (or not) to pass personal data to the server.
2. Use `Configuration.useGeolocation` to restrict access to geolocation data (will not be used if `personalizeAds` is `false`).
3. An [IAB Consent String](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Mobile%20In-App%20Consent%20APIs%20v1.0%20Final.md) will be read from `UserDefaults` and – if found – will be forwarded to the Yieldprobe servers. If you use an IAB compliant CMP, this will be picked up automatically.
