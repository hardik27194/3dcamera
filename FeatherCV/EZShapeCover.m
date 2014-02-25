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
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void) tapped:(id)sender
{
    EZDEBUG(@"tap get called");
    if(_releaseBlock){
        _releaseBlock(self);
    }
}

- (void) digHole:(CGFloat)radius color:(UIColor *)fillColor opacity:(CGFloat)opacity
{
    //int radius = 310.0;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:0];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(5, (self.bounds.size.height - radius)/2.0 - 10.0, radius, radius) cornerRadius:radius];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    
    _fillLayer = [CAShapeLayer layer];
    _fillLayer.path = path.CGPath;
    _fillLayer.fillRule = kCAFillRuleEvenOdd;
    _fillLayer.fillColor = fillColor.CGColor;
    _fillLayer.opacity = opacity;
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
