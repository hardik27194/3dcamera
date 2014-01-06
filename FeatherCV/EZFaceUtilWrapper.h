//
//  EZFaceUtilWrapper.h
//  FeatherCV
//
//  Created by xietian on 14-1-6.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZFaceUtilWrapper : NSObject

+ (NSArray*) detectFace:(UIImage*) image ratio:(CGFloat) miniRatio;

@end
