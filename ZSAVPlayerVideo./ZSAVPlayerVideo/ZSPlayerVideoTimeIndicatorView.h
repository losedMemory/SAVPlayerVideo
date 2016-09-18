//
//  ZSPlayerVideoTimeIndicatorView.h
//  ZSAVPlayerVideo
//
//  Created by 周松 on 16/9/12.
//  Copyright © 2016年 周松. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,ZSPlayerVideoTimeState) {
    
    ZSPlayerVideoTimeStateRewind,//倒回
    ZSPlayerVideoTimeStateForward,//前进
    
};
//时间指示器的W H
static const CGFloat kVideoTimeIndicatorViewSide = 96.0;

@interface ZSPlayerVideoTimeIndicatorView : UIView

@property (nonatomic,assign,readwrite) ZSPlayerVideoTimeState playeState;//状态

@property (nonatomic,copy,readwrite) NSString *labelText;//将时间赋值

@end
