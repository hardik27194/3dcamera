//
//  EZSeperator.m
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZSeperator.h"

@implementation EZSeperator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
        _color = [UIColor whiteColor];
        _gap = 0;
        _padding = 11;
        _leftBar = [[UIView alloc] initWithFrame:CGRectMake(_padding, 0, CurrentScreenWidth/2.0 - _padding, frame.size.height)];
        _leftBar.backgroundColor = _color;
        
        _rightBar = [[UIView alloc] initWithFrame:CGRectMake(CurrentScreenWidth/2.0, 0, CurrentScreenWidth/2.0 - _padding, frame.size.height)];
        _rightBar.backgroundColor = _color;
        
        [self addSubview:_leftBar];
        [self addSubview:_rightBar];
    }
    return self;
}

- (void) setGap:(CGFloat)gap
{
    CGFloat length = CurrentScreenWidth/2.0 - _padding - gap/2.0;
    [_leftBar setWidth:length];
    [_rightBar setWidth:length];
    [_rightBar setX:CurrentScreenWidth/2.0 + gap/2.0];
    _gap = gap;
}


- (void) setColor:(UIColor *)color
{
    _leftBar.backgroundColor = color;
    _rightBar.backgroundColor = color;
    _color = color;
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
