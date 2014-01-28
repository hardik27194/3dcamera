//
//  EZAlbumTablePage.h
//  Feather
//
//  Created by xietian on 13-11-13.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAppConstants.h"
#import "DLCImagePickerController.h"
#import "SlideAnimation.h"
#import "EZRaiseAnimation.h"
#import "EZModalRaiseAnimation.h"

@class EZDisplayPhoto;
@interface EZAlbumTablePage : UITableViewController<DLCImagePickerDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate>


@property (nonatomic, strong) NSMutableArray* combinedPhotos;

//@property (nonatomic, strong) UISwipeGestureRecognize


-(id)initWithQueryBlock:(EZQueryBlock)queryBlock;

- (void) addPhoto:(EZDisplayPhoto*)photo;
//It is not necessarilly the current user.
//So I need to compare it.

//Whether to show the hidden button or not.
@property (nonatomic, assign) BOOL showHiddenButton;

@property (nonatomic, strong) UILabel* totalEntries;
@property (nonatomic, strong) UILabel* monthCount;
@property (nonatomic, strong) UILabel* weekCount;
@property (nonatomic, strong) UILabel* dailyCount;
@property (nonatomic, strong) UIView* container;

@property (nonatomic, assign) CGFloat menuHeight;

@property (nonatomic, strong) UIView* menuView;

@property (nonatomic, strong) SlideAnimation* slideAnimation;

@property (nonatomic, strong) EZModalRaiseAnimation* cameraAnimation;

@property (nonatomic, strong) EZRaiseAnimation* raiseAnimation;
//This is a successful pattern I have explored several years ago.
@property (nonatomic, strong) EZQueryBlock queryBlock;

//either user are dragging or the tableview is scrolling,
//This scrolling is true.
@property (nonatomic, assign) BOOL isScrolling;

@property (nonatomic, strong) EZEventBlock cameraClicked;

@property (nonatomic, strong) UIButton* moreButton;


//Where do we begin
//It used to save the memory consumption
- (void) raiseCamera;

@end
