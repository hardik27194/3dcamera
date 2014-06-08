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
#import "ILTranslucentView.h"
#import "EZDisplayPhoto.h"
#import "EZBarRegion.h"
#import "EZChatUnit.h"
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
@class EZSimpleClick;
@class EZScrollViewer;

#define MainLabelTag 20140103

#define ToolRegionHeight 80
#define InitialFeedbackRegion 60

#define ToolRegionRect CGRectMake(0, 300, 300, ToolRegionHeight)

#define FeedbackRegionRect CGRectMake(0,380, 300, 40)

@class EZShapeButton;
@class EZEnlargedView;

@interface EZPhotoCell : UITableViewCell

@property (nonatomic, assign) int currentPos;

@property (nonatomic, assign) BOOL isLarge;

//The purpose of the container is to limit the scope of the flip animation.
//Otherwise the whole thing rotate together, this is not what I expected.
@property (nonatomic, strong) UIView* container;

//All the control will be locate at this layer,
//Then the full screen will be more easy to implement.
@property (nonatomic, strong) UIView* controlLayer;

//This view will in charge of the whole rotate, because I need to rotate the whole thing.
@property (nonatomic, strong) UIView* rotateContainer;

@property (nonatomic, strong) EZBarRegion* toolRegion;

@property (nonatomic, strong) UIView* feedbackRegion;

//The UIImage which have no effects
//@property (nonatomic, strong) UIImageView* frontNoEffects;

//@property (nonatomic, strong) EZSimpleClick* frontImage;

@property (nonatomic, strong) EZScrollViewer* frontImage;

@property (nonatomic, strong) UIImageView* backImage;

@property (nonatomic, strong) UILabel* photoTalk;

@property (nonatomic, strong) EZEnlargedView* headIcon;

@property (nonatomic, strong) UILabel* authorName;

@property (nonatomic, strong) EZEnlargedView* otherIcon;

@property (nonatomic, strong) EZEnlargedView* ownChatButton;

@property (nonatomic, strong) EZEnlargedView* otherChatButton;

@property (nonatomic, strong) UILabel* otherName;

@property (nonatomic, strong) UILabel* photoDate;

@property (nonatomic, strong) UILabel* andSymbol;

@property (nonatomic, strong) UILabel* ownTalk;

@property (nonatomic, strong) UILabel* otherTalk;

@property (nonatomic, strong) EZShapeButton* moreButton;
//The icon which represent the relationship between the headIcon and other icons
//Which could be lock or other icons.
@property (nonatomic, strong) EZClickImage* linkIcon;

//The head icon for the image which on the back of the current image.
@property (nonatomic, strong) EZClickImage* backIcon;

//The icon will show the available image to match this image
@property (nonatomic, strong) UILabel* countIcon;

@property (nonatomic, strong) UITextView* photoWord;

@property (nonatomic, strong) UIButton* likeButton;
//You can talk as you like.
@property (nonatomic, strong) EZClickImage* talkButton;

@property (nonatomic, strong) EZEventBlock clicked;

@property (nonatomic, strong) EZClickImage* clickHeart;

@property (nonatomic, strong) UIView* otherLike;
//Name of the current image
@property (nonatomic, strong) UILabel* name;

@property (nonatomic, strong) UIView* homeSliverLine;

@property (nonatomic, strong) UIView* otherSliverLine;

@property (nonatomic, strong) UIView* leftHalf;

@property (nonatomic, strong) UIView* rightHalf;

//Used to record the status of the photo cell, so when I turn I knew which one is on the front.
@property (nonatomic, assign) BOOL isFrontImage;

//The flipped status will be with the EZCombinedPhotot object itself, then the flipped will
//Decouple the logic. I love this game.
@property (nonatomic, strong) EZEventBlock flippedCompleted;

//will show this when encounter a photo request
@property (nonatomic, strong) UIView* cameraView;

@property (nonatomic, strong) UILabel* requestInfo;

@property (nonatomic, strong) UILabel* requestFixInfo;

@property (nonatomic, strong) UILabel* waitingInfo;

@property (nonatomic, strong) UIActivityIndicatorView* activityView;

//I will use small image initially, then switch to the large image.
@property (nonatomic, assign) BOOL isLargeImage;

//Don't use the cell which is turning.
@property (nonatomic, assign) BOOL isTurning;

@property (nonatomic, strong) EZClickImage* shotPhoto;

//@property (nonatomic, strong) UIPageControl* pageControl;


@property (nonatomic, strong) UIView* firstTimeView;
//@property (nonatomic, strong) EZChatUnit* chatUnit;

//Used to maintain that only cell at the same rotation will happen
@property (nonatomic, assign) NSInteger rotateCount;

@property (nonatomic, strong) UIView* gradientView;

@property (nonatomic, strong) EZEventBlock buttonClicked;
//- (void) adjust

- (void) displayPhoto:(NSString*)photo;

//I am happy that define a good interface to handle the image switch action
- (void) switchImageTo:(NSString*)url;

//I will show the rotation animation;
- (void) switchImage:(EZPhoto*)photo photo:(EZDisplayPhoto*)dp complete:(EZEventBlock)blk tableView:(UITableView*)tableView index:(NSIndexPath*)path;

- (void) displayImage:(UIImage*)img;

- (void) displayEffectImage:(UIImage*)img;

//Why have a different method do this?
//Why not use a single method to handle all of them?
//This is great idea.
- (void) backToOriginSize;

+ (UIView*) createWaitView:(NSString*)name;

- (void) adjustCellSize:(CGSize)size;

- (UIView*) createDupContainer:(UIImage*)img;

- (void) setTimeStr:(NSString*)timeStr;

- (void) setFrontFormat:(BOOL)front;

- (void) setupCell:(EZDisplayPhoto*)dp;

- (id) init;

@end
