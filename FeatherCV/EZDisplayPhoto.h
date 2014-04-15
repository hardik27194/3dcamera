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
    kEZStartStatus,
    kEZSendSharedRequest,//either shared with another person or shared with anonymous person
    kEZShareAvailable,
    kEZWaitingPicture,

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
//I don't get it.
@property (nonatomic, assign) int pid;

@property (nonatomic, strong) EZPhoto* photo;

//@property (nonatomic, assign) CGSize imageSize;

@property (nonatomic, assign) EZCombinedStatus combineStatus;

//Which photo do I need use as my background.
@property (nonatomic, assign) int preferredPos;
//Transition field. will not persistent to the database.
@property (nonatomic, assign) BOOL isFront;

//Whether I am turning the image or not
@property (nonatomic, assign) BOOL isTurning;

//Once this one get displayed, I will disappear.
@property (nonatomic, assign) BOOL isFirstTime;


//Only display a single photo
@property (nonatomic, assign) BOOL isSingle;

//Some animation will need to be used.
@property (nonatomic, strong) EZEventBlock turningAnimation;

//The previous remove should happen at the cell closed.
@property (nonatomic, strong) EZEventBlock removeShadow;

@property (nonatomic, assign) CGSize turningImageSize;

@property (nonatomic, strong) UIView* oldTurnedImage;

//If this is a place hold or not.
//Mean I am loading the photo.
@property (nonatomic, assign) BOOL isPlaceHolder;

@property (nonatomic, assign) BOOL isLoading;

//The photo will be displayed.
@property (nonatomic, assign) int photoPos;
//What's the status of the turning angle.
//To visualize the whole process, is that, we will uploading the image
//In the meanwhile, we will try to download the image.
//Once the image is done, but we can get the progress easily, right?
//Just fake the process.
//Initially, it is faster, the decrease exponentially, this is really great.
@property (nonatomic, assign) CGFloat turningDegree;


@property (nonatomic, strong) NSString* randImage;

@end
