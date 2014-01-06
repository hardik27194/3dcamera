//
//  EZFaceUtilWrapper.m
//  FeatherCV
//
//  Created by xietian on 14-1-6.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZFaceUtilWrapper.h"
#include "EZFaceUtil.h"

@implementation EZFaceUtilWrapper

+ (NSArray*) detectFace:(UIImage*) image ratio:(CGFloat) miniRatio
{
    return singleton<EZFaceUtil>().detectFace(image, miniRatio);
}

@end
