//
//  EZAlbumCollectionPage.h
//  Feather
//
//  Created by xietian on 13-10-11.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

//Just blindly move ahead, turn unknown into the normal status of your life.
//Move as deep as your code
//What's the purpose of this class?
//Will be the collection as the main timeline.
#import <UIKit/UIKit.h>
#import "EZAppConstants.h"

@interface EZAlbumCollectionPage : UICollectionViewController<UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray* combinedPhotos;

//@property (nonatomic, strong) UISwipeGestureRecognize

+ (EZAlbumCollectionPage*) createGridAlbumPage:(BOOL)isLarge ownID:(int)ownID queryBlock:(EZQueryBlock)queryBlock;

-(id)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout queryBlock:(EZQueryBlock)queryBlock queryLimit:(int)queryLimit;
//It is not necessarilly the current user.
//So I need to compare it.
@property (nonatomic, assign) int ownerID;

@property (nonatomic, strong) EZEventBlock uploadProcess;

@property (nonatomic, assign) BOOL leftSwipe;

//Whether to show the hidden button or not.
@property (nonatomic, assign) BOOL showHiddenButton;

@property (nonatomic, strong) UILabel* totalEntries;
@property (nonatomic, strong) UILabel* monthCount;
@property (nonatomic, strong) UILabel* weekCount;
@property (nonatomic, strong) UILabel* dailyCount;
@property (nonatomic, strong) UIView* container;

//This is a successful pattern I have explored several years ago.
@property (nonatomic, strong) EZQueryBlock queryBlock;
//Where do we begin
//It used to save the memory consumption
@property (nonatomic, assign) int currentBegin;

@property (nonatomic, assign) int queryLimit;

@property (nonatomic, assign) int totalLength;

@property (nonatomic, assign) BOOL isLarge;


@end
