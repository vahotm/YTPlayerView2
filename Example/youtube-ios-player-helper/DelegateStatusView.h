//
//  DelegateStatusView.h
//  youtube-ios-player-helper
//
//  Created by Ono Masashi on 2016/03/24.
//  Copyright © 2016年 akisute. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YTPlayerView/YTPlayerView.h>

NS_ASSUME_NONNULL_BEGIN

@interface DelegateStatusView : UIView

- (void)setReady:(BOOL)ready;
- (void)setState:(YTPlayerState)state;
- (void)setQuality:(YTPlaybackQuality)quality;
- (void)setError:(nullable NSError *)error;
- (void)setPlayTime:(float)playTime;

@end

NS_ASSUME_NONNULL_END
