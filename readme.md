# Yieldprobe SDK for iOS

## Repository Layout

* `Package.swift`: Meta Data for Swift Package Manager.
* `Sources`: Source code for Swift Package.
* `Tests`: Test Code for Swift Package.
* `SDK.xcodeproj`: The Xcode project used for development. Contains a test harness.
* `XcodeWrapper`: A folder containing the Xcode project `Dummy`. This Xcode project depends on the Swift Package.

## Known Issues

### `swift build` in the Command Line

`swift build` is known to be incapable of building standalone packages for iOS:

```
$ swift build
Sources/Yieldprobe/Extensions/UIDevice+YLD.swift:8:8: error: no such module 'UIKit'
import UIKit
       ^
…
# 
```

For command line builds, use the provided `XcodeWrapper`:

```
$ xcodebuild build -project XcodeWrapper/Dummy.xcodeproj -scheme Dummy
```
