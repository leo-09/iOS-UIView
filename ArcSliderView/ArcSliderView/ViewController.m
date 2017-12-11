//
//  ViewController.m
//  ArcSliderView
//
//  Created by liyy on 2017/12/11.
//  Copyright © 2017年 ccdc. All rights reserved.
//

#import "ViewController.h"
#import "MemberGradeView.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 显示等级
    MemberGradeView *memberView = [[MemberGradeView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH - 30, 110)];
    [self.view addSubview:memberView];
    
    memberView.grade = 0.45;
}

@end
