//
//  EZMainLayout.m
//  3DCamera
//
//  Created by xietian on 14-9-4.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZMainLayout.h"

@implementation EZMainLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    EZDEBUG("flow layout changed %@", NSStringFromCGRect(newBounds));
    return YES;
}

@end
