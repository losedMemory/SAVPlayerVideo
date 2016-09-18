//
//  ZSPlayerVideoTimeIndicatorView.m
//  ZSAVPlayerVideo
//
//  Created by 周松 on 16/9/12.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSPlayerVideoTimeIndicatorView.h"
#import "ZSPlayerVideoContolView.h"
#import "ZSPlayerVideoBrightnessView.h"
#import "ZSPlayerVideoVolumeView.h"
static const CGFloat kViewSpacing = 15.0;

static const CGFloat kTimeIndicatorAutoFadeOutTimeInterval = 1.0;

@interface ZSPlayerVideoTimeIndicatorView ()
//箭头图标
@property (nonatomic,strong) UIImageView *arrowImageView;
//时间
@property (nonatomic,strong) UILabel *timeLabel;

@end

@implementation ZSPlayerVideoTimeIndicatorView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame: frame];
    
    if (self) {
        
        self.hidden = YES;
        
        self.layer.cornerRadius = 5;
        
        self.layer.masksToBounds = YES;
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
        [self creatTimeIndicaton];
        
    }
    
    return self;
}
///在这个方法中改变图标,因为每次设置frame都会调用这个方法
- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    if (self.playeState == ZSPlayerVideoTimeStateRewind) {
        
        [self.arrowImageView setImage:[UIImage imageNamed:@"zx-video-player-rewind"]];
    
    }else{
        
        [self.arrowImageView setImage:[UIImage imageNamed:@"zx-video-player-fastForward"]];
    }
    
}

///时间指示器
- (void)creatTimeIndicaton{
    
    CGFloat margin = (kVideoTimeIndicatorViewSide - 24 - 12 - kViewSpacing) / 2;
    
    //快进退的图标
    self.arrowImageView = [[UIImageView alloc]initWithFrame:CGRectMake((kVideoTimeIndicatorViewSide - 44) / 2, margin, 44, 24)];
    
    [self addSubview:self.arrowImageView];
    
    //时间label
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,margin + 24 + kViewSpacing , kVideoTimeIndicatorViewSide, 12)];
    
    self.timeLabel.textColor = [UIColor whiteColor];
    //设置背景颜色为clear,显示父控件的颜色
    self.timeLabel.backgroundColor = [UIColor clearColor];
    
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    
    [self addSubview:self.timeLabel];
    
}

- (void)setLabelText:(NSString *)labelText{
    
    self.hidden = NO;
    
    self.timeLabel.text = labelText;
    
    //防止重叠显示
    if (self.superview.accessibilityIdentifier) {
        
        ZSPlayerVideoContolView *playVideoView = (ZSPlayerVideoContolView *)self.superview;
        
        playVideoView.brightView.hidden = YES;
        
        playVideoView.volumeView.hidden = YES;
        
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animationHide) object:nil];
    
    [self performSelector:@selector(animationHide) withObject:nil afterDelay:kTimeIndicatorAutoFadeOutTimeInterval];
}
///隐藏视图
- (void)animationHide{
    
    [UIView animateWithDuration:3 animations:^{
        
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
       
        self.hidden = YES;
        
        self.alpha = 1.0;
        
        self.superview.accessibilityIdentifier = nil;
        
    }];
}


@end













