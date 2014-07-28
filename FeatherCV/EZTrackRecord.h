//
//  EZTrackRecord.h
//  BabyCare
//
//  Created by xietian on 14-7-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface EZTrackRecord : NSObject

@property (nonatomic, assign) EZTrackRecordType type;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, assign) CGFloat  measures;
//If this is not zero will display it immediately
@property (nonatomic, strong) NSString* formattedStr;
@property (nonatomic, strong) NSString* attachedImage;
@property (nonatomic, strong) NSDate* measuredDate;
@property (nonatomic, strong) NSString* graphURL;


@end
