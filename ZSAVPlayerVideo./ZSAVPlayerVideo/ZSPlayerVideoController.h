//
//  ZSPlayerVideoController.h
//  ZSAVPlayerVideo
//
//  Created by 周松 on 16/9/15.
//  Copyright © 2016年 周松. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSVideo.h"
@import MediaPlayer;
#define kZSVideoPlayerOriginalWidth  MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
//这里设置的竖屏模式下宽高比
#define kZSVideoPlayerOriginalHeight (kZSVideoPlayerOriginalWidth * (11.0 / 16.0))
@interface ZSPlayerVideoController : MPMoviePlayerController

@property (nonatomic, assign) CGRect frame;
/// video model
@property (nonatomic, strong) ZSVideo *video;
/// 竖屏模式下点击返回
@property (nonatomic, copy) void(^videoPlayerGoBackBlock)(void);
/// 将要切换到竖屏模式
@property (nonatomic, copy) void(^videoPlayerWillChangeToOriginalScreenModeBlock)();
/// 将要切换到全屏模式
@property (nonatomic, copy) void(^videoPlayerWillChangeToFullScreenModeBlock)();

- (instancetype)initWithFrame:(CGRect)frame;
/// 展示播放器
- (void)showInView:(UIView *)view;


@end
