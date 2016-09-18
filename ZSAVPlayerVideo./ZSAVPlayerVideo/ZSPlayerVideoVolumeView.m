//
//  ZSPlayerVideoVolumeView.m
//  ZSAVPlayerVideo
//
//  Created by 周松 on 16/9/12.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSPlayerVideoVolumeView.h"
#import "ZSPlayerVideoContolView.h"
#import "ZSPlayerVideoTimeIndicatorView.h"
#import "ZSPlayerVideoBrightnessView.h"

static const CGFloat kViewSpacing = 21.0;
static const CGFloat kVolumeIndicatorAutoFadeOutTimeInterval = 1.0;
@interface ZSPlayerVideoVolumeView ()

//可变数组,存放音量条
@property (nonatomic,strong) NSMutableArray *volumArray;

//音量图标
@property (nonatomic,strong) UIImageView *volumImageView;

@end
@implementation ZSPlayerVideoVolumeView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.layer.cornerRadius = 5;
        
        self.layer.masksToBounds = YES;
        
        self.hidden = YES;
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
        [self creatVolumIndicator];
        
        [self volumNotification];
    }
    
    return self;
}

//创建音量指示器
- (void)creatVolumIndicator{
   
    self.volumImageView = [[UIImageView alloc]initWithFrame:CGRectMake((kVideoVolumeIndicatorViewSide - 50) / 2, kViewSpacing, 50, 50)];
    
    [self.volumImageView setImage:[UIImage imageNamed:@"zx-video-player-volume"]];
    
    [self addSubview:self.volumImageView];
    
    //创建音量条view
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake((kVideoVolumeIndicatorViewSide - 105) / 2, 50 + 2 * kViewSpacing, 105, 2.75 + 2)];
    
    backgroundView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.22f alpha:0.65];
    
    [self addSubview:backgroundView];
    
    self.volumArray = [NSMutableArray arrayWithCapacity:16];
    
    CGFloat margin = 1;
    CGFloat blockW = 5.5;
    CGFloat blockH = 2.75;
    
    for (int i = 0; i < 16; i ++) {
        
        CGFloat x = i * (margin + blockW) + margin;
        
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(x, margin, blockW, blockH)];
        
        imgView.backgroundColor = [UIColor whiteColor];
        
        [backgroundView addSubview:imgView];
        
        [self.volumArray addObject:imgView];
        
    }
    
}
///监听系统声音
- (void)volumNotification{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(volumChange:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
}

- (void)volumChange:(NSNotification *)notification{
    
    float outputVolume = [[[notification userInfo]objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]floatValue];
    
    [self updateVolume:outputVolume];
    
}
///更新音量
- (void)updateVolume:(CGFloat)value{
    
    self.hidden = NO;
    
    //防止重叠
    if (self.superview.accessibilityIdentifier) {
        
        ZSPlayerVideoContolView *playView = (ZSPlayerVideoContolView *)self.superview;
        
        playView.timeIndicationView.hidden = YES;
        
        playView.brightView.hidden = YES;
    }else{
        
        self.superview.accessibilityIdentifier = @"";
    }
    
    
    NSInteger level = value * 16;
    
    for (NSInteger i = 0; i < self.volumArray.count; i ++) {
        
        UIImageView *imgView = self.volumArray[i];
        
        if (i < level) {
            
            imgView.hidden = NO;
            
        }else{
          
            imgView.hidden = YES;
            
        }
        
    }
    
    if (value == 0) {
        //当value == 0时不能再往下降了
        if (!self.volumImageView.accessibilityIdentifier ) {
            
            self.volumImageView.accessibilityIdentifier = @"";
            
            self.volumImageView.image = [UIImage imageNamed:@"zx-video-player-volumeMute"];
        }
        
    }else{
       
        if (self.volumImageView.accessibilityIdentifier) {
            
            self.volumImageView.accessibilityIdentifier = nil;
            
            self.volumImageView.image = [UIImage imageNamed:@"zx-video-player-volume"];
        }
    }
    
    
    //为什么设置延迟执行,因为不设置的话当滑动的时候会快速显示图标然后隐藏,不符合用户使用习惯
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animationHide) object:nil];
    
    [self performSelector:@selector(animationHide) withObject:nil afterDelay:kVolumeIndicatorAutoFadeOutTimeInterval];
    
}

- (void)animationHide{
    
    [UIView animateWithDuration:2 animations:^{
        
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
       
        self.hidden = YES;
        
        self.alpha = 1.0;
        
        self.superview.accessibilityIdentifier = nil;
        
    }];
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end










