//
//  EZPathObject.h
//  3DCamera
//
//  Created by xietian on 14-9-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZCanvas.h"

@interface EZPathObject : EZDrawable

@property (nonatomic, strong) NSMutableArray* points;

@property (nonatomic, strong) UIColor* color;

@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, assign) BOOL isFill;

+ (EZPathObject*) createPath:(UIColor*)color width:(CGFloat)lineWidth isFill:(BOOL)isFill;

- (void) addPoint:(CGPoint)point;

- (void) addPoints:(NSArray*)points;

@end
