//
//  EZShotButton.m
//  3DCamera
//
//  Created by xietian on 14-10-8.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZShotButton.h"

@implementation EZShotButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (EZShotButton*) createButton:(CGRect)rect
{
    EZShotButton* button = [[EZShotButton alloc] initWithFrame:rect];
    button.showsTouchWhenHighlighted = YES;
    button.backgroundColor = RGBACOLOR(255, 119, 86, 180);
    
    UIView* vertical = [[UIView alloc] initWithFrame:CGRectMake(0, 0, button.width - 20, 2)];
    vertical.backgroundColor = [UIColor whiteColor];
    
    UIView* horizon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, button.height - 20)];
    horizon.backgroundColor = [UIColor whiteColor];
    vertical.center = CGPointMake(button.width/2.0, button.height/2.0);
    horizon.center = CGPointMake(button.width/2.0, button.height/2.0);
    
    [button addSubview:horizon];
    [button addSubview:vertical];
    [button enableRoundEdge];
    return button;
}


+ (EZShotButton*) createCellShot:(CGRect)rect
{
    EZShotButton* button = [[EZShotButton alloc] initWithFrame:rect];
    button.showsTouchWhenHighlighted = YES;
    //button.backgroundColor = RGBACOLOR(255, 119, 86, 180);
    button.backgroundColor = [UIColor clearColor];
    
    UIView* vertical = [[UIView alloc] initWithFrame:CGRectMake(0, 0, button.width * 0.6, 2)];
    vertical.backgroundColor = [UIColor grayColor];
    
    UIView* horizon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, button.height * 0.6)];
    horizon.backgroundColor = [UIColor grayColor];
    vertical.center = CGPointMake(button.width/2.0, button.height/2.0);
    horizon.center = CGPointMake(button.width/2.0, button.height/2.0);
    
    [button addSubview:horizon];
    [button addSubview:vertical];
    return button;
}

@end
