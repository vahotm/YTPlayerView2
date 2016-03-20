// Copyright 2014 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "YTPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const YTPlayerErrorDomain = @"YTPlayerErrorDomain";

// These are instances of NSString because we get them from parsing a URL. It would be silly to
// convert these into an integer just to have to convert the URL query string value into an integer
// as well for the sake of doing a value comparison. A full list of response error codes can be
// found here:
//   https://developers.google.com/youtube/iframe_api_reference
NSString static * const YTPlayerStateUnstartedCode = @"-1";
NSString static * const YTPlayerStateEndedCode = @"0";
NSString static * const YTPlayerStatePlayingCode = @"1";
NSString static * const YTPlayerStatePausedCode = @"2";
NSString static * const YTPlayerStateBufferingCode = @"3";
NSString static * const YTPlayerStateCuedCode = @"5";
NSString static * const YTPlayerStateUnknownCode = @"unknown";

// Constants representing playback quality.
NSString static * const YTPlaybackQualitySmallQuality = @"small";
NSString static * const YTPlaybackQualityMediumQuality = @"medium";
NSString static * const YTPlaybackQualityLargeQuality = @"large";
NSString static * const YTPlaybackQualityHD720Quality = @"hd720";
NSString static * const YTPlaybackQualityHD1080Quality = @"hd1080";
NSString static * const YTPlaybackQualityHighResQuality = @"highres";
NSString static * const YTPlaybackQualityAutoQuality = @"auto";
NSString static * const YTPlaybackQualityDefaultQuality = @"default";
NSString static * const YTPlaybackQualityUnknownQuality = @"unknown";

// Constants representing YouTube player errors.
NSString static * const YTPlayerErrorInvalidParamErrorCode = @"2";
NSString static * const YTPlayerErrorHTML5ErrorCode = @"5";
NSString static * const YTPlayerErrorVideoNotFoundErrorCode = @"100";
NSString static * const YTPlayerErrorNotEmbeddableErrorCode = @"101";
NSString static * const YTPlayerErrorCannotFindVideoErrorCode = @"105";
NSString static * const YTPlayerErrorSameAsNotEmbeddableErrorCode = @"150";

// Constants representing player callbacks.
NSString static * const YTPlayerCallbackOnReady = @"onReady";
NSString static * const YTPlayerCallbackOnStateChange = @"onStateChange";
NSString static * const YTPlayerCallbackOnPlaybackQualityChange = @"onPlaybackQualityChange";
NSString static * const YTPlayerCallbackOnError = @"onError";
NSString static * const YTPlayerCallbackOnPlayTime = @"onPlayTime";
NSString static * const YTPlayerCallbackOnYouTubeIframeAPIReady = @"onYouTubeIframeAPIReady";
NSString static * const YTPlayerCallbackOnYouTubeIframeAPIFailedToLoad = @"onYouTubeIframeAPIFailedToLoad";

// Constants for regex patterns.
NSString static * const YTPlayerEmbedUrlRegexPattern = @"^http(s)://(www.)youtube.com/embed/(.*)$";
NSString static * const YTPlayerAdUrlRegexPattern = @"^http(s)://pubads.g.doubleclick.net/pagead/conversion/";
NSString static * const YTPlayerOAuthRegexPattern = @"^http(s)://accounts.google.com/o/oauth2/(.*)$";
NSString static * const YTPlayerStaticProxyRegexPattern = @"^https://content.googleapis.com/static/proxy.html(.*)$";

/**
 * Convert a quality value from NSString to the typed enum value.
 *
 * @param qualityString A string representing playback quality. Ex: "small", "medium", "hd1080".
 * @return An enum value representing the playback quality.
 */
YTPlaybackQuality YTPlaybackQualityFromNSString(NSString *qualityString) {
    YTPlaybackQuality quality = YTPlaybackQualityUnknown;
    
    if ([qualityString isEqualToString:YTPlaybackQualitySmallQuality]) {
        quality = YTPlaybackQualitySmall;
    } else if ([qualityString isEqualToString:YTPlaybackQualityMediumQuality]) {
        quality = YTPlaybackQualityMedium;
    } else if ([qualityString isEqualToString:YTPlaybackQualityLargeQuality]) {
        quality = YTPlaybackQualityLarge;
    } else if ([qualityString isEqualToString:YTPlaybackQualityHD720Quality]) {
        quality = YTPlaybackQualityHD720;
    } else if ([qualityString isEqualToString:YTPlaybackQualityHD1080Quality]) {
        quality = YTPlaybackQualityHD1080;
    } else if ([qualityString isEqualToString:YTPlaybackQualityHighResQuality]) {
        quality = YTPlaybackQualityHighRes;
    } else if ([qualityString isEqualToString:YTPlaybackQualityAutoQuality]) {
        quality = YTPlaybackQualityAuto;
    }
    
    return quality;
}

/**
 * Convert a |YTPlaybackQuality| value from the typed value to NSString.
 *
 * @param quality A |YTPlaybackQuality| parameter.
 * @return An |NSString| value to be used in the JavaScript bridge.
 */
NSString *NSStringFromYTPlaybackQuality(YTPlaybackQuality quality) {
    switch (quality) {
        case YTPlaybackQualitySmall:
            return YTPlaybackQualitySmallQuality;
        case YTPlaybackQualityMedium:
            return YTPlaybackQualityMediumQuality;
        case YTPlaybackQualityLarge:
            return YTPlaybackQualityLargeQuality;
        case YTPlaybackQualityHD720:
            return YTPlaybackQualityHD720Quality;
        case YTPlaybackQualityHD1080:
            return YTPlaybackQualityHD1080Quality;
        case YTPlaybackQualityHighRes:
            return YTPlaybackQualityHighResQuality;
        case YTPlaybackQualityAuto:
            return YTPlaybackQualityAutoQuality;
        default:
            return YTPlaybackQualityUnknownQuality;
    }
}

/**
 * Private method to convert a Objective-C BOOL value to JS boolean value.
 *
 * @param boolValue Objective-C BOOL value.
 * @return JavaScript Boolean value, i.e. "true" or "false".
 */
NSString *NSStringFromYTPlayerJSBoolean(BOOL boolValue) {
    return boolValue ? @"true" : @"false";
}

#pragma mark -


@interface YTPlayerView() <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong, nullable) WKWebView *webView;

@property (nonatomic, strong) NSURL *originURL;
@property (nonatomic, strong, nullable) WKNavigation *htmlLoadingNavigation;
@property (nonatomic) YTPlayerState playerState;

@end

@implementation YTPlayerView

#pragma mark - Init/dealloc

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialize];
    }
    return self;
}

- (void)commonInitialize {
    self.playerState = YTPlayerStateUnknown;
}

#pragma mark - Initial configuration properties

- (void)setBeforeLoadingView:(nullable UIView *)beforeLoadingView {
    if (_beforeLoadingView != nil) {
        [_beforeLoadingView removeFromSuperview];
    }
    _beforeLoadingView = beforeLoadingView;
    // Display the given view immediately if the internal state is `Not Loading Yet`.
    if (self.webView == nil && self.htmlLoadingNavigation == nil) {
        [self showBeforeLoadingView];
    }
}

- (void)setInitialLoadingView:(nullable UIView *)initialLoadingView {
    if (_initialLoadingView != nil) {
        [_initialLoadingView removeFromSuperview];
    }
    _initialLoadingView = initialLoadingView;
    // Display the given view immediately if the internal state is `Loading the YouTube iframe Player`.
    if (self.webView == nil && self.htmlLoadingNavigation != nil) {
        [self showInitialLoadingView];
    }
}

#pragma mark - Initial loading methods

- (BOOL)loadPlayerWithVideoId:(NSString *)videoId {
    return [self loadPlayerWithVideoId:videoId playerVars:nil];
}

- (BOOL)loadPlayerWithPlaylistId:(NSString *)playlistId {
    return [self loadPlayerWithPlaylistId:playlistId playerVars:nil];
}

- (BOOL)loadPlayerWithVideoId:(NSString *)videoId playerVars:(nullable NSDictionary *)playerVars {
    if (playerVars == nil) {
        playerVars = @{};
    }
    NSDictionary *playerParams = @{@"videoId": videoId, @"playerVars": playerVars};
    return [self loadPlayerWithPlayerParams:playerParams];
}

- (BOOL)loadPlayerWithPlaylistId:(NSString *)playlistId playerVars:(nullable NSDictionary *)playerVars {
    NSMutableDictionary *tempPlayerVars = (playerVars == nil) ? [NSMutableDictionary dictionary] : [playerVars mutableCopy];
    tempPlayerVars[@"listType"] = @"playlist";
    tempPlayerVars[@"list"] = playlistId;
    NSDictionary *playerParams = @{@"playerVars": tempPlayerVars};
    return [self loadPlayerWithPlayerParams:playerParams];
}

- (BOOL)loadPlayerWithPlayerParams:(nullable NSDictionary *)additionalPlayerParams {
    NSMutableDictionary *playerParams = (additionalPlayerParams == nil) ? [NSMutableDictionary dictionary] : [additionalPlayerParams mutableCopy];
    if (playerParams[@"height"] == nil) {
        playerParams[@"height"] = @"100%";
    }
    if (playerParams[@"width"] == nil) {
        playerParams[@"width"] = @"100%";
    }
    playerParams[@"events"] = @{@"onReady": @"onReady",
                                @"onStateChange": @"onStateChange",
                                @"onPlaybackQualityChange": @"onPlaybackQualityChange",
                                @"onError": @"onPlayerError"};
    
    NSDictionary *playerVars = playerParams[@"playerVars"];
    if (playerVars != nil) {
        NSString *origin = playerVars[@"origin"];
        NSURL *originURL = [NSURL URLWithString:origin];
        if (originURL != nil) {
            self.originURL = originURL;
        } else {
            self.originURL = [NSURL URLWithString:@"about:blank"];
        }
    } else {
        // playerVars must not be empty.
        playerParams[@"playerVars"] = @{};
        self.originURL = [NSURL URLWithString:@"about:blank"];
    }
    
    // Remove the existing webView to reset any state, then create a new one.
    [self removeWebView];
    self.webView = [self instantiateWebView];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self addSubview:self.webView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.webView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.webView}]];
    
    NSString *htmlPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"YTPlayerView-iframe-player"
                                                                          ofType:@"html"
                                                                     inDirectory:@"youtube-ios-player-helper"];
    
    // In case of using Swift and embedded frameworks, resources included not in main bundle, but in framework bundle.
    if (htmlPath == nil) {
        htmlPath = [[[self class] frameworkBundle] pathForResource:@"YTPlayerView-iframe-player"
                                                            ofType:@"html"
                                                       inDirectory:@"youtube-ios-player-helper"];
    }
    
    NSError *htmlError = nil;
    NSString *embedHTMLTemplate = [NSString stringWithContentsOfFile:htmlPath
                                                            encoding:NSUTF8StringEncoding
                                                               error:&htmlError];
    if (htmlError) {
        NSLog(@"Received error while reading YTPlayerView HTML template: %@", htmlError);
        return NO;
    }
    
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:playerParams
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonError];
    if (jsonError) {
        NSLog(@"Attempted configuration of player with invalid playerVars: %@ \tError: %@",
              playerParams,
              jsonError);
        return NO;
    }
    
    [self hideBeforeLoadingView];
    [self showInitialLoadingView];
    
    NSString *playerVarsJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *embedHTML = [NSString stringWithFormat:embedHTMLTemplate, playerVarsJsonString];
    self.htmlLoadingNavigation = [self.webView loadHTMLString:embedHTML baseURL:self.originURL];
    
    return (self.htmlLoadingNavigation != nil);
}

#pragma mark - Player controls

- (void)playVideo:(nullable YTPlayerViewJSResultVoid)callback {
    [self evaluateJavaScript:@"player.playVideo();" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

- (void)pauseVideo:(nullable YTPlayerViewJSResultVoid)callback {
    __weak typeof(self) weakSelf = self;
    [self evaluateJavaScript:@"player.pauseVideo();" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error == nil) {
            // Update the internal state using the mocked callback URL since the player doesn't cause the callback automatically in this case.
            [weakSelf handleYouTubeCallbackURL:[NSURL URLWithString:[NSString stringWithFormat:@"ytplayer://onStateChange?data=%@", YTPlayerStatePausedCode]]];
        }
        if (callback) {
            callback(error);
        }
    }];
}

- (void)stopVideo:(nullable YTPlayerViewJSResultVoid)callback {
    [self evaluateJavaScript:@"player.stopVideo();" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

- (void)seekToSeconds:(float)seekToSeconds allowSeekAhead:(BOOL)allowSeekAhead callback:(nullable YTPlayerViewJSResultVoid)callback {
    NSNumber *secondsValue = [NSNumber numberWithFloat:seekToSeconds];
    NSString *allowSeekAheadValue = NSStringFromYTPlayerJSBoolean(allowSeekAhead);
    NSString *command = [NSString stringWithFormat:@"player.seekTo(%@, %@);", secondsValue, allowSeekAheadValue];
    [self evaluateJavaScript:command completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

#pragma mark - Queuing videos

- (void)cueVideoById:(NSString *)videoId
        startSeconds:(float)startSeconds
    suggestedQuality:(YTPlaybackQuality)suggestedQuality
            callback:(nullable YTPlayerViewJSResultVoid)callback {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = NSStringFromYTPlaybackQuality(suggestedQuality);
    NSString *command = [NSString stringWithFormat:@"player.cueVideoById('%@', %@, '%@');", videoId, startSecondsValue, qualityValue];
    [self evaluateJavaScript:command completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

- (void)cueVideoById:(NSString *)videoId
        startSeconds:(float)startSeconds
          endSeconds:(float)endSeconds
    suggestedQuality:(YTPlaybackQuality)suggestedQuality
            callback:(nullable YTPlayerViewJSResultVoid)callback {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
    NSString *qualityValue = NSStringFromYTPlaybackQuality(suggestedQuality);
    NSString *command = [NSString stringWithFormat:@"player.cueVideoById({'videoId': '%@', 'startSeconds': %@, 'endSeconds': %@, 'suggestedQuality': '%@'});", videoId, startSecondsValue, endSecondsValue, qualityValue];
    [self evaluateJavaScript:command completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

- (void)loadVideoById:(NSString *)videoId
         startSeconds:(float)startSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality
             callback:(nullable YTPlayerViewJSResultVoid)callback {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = NSStringFromYTPlaybackQuality(suggestedQuality);
    NSString *command = [NSString stringWithFormat:@"player.loadVideoById('%@', %@, '%@');", videoId, startSecondsValue, qualityValue];
    [self evaluateJavaScript:command completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

- (void)loadVideoById:(NSString *)videoId
         startSeconds:(float)startSeconds
           endSeconds:(float)endSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality
             callback:(nullable YTPlayerViewJSResultVoid)callback {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
    NSString *qualityValue = NSStringFromYTPlaybackQuality(suggestedQuality);
    NSString *command = [NSString stringWithFormat:@"player.loadVideoById({'videoId': '%@', 'startSeconds': %@, 'endSeconds': %@, 'suggestedQuality': '%@'});",videoId, startSecondsValue, endSecondsValue, qualityValue];
    [self evaluateJavaScript:command completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

- (void)cueVideoByURL:(NSString *)videoURL
         startSeconds:(float)startSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality
             callback:(nullable YTPlayerViewJSResultVoid)callback {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = NSStringFromYTPlaybackQuality(suggestedQuality);
    NSString *command = [NSString stringWithFormat:@"player.cueVideoByUrl('%@', %@, '%@');", videoURL, startSecondsValue, qualityValue];
    [self evaluateJavaScript:command completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

- (void)cueVideoByURL:(NSString *)videoURL
         startSeconds:(float)startSeconds
           endSeconds:(float)endSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality
             callback:(nullable YTPlayerViewJSResultVoid)callback {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
    NSString *qualityValue = NSStringFromYTPlaybackQuality(suggestedQuality);
    NSString *command = [NSString stringWithFormat:@"player.cueVideoByUrl('%@', %@, %@, '%@');", videoURL, startSecondsValue, endSecondsValue, qualityValue];
    [self evaluateJavaScript:command completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

- (void)loadVideoByURL:(NSString *)videoURL
          startSeconds:(float)startSeconds
      suggestedQuality:(YTPlaybackQuality)suggestedQuality
              callback:(nullable YTPlayerViewJSResultVoid)callback {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = NSStringFromYTPlaybackQuality(suggestedQuality);
    NSString *command = [NSString stringWithFormat:@"player.loadVideoByUrl('%@', %@, '%@');", videoURL, startSecondsValue, qualityValue];
    [self evaluateJavaScript:command completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

- (void)loadVideoByURL:(NSString *)videoURL
          startSeconds:(float)startSeconds
            endSeconds:(float)endSeconds
      suggestedQuality:(YTPlaybackQuality)suggestedQuality
              callback:(nullable YTPlayerViewJSResultVoid)callback {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
    NSString *qualityValue = NSStringFromYTPlaybackQuality(suggestedQuality);
    NSString *command = [NSString stringWithFormat:@"player.loadVideoByUrl('%@', %@, %@, '%@');", videoURL, startSecondsValue, endSecondsValue, qualityValue];
    [self evaluateJavaScript:command completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

#pragma mark - Playing a video in a playlist

- (void)nextVideo:(nullable YTPlayerViewJSResultVoid)callback {
    [self evaluateJavaScript:@"player.nextVideo();" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

- (void)previouVideo:(nullable YTPlayerViewJSResultVoid)callback {
    [self evaluateJavaScript:@"player.previousVideo();" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

- (void)playVideoAt:(NSInteger)index callback:(nullable YTPlayerViewJSResultVoid)callback {
    NSString *command = [NSString stringWithFormat:@"player.playVideoAt(%@);", [NSNumber numberWithInteger:index]];
    [self evaluateJavaScript:command completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

#pragma mark - Setting the playback rate

- (void)playbackRate:(nullable YTPlayerViewJSResultFloat)callback {
    [self evaluateJavaScript:@"player.getPlaybackRate();" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback([result floatValue], error);
        }
    }];
}

- (void)setPlaybackRate:(float)suggestedRate callback:(nullable YTPlayerViewJSResultVoid)callback {
    NSString *command = [NSString stringWithFormat:@"player.setPlaybackRate(%f);", suggestedRate];
    [self evaluateJavaScript:command completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (callback) {
            callback(error);
        }
    }];
}

- (void)availablePlaybackRates:(nullable YTPlayerViewJSResultNumberArray)callback {
    [self evaluateJavaScript:@"player.getAvailablePlaybackRates();" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (callback) {
            NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSError *jsonError;
            NSArray *playbackRates = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:0
                                                                       error:&jsonError];
            if (jsonError) {
                callback(nil, [NSError errorWithDomain:YTPlayerErrorDomain code:YTPlayerErrorJSError userInfo:@{NSUnderlyingErrorKey: jsonError}]);
            } else {
                callback(playbackRates, error);
            }
        }
    }];
}

#pragma mark - Exposed for Testing

- (void)removeWebView {
    self.htmlLoadingNavigation = nil;
    self.webView.navigationDelegate = nil;
    self.webView.UIDelegate = nil;
    [self.webView removeFromSuperview];
    self.webView = nil;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // Might be able to determine behavior using WKNavigationAction more wisely, but I'll stick to the old code :D
    
    NSURL *url = navigationAction.request.URL;
    
    if ([url.host isEqualToString:self.originURL.host]) {
        // Request for template HTML. Always allow.
        decisionHandler(WKNavigationActionPolicyAllow);
    } else if ([url.scheme isEqualToString:@"ytplayer"]) {
        // Callbacks from YouTube iframe API. Do not navigate, just handle it internally.
        [self handleYouTubeCallbackURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        // Other HTTP/HTTPS requests.
        // Usually this means the user has clicked on the YouTube logo or an error message in the
        // player. Most URLs should open in the browser. The only http(s) URL that should open internally
        // is the URL for the embed, which is of the format:
        //   http(s)://www.youtube.com/embed/[VIDEO ID]?[PARAMETERS]
        NSString *urlString = url.absoluteString;
        NSRange range = NSMakeRange(0, urlString.length);
        
        NSRegularExpression *ytRegex = [NSRegularExpression regularExpressionWithPattern:YTPlayerEmbedUrlRegexPattern
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
        NSTextCheckingResult *ytMatch = [ytRegex firstMatchInString:urlString
                                                            options:0
                                                              range:range];
        
        NSRegularExpression *adRegex = [NSRegularExpression regularExpressionWithPattern:YTPlayerAdUrlRegexPattern
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
        NSTextCheckingResult *adMatch = [adRegex firstMatchInString:urlString
                                                            options:0
                                                              range:range];
        
        NSRegularExpression *oauthRegex = [NSRegularExpression regularExpressionWithPattern:YTPlayerOAuthRegexPattern
                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                      error:nil];
        NSTextCheckingResult *oauthMatch = [oauthRegex firstMatchInString:urlString
                                                                  options:0
                                                                    range:range];
        
        NSRegularExpression *staticProxyRegex = [NSRegularExpression regularExpressionWithPattern:YTPlayerStaticProxyRegexPattern
                                                                                          options:NSRegularExpressionCaseInsensitive
                                                                                            error:nil];
        NSTextCheckingResult *staticProxyMatch = [staticProxyRegex firstMatchInString:urlString
                                                                              options:0
                                                                                range:range];
        
        if (ytMatch || adMatch || oauthMatch || staticProxyMatch) {
            decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    } else {
        // Anything else.
        // This should not happen but we just allow them here
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    // Always allow the navigation to any HTTP responses.
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (self.htmlLoadingNavigation == navigation) {
        // The initial HTML load is failed. Fallback to the initial state.
        [self removeWebView];
        [self hideInitialLoadingView];
        [self showBeforeLoadingView];
        [self delegateErrorWithCode:YTPlayerErrorUnknown description:@"Failed to load YTPlayerView HTML template in web view." underlyingError:error];
    } else {
        [self delegateErrorWithCode:YTPlayerErrorUnknown description:nil underlyingError:error];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (self.htmlLoadingNavigation == navigation) {
        // The initial HTML load is failed. Fallback to the initial state.
        [self removeWebView];
        [self hideInitialLoadingView];
        [self showBeforeLoadingView];
        [self delegateErrorWithCode:YTPlayerErrorUnknown description:@"Failed to load YTPlayerView HTML template in web view." underlyingError:error];
    } else {
        [self delegateErrorWithCode:YTPlayerErrorUnknown description:nil underlyingError:error];
    }
}

#pragma mark - WKUIDelegate

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    // Returns nil, YouTube iframe API will not pop the new window.
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    // Do nothing, YouTube iframe API will not pop any alerts.
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    // Do nothing, YouTube iframe API will not pop any confirmations.
    completionHandler(NO);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    // Do nothing, YouTube iframe API will not pop any JS text input prompts.
    completionHandler(defaultText);
}

#pragma mark - Private methods

+ (NSBundle *)frameworkBundle {
    static NSBundle *frameworkBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* mainBundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"youtube-ios-player-helper.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}

- (WKWebView *)instantiateWebView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    
    // WebKit configurations.
    // XXX: processPool, should we share Web Content processes between all YTPlayerViews or not?
    // XXX: websiteDataStore, should we add any ways to clear up local data store (such as cookies or local storages YouTube might use)?
    
    // media configurations.
    configuration.allowsInlineMediaPlayback = YES;
    if ([configuration respondsToSelector:@selector(requiresUserActionForMediaPlayback)]) {
        configuration.requiresUserActionForMediaPlayback = NO;
    } else {
        configuration.mediaPlaybackRequiresUserAction = NO;
    }
    if ([configuration respondsToSelector:@selector(allowsAirPlayForMediaPlayback)]) {
        configuration.allowsAirPlayForMediaPlayback = self.allowsAirPlayForMediaPlayback;
    } else {
        configuration.mediaPlaybackAllowsAirPlay = self.allowsAirPlayForMediaPlayback;
    }
    if ([configuration respondsToSelector:@selector(allowsPictureInPictureMediaPlayback)]) {
        configuration.allowsPictureInPictureMediaPlayback = self.allowsPictureInPictureMediaPlayback;
    }
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    webView.scrollView.scrollEnabled = NO;
    webView.scrollView.bounces = NO;
    
    return webView;
}

- (void)showBeforeLoadingView {
    if (self.beforeLoadingView != nil) {
        self.beforeLoadingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.beforeLoadingView];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.beforeLoadingView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.beforeLoadingView}]];
    }
}

- (void)showInitialLoadingView {
    if (self.initialLoadingView != nil) {
        self.initialLoadingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.initialLoadingView];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.initialLoadingView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.initialLoadingView}]];
    }
}

- (void)hideBeforeLoadingView {
    [self.beforeLoadingView removeFromSuperview];
}

- (void)hideInitialLoadingView {
    [self.initialLoadingView removeFromSuperview];
}

- (void)delegateErrorWithCode:(YTPlayerError)errorCode description:(nullable NSString *)description underlyingError:(nullable NSError *)underlyingError {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (description != nil) {
        userInfo[NSLocalizedDescriptionKey] = description;
    }
    if (underlyingError != nil) {
        userInfo[NSUnderlyingErrorKey] = underlyingError;
    }
    NSError *error = [NSError errorWithDomain:YTPlayerErrorDomain code:errorCode userInfo:userInfo];
    [self delegateError:error];
}

- (void)delegateError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(playerView:didReceiveError:)]) {
        [self.delegate playerView:self didReceiveError:error];
    }
}

- (void)handleYouTubeCallbackURL:(NSURL *)url {
    /**
     * Private method to handle "navigation" to a callback URL of the format
     * ytplayer://action?data=someData
     * This is how the web view communicates with the containing Objective-C code.
     * Side effects of this method are that it calls methods on this class's delegate.
     *
     * @param url A URL of the format ytplayer://action?data=value.
     */
    NSString *action = url.host;
    
    // We know the query can only be of the format ytplayer://action?data=SOMEVALUE,
    // so we parse out the value.
    NSString *query = url.query;
    NSString *data;
    if (query != nil) {
        data = [query componentsSeparatedByString:@"="][1];
    }
    
    if ([action isEqualToString:YTPlayerCallbackOnReady]) {
        [self hideBeforeLoadingView];
        [self hideInitialLoadingView];
        if ([self.delegate respondsToSelector:@selector(playerViewDidBecomeReady:)]) {
            [self.delegate playerViewDidBecomeReady:self];
        }
    } else if ([action isEqualToString:YTPlayerCallbackOnStateChange]) {
        // Caches state internally to use it immediately, because we have to wait when we query using JS now.
        YTPlayerState state = YTPlayerStateUnknown;
        
        if ([data isEqualToString:YTPlayerStateEndedCode]) {
            state = YTPlayerStateEnded;
        } else if ([data isEqual:YTPlayerStatePlayingCode]) {
            state = YTPlayerStatePlaying;
        } else if ([data isEqual:YTPlayerStatePausedCode]) {
            state = YTPlayerStatePaused;
        } else if ([data isEqual:YTPlayerStateBufferingCode]) {
            state = YTPlayerStateBuffering;
        } else if ([data isEqual:YTPlayerStateCuedCode]) {
            state = YTPlayerStateQueued;
        } else if ([data isEqual:YTPlayerStateUnstartedCode]) {
            state = YTPlayerStateUnstarted;
        }
        
        self.playerState = state;
        if ([self.delegate respondsToSelector:@selector(playerView:didChangeToState:)]) {
            [self.delegate playerView:self didChangeToState:state];
        }
    } else if ([action isEqualToString:YTPlayerCallbackOnPlaybackQualityChange]) {
        if ([self.delegate respondsToSelector:@selector(playerView:didChangeToQuality:)]) {
            YTPlaybackQuality quality = YTPlaybackQualityFromNSString(data);
            [self.delegate playerView:self didChangeToQuality:quality];
        }
    } else if ([action isEqualToString:YTPlayerCallbackOnError]) {
        if ([self.delegate respondsToSelector:@selector(playerView:didReceiveError:)]) {
            YTPlayerError errorCode = YTPlayerErrorUnknown;
            
            if ([data isEqual:YTPlayerErrorInvalidParamErrorCode]) {
                errorCode = YTPlayerErrorInvalidParam;
            } else if ([data isEqual:YTPlayerErrorHTML5ErrorCode]) {
                errorCode = YTPlayerErrorHTML5Error;
            } else if ([data isEqual:YTPlayerErrorNotEmbeddableErrorCode] ||
                       [data isEqual:YTPlayerErrorSameAsNotEmbeddableErrorCode]) {
                errorCode = YTPlayerErrorNotEmbeddable;
            } else if ([data isEqual:YTPlayerErrorVideoNotFoundErrorCode] ||
                       [data isEqual:YTPlayerErrorCannotFindVideoErrorCode]) {
                errorCode = YTPlayerErrorVideoNotFound;
            }
            
            [self delegateErrorWithCode:errorCode description:nil underlyingError:nil];
        }
    } else if ([action isEqualToString:YTPlayerCallbackOnPlayTime]) {
        if ([self.delegate respondsToSelector:@selector(playerView:didPlayTime:)]) {
            float time = [data floatValue];
            [self.delegate playerView:self didPlayTime:time];
        }
    } else if ([action isEqualToString:YTPlayerCallbackOnYouTubeIframeAPIFailedToLoad]) {
        // The initial HTML load is succeeded but YouTube iframe API failed. Fallback to the initial state.
        // XXX: Might be able to handle this error using WKNavigationDelegate by captureing new iframe WKNavigation request, but I'll stick to the old way for now.
        [self removeWebView];
        [self hideInitialLoadingView];
        [self showBeforeLoadingView];
        [self delegateErrorWithCode:YTPlayerErrorFailedToLoadPlayer description:nil underlyingError:nil];
    }
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(_Nullable id result, NSError * _Nullable error))completionHandler {
    if (self.webView == nil) {
        NSError *error = [NSError errorWithDomain:YTPlayerErrorDomain code:YTPlayerErrorJSError userInfo:@{NSLocalizedDescriptionKey: @"YTPlayerView didn't load the internal web view yet. Load before using any other public methods."}];
        completionHandler(nil, error);
    } else {
        [self.webView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (error != nil) {
                NSError *jsError = [NSError errorWithDomain:YTPlayerErrorDomain code:YTPlayerErrorJSError userInfo:@{NSUnderlyingErrorKey: error}];
                completionHandler(result, jsError);
            } else {
                completionHandler(result, nil);
            }
        }];
    }
}

@end

NS_ASSUME_NONNULL_END
