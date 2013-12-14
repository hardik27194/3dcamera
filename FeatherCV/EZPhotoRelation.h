//
//  EZPhotoRelation.h
//  FeatherCV
//
//  Created by xietian on 13-12-14.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZPhoto.h"
//Take 5 minutes to visualize, how I am going to use this object.
@interface EZPhotoRelation : NSObject

//old habit
@property (nonatomic, assign) int relationID;
//No need person, the person just in the photo
@property (nonatomic, strong) EZPhoto* photo;

//This is clearly the conversation happened on this relations
@property (nonatomic, strong) NSArray* conversations;

@end
