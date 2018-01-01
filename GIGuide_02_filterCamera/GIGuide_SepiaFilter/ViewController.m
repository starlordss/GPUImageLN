//
//  ViewController.m
//  GIGuide_SepiaFilter
//
//  Created by Zahi on 2018/1/1.
//  Copyright © 2018年 Zahi. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage.h>

@interface ViewController ()
/**图片控件*/
@property (nonatomic, strong) GPUImageView *imageView;
/**相机**/
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.imageView];
    // 马赛克滤镜
    GPUImagePixellateFilter *filter = [[GPUImagePixellateFilter alloc] init];
//    GPUImageSketchFilter *filter = [[GPUImageSketchFilter alloc] init];
    // 给相机添加滤镜：当新frames可用时，添加一个目标接受通知
    [self.videoCamera addTarget:filter];
    // 展示滤镜
    [filter addTarget:self.imageView];
    // 开始捕获
    [self.videoCamera startCameraCapture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    

}


- (void)deviceOrientationDidChange:(NSNotification *)noti {
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    self.videoCamera.outputImageOrientation = orientation;
}

- (GPUImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
        _imageView.backgroundColor = [UIColor yellowColor];
        /**
         * kGPUImageFillModeStretch,  拉伸来填充整个视图，可能会扭曲图像
         * kGPUImageFillModePreserveAspectRatio, 保持源图像的宽比，会出现黑边
         * kGPUImageFillModePreserveAspectRatioAndFill 保持源图像的纵横比，放大其中心以填充视图
         */
        _imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        
        
    }
    return _imageView;
}


- (GPUImageVideoCamera *)videoCamera
{
    if (_videoCamera == nil) {
        /**
         * 参数一：预置CaputrePreset-->可以捕获不同的分辨率的session
         * 参数二：相机的位置：这里是后置 AVCaptureDevicePositionBack
         */
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    }
    return _videoCamera;
}

@end
