//
//  EZImageAsset.h
//  FeatherCV
//
//  Created by xietian on 14-5-23.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
//#include <CoreLocation/CLLocation.h>

@class CLLocation;
@interface EZImageAsset : NSObject

@property (nonatomic, strong) NSString* assetURL;

@property (nonatomic, strong) NSDictionary* metaData;

@property (nonatomic, strong) NSString* storedImageFile;

@property (nonatomic, assign) UIImageOrientation orientation;

@property (nonatomic, strong) NSDate* createdTime;

@property (nonatomic, strong) CLLocation* location;

@end
