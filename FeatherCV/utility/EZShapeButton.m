//
//  EZShapeButton.m
//  FeatherCV
//
//  Created by xietian on 14-3-6.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZShapeButton.h"

@implementation EZShapeButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        _fillColor = [UIColor whiteColor];
        self.enableTouchEffects = false;
        [self enableShadow:[UIColor blackColor]];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGFloat _radius = 2.5;
    CGFloat _gap = 3.0;
    CGFloat diameter = _radius * 2.0;
 
    CGFloat totalLength = diameter * 3 + _gap * 2;
    
    CGFloat begin = (self.width - totalLength)/2.0;
    CGFloat height = (self.height - diameter)/2.0;
    CGContextSetFillColorWithColor( context, _fillColor.CGColor);
    for(int i = 0; i < 3; i ++){
        CGRect innerCycle = CGRectMake(begin, height, diameter, diameter);
        CGContextFillEllipseInRect(context, innerCycle);
        begin += (diameter + _gap);
    }
}


@end
