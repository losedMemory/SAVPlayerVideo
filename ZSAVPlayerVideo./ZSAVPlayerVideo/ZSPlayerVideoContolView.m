//
//  ZSPlayerVideoContolView.m
//  ZSAVPlayerVideo
//
//  Created by 周松 on 16/9/12.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSPlayerVideoContolView.h"
#import "ZSPlayerVideoBrightnessView.h"
#import "ZSPlayerVideoTimeIndicatorView.h"
#import "ZSPlayerVideoVolumeView.h"

static const CGFloat kVideoControlBarHeight = 20.0 + 30.0;//开始播放按钮WH
static const CGFloat kVideoControlAnimationTimeInterval = 0.3;
static const CGFloat kVideoControlTimeLabelFontSize = 10.0;//时间的WH
static const CGFloat kVideoControlBarAutoFadeOutTimeInterval = 5.0;
@interface ZSPlayerVideoContolView ()

@end
@implementation ZSPlayerVideoContolView

- (instancetype) initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
       
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.topBar];
        
        [self addSubview:self.bottomBar];
        
        [self.bottomBar addSubview:self.playButton];
        
        [self.bottomBar addSubview:self.pasueButton];
        
        self.pasueButton.hidden = YES;
        
        [self.bottomBar addSubview:self.fullScreenButton];
        
        self.verticalScreenButton.hidden = YES;
        
        [self.bottomBar addSubview:self.verticalScreenButton];
        
        [self.bottomBar addSubview:self.timeLabel];
        
        [self.bottomBar addSubview:self.progressSlider];
        
        [self addSubview:self.indicatorView];//小菊花
        
        [self.topBar addSubview:self.backButton];
        
        // 缓冲进度条 这是将进度条插入bottomBar中并且是在progressSlider中,也就是progressSlider是在topBar中的
        
        [self.bottomBar insertSubview:self.bufferProgressView belowSubview:self.progressSlider];
        
        [self addSubview:self.timeIndicationView];
        
        [self addSubview:self.brightView];
        
        [self addSubview:self.volumeView];
        
        [self.topBar addSubview:self.titleLabel];
        
        //添加tap手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
        
        [self addGestureRecognizer:tap];
        
    }
    
    return self;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    self.topBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), kVideoControlBarHeight);
    
    self.bottomBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds) - kVideoControlBarHeight, CGRectGetWidth(self.bounds), kVideoControlBarHeight);
    
    self.playButton.frame = CGRectMake(CGRectGetMinX(self.bottomBar.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.playButton.bounds)/2, CGRectGetWidth(self.playButton.bounds), CGRectGetHeight(self.playButton.bounds));
    
    self.pasueButton.frame = self.playButton.frame;
    
    self.fullScreenButton.frame = CGRectMake(CGRectGetWidth(self.bottomBar.bounds) - CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.fullScreenButton.bounds)/2, CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.fullScreenButton.bounds));
    
    self.verticalScreenButton.frame = self.fullScreenButton.frame;
    
    self.progressSlider.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), 0, CGRectGetMinX(self.fullScreenButton.frame) - CGRectGetMaxX(self.playButton.frame), kVideoControlBarHeight);
    
    self.timeLabel.frame = CGRectMake(CGRectGetMidX(self.progressSlider.frame), CGRectGetHeight(self.bottomBar.bounds) - CGRectGetHeight(self.timeLabel.bounds) - 2.0, CGRectGetWidth(self.progressSlider.bounds) / 2, CGRectGetHeight(self.timeLabel.bounds));
    
    //加载的菊花
    self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    //返回按钮
    self.backButton.frame = CGRectMake(CGRectGetMinX(self.topBar.bounds), CGRectGetHeight(self.topBar.bounds) - 40, 40, 40);
    
    //缓冲进度条
    self.bufferProgressView.bounds = CGRectMake(0, 0, CGRectGetWidth(self.progressSlider.bounds) - 7, CGRectGetHeight(self.progressSlider.bounds));
    self.bufferProgressView.center = CGPointMake(self.progressSlider.center.x + 2, self.progressSlider.center.y);
    
    //快进退指示器
    self.timeIndicationView.center = self.indicatorView.center;
    
    //音量指示器
    self.volumeView.center = self.indicatorView.center;
    
    //亮度指示器
    self.brightView.center = self.indicatorView.center;
    
    //标题
    self.titleLabel.frame = CGRectMake(CGRectGetWidth(self.backButton.bounds), 20, CGRectGetWidth(self.topBar.bounds) - CGRectGetWidth(self.backButton.bounds), kVideoControlBarHeight - 20);
    
}

//视图移动完成后调用
- (void)didMoveToSuperview{
    
    [super didMoveToSuperview];
    
    self.isBarShowing = YES;
}

///tap手势的调用的方法
- (void)onTap:(UIGestureRecognizer *)gesture{
    //识别到手势
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        
        //如果显示bar,就隐藏
        if (self.isBarShowing) {
            
            [self animationHide];
            
        }else{
            
            [self animationShow];
            
            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        
        }
    }
    
}

//显示控制条
- (void)animationShow{
    
    if (self.isBarShowing) {
        
        return;
    }
    
    [UIView animateWithDuration:kVideoControlAnimationTimeInterval animations:^{
        
        self.topBar.alpha = 1.0;
        
        self.bottomBar.alpha = 1.0;
        
    } completion:^(BOOL finished) {
       
        self.isBarShowing = YES;
        
        [self autoDisappearControlBar];
    }];
    
}

//隐藏
- (void)animationHide{
    
    if (!self.isBarShowing) {
        
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kZSPlayerControlViewHideNotification object:nil];
    
    [UIView animateWithDuration:kVideoControlAnimationTimeInterval animations:^{
       
        self.topBar.alpha = 0;
        
        self.bottomBar.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.isBarShowing = NO;
    }];
    
    //隐藏控制条还要隐藏状态栏,但是在全屏和竖屏的情况下是不一样的,全屏是隐藏状态栏,但是竖屏是不隐藏状态栏,这里用通知控制器解决
    
    
    
}

//控制条自动消失
- (void)autoDisappearControlBar{
    
    //只有在显示bar时才自动消失
    if (!self.isBarShowing) {
        
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animationHide) object:nil];
    
    [self performSelector:@selector(animationHide) withObject:nil afterDelay:kVideoControlBarAutoFadeOutTimeInterval];
}

//取消控制条消失
- (void)cancelAutoDisappearControlBar{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animationHide) object:nil];
    
}

#pragma mark --控件的懒加载

-(UIView *)topBar{
    if (_topBar == nil) {
        
        _topBar = [[UIView alloc] init];
        
        _topBar.accessibilityIdentifier = @"TopBar";
        
        _topBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    
    return _topBar;
}

-(UIView *)bottomBar{
    
    if (_bottomBar == nil) {
        
        _bottomBar = [[UIView alloc]init];
        
        _bottomBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
    }
    
    return _bottomBar;
}

-(UIButton *)playButton{
    
    if (_playButton == nil) {
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
                       
        [_playButton setImage:[UIImage imageNamed:@"kr-video-player-play"] forState:UIControlStateNormal];
        
        _playButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    
    return _playButton;
}

-(UIButton *)pasueButton{
    
    if (_pasueButton == nil) {
        
        _pasueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_pasueButton setImage:[UIImage imageNamed:@"kr-video-player-pause"] forState:UIControlStateNormal];
        
        _pasueButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    
    return _pasueButton;
}

-(UIButton *)fullScreenButton{
    
    if (_fullScreenButton == nil) {
        
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_fullScreenButton setImage:[UIImage imageNamed:@"kr-video-player-fullscreen"] forState:UIControlStateNormal];
        
        _fullScreenButton.bounds = CGRectMake(0,0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    
    return _fullScreenButton;
}

-(UIButton *)verticalScreenButton{
    
    if (_verticalScreenButton == nil) {
    
        _verticalScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_verticalScreenButton setImage:[UIImage imageNamed:@"kr-video-player-shrinkscreen"] forState:UIControlStateNormal];
        
        _verticalScreenButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    
    return _verticalScreenButton;
}

-(UISlider *)progressSlider{
    
    if (_progressSlider == nil) {
        
        _progressSlider = [[UISlider alloc]init];
        
        [_progressSlider setThumbImage:[UIImage imageNamed:@"kr-video-player-point"] forState:UIControlStateNormal];
        
        [_progressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
        
        [_progressSlider setMaximumTrackTintColor:[UIColor lightGrayColor]];
        
        _progressSlider.value = 0.f;
        
        //设置滑块是否连续变化
        _progressSlider.continuous = YES;
    }
    
    return _progressSlider;
}

-(UILabel *)timeLabel{
    
    if (_timeLabel == nil) {
        
        _timeLabel = [[UILabel alloc] init];
        
        _timeLabel.backgroundColor = [UIColor clearColor];
        
        _timeLabel.textColor = [UIColor whiteColor];
        
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        
        _timeLabel.font = [UIFont systemFontOfSize:10];
        
        _timeLabel.bounds = CGRectMake(0, 0, kVideoControlTimeLabelFontSize, kVideoControlTimeLabelFontSize);
    }
    
    return  _timeLabel;
}

- (UIActivityIndicatorView *)indicatorView{
    
    if (_indicatorView == nil) {
        
        _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        //停止动画
        [_indicatorView stopAnimating];
    }
    
    return _indicatorView;
}

- (UIButton *)backButton{
    
    if (_backButton == nil) {
        
        _backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight)];
        
        [_backButton setImage:[UIImage imageNamed:@"zx-video-banner-back"] forState:UIControlStateNormal];
        
        //设置内部控件的
        _backButton.contentEdgeInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
        _backButton.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    }
    
    return _backButton;
}

- (UIProgressView *)bufferProgressView{
    
    if (_bufferProgressView == nil) {
        
        _bufferProgressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        
        //填充部分的颜色(也就是缓冲部分的颜色)
        _bufferProgressView.progressTintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        
        //未填充部分的颜色
        _bufferProgressView.trackTintColor = [UIColor clearColor];
    }
    
    return _bufferProgressView;
}

- (ZSPlayerVideoBrightnessView *)brightView{
    
    if (_brightView == nil) {
        
        _brightView = [[ZSPlayerVideoBrightnessView alloc]initWithFrame:CGRectMake(100, 50,kPlayerVideoBrightnessViewWH , kPlayerVideoBrightnessViewWH)];
    }
    
    return _brightView;
}

- (ZSPlayerVideoTimeIndicatorView *)timeIndicationView{
    
    if (_timeIndicationView == nil) {
        
        _timeIndicationView = [[ZSPlayerVideoTimeIndicatorView alloc]initWithFrame:CGRectMake(0, 0, kVideoTimeIndicatorViewSide, kVideoTimeIndicatorViewSide)];
    }
    
    return _timeIndicationView;
}

- (ZSPlayerVideoVolumeView *)volumeView{
    
    if (_volumeView == nil) {
        
        _volumeView = [[ZSPlayerVideoVolumeView alloc]initWithFrame:CGRectMake(0, 0,kPlayerVideoBrightnessViewWH, kPlayerVideoBrightnessViewWH)];
    }
    
    return _volumeView;
}

- (UILabel *)titleLabel{
    
    if (_titleLabel == nil) {
        
        _titleLabel = [[UILabel alloc]init];
        
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        _titleLabel.textColor = [UIColor whiteColor];
        
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLabel;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end




















