//
//  ZSPlayerVideoContolView.h
//  ZSAVPlayerVideo
//
//  Created by 周松 on 16/9/12.
//  Copyright © 2016年 周松. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZSPlayerVideoBrightnessView;
@class ZSPlayerVideoTimeIndicatorView;
@class ZSPlayerVideoVolumeView;

#define kZSPlayerControlViewHideNotification @"kZSPlayerControlViewHideNotification"

@interface ZSPlayerVideoContolView : UIView

@property (nonatomic,strong) UIView *topBar;//上

@property (nonatomic,strong) UIView *bottomBar;//下

@property (nonatomic,strong) UIButton *playButton;//开始

@property (nonatomic,strong) UIButton *pasueButton;//暂停

@property (nonatomic,strong) UIButton *fullScreenButton;//全屏

@property (nonatomic,strong) UIButton *verticalScreenButton;//竖屏

@property (nonatomic,strong) UISlider *progressSlider;//进度条

@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;//加载的菊花

@property (nonatomic,strong) UILabel *timeLabel;//时间

@property (nonatomic,assign) BOOL isBarShowing;//是否显示控制条

@property (nonatomic,strong) UIButton *backButton;//返回按钮

@property (nonatomic,strong) UIProgressView *bufferProgressView;//缓冲条

@property (nonatomic,strong) ZSPlayerVideoBrightnessView *brightView;//亮度视图

@property (nonatomic,strong) ZSPlayerVideoTimeIndicatorView *timeIndicationView;//时间指示器

@property (nonatomic,strong) ZSPlayerVideoVolumeView *volumeView;//音量视图

@property (nonatomic,strong) UILabel *titleLabel;//标题

- (void)animationHide;

- (void)animationShow;

- (void)autoDisappearControlBar;//控制条自动消失

-(void)cancelAutoDisappearControlBar;//控制条取消自动消失

@end













