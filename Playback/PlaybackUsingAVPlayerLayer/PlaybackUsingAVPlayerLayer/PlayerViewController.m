//
//  PlayerViewController.m
//  PlaybackUsingAVPlayerLayer
//
//  Created by HanGyo Jeong on 16/12/2018.
//  Copyright © 2018 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "PlayerView.h"

@interface PlayerViewController : UIViewController

@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

//Load the Video
- (IBAction)loadAssetFromFile:(id)sender;
- (IBAction)play:(id)sender;

// synchronizes the button’s state with the player’s state
- (void)syncUI;
@end

@implementation PlayerViewController

static const NSString *ItemStatusContext;

- (void)viewDidLoad{
    [super viewDidLoad];
    [self syncUI];
    
    //Make sound when ios silence
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)syncUI{
    if((self.player.currentItem != nil) && ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)){
        self.startButton.enabled = YES;
    }else{
        self.startButton.enabled = NO;
    }
}

- (IBAction)loadAssetFromFile:(id)sender {
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"widowMakerPOTG" withExtension:@"mp4"];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSString *tracksKey = @"tracks";
    
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:^{
       //The Completion Block
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
            
            if(status == AVKeyValueStatusLoaded){
                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                
                //ensure that this is done before the playeritem is associated with the player
                [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial context:&ItemStatusContext];
                
                //Register the event
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
                
                self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                [self.playerView setPlayer:self.player];
            }
            else{
                // You should deal with the error appropriately.
                NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
            }
        });
    }];
}

- (IBAction)play:(id)sender {
    [self.player play];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification{
    [self.player seekToTime:kCMTimeZero];
}

//When the player item’s status changes, the view controller receives a key-value observing change notification
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if(context == &ItemStatusContext){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncUI];
        });
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    return;
}

@end
