//
//  EZCombinedPhoto.h
//  Feather
//
//  Created by xietian on 13-9-23.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EZPhoto;
@interface EZCombinedPhoto : NSObject

@property (nonatomic, assign) int combinedID;

@property (nonatomic, strong) EZPhoto* selfPhoto;

//Mean I will have a lot of combined Photo with this photo
//@property (nonatomic, strong) EZPhoto* otherPhoto;
@property (nonatomic, strong) EZPhoto* otherPhoto;



//What's the meaning of this?
//Mean uploaded time, right?
@property (nonatomic, strong) NSDate* uploadedTime;

//Whether uploaded for combination or not.
//Actually, I suspect the status of this object will cover this.
//Let's check and see.
@property (nonatomic, assign) BOOL isUploaded;

//If true mean system will give you the photos which you can select to combine with your photos.
//The only difference is that you could select them to combine with you, then it is become visible to
//other people and system will no more remove it.
@property (nonatomic, assign) BOOL recommended;

//Initially, I want to simply use 2 bool to represent that, It is liked by me
//And like by the other person, then I think what if I will share this photo combination and allow other person to
//See them?
//Then word from PG remind, over-engineer are like telling a lie and need to memorize it.
//Follow the facts, let the facts lead your way gentlely and naturally
@property (nonatomic, assign) BOOL likedByMe;

@property (nonatomic, assign) BOOL likedByOthers;

//@property (nonatomic, strong) NSArray* conversations;




@end
