//
//  DelegateStatusView.m
//  youtube-ios-player-helper
//
//  Created by Ono Masashi on 2016/03/24.
//  Copyright © 2016年 akisute. All rights reserved.
//

#import "DelegateStatusView.h"

@interface DelegateStatusView ()
@property (nonatomic) IBOutlet UILabel *readyLabel;
@property (nonatomic) IBOutlet UILabel *stateLabel;
@property (nonatomic) IBOutlet UILabel *qualityLabel;
@property (nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic) IBOutlet UILabel *playTimeLabel;
@end

@implementation DelegateStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialize];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialize];
    }
    return self;
}

- (void)commonInitialize {
    [self setReady:NO];
    [self setState:YTPlayerStateUnknown];
    [self setQuality:YTPlaybackQualityUnknown];
    [self setError:nil];
    [self setPlayTime:0];
}

- (void)setReady:(BOOL)ready {
    if (ready) {
        self.readyLabel.text = @"YES";
    } else {
        self.readyLabel.text = @"NO";
    }
}

- (void)setState:(YTPlayerState)state {
    switch (state) {
        case YTPlayerStateUnstarted:
            self.stateLabel.text = @"Unstarted";
            break;
        case YTPlayerStateEnded:
            self.stateLabel.text = @"Ended";
            break;
        case YTPlayerStatePlaying:
            self.stateLabel.text = @"Playing";
            break;
        case YTPlayerStatePaused:
            self.stateLabel.text = @"Paused";
            break;
        case YTPlayerStateBuffering:
            self.stateLabel.text = @"Buffering";
            break;
        case YTPlayerStateQueued:
            self.stateLabel.text = @"Queued";
            break;
        case YTPlayerStateUnknown:
            self.stateLabel.text = @"Unknown";
            break;
    }
}

- (void)setQuality:(YTPlaybackQuality)quality {
    switch (quality) {
        case YTPlaybackQualitySmall:
            self.qualityLabel.text = @"Small";
            break;
        case YTPlaybackQualityMedium:
            self.qualityLabel.text = @"Medium";
            break;
        case YTPlaybackQualityLarge:
            self.qualityLabel.text = @"Large";
            break;
        case YTPlaybackQualityHD720:
            self.qualityLabel.text = @"HD720";
            break;
        case YTPlaybackQualityHD1080:
            self.qualityLabel.text = @"HD1080";
            break;
        case YTPlaybackQualityHighRes:
            self.qualityLabel.text = @"HighRes";
            break;
        case YTPlaybackQualityAuto:
            self.qualityLabel.text = @"Auto";
            break;
        case YTPlaybackQualityDefault:
            self.qualityLabel.text = @"Default";
            break;
        case YTPlaybackQualityUnknown:
            self.qualityLabel.text = @"Unknown";
            break;
    }
}

- (void)setError:(nullable NSError *)error {
    if (error) {
        self.errorLabel.text = error.description;
    } else {
        self.errorLabel.text = @"nil";
    }
}

- (void)setPlayTime:(float)playTime {
    self.playTimeLabel.text = [NSString stringWithFormat:@"%0.2f", playTime];
}

@end
