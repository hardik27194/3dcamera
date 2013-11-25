//
//  EZPhotoCell.h
//  Feather
//
//  Created by xietian on 13-9-17.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZConstants.h"
#import "EZPhoto.h"
#import "EZCombinedPhoto.h"
#import "EZStyleImage.h"
/**
 What's the purpose of this class?
 I will display a cell on the screen. 
 Have following parts:
 1. The photo.
    Click will trigger the rotation animation. 
 2. The functional part.
    Comments button will get into the comments window, it is another controller. 
    I can reuse the comments controller. Enjoy 30 minutes. 
   2.1 Heart clicked can be liked. 
 **/
@class EZClickImage;
@class EZClickView;
@interface EZPhotoCell : UITableViewCell

@property (nonatomic, assign) int currentPos;

@property (nonatomic, assign) BOOL isLarge;

//The UIImage which have no effects
@property (nonatomic, strong) UIImageView* frontNoEffects;

@property (nonatomic, strong) EZStyleImage* frontImage;

@property (nonatomic, strong) EZStyleImage* backImage;

//The purpose of the container is to limit the scope of the flip animation.
//Otherwise the whole thing rotate together, this is not what I expected.
@property (nonatomic, strong) EZClickView* container;

@property (nonatomic, strong) EZClickImage* likeButton;

//You can talk as you like.
@property (nonatomic, strong) EZClickImage* talkButton;

@property (nonatomic, strong) EZEventBlock clicked;

//Name of the current image
@property (nonatomic, strong) UILabel* name;

//Used to record the status of the photo cell, so when I turn I knew which one is on the front.
@property (nonatomic, assign) BOOL isFrontImage;

//The flipped status will be with the EZCombinedPhotot object itself, then the flipped will
//Decouple the logic. I love this game.
@property (nonatomic, strong) EZEventBlock flippedCompleted;

//I will use small image initially, then switch to the large image.
@property (nonatomic, assign) BOOL isLargeImage;

- (void) displayPhoto:(NSString*)photo;

//I am happy that define a good interface to handle the image switch action
- (void) switchImageTo:(NSString*)url;

- (void) displayImage:(UIImage*)img;

- (void) displayEffectImage:(UIImage*)img;

- (void) backToOriginSize;

- (id) init;

@end
