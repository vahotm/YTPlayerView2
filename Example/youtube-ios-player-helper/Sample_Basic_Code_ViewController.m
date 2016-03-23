//
//  Sample_Basic_Code_ViewController.m
//  youtube-ios-player-helper
//
//  Created by Ono Masashi on 2016/03/22.
//  Copyright © 2016年 akisute. All rights reserved.
//

#import <YTPlayerView/YTPlayerView.h>

#import "Sample_Basic_Code_ViewController.h"

@interface Sample_Basic_Code_ViewController ()
@property (nonatomic) YTPlayerView *playerView;
@end

@implementation Sample_Basic_Code_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ALWAYS ALWAYS make sure that the `UIViewController.automaticallyAdjustsScrollViewInsets` is set to NO!
    // This will automatically adds up unwanted content inset to the `YTPlayerView.webView.scrollView`, breaking viewports of the WKWebView completely when rotating the device (or possibly other re-layouting triggers).
    // Also it seems like this *unwanted content inset* issue only happens when we use `UIViewController.topLayoutGuide` to auto-layout the view, possibly only on iOS 8.
    // Anyway, remember to check the `YTPlayerView.webView.scrollView.contentInset` asap when you find the video size looks broken and that could be caused by `UIViewController.automaticallyAdjustsScrollViewInsets`.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"Instantiate using Code";
    self.view.backgroundColor = [UIColor blackColor];
    
    self.playerView = [[YTPlayerView alloc] initWithFrame:CGRectZero];
    self.playerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.playerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.playerView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeadingMargin relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTrailingMargin relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-20-[playerView]" options:0 metrics:nil views:@{@"topGuide": self.topLayoutGuide, @"playerView": self.playerView}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.playerView addConstraint:[NSLayoutConstraint constraintWithItem:self.playerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.playerView attribute:NSLayoutAttributeHeight multiplier:(16.0/9.0) constant:0]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.playerView loadPlayerWithVideoId:@"M7lc1UVf-VE"];
}

@end
