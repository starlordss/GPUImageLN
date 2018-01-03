//
//  ViewController.m
//  GIGuide_SepiaFilter
//
//  Created by Zahi on 2018/1/1.
//  Copyright © 2018年 Zahi. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage.h>
#import <Photos/Photos.h>

@interface ViewController ()
/**展示滤镜效果的视图*/
@property (nonatomic, strong) GPUImageView        *filterView;
/**相机**/
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) GPUImageMovie       *movie;
/**滤镜**/
@property (nonatomic, strong) GPUImageDissolveBlendFilter *filter;
/**提示录制标签**/
@property (nonatomic, strong) UILabel   *tipsLbl;


@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // 布局子view
    self.view = self.filterView;
    [self.view addSubview:self.tipsLbl];
    
    // 播放视频文件路径
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"demo.mp4" withExtension:nil];
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    self.movie = [[GPUImageMovie alloc] initWithAsset:asset];
    // 支持基准测试模式，它可以将瞬时和平均帧时间记录到控制台
    self.movie.runBenchmark = YES;
    // 按实际速度播放视频
    self.movie.playAtActualSpeed = YES;

    // 加水印到视频中
    CGSize size = self.view.bounds.size;
    NSLog(@"%@",NSStringFromCGSize(size));
    // 水印文字
    UILabel *watermarkLbl = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 50)];
    watermarkLbl.text = @"水印水印——眔眔的爱";
    watermarkLbl.font = [UIFont systemFontOfSize:30];
    watermarkLbl.textColor = [UIColor cyanColor];
    // 水印图片
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"watermark.png"]];
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.center = CGPointMake(subView.bounds.size.width / 2, subView.bounds.size.height / 2);
    [subView addSubview:imageView];
    [subView addSubview:watermarkLbl];
    
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc] initWithView:subView];
    // 录制的文件路径
    NSString *recordPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/movie.m4v"];
    unlink([recordPath UTF8String]);
    NSURL *recordURL = [NSURL fileURLWithPath:recordPath];
    // 初始化movieWriter
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:recordURL size:CGSizeMake(640.0, 480.0)];
    
    GPUImageFilter* progressFilter = [[GPUImageFilter alloc] init];
    [self.movie addTarget:progressFilter];
    [progressFilter addTarget:self.filter];
    [uielement addTarget:self.filter];
    
    self.movieWriter.shouldPassthroughAudio = YES;
    self.movie.audioEncodingTarget = self.movieWriter;
    [self.movie enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
    
    // 显示滤镜效果
    [self.filter addTarget:self.filterView];
    [self.filter addTarget:self.movieWriter];
    
    // 显示在view
    [self.filter addTarget:self.filterView];
    [self.filter addTarget:self.movieWriter];
    
    // 开始
    [self.movieWriter startRecording];
    [self.movie startProcessing];
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//    link.paused = NO;
    
    __weak typeof(self) _self = self;
    [progressFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.transform = CGAffineTransformTranslate(imageView.transform, 2, 2);
            [uielement updateWithTimestamp:time];
        });
       
    }];
    // movieWriter完成的回调
    [self.movieWriter setCompletionBlock:^{

        [_self.filter removeTarget:_self.movieWriter];
        [_self.movieWriter finishRecording];
        
        __block NSString *createdAssetID = nil;
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(recordPath)) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:recordURL].placeholderForCreatedAsset.localIdentifier;
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (error) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"视频保存失败" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
                        [alert addAction:action];
                        [_self presentViewController:alert animated:YES completion:nil];
                    } else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"视频保存成功" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
                        [alert addAction:action];
                        [_self presentViewController:alert animated:YES completion:nil];
                    }
                });
            }];
        }
    }];
}
#pragma mark - UI EVENT
- (void)updateProgress {
    self.tipsLbl.text = [NSString stringWithFormat:@"进度:%d%%", (int)(self.movie.progress * 100)];
}
#pragma mark - lazy
- (UILabel *)tipsLbl {
    if (_tipsLbl == nil) {
        _tipsLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 100)];
        _tipsLbl.textColor = [UIColor cyanColor];
    }
    return _tipsLbl;
}
- (GPUImageDissolveBlendFilter *)filter
{
    if (_filter == nil) {
        _filter = [[GPUImageDissolveBlendFilter alloc] init];
        _filter.mix = 0.5;
    }
    return _filter;
}

- (GPUImageView *)filterView
{
    if (_filterView == nil) {
        _filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    }
    return _filterView;
}

- (GPUImageVideoCamera *)videoCamera
{
    if (_videoCamera == nil) {
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
        _videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    }
    return _videoCamera;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
