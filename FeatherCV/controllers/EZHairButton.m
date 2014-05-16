//
//  EZHairButton.m
//  FeatherCV
//
//  Created by xietian on 14-4-4.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZHairButton.h"

@implementation EZHairButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //EZClickImage* clickView =  [[EZClickImage alloc] initWithFrame:CGRectMake(CurrentScreenWidth - 46 - 10, 30, 46, 46)];
        //[[EZCenterButton alloc] initWithFrame:CGRectMake(255, 23, 60,60) cycleRadius:21 lineWidth:2];
        //clickView.backgroundColor = RGBA(255, 255, 255, 120);
        //clickView.layer.borderColor = [UIColor whiteColor].CGColor;
        //clickView.layer.borderWidth = 2.0;
        [self enableRoundImage];
        self.enableTouchEffects = YES;
        
        _horizon = [[UIView alloc] initWithFrame:CGRectMake(30, 30, 31, 1)];
        _horizon.backgroundColor = ClickedColor;// [UIColor whiteColor];
        
        _vertical = [[UIView alloc] initWithFrame:CGRectMake(30, 30, 1, 31)];
        _vertical.backgroundColor = ClickedColor; //[UIColor whiteColor];
        
        _horizon.center = CGPointMake(23, 23);
        _vertical.center = CGPointMake(23, 23);
        //self.pressedColor = EZOrangeColor;
        [self addSubview:_horizon];
        [self addSubview:_vertical];
        self.backgroundColor = ButtonWhiteColor;
    }
    return self;
}

- (void) setButtonStyle:(EZShotButtonStyle)style
{
    EZDEBUG(@"setButtonStyle:%i", style);
    if(style == kShotForOne){
        _vertical.backgroundColor = [UIColor whiteColor];
        _horizon.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = ClickedColor;
    }else if(style == kShotForAll){
        _vertical.backgroundColor = ClickedColor;
        _horizon.backgroundColor = ClickedColor;
        self.backgroundColor = ButtonWhiteColor;
    }else if(style == kShotScreen){
        _vertical.backgroundColor = [UIColor whiteColor];
        _horizon.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = EZOrangeColor;
    }else if(style == kShotHappen){
        _vertical.backgroundColor = [UIColor whiteColor];
        _horizon.backgroundColor = [UIColor whiteColor];
        self.backgroundColor= [UIColor clearColor];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
