//
//  EZPalate.m
//  3DCamera
//
//  Created by xietian on 14-9-24.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZPalate.h"
#import "EZDrawAngle.h"

@implementation EZPalate



- (id) initWithFrame:(CGRect)frame activeColor:(UIColor*)activeColor inactiveColor:(UIColor*)inactiveColor background:(UIColor*)background total:(NSInteger)total
{
    self = [super initWithFrame:frame];
    EZDrawAngle* angle = [EZDrawAngle create:CGRectMake(0, 0, frame.size.width, frame.size.height) total:total occupiedColor:activeColor emptyColor:inactiveColor background:background length:10];
    angle.shiftAngle = - M_PI_2;
    [self addShapeObject:angle];
    
    _total = total;
    _occupied = 0;
    _drawAngle = angle;
    [self setNeedsDisplay];
    return self;
}

- (void) setOccupied:(CGFloat)occupied
{
    _occupied = occupied;
    _drawAngle.occupiedCount = occupied;
    [self setNeedsDisplay];
}

- (void) setTotal:(CGFloat)total
{
    _total = total;
    _drawAngle.totalAngle = total;
    [self setNeedsDisplay];
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
