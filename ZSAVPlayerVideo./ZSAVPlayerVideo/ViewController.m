//
//  ViewController.m
//  ZSAVPlayerVideo
//
//  Created by 周松 on 16/9/11.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ViewController.h"
#import "ZSVideo.h"
#import "ZSPlayerMainViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
}
//播放本地视频
- (IBAction)playLocalVideo:(id)sender {
    
    NSURL *videoURL = [[NSBundle mainBundle]URLForResource:@"150511_JiveBike" withExtension:@"mov"];
    
    ZSVideo *video = [[ZSVideo alloc]init];
    
    video.playUrl = videoURL.absoluteString;
    
    video.title = @"Test";
    
    ZSPlayerMainViewController *mainVC = [[ZSPlayerMainViewController alloc]init];
    
    mainVC.video = video;
    
    mainVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:mainVC animated:YES];
    
    
}

//播放网络视频
- (IBAction)playRemoteVideo:(id)sender {
    NSLog(@"点击");
    ZSVideo *video = [[ZSVideo alloc]init];
    
    video.playUrl = @"http://baobab.wdjcdn.com/1451897812703c.mp4";
    
    video.title = @"圆";
    
    ZSPlayerMainViewController *mainVC = [[ZSPlayerMainViewController alloc]init];
    
    mainVC.video = video;
        
    [self.navigationController pushViewController:mainVC animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
