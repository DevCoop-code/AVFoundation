//
//  AddBorderViewController.h
//  AddingBorderToVideo
//
//  Created by HanGyo Jeong on 05/01/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CommonVideoViewController.h"

@interface AddBorderViewController : CommonVideoViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSegment;
@property (weak, nonatomic) IBOutlet UISlider *widthBar;

- (IBAction)loadAsset:(id)sender;
- (IBAction)generateOutput:(id)sender;

@end
