//
//  EZShapeCover.m
//  FeatherCV
//
//  Created by xietian on 14-2-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZShapeCover.h"

@implementation EZShapeCover

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self digHole];
    }
    return self;
}

- (void) digHole
{
    int radius = 310.0;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:0];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(5, (self.bounds.size.height - 310.0)/2.0, 310, 310) cornerRadius:radius];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    
    _fillLayer = [CAShapeLayer layer];
    _fillLayer.path = path.CGPath;
    _fillLayer.fillRule = kCAFillRuleEvenOdd;
    _fillLayer.fillColor = [UIColor blackColor].CGColor;
    _fillLayer.opacity = 0.8;
    [self.layer addSublayer:_fillLayer];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/**
- (void)drawRect:(CGRect)rect
{

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 0.5);
    CGContextFillRect(context, self.bounds);
    
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.0);
    CGRect cycleBound = CGRectMake(5, (self.bounds.size.height - 310.0)/2.0, 310, 310);
    CGContextFillEllipseInRect(context, cycleBound);

}
**/

@end
