//
//  ZSPlayerVideoBrightnessView.m
//  ZSAVPlayerVideo
//
//  Created by 周松 on 16/9/11.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSPlayerVideoBrightnessView.h"
#import "ZSPlayerVideoContolView.h"
#import "ZSPlayerVideoTimeIndicatorView.h"
#import "ZSPlayerVideoVolumeView.h"

static const CGFloat kTopMargin = 21.0;
//视图自动消失时间
static const CGFloat kBrightnessAutoFadeInterval = 1.0;

@interface ZSPlayerVideoBrightnessView ()

//存放亮度条的数组
@property (nonatomic,strong) NSMutableArray *brightnessArray;

@end
@implementation ZSPlayerVideoBrightnessView

- (void)dealloc{
    
    [[UIScreen mainScreen]removeObserver:self forKeyPath:@"brightness"];
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.hidden = YES;
        
        self.layer.cornerRadius = 5;
        
        self.layer.masksToBounds = YES;
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
        //创建亮度图片视图
        [self creatBrightnessImageView];
        
        //注册观察者,观察系统的亮度
        [self creatObserveBrightness];
        
    }
    
    return self;
}
///注册观察者观察系统亮度
- (void)creatObserveBrightness{
    
    [[UIScreen mainScreen] addObserver:self forKeyPath:@"brightness" options:NSKeyValueObservingOptionNew context:NULL];
    
}

//在观察者中实现
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    CGFloat brightness = [change[@"new"] floatValue];
    
    [self updateBrightness:brightness];
}


///更新指示器
- (void)updateBrightness:(CGFloat)brightness{
    
    self.hidden = NO;
    
    //防重叠显示
    if (self.superview.accessibilityIdentifier) {
        
        ZSPlayerVideoContolView *playerView = (ZSPlayerVideoContolView *)self.superview;
        
//        self.timeView
        playerView.timeIndicationView.hidden = YES;
        
        playerView.volumeView.hidden = YES;
        
    
    }else{
        
        self.superview.accessibilityIdentifier = @"";
    }
    
    NSInteger level = brightness * 16;

    for (NSInteger i = 0; i < self.brightnessArray.count; i ++) {
        
        UIImageView *img = self.brightnessArray[i];
        
        if (i <= level) {
            
            img.hidden = NO;
            
        }else{
            
            img.hidden = YES;
        }
        
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animationHide) object:nil];
    
    [self performSelector:@selector(animationHide) withObject:nil afterDelay:kBrightnessAutoFadeInterval];
    
}

- (void)animationHide{
    
    [UIView animateWithDuration:3 animations:^{
        
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
       
        self.hidden = YES;
        
        self.alpha = 1.0;//这里不设置非透明,下次再滑动就不会显示亮度图标
        
        self.superview.accessibilityIdentifier = nil;
    }];
    
}

///创建亮度视图
- (void)creatBrightnessImageView{
    
    //创建亮度图标
    UIImageView *brightnessImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kPlayerVideoBrightnessViewWH - 50) / 2, kTopMargin, 50, 50)];
    
    brightnessImageView.image = [UIImage imageNamed:@"zx-video-player-brightness"];
    
    [self addSubview:brightnessImageView];
    
    //创建一个可变数组,容量为16
    self.brightnessArray = [NSMutableArray arrayWithCapacity:16];
    
    //创建亮度条
    UIView *brightnessBarView = [[UIView alloc] initWithFrame:CGRectMake((kPlayerVideoBrightnessViewWH - 105) / 2, 50 + kTopMargin * 2, 105, 2.75 + 2)];
    
    brightnessBarView.backgroundColor = [UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:0.65];
    
    [self addSubview:brightnessBarView];
    
    CGFloat margin = 1;
    CGFloat brightnessW = 5.5;
    CGFloat brightnessH = 2.75;
    
    for (int i = 0; i < 16; i ++) {
        
        CGFloat x = i * (margin + brightnessW) + margin;
        
        UIImageView *brightnessBarImageView = [[UIImageView alloc] init];
        
        brightnessBarImageView.backgroundColor = [UIColor whiteColor];
        
        brightnessBarImageView.frame = CGRectMake(x, margin, brightnessW, brightnessH);
        
        [brightnessBarView addSubview:brightnessBarImageView];
        
        [self.brightnessArray addObject:brightnessBarImageView];
        
    }
    
}

@end


















