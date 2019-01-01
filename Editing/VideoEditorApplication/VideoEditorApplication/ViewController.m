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
    
    if(firstVideoAssetTrack != nil){
        NSLog(@"firstVideo AssetTrack is exists");
    }
    if(secondVideoAssetTrack != nil){
        NSLog(@"secondVideo AssetTrack is exists");
    }
    if(audioAssetTrack != nil){
        NSLog(@"audio AssetTrack is exists");
    }
    
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration) ofTrack:firstVideoAssetTrack atTime:kCMTimeZero error:nil];
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondVideoAssetTrack.timeRange.duration) ofTrack:secondVideoAssetTrack atTime:firstVideoAssetTrack.timeRange.duration error:nil];
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
        NSLog(@"Error Cannot combine a video shot in portrai tmode with a video shot in landscape mode");
        //Deprecated in ios 9.0
//        UIAlertView *incompatibleVideoOrientationAlert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Cannot combine a video shot in portrait mode with a video shot in landscape mode" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        
//        [incompatibleVideoOrientationAlert show];
        
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
    secondVideoCompositionInstruction.timeRange = CMTimeRangeMake(firstVideoAssetTrack.timeRange.duration, secondVideoAssetTrack.timeRange.duration);
    
    AVMutableVideoCompositionLayerInstruction *firstVideoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    AVMutableVideoCompositionLayerInstruction *secondVideoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    
    // Set the transform of the first layer instruction to the preferred transform of the first video track.
    [firstVideoLayerInstruction setTransform:firstTransform atTime:kCMTimeZero];
    // Set the transform of the second layer instruction to the preferred transform of the second video track.
    [secondVideoLayerInstruction setTransform:secondTransform atTime:firstVideoAssetTrack.timeRange.duration];
    
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
        NSLog(@"First video asset was shot in portrait mode");
        //Invert the width and height for the video tracks to ensure that they display properly.
        naturalSizeFirst = CGSizeMake(firstVideoAssetTrack.naturalSize.height, firstVideoAssetTrack.naturalSize.width);
        naturalSizeSecond = CGSizeMake(secondVideoAssetTrack.naturalSize.height, secondVideoAssetTrack.naturalSize.width);
    }
    // If the videos weren't shot in portrait mode, we can just use their natural sizes.
    else{
        NSLog(@"Videos weren't shot in portrait mode");
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
    
    NSError *error;
    // Set the desired output URL for the file created by the export process.
    exporter.outputURL = [[[[NSFileManager defaultManager]URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error]
                           URLByAppendingPathComponent:[kDateFormatter stringFromDate:[NSDate date]]]
                          URLByAppendingPathExtension:CFBridgingRelease(UTTypeCopyPreferredTagWithClass((CFStringRef)AVFileTypeQuickTimeMovie, kUTTagClassFilenameExtension))];
    
    if(error){
        NSLog(@"Fail to create exporter outputURL");
    }
    // Set the output file type to be a QuickTime movie.
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mutableVideoComposition;
    
    NSLog(@"export asynchronous");
    // Asynchronously export the composition to a video file and save this file to the camera roll once export completes.
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(exporter.status == AVAssetExportSessionStatusCompleted){
                NSLog(@"exporter session status completed");
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];

                if([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:exporter.outputURL]){
                    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:exporter.outputURL completionBlock:nil];
                }
//                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//                    switch (status) {
//                        case PHAuthorizationStatusAuthorized:{
//                            NSLog(@"PHAuthorizationStatusAuthorized");
//                            __block PHObjectPlaceholder *placeholder;
//                            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//                                PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:exporter.outputURL];
//                                placeholder = [createAssetRequest placeholderForCreatedAsset];
//                            } completionHandler:^(BOOL success, NSError * _Nullable error) {
//                                if(success){
//                                    NSLog(@"Success!!");
//                                }else{
//                                    NSLog(@"Fail!!");
//                                }
//                            }];
//                        }
//                            break;
//
//                        case PHAuthorizationStatusRestricted:
//                            NSLog(@"PHAuthorizationStatusRestricted");
//                            break;
//
//                        case PHAuthorizationStatusDenied:
//                            NSLog(@"PHAuthorizationStatusDenied");
//                            break;
//                        case PHAuthorizationStatusNotDetermined:
//                            NSLog(@"PHAuthorizationStatusNotDetermined");
//                            break;
//                    }
//                }];
            }
            else if(exporter.status == AVAssetExportSessionStatusUnknown){
                NSLog(@"exporter session status unknown");
            }
            else if(exporter.status == AVAssetExportSessionStatusWaiting){
                NSLog(@"exporter session status waiting");
            }
            else if(exporter.status == AVAssetExportSessionStatusFailed){
                NSLog(@"exporter session status Failed");
            }
        });
    }];
}


@end
