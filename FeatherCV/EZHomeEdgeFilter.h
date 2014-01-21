//
//  EZHomeEdgeFilter.h
//  FeatherCV
//
//  Created by xietian on 14-1-12.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImageSobelEdgeDetectionFilter.h>
#import <GPUImageThresholdEdgeDetectionFilter.h>
@interface EZHomeEdgeFilter : GPUImageThresholdEdgeDetectionFilter

//This is the value we could adjust for the purpose make the line wider
//This seems reasonable to me.
@property (nonatomic, assign) CGFloat edgeRatio;

@end
