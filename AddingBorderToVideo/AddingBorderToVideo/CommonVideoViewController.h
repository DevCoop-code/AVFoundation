//
//  ViewController.h
//  AddingBorderToVideo
//
//  Created by HanGyo Jeong on 04/01/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface CommonVideoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong)AVAsset *videoAsset;

- (BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;
- (void)exportDidFinish:(AVAssetExportSession*)session;
- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition*)composition size:(CGSize)size;
- (void)videoOutput;

@end

