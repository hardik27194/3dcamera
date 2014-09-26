//
//  EZPalate.h
//  3DCamera
//
//  Created by xietian on 14-9-24.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZCanvas.h"

@class EZDrawAngle;
@interface EZPalate : EZCanvas

@property (nonatomic, assign) CGFloat total;

@property (nonatomic, assign) CGFloat occupied;

@property (nonatomic, strong) EZDrawAngle* drawAngle;

- (id) initWithFrame:(CGRect)frame activeColor:(UIColor*)activeColor inactiveColor:(UIColor*)inactiveColor background:(UIColor*)background total:(NSInteger)total;



@end
