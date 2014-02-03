//
//  EZFaceResultObj.h
//  FeatherCV
//
//  Created by xietian on 14-1-6.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZFaceResultObj : NSObject

@property (nonatomic, assign) CGRect orgRegion;

//Average face color
@property (nonatomic, strong) NSArray* avgFaceColor;


@property (nonatomic, assign) CGFloat skinDistance;

@end
