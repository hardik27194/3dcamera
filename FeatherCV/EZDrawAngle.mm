//
//  EZDrawAngle.m
//  3DCamera
//
//  Created by xietian on 14-9-23.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZDrawAngle.h"

@implementation EZDrawAngle


+ (EZDrawAngle*) create:(CGRect)rect total:(CGFloat)total occupiedColor:(UIColor*)occupiedColor emptyColor:(UIColor*)emptyColor background:(UIColor*)background length:(CGFloat)length
{
    EZDrawAngle* res = [[EZDrawAngle alloc] init];
    res.frame = rect;
    res.background = background;
    res.totalAngle = total;
    res.occupiedColor = occupiedColor;
    res.emptyColor = emptyColor;
    res.length = length;
    res.center = CGPointMake(rect.origin.x + rect.size.width/2.0, rect.origin.y + rect.size.height/2.0);
    res.radius = rect.size.width/2.0;
    return res;
}

- (id) init
{
    self = [super init];
    _occupiedColor = [UIColor blackColor];
    _emptyColor = [UIColor whiteColor];
    return self;
}

- (void) drawContext:(CGContextRef)ctx
{
    
    //EZPoint* pt = [_points objectAtIndex:0];
    //CGPoint shiftedPt = [self shiftPoint:pt.point shift:self.shift];
    //CGMutablePathRef path = CGPathCreateMutable();
    //CGPathMoveToPoint(path, NULL, shiftedPt.x, shiftedPt.y);
    CGContextSetFillColorWithColor(ctx, _background.CGColor);
    CGContextFillEllipseInRect(ctx, _frame);
    CGFloat halfAngle = M_PI/_totalAngle;
    CGFloat upperBound = M_PI/72.0;
    CGFloat deltaAngle = MIN(upperBound, halfAngle);
    EZDEBUG(@"half angle:%f", halfAngle);
    for(int i = 0; i < _totalAngle; i ++){
        //EZPoint* pt1 = [_points objectAtIndex:i];
        //shiftedPt = [self shiftPoint:pt1.point shift:self.shift];
        //CGPathAddLineToPoint(path, NULL, shiftedPt.x, shiftedPt.y)
        CGMutablePathRef path = CGPathCreateMutable();
        CGFloat curAngle = i * 2 * halfAngle - deltaAngle;
        CGFloat btmY = _center.y - sinf(curAngle) * _radius;
        CGFloat btmX = _center.x - cosf(curAngle) * _radius;
        
        CGFloat midAngle = i * 2 * halfAngle;
        CGFloat midY = _center.y - sinf(midAngle) * (_radius - _length);
        CGFloat midX = _center.x - cosf(midAngle) * (_radius - _length);
        
        CGFloat upperAngle = i * 2  * halfAngle + deltaAngle;
        CGFloat upperY = _center.y - sinf(upperAngle) * _radius;
        CGFloat upperX = _center.x - cosf(upperAngle) * _radius;
        
        EZDEBUG(@"cur:%f, mid:%f, upper:%f, midX:%f, midY:%f", curAngle, midAngle, upperAngle, midX, midY);
        CGPathMoveToPoint(path, nil, btmX, btmY);
        CGPathAddLineToPoint(path, nil, midX, midY);
        CGPathAddLineToPoint(path, nil, upperX, upperY);
        CGPathCloseSubpath(path);
        CGContextSetFillColorWithColor(ctx,i < _occupiedCount?_occupiedColor.CGColor:_emptyColor.CGColor);
        CGContextAddPath(ctx, path);
        CGContextFillPath(ctx);
        
        /**
        CGContextSetFillColorWithColor(ctx, [UIColor yellowColor].CGColor);
        CGContextFillEllipseInRect(ctx, CGRectMake(midX, midY, 5, 5));
        
        CGContextSetFillColorWithColor(ctx, [UIColor greenColor].CGColor);
        CGContextFillEllipseInRect(ctx, CGRectMake(btmX, btmY, 5, 5));
        
        CGContextSetFillColorWithColor(ctx, [UIColor grayColor].CGColor);
        CGContextFillEllipseInRect(ctx, CGRectMake(upperX, upperY, 5, 5));
        **/
    }

}

@end
