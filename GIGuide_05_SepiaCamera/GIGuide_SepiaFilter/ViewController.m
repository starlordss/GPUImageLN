//
//  ViewController.m
//  GIGuide_SepiaFilter
//
//  Created by Zahi on 2018/1/1.
//  Copyright © 2018年 Zahi. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()
/**展示滤镜效果的视图*/
@property (nonatomic, strong) GPUImageView        *filterView;
/**相机**/
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
/**滤镜**/
@property (nonatomic, strong) GPUImageSepiaFilter *filter;

/**录制/结束按钮**/
@property (nonatomic, strong) UIButton  *recordBtn;
/**提示录制标签**/
@property (nonatomic, strong) UILabel   *tipsLbl;
/**滑条**/
@property (nonatomic, strong) UISlider  *slider;
/**定时器**/
@property (nonatomic, strong) NSTimer        *recordTimer;
@property (nonatomic , strong) CADisplayLink *displayLink;


@end

@implementation ViewController {
    NSURL          *_movieURL;
    NSString       *_moviePath;
    int            _second;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _second = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置UI
    self.view = self.filterView;
    [self.view addSubview:self.recordBtn];
    [self.view addSubview:self.tipsLbl];
    [self.view addSubview:self.slider];

    // 设置文件路径
    _moviePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/movie.m4v"];
    _movieURL = [NSURL fileURLWithPath:_moviePath];
    
    // 滤镜关联
    [self.videoCamera addTarget:self.filter];
    [self.filter addTarget:self.filterView];
    // 相机开始捕获
    [self.videoCamera startCameraCapture];
    
    // 订阅通知
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        _videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    }];
}
- (void)setTips{
    _tipsLbl.text = [NSString stringWithFormat:@"录制时间:%ds", _second++];
}

#pragma mark - UI EVENT
- (void)onClick:(UIButton *)btn {
    btn.selected = !btn.isSelected;
    if (btn.isSelected) {
        btn.backgroundColor = [UIColor redColor];
        NSLog(@"按钮被选中....开始录制");
        //如果已经存在文件，AVAssetWriter会有异常
        unlink([_moviePath UTF8String]);
        // 给滤镜添加movieWriter
        [self.filter addTarget:self.movieWriter];
        self.videoCamera.audioEncodingTarget = self.movieWriter;
        // 开始录制
        [self.movieWriter startRecording];
        
        _tipsLbl.hidden = NO;
        _second = 0;
        [self setTips];
        _recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setTips) userInfo:nil repeats:YES];
    } else {
        btn.backgroundColor = [UIColor yellowColor];
        NSLog(@"取消选选中---取消录制");
        _tipsLbl.hidden = YES;
        if (_recordTimer) {
            [_recordTimer invalidate];
        }
        [self.filter removeTarget:self.movieWriter];
        _videoCamera.audioEncodingTarget = nil;
        [_movieWriter finishRecording];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_moviePath))
        {
            [library writeVideoAtPathToSavedPhotosAlbum:_movieURL completionBlock:^(NSURL *assetURL, NSError *error)
             {
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
        }
    }
}

- (void)updateSliderValue:(UISlider *)slider {
    // 设置滤镜效果程度
    [self.filter setIntensity:slider.value];
}
#pragma mark - lazy
- (UISlider *)slider
{
    if (_slider == nil) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(self.view.frame) - 44, 250, 44)];
        [_slider addTarget:self action:@selector(updateSliderValue:) forControlEvents:UIControlEventValueChanged];
        _slider.value = 0.5;
    }
    return _slider;
}

- (UILabel *)tipsLbl {
    if (_tipsLbl == nil) {
        _tipsLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.recordBtn.frame) + 10, 20, 150, 44)];
        _tipsLbl.hidden = YES;
        _tipsLbl.textColor = [UIColor whiteColor];
    }
    return _tipsLbl;
}
- (UIButton *)recordBtn {
    if (!_recordBtn) {
        _recordBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 70, 44)];
        _recordBtn.backgroundColor = [UIColor yellowColor];
        [_recordBtn setTitle:@"录制" forState:UIControlStateNormal];
        [_recordBtn setTitle:@"结束" forState:UIControlStateSelected];
        [_recordBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordBtn;
}

- (GPUImageMovieWriter *)movieWriter
{
    if (_movieWriter == nil) {
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:_movieURL size:CGSizeMake(480.0, 640.0)];
        _movieWriter.encodingLiveVideo = YES;
        
    }
    return _movieWriter;
}


- (GPUImageSepiaFilter *)filter
{
    if (_filter == nil) {
        _filter = [[GPUImageSepiaFilter alloc] init];
        _filter.intensity = 0.5f;
    }
    return _filter;
}

- (GPUImageView *)filterView
{
    if (_filterView == nil) {
        _filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
        /**
         * kGPUImageFillModeStretch,  拉伸来填充整个视图，可能会扭曲图像
         * kGPUImageFillModePreserveAspectRatio, 保持源图像的宽比，会出现黑边
         * kGPUImageFillModePreserveAspectRatioAndFill 保持源图像的纵横比，放大其中心以填充视图
         */
    }
    return _filterView;
}

- (GPUImageVideoCamera *)videoCamera
{
    if (_videoCamera == nil) {
        /**
         * 参数一：预置CaputrePreset-->可以捕获不同的分辨率的session
         * 参数二：相机的位置：这里是后置 AVCaptureDevicePositionBack
         */
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
        _videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
    }
    return _videoCamera;
}

@end
