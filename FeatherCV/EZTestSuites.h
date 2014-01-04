//
//  EZTestSuites.h
//  Feather
//
//  Created by xietian on 13-10-29.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZTestSuites : NSObject

+ (void) testAll;

+ (UIView*) testResizeMasks;

+ (void) testAlphaSetting;

+ (void) testClickView:(UIView*)parentView;

@end
