//
//  ViewController.m
//  JGLearnGPUImage
//
//  Created by mtgao on 2018/4/26.
//  Copyright © 2018年 mtgao. All rights reserved.
//

#import "ViewController.h"

#import <GPUImage.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()
{
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    
    GPUImageMovieWriter *movieWriter;
    BOOL isRecording;
}
@property (weak, nonatomic) IBOutlet UISlider *slider;
@end

@implementation ViewController


#pragma mark --Actions---
- (IBAction)doRecord:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    if(isRecording){
        [self stopRecord];
        isRecording = NO;
        [btn setTitle:@"开始录制" forState:UIControlStateNormal];
    }else{
        isRecording = YES;
        [self startRecord];
        [btn setTitle:@"停止录制" forState:UIControlStateNormal];
    }
}

- (IBAction)didSliderUpdate:(id)sender {
    UISlider *slider = (UISlider *)sender;
    GPUImageBrightnessFilter *brightFilter = (GPUImageBrightnessFilter *)filter;
    brightFilter.brightness = slider.value;
}


#pragma mark --LifeCycle---
- (void)viewDidLoad {
    [super viewDidLoad];
    [self audioSessionConfig];
    [self capture];
}


- (void)audioSessionConfig{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
}

- (void)capture{
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    filter = [[GPUImageBrightnessFilter alloc] init];
    
    GPUImageView *filterView = (GPUImageView *)self.view;
    
    [videoCamera addTarget:filter];
    [filter addTarget:filterView];
    
    [videoCamera startCameraCapture];
}

- (void)startRecord{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject];
    NSURL *url = [NSURL fileURLWithPath:[documentPath stringByAppendingPathComponent:@"hello.mp4"]];
    unlink(url.path.UTF8String);
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:CGSizeMake(480.0, 640.0)];
    movieWriter.encodingLiveVideo = YES;
   
    [videoCamera addTarget:movieWriter];
    videoCamera.audioEncodingTarget = movieWriter;
    
    [movieWriter startRecording];
}

- (void)stopRecord{
     [movieWriter finishRecording];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject];
    NSURL *url = [NSURL fileURLWithPath:[documentPath stringByAppendingPathComponent:@"hello.mp4"]];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path))
    {
        [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存失败" message:nil
                                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 } else {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存成功" message:nil
                                                                    delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 }
             });
         }];
    }
}

@end
