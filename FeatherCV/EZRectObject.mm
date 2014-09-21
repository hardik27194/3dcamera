//
//  EZRectObject.m
//  3DCamera
//
//  Created by xietian on 14-9-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZRectObject.h"

@implementation EZRectObject

- (void) drawContext:(CGContextRef)context
{
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    //UIColor * redColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    CGRect shiftedRect = [self shiftRect:_frame shift:self.shift];
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    if(_isStroke){
        
        CGContextSetStrokeColorWithColor(context,self.selected?self.selectedColor.CGColor:_color.CGColor);
        CGContextSetLineWidth(context, _borderWidth);
        CGContextStrokeRect(context, shiftedRect);
    }else{
        CGContextSetFillColorWithColor(context,self.selected?self.selectedColor.CGColor:_color.CGColor);
        CGContextFillRect(context, shiftedRect);
    }
}

/**
- (void) setShift:(CGPoint)pt
{
    //[self set [self shiftRect:_frame shift:pt];
    //self.boundingRect = _frame;
}
**/
- (void) setFrame:(CGRect)frame
{
    _frame = frame;
    self.boundingRect = frame;
}

- (void) mergeShift:(CGPoint)shift
{
    [super mergeShift:shift];
    self.frame = [self shiftRect:_frame shift:shift];
    
}


+ (EZRectObject*) createRect:(CGRect)rect isStroke:(BOOL)isStroke color:(UIColor*)color borderWidth:(CGFloat)borderWidth
{
    EZRectObject* object = [[EZRectObject alloc] init];
    object.frame = rect;
    object.isStroke = isStroke;
    object.color = color;
    object.borderWidth = borderWidth;
    return object;
}

@end
