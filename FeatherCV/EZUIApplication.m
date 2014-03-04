//
//  EZUIApplication.m
//  FeatherCV
//
//  Created by xietian on 14-3-3.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZUIApplication.h"
#import "EZMessageCenter.h"

@implementation EZUIApplication

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
    [self checkForStatusBarChangeBeforeAndAfterBlock:^{
        [super setStatusBarStyle:statusBarStyle];
    }];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated
{
    [self checkForStatusBarChangeBeforeAndAfterBlock:^{
        [super setStatusBarStyle:statusBarStyle animated:animated];
    }];
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden
{
    [self checkForStatusBarChangeBeforeAndAfterBlock:^{
        [super setStatusBarHidden:statusBarHidden];
    }];
}

- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self checkForStatusBarChangeBeforeAndAfterBlock:^{
        [super setStatusBarHidden:hidden animated:animated];
    }];
}

- (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation
{
    [self checkForStatusBarChangeBeforeAndAfterBlock:^{
        [super setStatusBarHidden:hidden withAnimation:animation];
    }];
}

- (void)checkForStatusBarChangeBeforeAndAfterBlock:(dispatch_block_t)block
{
    
    //self.isCheckingStatusBarDisplayChange = YES;
    BOOL wasHidden = self.statusBarHidden;
    block();
    BOOL isHidden = self.statusBarHidden;
    //self.isCheckingStatusBarDisplayChange = NO;
    
    if(wasHidden != isHidden)
    {
        //[self postStatusBarHideStatusNotification];
        [[EZMessageCenter getInstance] postEvent:EZStatusBarChange attached:@(isHidden)];
    }
}



@end
