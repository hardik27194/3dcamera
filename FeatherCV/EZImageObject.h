//
//  EZImageObject.h
//  3DCamera
//
//  Created by xietian on 14-9-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZCanvas.h"

@interface EZImageObject : EZDrawable

@property (nonatomic, assign) CGPoint point;

@property (nonatomic, assign) CGSize size;

@property (nonatomic, strong) UIImage* image;


+ (EZImageObject*) createImage:(UIImage*)image frame:(CGRect)frame;


@end
