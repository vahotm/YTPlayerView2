//
//  Sample_Basic_IB_ViewController.m
//  youtube-ios-player-helper
//
//  Created by Ono Masashi on 2016/03/22.
//  Copyright © 2016年 akisute. All rights reserved.
//

#import <YTPlayerView/YTPlayerView.h>

#import "Sample_Basic_IB_ViewController.h"
#import "DelegateStatusView.h"

@interface Sample_Basic_IB_ViewController () <YTPlayerViewDelegate>
@property (nonatomic) IBOutlet YTPlayerView *playerView;
@property (nonatomic) IBOutlet DelegateStatusView *delegateStatusView;
@end

@implementation Sample_Basic_IB_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Instantiate using Interface Builder";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.playerView loadPlayerWithVideoId:@"M7lc1UVf-VE"];
}

#pragma mark - YTPlayerViewDelegate

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    [self.delegateStatusView setReady:YES];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    [self.delegateStatusView setState:state];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality)quality {
    [self.delegateStatusView setQuality:quality];
}

- (void)playerView:(YTPlayerView *)playerView didReceiveError:(NSError *)error {
    [self.delegateStatusView setError:error];
}

- (void)playerView:(YTPlayerView *)playerView didPlayTime:(float)playTime {
    [self.delegateStatusView setPlayTime:playTime];
}

@end
