//
//  ViewController.m
//  AddingSubtitleVideo
//
//  Created by HanGyo Jeong on 05/01/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

#import "AddSubtitleViewController.h"

@interface AddSubtitleViewController ()

@end

@implementation AddSubtitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)loadAsset:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (IBAction)generateOutput:(id)sender {
    [self videoOutput];
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    //Set up Text Layer
    CATextLayer *subtitleText = [[CATextLayer alloc] init];
    [subtitleText setFont:@"Helvetica-Bold"];
    [subtitleText setFontSize:32];
    [subtitleText setFrame:CGRectMake(0, 0, size.width, 100)];
    [subtitleText setString:_subText.text];
    [subtitleText setAlignmentMode:kCAAlignmentCenter];
    [subtitleText setForegroundColor:[[UIColor whiteColor] CGColor]];
    
    //Usual overlay layer
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:subtitleText];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}
@end
