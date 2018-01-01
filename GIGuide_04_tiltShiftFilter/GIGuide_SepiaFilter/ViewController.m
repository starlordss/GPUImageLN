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
/**原图效果展示图片控件**/
@property (nonatomic, strong) GPUImageView *imgView;

@property (nonatomic, strong) GPUImagePicture *outputPicture;
@property (nonatomic , strong) GPUImageTiltShiftFilter *tiltShiftFilter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"1.jpeg"];
    self.view = self.imgView;
    _outputPicture = [[GPUImagePicture alloc] initWithImage:image];
    self.tiltShiftFilter = [[GPUImageTiltShiftFilter alloc] init];
    // 模糊半径：px
    self.tiltShiftFilter.blurRadiusInPixels = 40.0;
    // 促使处理的大小
    [self.tiltShiftFilter forceProcessingAtSize:self.imgView.sizeInPixels];
    // 添加滤镜
    [self.outputPicture addTarget:self.tiltShiftFilter];
    // 添加控件在滤镜上
    [self.tiltShiftFilter addTarget:self.imgView];
    // 渲染图片
    [self.outputPicture processImage];
    
    // CGPImageContext 相关的数据显示
    GLint size = [GPUImageContext maximumTextureSizeForThisDevice];
    GLint unit = [GPUImageContext maximumTextureUnitsForThisDevice];
    GLint vector = [GPUImageContext maximumVaryingVectorsForThisDevice];
    NSLog(@"size:%d unit:%d vector:%d",size,unit,vector);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:touch.view];
    float rate = point.y / self.view.frame.size.height;
    NSLog(@"处理中");
    [self.tiltShiftFilter setTopFocusLevel:rate - 0.1];
    [self.tiltShiftFilter setBottomFocusLevel:rate + 0.1];
    [self.outputPicture processImage];
}

#pragma mark - GETTER
- (GPUImageView *)imgView
{
    if (_imgView == nil) {
        _imgView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgView;
}

@end
