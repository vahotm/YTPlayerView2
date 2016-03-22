//
//  Sample_Basic_IB_ViewController.m
//  youtube-ios-player-helper
//
//  Created by Ono Masashi on 2016/03/22.
//  Copyright © 2016年 akisute. All rights reserved.
//

#import <youtube_ios_player_helper/YTPlayerView.h>

#import "Sample_Basic_IB_ViewController.h"

@interface Sample_Basic_IB_ViewController ()
@property (nonatomic) IBOutlet YTPlayerView *playerView;
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

@end
