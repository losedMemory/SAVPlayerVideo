//
//  ZSPlayerMainViewController.m
//  ZSAVPlayerVideo
//
//  Created by 周松 on 16/9/18.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSPlayerMainViewController.h"
#import "ZSVideo.h"
#import "ZSPlayerVideoContolView.h"
#import "ZSPlayerVideoController.h"
@interface ZSPlayerMainViewController ()

@property (nonatomic,strong) ZSPlayerVideoController *playerVideoController;

@end

@implementation ZSPlayerMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self playVideo];
    
}

- (void)playVideo{
    
    if (!self.playerVideoController) {
        
        self.playerVideoController = [[ZSPlayerVideoController alloc]initWithFrame:CGRectMake(0, 0, kZSVideoPlayerOriginalWidth, kZSVideoPlayerOriginalHeight)];
        
        __weak typeof(self) weakSelf = self;
        
        self.playerVideoController.videoPlayerGoBackBlock = ^{
            
            __strong typeof(self) strongSelf = weakSelf;
            
            [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
            
            [strongSelf.navigationController popViewControllerAnimated:YES];
            
            [strongSelf.navigationController setNavigationBarHidden:NO animated:YES];
            
            strongSelf.playerVideoController = nil;
            
        };
        
        [self.playerVideoController showInView:self.view];
    }
    
    self.playerVideoController.video = self.video;
    
}

- (void)dealloc{
    

}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
