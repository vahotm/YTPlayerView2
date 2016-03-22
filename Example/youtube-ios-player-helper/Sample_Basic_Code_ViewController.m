//
//  Sample_Basic_Code_ViewController.m
//  youtube-ios-player-helper
//
//  Created by Ono Masashi on 2016/03/22.
//  Copyright © 2016年 akisute. All rights reserved.
//

// TODO: change the module name completely... I can't bare with this
// To confirm clang module system, we must not use - (dash) in the module name, which is replaced to _ (underscore).
// https://github.com/CocoaPods/Core/issues/205

// Doesn't work, needs umbrella header youtube-ios-player-helper.h, kinda ugly
//#import <youtube-ios-player-helper/youtube-ios-player-helper.h>

// Doesn't work because - is replaced to _ when clang module is enabled...
//#import <youtube-ios-player-helper/YTPlayerView.h>

// This one works but so ugly
#import <youtube_ios_player_helper/YTPlayerView.h>

#import "Sample_Basic_Code_ViewController.h"

@interface Sample_Basic_Code_ViewController ()
@property (nonatomic) YTPlayerView *playerView;
@end

@implementation Sample_Basic_Code_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Instantiate using Code";
    self.view.backgroundColor = [UIColor blackColor];
    
    self.playerView = [[YTPlayerView alloc] initWithFrame:CGRectZero];
    self.playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.playerView];
    
    NSDictionary *views = @{@"playerView": self.playerView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[playerView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[playerView]" options:0 metrics:nil views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.playerView addConstraint:[NSLayoutConstraint constraintWithItem:self.playerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeHeight multiplier:(16.0/9.0) constant:0]];
}

@end
