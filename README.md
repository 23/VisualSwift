# VisualSwift

[![Version](https://img.shields.io/cocoapods/v/VisualSwift.svg?style=flat)](http://cocoapods.org/pods/VisualSwift)
[![License](https://img.shields.io/cocoapods/l/VisualSwift.svg?style=flat)](http://cocoapods.org/pods/VisualSwift)
[![Platform](https://img.shields.io/cocoapods/p/VisualSwift.svg?style=flat)](http://cocoapods.org/pods/VisualSwift)

Swift library for interfacing with the [TwentyThree API](https://www.twentythree.net/api/).

## Usage

After installation, import `VisualSwift` and init an API object with the domain and protocol of you TwentyThree account:

```swift
import VisualSwift

let visualAPI = VisualSwift(domain: "video.twentythree.net", scheme: "https")
```

If you need authorized access and have obtained the required API credentials, include these as a third argument when initializing the API object:

```swift
let credentials = [
    "consumer_key": "<consumer key>",
    "consumer_secret": "<consumer secret>",
    "access_token": "<access token>",
    "access_token_secret": "<access token secret>"
]
let visualAPI = VisualSwift(domain: "video.twentythree.net", scheme: "https", credentials: credentials)
```

### Make requests

Now you're ready to start making requests against the API by calling the `request()` method of your API object. Read the API documentation on [https://www.twentythree.net/api](https://www.twentythree.net/api) to get a list of available endpoints.

```swift
// Simple request
visualAPI.request("/api/photo/list") {
    result in
    if result.isSuccess {
        print(result.value)
    }
}

// Request with parameters
let parameters = [
    "album_id": "123456"
]
visualAPI.request("/api/photo/list", parameters: parameters) {...}

// Specify request method
let method = "GET"
visualAPI.request("/api/photo/list", parameters: parameters, method: method) {...}

// Specify cache usage
let useCache = true
visualAPI.request("/api/photo/list", parameters: parameters, method: method, useCache: useCache) {...}
```

### Upload videos

```swift
let parameters = [
    "title": "My new video"
]
let fileURL: NSURL = <NSURL object>
visualAPI.uploadFile("/api/photo/upload", parameters: parameters, fileURL: fileURL, progressCallback: {
    progress in
    dispatch_async(dispatch_get_main_queue(), {
        print(progress)
    })
}) {
    result in
    if result.isSuccess {
        print(result.value)
    }
}
```

## Installation

### CocoaPods

VisualSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "VisualSwift"
```

### Manual

Copy `VisualSwift.swift` and `VisualSwiftUtils.swift` from [/Pod/Classes/](https://github.com/23/VisualSwift/tree/master/Pod/Classes) into your Xcode project.

## Author

Kalle Kabell, kkabell@gmail.com

## License

VisualSwift is available under the MIT license. See the LICENSE file for more info.
