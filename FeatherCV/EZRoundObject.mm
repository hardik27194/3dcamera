//
//  EZRoundObject.m
//  3DCamera
//
//  Created by xietian on 14-9-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZRoundObject.h"

@implementation EZRoundObject

- (void) drawContext:(CGContextRef)context
{
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    //UIColor * redColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    CGRect shiftedRect = [self shiftRect:self.frame shift:self.shift];
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    if(self.isStroke){
        CGContextSetStrokeColorWithColor(context,self.selected?self.selectedColor.CGColor:self.color.CGColor);
        CGContextSetLineWidth(context, self.borderWidth);
        CGContextStrokeEllipseInRect(context, shiftedRect);
    }else{
        CGContextSetFillColorWithColor(context,self.selected?self.selectedColor.CGColor:self.color.CGColor);
        CGContextFillEllipseInRect(context, shiftedRect);
    }
}

+ (EZRoundObject*) createRound:(CGRect)rect isStroke:(BOOL)isStroke color:(UIColor*)color borderWidth:(CGFloat)borderWidth
{
    EZRoundObject* object = [[EZRoundObject alloc] init];
    object.frame = rect;
    object.isStroke = isStroke;
    object.color = color;
    object.borderWidth = borderWidth;
    return object;
}

@end
