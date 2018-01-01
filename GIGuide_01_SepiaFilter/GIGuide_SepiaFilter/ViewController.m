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
@property (nonatomic, strong) UIImageView *imgView;
/**处理后效果展示图片控件**/
@property (nonatomic, strong) UIImageView *laterImgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.imgView];
    [self.view addSubview:self.laterImgView];
    //  让laterImgView的图片成深褐色效果
    [self sepiaFilterWithImageView:self.laterImgView];
    
}


/// 让图片控件的图片成深褐色效果
- (void)sepiaFilterWithImageView:(UIImageView *)imageView
{
    UIImage *img = imageView.image;
    // 深褐色滤镜
    GPUImageSepiaFilter *sepiaFilter = [GPUImageSepiaFilter new];
    if (img) {
        imageView.image = [sepiaFilter imageByFilteringImage:img];
    }
}

#pragma mark - GETTER
- (UIImageView *)imgView
{
    if (_imgView == nil) {
        _imgView = [[UIImageView alloc] initWithImage:[self loadImage]];
        _imgView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 0.5);
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgView;
}

- (UIImageView *)laterImgView
{
    if (_laterImgView == nil) {
        _laterImgView = [[UIImageView alloc] initWithImage:[self loadImage]];
        _laterImgView.frame = CGRectMake(0, CGRectGetMaxY(_imgView.frame), self.view.bounds.size.width, CGRectGetHeight(_imgView.frame));
        _laterImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _laterImgView;
}

- (UIImage *)loadImage {
    return [UIImage imageNamed:@"sw.jpg"];
}

@end
