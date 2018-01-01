//
//  ViewController.m
//  GIGuide_SepiaFilter
//
//  Created by Zahi on 2018/1/1.
//  Copyright © 2018年 Zahi. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage.h>
#import "GPUImageBeautifyFilter.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()
/**图片控件*/
@property (nonatomic, strong) GPUImageView *imageView;
/**相机**/
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
/**导演*/
@property (nonatomic , strong) GPUImageMovieWriter *movieWriter;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.imageView];
    // 视频的路径
    NSString *moviePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.m4v"];
    unlink([moviePath UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
    // 实例化writer: size大小和屏幕一样大小可以显示的效果和录制效果一致
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:[UIScreen mainScreen].bounds.size];
    // 设置相机的编码目标为writer
    self.videoCamera.audioEncodingTarget = _movieWriter;
    // 实时编码视频
    _movieWriter.encodingLiveVideo = YES;
    // 相机开始捕获
    [self.videoCamera startCameraCapture];
    // 美颜滤镜
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:[UIScreen mainScreen].bounds];
    // 添加美颜滤镜
    [self.videoCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:self.imageView];
    [beautifyFilter addTarget:self.movieWriter];
    // 开始录制
    [_movieWriter startRecording];
    
    // 5s结束录制
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [beautifyFilter removeTarget:_movieWriter];
        [_movieWriter finishRecording];
        //  创建资源库
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        // 判断路径和相册是否兼容
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
            
                [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
                    // 
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"视频保存失败" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
                            [alert addAction:action];
                            [self presentViewController:alert animated:YES completion:nil];
                        } else {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"视频保存成功" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
                            [alert addAction:action];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    });
                }];
        } else {
             NSLog(@"error");
        }

    
    });
}


- (GPUImageVideoCamera *)videoCamera
{
    if (_videoCamera == nil) {
        // 初始化：分辨率和相机位置（前置摄像头）
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
        // 输出的图片方向
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        // 镜子前的效果
        _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
        // 镜子后面的效果
//        _videoCamera.horizontallyMirrorRearFacingCamera = YES;
        
    }
    return _videoCamera;
}

- (GPUImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
//        _imageView.center  = self.view.center;
        _imageView.fillMode = kGPUImageFillModePreserveAspectRatio;

    }
    return _imageView;
}

@end
