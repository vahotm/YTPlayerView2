# YTPlayerView2

youtube-ios-player-helper(https://github.com/youtube/youtube-ios-player-helper) is a great library to play YouTube videos in your iOS app, but it's seemed to be somewhat *discontinued* and now it has some major issues like:

- No Picture-in-Picture support.
- Not taking advantage of the latest Objective-C features like nullability/generics.

So I decided to rewrite the entire library using the latest Objective-C features and the WebKit.framework. I'd like to donate this codebase to the official Google guys if I succeed but I don't know I can :P

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Initialize YTPlayerView

TBD

### Configure YTPlayerView

TBD

### Control YTPlayerView

YTPlayerView internally uses WebKit `WKWebView` rather than `UIWebView` and we call all control methods using JavaScript interface of the YouTube player. This means all the control API of YTPlayerView is now asynchronus so be careful about that.

## Requirements

- Xcode 7.2 or later (Xcode that at least support the Objective-C nullablity/generics features)
- iOS 8 or later

- OSX is not supported (because I'm lazy to support it)
- watchOS is not supported (YouTube requires any web browsers to play and watchOS doesn't have it)
- tvOS is not supported (ditto)

## Installation

### CocoaPods

YouTube-Player-iOS-Helper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "youtube-ios-player-helper"
```

### Carthage

Maybe. I prefer using Carthage these days :D

### Swift Package Manager

Not available because this is not a swift project :P

## Author

akisute(Masashi Ono), akisutesama@gmail.com

## Original Author

Ikai Lan
Ibrahim Ulukaya, ulukaya@google.com
Yoshifumi Yamaguchi, yoshifumi@google.com

## License

YouTube-Player-iOS-Helper is available under the Apache 2.0 license. See the LICENSE file for more info.
