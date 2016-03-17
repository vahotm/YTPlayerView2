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

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YTPlayerView;


#pragma mark - Enums/Constants definitions


/// Enums that represents the state of the current video in the player.
typedef NS_ENUM(NSInteger, YTPlayerState) {
    YTPlayerStateUnstarted,
    YTPlayerStateEnded,
    YTPlayerStatePlaying,
    YTPlayerStatePaused,
    YTPlayerStateBuffering,
    YTPlayerStateQueued,
    YTPlayerStateUnknown
};

/// Enums that represents the resolution of the currently loaded video.
typedef NS_ENUM(NSInteger, YTPlaybackQuality) {
    YTPlaybackQualitySmall,
    YTPlaybackQualityMedium,
    YTPlaybackQualityLarge,
    YTPlaybackQualityHD720,
    YTPlaybackQualityHD1080,
    YTPlaybackQualityHighRes,
    YTPlaybackQualityAuto,     /// Addition for YouTube Live Events.
    YTPlaybackQualityDefault,
    YTPlaybackQualityUnknown   /// This should never be returned. It is here for future proofing.
};

/// Constant used by NSError to differentiate between "domains" of error codes, serving as a discriminator for error codes that originate from different subsystems or sources.
/// All NSError objects returned from YTPlayerView has this domain.
extern NSString * const YTPlayerErrorDomain;

/// Enums that represents error codes thrown by the player.
/// All NSError objects returned from YTPlayerView uses this error codes.
typedef NS_ENUM(NSInteger, YTPlayerError) {
    YTPlayerErrorInvalidParam,
    YTPlayerErrorHTML5Error,
    YTPlayerErrorVideoNotFound, /// Functionally equivalent error codes 100 and 105 have been collapsed into `YTPlayerErrorVideoNotFound`.
    YTPlayerErrorNotEmbeddable, /// Functionally equivalent error codes 101 and 150 have been collapsed into `YTPlayerErrorNotEmbeddable`.
    YTPlayerErrorUnknown
};


#pragma mark - YTPlayerViewDelegate


/**
 * A delegate for ViewControllers to respond to YouTube player events outside
 * of the view, such as changes to video playback state or playback errors.
 * The callback functions correlate to the events fired by the IFrame API.
 * For the full documentation, see the IFrame documentation here:
 *   https://developers.google.com/youtube/iframe_api_reference#Events
 */
@protocol YTPlayerViewDelegate<NSObject>

@optional
/**
 * Invoked when the player view is ready to receive API calls.
 *
 * @param playerView The YTPlayerView instance that has become ready.
 */
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView;

/**
 * Callback invoked when player state has changed, e.g. stopped or started playback.
 *
 * @param playerView The YTPlayerView instance where playback state has changed.
 * @param state YTPlayerState designating the new playback state.
 */
- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state;

/**
 * Callback invoked when playback quality has changed.
 *
 * @param playerView The YTPlayerView instance where playback quality has changed.
 * @param quality YTPlaybackQuality designating the new playback quality.
 */
- (void)playerView:(YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality)quality;

/**
 * Callback invoked when an error has occured.
 *
 * @param playerView The YTPlayerView instance where the error has occurred.
 * @param error An NSError objects that `domain` is `YTPlayerErrorDomain` and `code` represends `YTPlayerError`,
 */
- (void)playerView:(YTPlayerView *)playerView receivedError:(NSError *)error;

/**
 * Callback invoked frequently when playBack is playing.
 *
 * @param playerView The YTPlayerView instance where the error has occurred.
 * @param playTime float containing current playback time.
 */
- (void)playerView:(YTPlayerView *)playerView didPlayTime:(float)playTime;

@end


#pragma mark - YTPlayerView


/**
 * YTPlayerView is a custom UIView that client developers will use to include YouTube
 * videos in their iOS applications. It can be instantiated programmatically, or via
 * Interface Builder. You must call methods under *Initial player loading methods* category
 * to start initial loading of the YouTube player via YouTube iframe API.
 */
@interface YTPlayerView : UIView

#pragma mark - Internal UI components

/** A web view that displays the YouTube player internally. */
@property (nonatomic, strong, nullable, readonly) WKWebView *webView;

#pragma mark - Initial configuration properties

/** A delegate to be notified on playback events. */
@property (nonatomic, weak, nullable) id<YTPlayerViewDelegate> delegate;

/**
 A view that is displayed while the YouTube player is not loaded or not being loaded yet.
 
 YTPlayerView can't show users anything unless the YouTube player is loaded to the web view through YouTube iframe API.
 Main purpose of this view is to show users something (like thumbnail images, play buttons, etc...) before users attempt to start playing the video.
 This view will be immediately hidden once you start initial loading and will never be shown again.
 
 Default value is nil, which shows nothing. You must set the value before starting the initial load.
 */
@property (nonatomic, strong, nullable) UIView *beforeLoadingView;

/**
 A view that is displayed while the YouTube player is being loaded by webView.
 
 YTPlayerView can't show users anything unless the YouTube player is loaded to the web view through YouTube iframe API.
 The initial loading could take up like 10 seconds or more when users are in bad internet connectivity, so main purpose of this view is
 to show users some loading UI while they wait for loading.
 This view will be immediately hidden once the initial loading is finished and will never be shown again.
 
 Default value is nil, which shows nothing. You must set the value before starting the initial load.
 */
@property (nonatomic, strong, nullable) UIView *initialLoadingView;

#pragma mark - Initial loading methods

/**
 * This method loads the player with the given video ID.
 * This is a convenience method for calling YTPlayerView::loadPlayerWithVideoId:withPlayerVars:
 * without player variables.
 *
 * This method reloads the entire contents of the UIWebView and regenerates its HTML contents.
 * To change the currently loaded video without reloading the entire UIWebView, use the
 * YTPlayerView::cueVideoById:startSeconds:suggestedQuality: family of methods.
 *
 * @param videoId The YouTube video ID of the video to load in the player view.
 * @return YES if player has been configured correctly, NO otherwise.
 */
- (BOOL)loadPlayerWithVideoId:(NSString *)videoId;

/**
 * This method loads the player with the given playlist ID.
 * This is a convenience method for calling YTPlayerView::loadWithPlaylistId:withPlayerVars:
 * without player variables.
 *
 * This method reloads the entire contents of the UIWebView and regenerates its HTML contents.
 * To change the currently loaded video without reloading the entire UIWebView, use the
 * YTPlayerView::cuePlaylistByPlaylistId:index:startSeconds:suggestedQuality:
 * family of methods.
 *
 * @param playlistId The YouTube playlist ID of the playlist to load in the player view.
 * @return YES if player has been configured correctly, NO otherwise.
 */
- (BOOL)loadPlayerWithPlaylistId:(NSString *)playlistId;

/**
 * This method loads the player with the given video ID and player variables. Player variables
 * specify optional parameters for video playback. For instance, to play a YouTube
 * video inline, the following playerVars dictionary would be used:
 *
 * @code
 * @{ @"playsinline" : @1 };
 * @endcode
 *
 * Note that when the documentation specifies a valid value as a number (typically 0, 1 or 2),
 * both strings and integers are valid values. The full list of parameters is defined at:
 *   https://developers.google.com/youtube/player_parameters?playerVersion=HTML5.
 *
 * This method reloads the entire contents of the UIWebView and regenerates its HTML contents.
 * To change the currently loaded video without reloading the entire UIWebView, use the
 * YTPlayerView::cueVideoById:startSeconds:suggestedQuality: family of methods.
 *
 * @param videoId The YouTube video ID of the video to load in the player view.
 * @param playerVars An NSDictionary of player parameters.
 * @return YES if player has been configured correctly, NO otherwise.
 */
- (BOOL)loadPlayerWithVideoId:(NSString *)videoId playerVars:(nullable NSDictionary *)playerVars;

/**
 * This method loads the player with the given playlist ID and player variables. Player variables
 * specify optional parameters for video playback. For instance, to play a YouTube
 * video inline, the following playerVars dictionary would be used:
 *
 * @code
 * @{ @"playsinline" : @1 };
 * @endcode
 *
 * Note that when the documentation specifies a valid value as a number (typically 0, 1 or 2),
 * both strings and integers are valid values. The full list of parameters is defined at:
 *   https://developers.google.com/youtube/player_parameters?playerVersion=HTML5.
 *
 * This method reloads the entire contents of the UIWebView and regenerates its HTML contents.
 * To change the currently loaded video without reloading the entire UIWebView, use the
 * YTPlayerView::cuePlaylistByPlaylistId:index:startSeconds:suggestedQuality:
 * family of methods.
 *
 * @param playlistId The YouTube playlist ID of the playlist to load in the player view.
 * @param playerVars An NSDictionary of player parameters.
 * @return YES if player has been configured correctly, NO otherwise.
 */
- (BOOL)loadPlayerWithPlaylistId:(NSString *)playlistId playerVars:(nullable NSDictionary *)playerVars;

/**
 * This method loads an iframe player with the given player parameters. Usually you may want to use
 * -loadWithVideoId:playerVars: or -loadWithPlaylistId:playerVars: instead of this method does not handle
 * video_id or playlist_id at all. The full list of parameters is defined at:
 *   https://developers.google.com/youtube/player_parameters?playerVersion=HTML5.
 *
 * @param additionalPlayerParams An NSDictionary of parameters in addition to required parameters
 *                               to instantiate the HTML5 player with. This differs depending on
 *                               whether a single video or playlist is being loaded.
 * @return YES if successful, NO if not.
 */
- (BOOL)loadPlayerWithPlayerParams:(nullable NSDictionary *)additionalPlayerParams;

// TODO: Add loadPlayerWithURL:playerVars:

#pragma mark - Player controls

// TODO: ALL METHODS THAT CALLS JS MUST HAVE ASYNC CALLBACK

// These methods correspond to their JavaScript equivalents as documented here:
//   https://developers.google.com/youtube/iframe_api_reference#Playback_controls

/**
 * Starts or resumes playback on the loaded video. Corresponds to this method from
 * the JavaScript API:
 *   https://developers.google.com/youtube/iframe_api_reference#playVideo
 */
- (void)playVideo;

/**
 * Pauses playback on a playing video. Corresponds to this method from
 * the JavaScript API:
 *   https://developers.google.com/youtube/iframe_api_reference#pauseVideo
 */
- (void)pauseVideo;

/**
 * Stops playback on a playing video. Corresponds to this method from
 * the JavaScript API:
 *   https://developers.google.com/youtube/iframe_api_reference#stopVideo
 */
- (void)stopVideo;

/**
 * Seek to a given time on a playing video. Corresponds to this method from
 * the JavaScript API:
 *   https://developers.google.com/youtube/iframe_api_reference#seekTo
 *
 * @param seekToSeconds The time in seconds to seek to in the loaded video.
 * @param allowSeekAhead Whether to make a new request to the server if the time is
 *                       outside what is currently buffered. Recommended to set to YES.
 */
- (void)seekToSeconds:(float)seekToSeconds allowSeekAhead:(BOOL)allowSeekAhead;

#pragma mark - Queuing videos

// Queueing functions for videos. These methods correspond to their JavaScript
// equivalents as documented here:
//   https://developers.google.com/youtube/iframe_api_reference#Queueing_Functions

/**
 * Cues a given video by its video ID for playback starting at the given time and with the
 * suggested quality. Cueing loads a video, but does not start video playback. This method
 * corresponds with its JavaScript API equivalent as documented here:
 *   https://developers.google.com/youtube/iframe_api_reference#cueVideoById
 *
 * @param videoId A video ID to cue.
 * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
 * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
 */
- (void)cueVideoById:(NSString *)videoId
        startSeconds:(float)startSeconds
    suggestedQuality:(YTPlaybackQuality)suggestedQuality;

/**
 * Cues a given video by its video ID for playback starting and ending at the given times
 * with the suggested quality. Cueing loads a video, but does not start video playback. This
 * method corresponds with its JavaScript API equivalent as documented here:
 *   https://developers.google.com/youtube/iframe_api_reference#cueVideoById
 *
 * @param videoId A video ID to cue.
 * @param startSeconds Time in seconds to start the video when playVideo() is called.
 * @param endSeconds Time in seconds to end the video after it begins playing.
 * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
 */
- (void)cueVideoById:(NSString *)videoId
        startSeconds:(float)startSeconds
          endSeconds:(float)endSeconds
    suggestedQuality:(YTPlaybackQuality)suggestedQuality;

/**
 * Loads a given video by its video ID for playback starting at the given time and with the
 * suggested quality. Loading a video both loads it and begins playback. This method
 * corresponds with its JavaScript API equivalent as documented here:
 *   https://developers.google.com/youtube/iframe_api_reference#loadVideoById
 *
 * @param videoId A video ID to load and begin playing.
 * @param startSeconds Time in seconds to start the video when it has loaded.
 * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
 */
- (void)loadVideoById:(NSString *)videoId
         startSeconds:(float)startSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality;

/**
 * Loads a given video by its video ID for playback starting and ending at the given times
 * with the suggested quality. Loading a video both loads it and begins playback. This method
 * corresponds with its JavaScript API equivalent as documented here:
 *   https://developers.google.com/youtube/iframe_api_reference#loadVideoById
 *
 * @param videoId A video ID to load and begin playing.
 * @param startSeconds Time in seconds to start the video when it has loaded.
 * @param endSeconds Time in seconds to end the video after it begins playing.
 * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
 */
- (void)loadVideoById:(NSString *)videoId
         startSeconds:(float)startSeconds
           endSeconds:(float)endSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality;

/**
 * Cues a given video by its URL on YouTube.com for playback starting at the given time
 * and with the suggested quality. Cueing loads a video, but does not start video playback.
 * This method corresponds with its JavaScript API equivalent as documented here:
 *   https://developers.google.com/youtube/iframe_api_reference#cueVideoByUrl
 *
 * @param videoURL URL of a YouTube video to cue for playback.
 * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
 * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
 */
- (void)cueVideoByURL:(NSURL *)videoURL
         startSeconds:(float)startSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality;

/**
 * Cues a given video by its URL on YouTube.com for playback starting at the given time
 * and with the suggested quality. Cueing loads a video, but does not start video playback.
 * This method corresponds with its JavaScript API equivalent as documented here:
 *   https://developers.google.com/youtube/iframe_api_reference#cueVideoByUrl
 *
 * @param videoURL URL of a YouTube video to cue for playback.
 * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
 * @param endSeconds Time in seconds to end the video after it begins playing.
 * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
 */
- (void)cueVideoByURL:(NSURL *)videoURL
         startSeconds:(float)startSeconds
           endSeconds:(float)endSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality;

/**
 * Loads a given video by its video ID for playback starting at the given time
 * with the suggested quality. Loading a video both loads it and begins playback. This method
 * corresponds with its JavaScript API equivalent as documented here:
 *   https://developers.google.com/youtube/iframe_api_reference#loadVideoByUrl
 *
 * @param videoURL URL of a YouTube video to load and play.
 * @param startSeconds Time in seconds to start the video when it has loaded.
 * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
 */
- (void)loadVideoByURL:(NSURL *)videoURL
          startSeconds:(float)startSeconds
      suggestedQuality:(YTPlaybackQuality)suggestedQuality;

/**
 * Loads a given video by its video ID for playback starting and ending at the given times
 * with the suggested quality. Loading a video both loads it and begins playback. This method
 * corresponds with its JavaScript API equivalent as documented here:
 *   https://developers.google.com/youtube/iframe_api_reference#loadVideoByUrl
 *
 * @param videoURL URL of a YouTube video to load and play.
 * @param startSeconds Time in seconds to start the video when it has loaded.
 * @param endSeconds Time in seconds to end the video after it begins playing.
 * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
 */
- (void)loadVideoByURL:(NSURL *)videoURL
          startSeconds:(float)startSeconds
            endSeconds:(float)endSeconds
      suggestedQuality:(YTPlaybackQuality)suggestedQuality;

#pragma mark - Playing a video in a playlist

// These methods correspond to the JavaScript API as defined under the
// "Playing a video in a playlist" section here:
//   https://developers.google.com/youtube/iframe_api_reference#Playback_status

/**
 * Loads and plays the next video in the playlist. Corresponds to this method from
 * the JavaScript API:
 *   https://developers.google.com/youtube/iframe_api_reference#nextVideo
 */
- (void)nextVideo;

/**
 * Loads and plays the previous video in the playlist. Corresponds to this method from
 * the JavaScript API:
 *   https://developers.google.com/youtube/iframe_api_reference#previousVideo
 */
- (void)previouVideo;

/**
 * Loads and plays the video at the given 0-indexed position in the playlist.
 * Corresponds to this method from the JavaScript API:
 *   https://developers.google.com/youtube/iframe_api_reference#playVideoAt
 *
 * @param index The 0-indexed position of the video in the playlist to load and play.
 */
- (void)playVideoAt:(NSInteger)index;

#pragma mark - Setting the playback rate

/**
 * Gets the playback rate. The default value is 1.0, which represents a video
 * playing at normal speed. Other values may include 0.25 or 0.5 for slower
 * speeds, and 1.5 or 2.0 for faster speeds. This method corresponds to the
 * JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#getPlaybackRate
 *
 * @return A float value that represends the current playback rate.
 */
- (float)playbackRate;

/**
 * Sets the playback rate. The default value is 1.0, which represents a video
 * playing at normal speed. Other values may include 0.25 or 0.5 for slower
 * speeds, and 1.5 or 2.0 for faster speeds. To fetch a list of valid values for
 * this method, call YTPlayerView::getAvailablePlaybackRates. This method does not
 * guarantee that the playback rate will change.
 * This method corresponds to the JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#setPlaybackRate
 *
 * @param suggestedRate A playback rate to suggest for the player.
 */
- (void)setPlaybackRate:(float)suggestedRate;

/**
 * Gets a list of the valid playback rates, useful in conjunction with
 * YTPlayerView::setPlaybackRate. This method corresponds to the
 * JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#getPlaybackRate
 *
 * @return An NSArray containing available playback rates. nil if there is an error.
 */
- (nullable NSArray *)availablePlaybackRates;

#pragma mark - Setting playback behavior for playlists

/**
 * Sets whether the player should loop back to the first video in the playlist
 * after it has finished playing the last video. This method corresponds to the
 * JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#loopPlaylist
 *
 * @param loop A boolean representing whether the player should loop.
 */
- (void)setLoop:(BOOL)loop;

/**
 * Sets whether the player should shuffle through the playlist. This method
 * corresponds to the JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#shufflePlaylist
 *
 * @param shuffle A boolean representing whether the player should
 *                shuffle through the playlist.
 */
- (void)setShuffle:(BOOL)shuffle;

#pragma mark - Playback status
// These methods correspond to the JavaScript methods defined here:
//   https://developers.google.com/youtube/js_api_reference#Playback_status

/**
 * Returns a number between 0 and 1 that specifies the percentage of the video
 * that the player shows as buffered. This method corresponds to the
 * JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#getVideoLoadedFraction
 *
 * @return A float value between 0 and 1 representing the percentage of the video
 *         already loaded.
 */
- (float)videoLoadedFraction;

/**
 * Returns the state of the player. This method corresponds to the
 * JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#getPlayerState
 *
 * @return |YTPlayerState| representing the state of the player.
 */
- (YTPlayerState)playerState;

/**
 * Returns the elapsed time in seconds since the video started playing. This
 * method corresponds to the JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#getCurrentTime
 *
 * @return Time in seconds since the video started playing.
 */
- (float)currentTime;

#pragma mark - Playback quality

// Playback quality. These methods correspond to the JavaScript
// methods defined here:
//   https://developers.google.com/youtube/js_api_reference#Playback_quality

/**
 * Returns the playback quality. This method corresponds to the
 * JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#getPlaybackQuality
 *
 * @return YTPlaybackQuality representing the current playback quality.
 */
- (YTPlaybackQuality)playbackQuality;

/**
 * Suggests playback quality for the video. It is recommended to leave this setting to
 * |default|. This method corresponds to the JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#setPlaybackQuality
 *
 * @param quality YTPlaybackQuality value to suggest for the player.
 */
- (void)setPlaybackQuality:(YTPlaybackQuality)suggestedQuality;

/**
 * Gets a list of the valid playback quality values, useful in conjunction with
 * YTPlayerView::setPlaybackQuality. This method corresponds to the
 * JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#getAvailableQualityLevels
 *
 * @return An NSArray containing available playback quality levels. Returns nil if there is an error.
 */
- (nullable NSArray *)availableQualityLevels;

#pragma mark - Retrieving video information

// Retrieving video information. These methods correspond to the JavaScript
// methods defined here:
//   https://developers.google.com/youtube/js_api_reference#Retrieving_video_information

/**
 * Returns the duration in seconds since the video of the video. This
 * method corresponds to the JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#getDuration
 *
 * @return Length of the video in seconds.
 */
- (NSTimeInterval)duration;

/**
 * Returns the YouTube.com URL for the video. This method corresponds
 * to the JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#getVideoUrl
 *
 * @return The YouTube.com URL for the video. Returns nil if no video is loaded yet.
 */
- (nullable NSURL *)videoURL;

/**
 * Returns the embed code for the current video. This method corresponds
 * to the JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#getVideoEmbedCode
 *
 * @return The embed code for the current video. Returns nil if no video is loaded yet.
 */
- (nullable NSString *)videoEmbedCode;

#pragma mark - Retrieving playlist information

// Retrieving playlist information. These methods correspond to the
// JavaScript defined here:
//  https://developers.google.com/youtube/js_api_reference#Retrieving_playlist_information

/**
 * Returns an ordered array of video IDs in the playlist. This method corresponds
 * to the JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#getPlaylist
 *
 * @return An NSArray containing all the video IDs in the current playlist. |nil| on error.
 */
- (nullable NSArray *)playlist;

/**
 * Returns the 0-based index of the currently playing item in the playlist.
 * This method corresponds to the JavaScript API defined here:
 *   https://developers.google.com/youtube/iframe_api_reference#getPlaylistIndex
 *
 * @return The 0-based index of the currently playing item in the playlist.
 */
- (NSInteger)playlistIndex;

#pragma mark - Exposed for Testing

/**
 * Removes the internal web view from this player view.
 * Intended to use for testing, should not be used in production code.
 */
- (void)removeWebView;

@end

NS_ASSUME_NONNULL_END
