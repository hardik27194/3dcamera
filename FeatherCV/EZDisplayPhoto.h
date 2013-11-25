//
//  EZDisplayPhoto.h
//  Feather
//
//  Created by xietian on 13-10-29.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZPhoto.h"

typedef enum {
    kEZNotShared,
    kEZUploadWaiting,
    //Upload Waiting and Waiting to join is the same.
    //kEZWaitingToJoin,
    
    //Final status
    kEZCombined,
    //Ask a new image from you.
    kEZRemoteRequest
}EZCombinedStatus;
//Why do I invent this object?
//First, CombinedPhoto is not a 1 to M relationship?
//It is a one to one relationship.
//So I need a object to bind the relationship.
//EZPhoto could do this?
//But the cyclic dependence of the object make me feel bad.
//So I invent a EZDisplayPhoto to capture the relationship.
//There is nothing to sync up to database in this object.
@interface EZDisplayPhoto : NSObject

//Just for the purpose of asynchronize the photos.
@property (nonatomic, assign) int pid;

@property (nonatomic, strong) EZPhoto* myPhoto;

@property (nonatomic, assign) CGSize imageSize;

@property (nonatomic, assign) EZCombinedStatus combineStatus;
//Transition field. will not persistent to the database.
@property (nonatomic, assign) BOOL isFront;

//Mean the photo which will show on the back of this photo
@property (nonatomic, assign) int selectedCombinePhoto;

@property (nonatomic, strong) NSArray* combinedPhotos;

//Whether it is a date or a photo.
@property (nonatomic, assign) int displayType;

@end
