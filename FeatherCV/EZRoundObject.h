//
//  EZRoundObject.h
//  3DCamera
//
//  Created by xietian on 14-9-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZRectObject.h"

@interface EZRoundObject : EZRectObject


- (void) drawContext:(CGContextRef)ctx;

+ (EZRoundObject*) createRound:(CGRect)rect isStroke:(BOOL)isStroke color:(UIColor*)color borderWidth:(CGFloat)borderWidth;

@end
