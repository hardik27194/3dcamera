//
//  EZMotionRecord.h
//  FeatherCV
//
//  Created by xietian on 14-5-12.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZMotionRecord : NSObject

@property (nonatomic, strong) NSString* imageURL;

@property (nonatomic, strong) UIImage* image;

//The delta rotation alone x axis
@property (nonatomic, assign) CGFloat deltaX;

//The delta rotation alone y axis
@property (nonatomic, assign) CGFloat deltaY;

//The delta rotation alone z axis.
@property (nonatomic, assign) CGFloat deltaZ;

@end
