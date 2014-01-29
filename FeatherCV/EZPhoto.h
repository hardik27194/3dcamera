//
//  EZPhoto.h
//  Feather
//
//  Created by xietian on 13-9-17.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "EZAppConstants.h"

@class ALAsset;
@class EZPerson;
@interface EZPhoto : NSObject

@property (nonatomic, assign) int photoID;


@property (nonatomic, strong) EZPerson* owner;
//@property (nonatomic, assign) int ownerID;

//@property (nonatomic, assign) int otherID;

@property (nonatomic, strong) NSString* url;

//I could use this to compare if I have newly added photo or not.
//Great, I love this game
//This can not be used.
//Will be used to match the photo from the asset.

//For local image only, we will make use of the system thumbnail.
//@property (nonatomic, strong) UIImage* thumbnail;

//This is information I extracted from the photo itself.
@property (nonatomic, strong) NSDate* createdTime;

@property (nonatomic, assign) double latitude;

@property (nonatomic, assign) double longitude;

@property (nonatomic, assign) double altitude;

@property (nonatomic, strong) NSString* address;

//Just to keep it temporarily. 
@property (nonatomic, strong) ALAsset* asset;

//Whether this photo uploaded or not
//Mean if the photo is local photo or not
//Who need this?
//for what purpose?
//Why should I care it is local or not?
//Don't know, put it here, let's Darwin decide it
//This property don't seems very well.
@property (nonatomic, assign) BOOL isLocal;

//Do I have any case to use this?
@property (nonatomic, strong) NSDate* uploadedTime;

//The comment given by the owner
@property (nonatomic, strong) NSString* photoTalk;

//It is true,mean only visible to specified user
//Otherwise mean everybody can combine with it
@property (nonatomic, assign) BOOL isPeerOnly;

//The size for the image. why do I need it?
//I need this because, I need to determine the height for the
//Image, that's why I need it.
@property (nonatomic, assign) CGSize size;

//The photo which have a relationship with this one
@property (nonatomic, strong) NSArray* photoRelations;

@property (nonatomic, strong) NSArray* conversations;

//@property (nonatomic, strong) NSString* otherURL;

//@property (nonatomic, assign) BOOL likedByOther;

//@property (nonatomic, assign) BOOL liked;
//Fetch the asset image, which is huge, so only do this when we really need it
//Even for thumbnail, we also have the memory issue with it. We need to get it done.
- (UIImage*) getOriginalImage;

- (UIImage*) getScreenImage;

- (UIImage*) getThumbnail;

- (void) getAsyncImage:(EZEventBlock)block;


@end
