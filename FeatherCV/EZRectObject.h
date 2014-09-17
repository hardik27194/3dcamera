//
//  EZRectObject.h
//  3DCamera
//
//  Created by xietian on 14-9-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZCanvas.h"

@interface EZRectObject : EZDrawable

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, strong) UIColor* color;

@property (nonatomic, assign) BOOL isStroke;

//@property (nonatomic, strong) UIColor* borderColor;

@property (nonatomic, assign) CGFloat borderWidth;


- (void) drawContext:(CGContextRef)ctx;

+ (EZRectObject*) createRect:(CGRect)rect isStroke:(BOOL)isStroke color:(UIColor*)color borderWidth:(CGFloat)borderWidth;

@end
