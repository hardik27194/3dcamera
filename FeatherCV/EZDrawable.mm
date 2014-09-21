//
//  EZDrawable.m
//  3DCamera
//
//  Created by xietian on 14-9-17.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZDrawable.h"
@implementation EZDrawable

- (id) init
{
    self = [super init];
    _selectedColor = RGBCOLOR(254, 208, 73);
    return self;
}

- (void) drawContext:(CGContextRef)context
{
    
}

- (void) mergeShift:(CGPoint)shift
{
    _boundingRect = [self shiftRect:_boundingRect shift:_shift];
    _shift = CGPointZero;
}

- (void) mergeShift
{
    [self mergeShift:_shift];
}

- (CGRect) getBoundingRect
{
    return CGRectMake(_boundingRect.origin.x + _shift.x, _boundingRect.origin.y + _shift.y, _boundingRect.size.width, _boundingRect.size.height);
}

- (CGRect) shiftRect:(CGRect)rect shift:(CGPoint)shift
{
    return CGRectMake(rect.origin.x + shift.x, rect.origin.y + shift.y, rect.size.width, rect.size.height);
}

- (CGPoint) shiftPoint:(CGPoint)pt shift:(CGPoint)shift
{
    return CGPointMake(pt.x + shift.x, pt.y + shift.y);
}

- (BOOL) pointInSide:(CGPoint)pt
{
    return CGRectContainsPoint(_boundingRect, pt);
}


- (void) setParent:(EZCanvas*)canvas
{
    _parent = canvas;
}

@end