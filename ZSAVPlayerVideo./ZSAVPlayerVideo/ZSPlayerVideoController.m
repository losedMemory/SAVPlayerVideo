//
//  ZSPlayerVideoController.m
//  ZSAVPlayerVideo
//
//  Created by 周松 on 16/9/15.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSPlayerVideoController.h"
#import "ZSPlayerVideoContolView.h"
#import "ZSPlayerVideoTimeIndicatorView.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger,ZSPanDirection) {
    
    ZSPanDirectionHorizontal,//横向移动
    ZSPanDirectionVertical//纵向移动
    
};

/// 播放器显示和消失的动画时长
static const CGFloat kVideoPlayerControllerAnimationTimeInterval = 0.3f;

@interface ZSPlayerVideoController()<UIGestureRecognizerDelegate>

///播放器视图
@property (nonatomic,strong) ZSPlayerVideoContolView *playerVideoView;

///是否已经全屏
@property (nonatomic,assign) BOOL isFullScreenMode;

///设备方向
@property (nonatomic,assign,getter=getDeviceOrientation)UIDeviceOrientation deviceOrientation;

@property (nonatomic,strong) NSTimer *durationTimer;

///手势pan的移动方向
@property (nonatomic,assign) ZSPanDirection panDirection;

///快进退的总时长
@property (nonatomic,assign) CGFloat sumTime;

///是否在调节音量
@property (nonatomic,assign) BOOL isVolumeAdjust;

///系统音量slider
@property (nonatomic,strong) UISlider *volumSlider;

@end
@implementation ZSPlayerVideoController

- (void)showInView:(UIView *)view{
    
    if ([UIApplication sharedApplication].statusBarStyle != UIStatusBarStyleLightContent) {
        
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    [view addSubview:self.view];//供外部调用
    
    self.view.alpha = 0.0;
    
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeInterval animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
       
        
    }];
    //判断设备的方向 让其自动旋转
    if (self.getDeviceOrientation == UIDeviceOrientationLandscapeLeft || self.getDeviceOrientation == UIDeviceOrientationLandscapeRight) {
        
        [self changeDeviceOrientation:self.getDeviceOrientation];
    }else{
        
        [self changeDeviceOrientation:UIDeviceOrientationPortrait];
    }
}


- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super init];
    
    if (self) {
       
        self.view.frame = frame;
        
        self.view.backgroundColor = [UIColor blackColor];
        
        //没有控制器
        self.controlStyle = MPMovieControlStyleNone;
        
        [self.view addSubview:self.playerVideoView];
        
        self.playerVideoView.frame = self.view.bounds;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
        
        pan.delegate = self;
        
        [self.playerVideoView addGestureRecognizer:pan];
        
        //监听播放器状态通知
        [self configObserver];
        
        //监听点击事件
        [self configControlAction];
        
        //监听设备旋转
        [self configDeviceOrientationObserver];
        
        //获取系统音量控件
        [self configVolume];
        
    }
    
    return self;
}
//代理方法
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isKindOfClass:[UISlider class]] || [touch.view isKindOfClass:[UIButton class]] || [touch.view.accessibilityIdentifier isEqualToString:@"TopBar"]) {
        return NO;
    }else{
        
        return YES;
    }
}

///监听播放器状态通知
- (void)configObserver{
    
    /// 播放状态改变, 可配合playbakcState属性获取具体状态
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    //媒体网络加载状态的改变
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    //视频显示状态的改变
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    
    //确定媒体播放时长
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onMPMovieDurationAvailableNotification) name:MPMovieDurationAvailableNotification object:nil];
    
    //控制器视图隐藏
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onPayerControlViewHideNotification) name:kZSPlayerControlViewHideNotification object:nil];
}

/// 播放状态改变, 可配合playbakcState属性获取具体状态
- (void)onMPMoviePlayerPlaybackStateDidChangeNotification{
    
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        
        self.playerVideoView.pasueButton.hidden = NO;
        
        self.playerVideoView.playButton.hidden = YES;
        
        [self startDurationTimer];//开启定时器
        
        //停止加载动画
        [self.playerVideoView.indicatorView stopAnimating];
        
        [self.playerVideoView autoDisappearControlBar];

        
    }else{
        
        self.playerVideoView.playButton.hidden = YES;
        
        self.playerVideoView.pasueButton.hidden = NO;
        
        [self stopTimer];
        
        //当播放停止时
        if (self.playbackState == MPMoviePlaybackStateStopped) {
            
            //显示控制条
            [self.playerVideoView animationShow];
        }
        
    }
}

///媒体网络加载状态的改变
- (void)onMPMoviePlayerLoadStateDidChangeNotification{
    
    if (self.loadState & MPMovieLoadStateStalled) {
        
        [self.playerVideoView.indicatorView startAnimating];
    }
}

///视频显示状态的改变
- (void)onMPMoviePlayerReadyForDisplayDidChangeNotification{
    
}

///确定媒体播放时长后
- (void)onMPMovieDurationAvailableNotification{
    
    //开启定时器
    [self startDurationTimer];
    
    //根据视频文件设置slider的最值
    [self setSliderMaxMidValue];
    
    self.playerVideoView.fullScreenButton.hidden = NO;
    
    self.playerVideoView.verticalScreenButton.hidden = YES;
    
}

///控制器视图隐藏状态栏隐藏
- (void)onPayerControlViewHideNotification{
    //隐藏状态栏
    if (self.isFullScreenMode) {
        
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }else{
        
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
}

//开启定时器
- (void)startDurationTimer{
    
    if (self.durationTimer) {
        
        //定时器继续执行操作
        [self.durationTimer setFireDate:[NSDate date]];
        
    }else{
        
        self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop]addTimer:self.durationTimer forMode:NSRunLoopCommonModes];
    }
}

///定时器监听的播放进度
- (void)monitorVideoPlayback{
                                //当前播放装置播放视频的时间 秒
    double currentTime = floor(self.currentPlaybackTime);
                                //持续时间,小于或等于括号内的最大整数
    double totalTime = floor(self.duration);
    
    //更新时间
    [self setTimerLabelValues:currentTime totalTime:totalTime];
    
    //更新播放进度
    self.playerVideoView.progressSlider.value = ceil(currentTime);
    
    //更新缓冲进度
    self.playerVideoView.bufferProgressView.progress = self.playableDuration / self.duration;
    
}
///更新时间
- (void)setTimerLabelValues:(double)currentTime totalTime:(double)totalTime{
    
    double minutesElapsed = floor(currentTime / 60.0);
                            //取模
    double secondElapsed = fmod(currentTime, 60.0);
    
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f",minutesElapsed,secondElapsed];
    
    double minutedRemaining = floor(totalTime / 60.0);
    
    double secondRemaining = fmod(totalTime, 60.0);
    
    NSString *timeRemainingString = [NSString stringWithFormat:@"%02.0f:%02.0f",minutedRemaining,secondRemaining];
    
    self.playerVideoView.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRemainingString];
    
}

///停止定时器
- (void)stopTimer{
    
    if (_durationTimer) {
        //NSTimer 关闭
        [self.durationTimer setFireDate:[NSDate distantFuture]];
    }
    
}

///根据视频文件设置slider的最值
- (void)setSliderMaxMidValue{
    
    CGFloat durtion = self.duration;
    
    self.playerVideoView.progressSlider.minimumValue = 0.f;
    
    self.playerVideoView.progressSlider.maximumValue = floor(durtion);
    
}

///监听点击事件
- (void)configControlAction{
    
    [self.playerVideoView.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.playerVideoView.pasueButton addTarget:self action:@selector(pasueButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.playerVideoView.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.playerVideoView.verticalScreenButton addTarget:self action:@selector(verticalScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.playerVideoView.backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.playerVideoView.progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.playerVideoView.progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    
    [self.playerVideoView.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.playerVideoView.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];//控件之外触摸抬起事件
    
    [self.playerVideoView.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchCancel];//触摸事件取消
    
    [self setSliderMaxMidValue];
    
    //监听播放进度
    [self monitorVideoPlayback];
    
}

///开始按钮点击事件
- (void)playButtonClick{
    
    [self play];
    
    self.playerVideoView.playButton.hidden = YES;
    
    self.playerVideoView.pasueButton.hidden = NO;
    
}

///暂停按钮的点击事件
- (void)pasueButtonClick{
    
    [self pause];
    
    self.playerVideoView.playButton.hidden = NO;
    
    self.playerVideoView.pasueButton.hidden = YES;
}

///全屏按钮点击事件
- (void)fullScreenButtonClick{
    
    if (self.isFullScreenMode) {
        
        return;
    }
    
    //手动切换设备方向  Home键在右边
    [self changeDeviceOrientation:UIDeviceOrientationLandscapeLeft];
    
}

///返回竖屏按钮点击事件
- (void)verticalScreenButtonClick{
    
    if (!self.isFullScreenMode) {
        
        return;
    }
    
       //Home键在底部
    [self changeDeviceOrientation:UIDeviceOrientationPortrait];
    
}

//返回按钮的点击事件
- (void)backButtonClick{
    
    if (self.isFullScreenMode) {
        
        [self changeDeviceOrientation:UIDeviceOrientationPortrait];
        
    }else{//如果是竖屏模式,就返回
        
        if (self) {
            
            [self.durationTimer invalidate];
            
            [self stop];
            
            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            
            if (self.videoPlayerGoBackBlock) {
                
                [self.playerVideoView cancelAutoDisappearControlBar];
                
                self.videoPlayerGoBackBlock();
            }
        }
    }
}

///滑竿的值改变
- (void)progressSliderValueChanged:(UISlider *)slider{
    
    double currentTime = floor(slider.value);
    
    double totalTime = floor(self.duration);
    
    [self setTimerLabelValues:currentTime totalTime:totalTime];
    
}

///slider按下事件
- (void)progressSliderTouchBegan:(UISlider *)slider{
    
    [self pause];
    
    [self stopTimer];
}

///slider松开事件
- (void)progressSliderTouchEnded:(UISlider *)slider{
    
    [self setCurrentPlaybackTime:floor(slider.value)];
    
    [self play];
    
    [self startDurationTimer];
    
    [self.playerVideoView autoDisappearControlBar];
    
}

///监听设备旋转通知
- (void)configDeviceOrientationObserver{
    
    //更新设备信息,必须调用,在监听设备方向
    [[UIDevice currentDevice]beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onDeviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

///设备旋转方向改变
- (void)onDeviceOrientationDidChange{
    
    UIDeviceOrientation orientation = self.getDeviceOrientation;
    
    switch (orientation) {
            //此时Home键是在下面,切换到竖屏模式
        case UIDeviceOrientationPortrait:
            
            [self changeVerticalScreenMode];
            
            break;
           //此时Home键是在右边,切换到全屏模式
        case UIDeviceOrientationLandscapeLeft:
            
            [self changeFullScreenMode];
            
            break;
          //此时Home键在左边,切换到竖屏模式
        case UIDeviceOrientationLandscapeRight:
            
            [self changeFullScreenMode];
            
            break;
            
        default:
            break;
    }
    
}


///自动切换到全屏模式
- (void)changeFullScreenMode{
    
    if (self.isFullScreenMode) {
        
        return;
    }
    
    if (self.playerVideoView.isBarShowing) {
        
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }else{
        
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    
    self.frame = [UIScreen mainScreen].bounds;
    
    self.isFullScreenMode = YES;
    
    self.playerVideoView.fullScreenButton.hidden = YES;
    
    self.playerVideoView.verticalScreenButton.hidden = NO;
    
}

///自动切换到竖屏模式
- (void)changeVerticalScreenMode{
    //如果是竖屏状态
    if (!self.isFullScreenMode) {
        
        return;
    }
    //如果状态栏隐藏
    if ([UIApplication sharedApplication].statusBarHidden) {
        
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
    self.frame = CGRectMake(0, 0, kZSVideoPlayerOriginalWidth, kZSVideoPlayerOriginalHeight);
    
    self.isFullScreenMode = NO;
    
    self.playerVideoView.fullScreenButton.hidden = NO;
    
    self.playerVideoView.verticalScreenButton.hidden = YES;
    
}

///获取系统音量控件
- (void)configVolume{
    
    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
    
    volumeView.center = CGPointMake(-1000, 0);
    
    [self.view addSubview:volumeView];
    
    _volumSlider = nil;
    
    for (UIView *view in volumeView.subviews) {
        
        //在MPVolumeViews中找一个slider的类
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
            
            self.volumSlider  = (UISlider *)view;
            
            break;
        }
    }
    
    NSError *error = nil;
    
    //使用这个category应用不会随着手机静音而静音,可以在手机静音状态下播放声音
    BOOL success = [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:&error];

    if (!success) {
        
        
    }
    
    //监听耳机的插入和拔出
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
}

///监听耳机的插入和拔出
- (void)audioRouteChangeListenerCallback:(NSNotification *)notification{
    
    NSInteger routeChangeReason = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey]integerValue];
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            
            NSLog(@"耳机插入");
            
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"耳机拔出");
           [self play];
            
            break;
            
        default:
            break;
    }
}

//手动切换设备方向
- (void)changeDeviceOrientation:(UIDeviceOrientation)orientation{
   //强制屏幕旋转,这是私有API,上架会被拒绝
    if ([[UIDevice currentDevice]respondsToSelector:@selector(setOrientation:)]) {
        
        //动态加载方法,performSelector:withObject可以调用消息,但是局限性是参数不能超过两个,所以使用NSInvocation,但是在iOS4之后,block出现,就一直block了
        SEL selector = NSSelectorFromString(@"setOrientation:");
        //消息传递和方法调用的一个类
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];//函数签名
        //设置selecter
        [invocation setSelector:selector];
        //设置target
        [invocation setTarget:[UIDevice currentDevice]];
        
        int val = orientation;
        //设置多个参数,Index要从2开始,因为前面两个参数被target和selecter占用
        [invocation setArgument:&val atIndex:2];
        //消息调用
        [invocation invoke];

    }
    
}

///pan手势的触发
- (void)panDirection:(UIPanGestureRecognizer *)pan{
    
    //手指点击屏幕时获取的坐标
    CGPoint locationPoint = [pan locationInView:self.playerVideoView];
    
    //在指定坐标系统中拖动的速度,xy轴方向的速度
    CGPoint veloctyPoint = [pan velocityInView:self.playerVideoView];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            
            CGFloat x = fabs(veloctyPoint.x);//绝对值,因为速度是矢量,有正负
            
            CGFloat y = fabs(veloctyPoint.y);
            
            if (x > y) {//水平移动  调节进度
                
                self.panDirection = ZSPanDirectionHorizontal;
                
                self.sumTime = self.currentPlaybackTime;
                
                //当滑动时暂停播放
                [self pause];
                
                //定时器停止
                [self stopTimer];
                
            }else if (x < y){//垂直滑动 调节音量 亮度
                
                self.panDirection = ZSPanDirectionVertical;
                
                if (locationPoint.x > self.view.bounds.size.width / 2) {
                    
                    self.isVolumeAdjust = YES;
                }else{
                    
                    self.isVolumeAdjust = NO;
                }
                
            }
        }
            
            break;
        
        case UIGestureRecognizerStateChanged://正在移动
            
            switch (self.panDirection) {
                    //横向移动
                case ZSPanDirectionHorizontal:
                    
                    [self horizontalMoved:veloctyPoint.x];
                    
                    break;
                    
                case ZSPanDirectionVertical:{
                    
                    [self verticalMoved:veloctyPoint.y];
                }
                    break;
                default:
                    break;
            }
            
            break;
        case UIGestureRecognizerStateEnded://停止移动
            
            switch (self.panDirection) {
                case ZSPanDirectionHorizontal:{
                    
                    [self setCurrentPlaybackTime:floor(self.sumTime)];
                    
                    [self play];
                    
                    [self startDurationTimer];
                    
                    [self.playerVideoView autoDisappearControlBar];
                }
                    
                    break;
                case ZSPanDirectionVertical:{
                    
                    break;
                }
                    break;
                    
                default:
                    break;
            }
            
        default:
            break;
    }
    
}

///水平移动
- (void)horizontalMoved:(CGFloat)value{
    
    self.sumTime += value / 210;
    
    //容错处理
    if (self.sumTime > self.duration) {
        
        self.sumTime = self.duration;
    }else if (self.sumTime < 0){
        
        self.sumTime = 0;
    
    }
    //时间更新
    CGFloat currentTime = self.sumTime;
    
    CGFloat totalTime = self.duration;
    
    [self setTimerLabelValues:currentTime totalTime:totalTime];
    
    //提示视图
    self.playerVideoView.timeIndicationView.labelText = self.playerVideoView.timeLabel.text;

    //播放进度更新
    self.playerVideoView.progressSlider.value = self.sumTime;
    
    //快进快退  状态调整
    ZSPlayerVideoTimeState playState = ZSPlayerVideoTimeStateRewind;
    
    if (value < 0) {//左滑
        
        playState = ZSPlayerVideoTimeStateRewind;
        
    }else{
        
        playState = ZSPlayerVideoTimeStateForward;
    }
    
    if (self.playerVideoView.timeIndicationView.playeState != playState) {
        
        if (value < 0) {
            
            self.playerVideoView.timeIndicationView.playeState = ZSPlayerVideoTimeStateRewind;
            //必须进行重新布局,不然只显示默认的图片
            [self.playerVideoView.timeIndicationView setNeedsLayout];
            
        }else{
            
            self.playerVideoView.timeIndicationView.playeState = ZSPlayerVideoTimeStateForward;
            
            [self.playerVideoView.timeIndicationView setNeedsLayout];
        }
    }
    
    
}

///垂直移动
- (void)verticalMoved:(CGFloat)value{
    
    if (self.isVolumeAdjust) {
        
        self.volumSlider.value -= value / 10000;
    }else{
        
        [UIScreen mainScreen].brightness -= value / 10000;
    }
}

#pragma mark - getters and setters

- (void)setContentURL:(NSURL *)contentURL{
    
    [self stop];
    
    [super setContentURL:contentURL];
    
    [self play];
}

- (ZSPlayerVideoContolView *)playerVideoView{
    
    if (_playerVideoView == nil) {
        
        _playerVideoView = [[ZSPlayerVideoContolView alloc]init];
        
    }
    return _playerVideoView;
}

-(void)setFrame:(CGRect)frame{
    
    [self.view setFrame:frame];
    
    [self.playerVideoView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    [self.playerVideoView setNeedsLayout];
    
    [self.playerVideoView layoutIfNeeded];
}

- (UIDeviceOrientation)getDeviceOrientation{
    
    return [UIDevice currentDevice].orientation;
}

- (void)setVideo:(ZSVideo *)video{
    
    _video = video;
    
    self.playerVideoView.titleLabel.text = _video.title;
    
    self.contentURL = [NSURL URLWithString:_video.playUrl];
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end













