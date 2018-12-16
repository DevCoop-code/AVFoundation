//
//  PlayerView.m
//  PlaybackUsingAVPlayerLayer
//
//  Created by HanGyo Jeong on 16/12/2018.
//  Copyright © 2018 HanGyoJeong. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView

/*
 Returns the class used to create the layer for instances of this class
 */
+ (Class)layerClass{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player{
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
@end
