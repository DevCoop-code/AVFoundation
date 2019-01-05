//
//  AddBorderViewController.m
//  AddingBorderToVideo
//
//  Created by HanGyo Jeong on 05/01/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

#import "AddBorderViewController.h"

@interface AddBorderViewController()

@end

@implementation AddBorderViewController

- (IBAction)loadAsset:(id)sender {
    NSLog(@"loadAsset Function called");
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (IBAction)generateOutput:(id)sender {
    NSLog(@"generateOutput Function called");
    [self videoOutput];
}

- (UIImage *)imageWithColor:(UIColor *)color rectSize:(CGRect)imageSize
{
    CGRect rect = imageSize;
    //Creates a bitmap-based graphics context with the spectied options
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   //Fill the specified color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    UIImage *borderImage = nil;
    if(_colorSegment.selectedSegmentIndex == 0){
        borderImage = [self imageWithColor:[UIColor blueColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
    }else if(_colorSegment.selectedSegmentIndex == 1){
        borderImage = [self imageWithColor:[UIColor redColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
    }else if(_colorSegment.selectedSegmentIndex == 2){
        borderImage = [self imageWithColor:[UIColor greenColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
    }else if(_colorSegment.selectedSegmentIndex == 3){
        borderImage = [self imageWithColor:[UIColor whiteColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
    }
    
    //Create background layer
    CALayer *backgroundLayer = [CALayer layer];
    [backgroundLayer setContents:(id)[borderImage CGImage]];
    backgroundLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [backgroundLayer setMasksToBounds:YES];
    
    //Create video layer
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(_widthBar.value, _widthBar.value, size.width - (_widthBar.value * 2), size.height - (_widthBar.value * 2));
    
    //Create parent layer
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    //Add background layer and video layer to parent layer
    //Ordering is important, ordering determine the sublayer depth
    [parentLayer addSublayer:backgroundLayer];
    [parentLayer addSublayer:videoLayer];
    
    composition.animationTool= [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}
@end
