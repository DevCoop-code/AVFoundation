//
//  ViewController.h
//  AddingSubtitleVideo
//
//  Created by HanGyo Jeong on 05/01/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

#import "CommonVideoViewController.h"

@interface AddSubtitleViewController : CommonVideoViewController

@property (weak, nonatomic) IBOutlet UITextField *subText;

- (IBAction)loadAsset:(id)sender;
- (IBAction)generateOutput:(id)sender;

@end

