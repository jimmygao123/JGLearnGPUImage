//
//  ViewController.m
//  JGLearnGPUImage
//
//  Created by mtgao on 2018/4/26.
//  Copyright © 2018年 mtgao. All rights reserved.
//

#import "ViewController.h"

#import <GPUImage.h>

@interface ViewController ()
{
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
}
@property (weak, nonatomic) IBOutlet UISlider *slider;
@end

@implementation ViewController

- (IBAction)didSliderUpdate:(id)sender {
    UISlider *slider = (UISlider *)sender;
    GPUImageBrightnessFilter *brightFilter = (GPUImageBrightnessFilter *)filter;
    brightFilter.brightness = slider.value;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    
    filter = [[GPUImageBrightnessFilter alloc] init];

    GPUImageView *filterView = (GPUImageView *)self.view;
    
    [videoCamera addTarget:filter];
    [filter addTarget:filterView];

    [videoCamera startCameraCapture];
}


@end
