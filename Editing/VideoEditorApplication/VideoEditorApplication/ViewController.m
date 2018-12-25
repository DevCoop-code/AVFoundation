//
//  ViewController.m
//  VideoEditorApplication
//
//  Created by HanGyo Jeong on 23/12/2018.
//  Copyright © 2018 HanGyoJeong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /*
     load video & audio
     */
    NSURL *firstFileURL = [[NSBundle mainBundle] URLForResource:@"widowMakerPOTG" withExtension:@"mp4"];
    NSURL *secondFileURL = [[NSBundle mainBundle] URLForResource:@"tracerPOTG" withExtension:@"mp4"];
    NSURL *audioFileURL = [[NSBundle mainBundle] URLForResource:@"SamuraiHeart" withExtension:@"mp3"];
    
    _firstAsset = [AVURLAsset URLAssetWithURL:firstFileURL options:nil];
    _secondAsset = [AVURLAsset URLAssetWithURL:secondFileURL options:nil];
    _audioAsset = [AVURLAsset URLAssetWithURL:audioFileURL options:nil];
    
    /*
     Creating the Composition
     */
    //Generate AVMutableComposition Object
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
 
    AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    /*
     Adding the Assets
     */
    AVAssetTrack *firstVideoAssetTrack = [[_firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVAssetTrack *secondVideoAssetTrack = [[_secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVAssetTrack *audioAssetTrack = [[_audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration) ofTrack:firstVideoAssetTrack atTime:firstVideoAssetTrack.timeRange.duration error:nil];
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondVideoAssetTrack.timeRange.duration) ofTrack:secondVideoAssetTrack atTime:secondVideoAssetTrack.timeRange.duration error:nil];
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssetTrack.timeRange.duration)) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    
    /*
     Checking the video orientation
     */
    BOOL isFirstVideoPortrait = NO;
    CGAffineTransform firstTransform = firstVideoAssetTrack.preferredTransform;
    // Check the first video track's preferred transform to determine if it was recorded in portrait mode.
    if(firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0)){
        isFirstVideoPortrait = YES;
    }
    
    BOOL isSecondVideoPortrait = NO;
    CGAffineTransform secondTransform = secondVideoAssetTrack.preferredTransform;
    // Check the second video track's preferred transform to determine if it was recorded in portrait mode.
    if(secondTransform.a == 0 && secondTransform.d == 0 && (secondTransform.b == 1.0 || secondTransform.b == -1.0) && (secondTransform.c == 1.0 || secondTransform.c == -1.0)){
        isSecondVideoPortrait = YES;
    }
    
    if((isFirstVideoPortrait && !isSecondVideoPortrait) || (!isFirstVideoPortrait && isSecondVideoPortrait)){
        UIAlertView *incompatibleVideoOrientationAlert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Cannot combine a video shot in portrait mode with a video shot in landscape mode" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        
        [incompatibleVideoOrientationAlert show];
        
        return;
    }
    
    /*
     Applying the Video Composition Layer Instruction
     */
    //Generate Instruction Object
    AVMutableVideoCompositionInstruction *firstVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    AVMutableVideoCompositionInstruction *secondVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    // Set the time range of the first instruction to span the duration of the first video track.
    firstVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration);
    // Set the time range of the second instruction to span the duration of the second video track.
    secondVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, secondVideoAssetTrack.timeRange.duration);
    
    AVMutableVideoCompositionLayerInstruction *firstVideoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    AVMutableVideoCompositionLayerInstruction *secondVideoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    
    // Set the transform of the first layer instruction to the preferred transform of the first video track.
    [firstVideoLayerInstruction setTransform:firstTransform atTime:kCMTimeZero];
    // Set the transform of the second layer instruction to the preferred transform of the second video track.
    [secondVideoLayerInstruction setTransform:secondTransform atTime:kCMTimeZero];
    
    firstVideoCompositionInstruction.layerInstructions = @[firstVideoLayerInstruction];
    secondVideoCompositionInstruction.layerInstructions = @[secondVideoLayerInstruction];
    
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = @[firstVideoCompositionInstruction, secondVideoCompositionInstruction];
    
    /*
     Setting the Render Size and Frame Duration
     */
    CGSize naturalSizeFirst, naturalSizeSecond;
    // If the first video asset was shot in portrait mode, then so was the second one if we made it here.
    if(isFirstVideoPortrait){
        //Invert the width and height for the video tracks to ensure that they display properly.
        naturalSizeFirst = CGSizeMake(firstVideoAssetTrack.naturalSize.height, firstVideoAssetTrack.naturalSize.width);
        naturalSizeSecond = CGSizeMake(secondVideoAssetTrack.naturalSize.height, secondVideoAssetTrack.naturalSize.width);
    }
    // If the videos weren't shot in portrait mode, we can just use their natural sizes.
    else{
        naturalSizeFirst = firstVideoAssetTrack.naturalSize;
        naturalSizeSecond = secondVideoAssetTrack.naturalSize;
    }
    
    float renderWidth, renderHeight;
    // Set the renderWidth and renderHeight to the max of the two videos widths and heights.
    if(naturalSizeFirst.width > naturalSizeSecond.width){
        renderWidth = naturalSizeFirst.width;
    }else{
        renderWidth = naturalSizeSecond.width;
    }
    
    if(naturalSizeFirst.height > naturalSizeSecond.height){
        renderHeight = naturalSizeFirst.height;
    }else{
        renderHeight = naturalSizeSecond.height;
    }
    
    mutableVideoComposition.renderSize = CGSizeMake(renderWidth, renderHeight);
    
    // Set the frame duration to an appropriate value (i.e. 30 frames per second for video).
    mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    
    /*
     Exporting the Composition and Saving it to the Camera Roll
     */
    // Create a static date formatter so we only have to initialize it once.
    static NSDateFormatter *kDateFormatter;
    if(!kDateFormatter){
        kDateFormatter = [[NSDateFormatter alloc] init];
        kDateFormatter.dateStyle = NSDateFormatterMediumStyle;
        kDateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    // Create the export session with the composition and set the preset to the highest quality.
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    
    // Set the desired output URL for the file created by the export process.
    exporter.outputURL = [[[[NSFileManager defaultManager]URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:@YES error:nil]URLByAppendingPathComponent:[kDateFormatter stringFromDate:[NSDate date]]]URLByAppendingPathExtension:CFBridgingRelease(UTTypeCopyPreferredTagWithClass((CFStringRef)AVFileTypeQuickTimeMovie, kUTTagClassFilenameExtension))];
    
    // Set the output file type to be a QuickTime movie.
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mutableVideoComposition;
    
    // Asynchronously export the composition to a video file and save this file to the camera roll once export completes.
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(exporter.status == AVAssetExportSessionStatusCompleted){
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
                
                if([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:exporter.outputURL]){
                    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:exporter.outputURL completionBlock:nil];
                }
            }
        });
    }];
}

- (IBAction)loadAsset:(id)sender {
    NSURL *firstFileURL = [[NSBundle mainBundle] URLForResource:@"widowMakerPOTG" withExtension:@"mp4"];
    NSURL *secondFileURL = [[NSBundle mainBundle] URLForResource:@"tracerPOTG" withExtension:@"mp4"];
    NSURL *audioFileURL = [[NSBundle mainBundle] URLForResource:@"SamuraiHeart" withExtension:@"mp3"];
    
    _firstAsset = [AVURLAsset URLAssetWithURL:firstFileURL options:nil];
    _secondAsset = [AVURLAsset URLAssetWithURL:secondFileURL options:nil];
    _audioAsset = [AVURLAsset URLAssetWithURL:audioFileURL options:nil];
}


@end
