//
//  ViewController.m
//  VideoMediaCaptureApplication
//
//  Created by HanGyo Jeong on 03/01/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     Create and Configure a Capture Session
     */
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    /*
     Create & Configure the Device and Device Output
     */
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    //Make Input
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if(!input){
        
    }
    [session addInput:input];
    
    //Make Output
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc]init];
    [session addOutput:output];
    output.videoSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    
    dispatch_queue_t queue = dispatch_queue_create("MyQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
}

-(void)captureOutput:(AVCaptureOutput *)output
        didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
        fromConnection:(AVCaptureConnection *)connection{
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
}

#pragma - CMSampleBuffer to UIImage
- (UIImage*)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    //Get a CMSampleBuffer's Core Video Image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    //Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);   //0:kCVPixelBufferLock_ReadOnly
    
    //Get the ImageBuffer Address
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    //Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    //Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    //Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    //Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    //Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    //Release the Quartz Image
    CGImageRelease(quartzImage);
    
    return (image);
}

@end
