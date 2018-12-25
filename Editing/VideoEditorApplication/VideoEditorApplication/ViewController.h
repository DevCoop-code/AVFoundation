//
//  ViewController.h
//  VideoEditorApplication
//
//  Created by HanGyo Jeong on 23/12/2018.
//  Copyright © 2018 HanGyoJeong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreServices/CoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController : UIViewController

@property(nonatomic) AVURLAsset *firstAsset;
@property(nonatomic) AVURLAsset *secondAsset;
@property(nonatomic) AVURLAsset *audioAsset;

@end

