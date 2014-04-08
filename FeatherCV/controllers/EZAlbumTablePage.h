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
#import "EZModalDissolveAnimation.h"
#import "EZCameraNaviAnimation.h"
#import "EZHairButton.h"


@class EZDisplayPhoto;
@class EZShapeCover;
@class EZPerson;
@class EZTrianglerView;
@interface EZAlbumTablePage : UIViewController<DLCImagePickerDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray* combinedPhotos;

//The photo not splitted yet.
//So the startPage will based on this list
//So I can get the correct photo back.
@property (nonatomic, strong) NSMutableArray* nonsplitted;

//@property (nonatomic, strong) UISwipeGestureRecognize


-(id)initWithQueryBlock:(EZQueryBlock)queryBlock;

- (void) addPhoto:(EZDisplayPhoto*)photo;
//It is not necessarilly the current user.
//So I need to compare it.

//Whether to show the hidden button or not.
@property (nonatomic, assign) BOOL showHiddenButton;

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) UIRefreshControl* refreshControl;

@property (nonatomic, strong) EZPerson* currentUser;
@property (nonatomic, strong) UILabel* totalEntries;
@property (nonatomic, strong) UILabel* monthCount;
@property (nonatomic, strong) UILabel* weekCount;
@property (nonatomic, strong) UILabel* dailyCount;
@property (nonatomic, strong) UIView* container;
@property (nonatomic, strong) UIProgressView* progressBar;

@property (nonatomic, strong) EZTrianglerView* triangler;

@property (nonatomic, assign) BOOL notFirstTime;

@property (nonatomic, assign) UIEdgeInsets prevInsets;

@property (nonatomic, strong) UIView* anotherView;

@property (nonatomic, strong) EZShapeCover* shapeCover;

//Sign
@property (nonatomic, strong) UIView* signRegion;

@property (nonatomic, strong) UILabel* numberLabel;

@property (nonatomic, assign) BOOL animStarted;

@property (nonatomic, assign) BOOL showShapeCover;

@property (nonatomic, assign) CGFloat menuHeight;

@property (nonatomic, strong) UIView* menuView;

@property (nonatomic, strong) SlideAnimation* slideAnimation;

@property (nonatomic, strong) EZModalRaiseAnimation* cameraAnimation;

@property (nonatomic, strong) EZModalDissolveAnimation* detailAnimation;

@property (nonatomic, strong) EZRaiseAnimation* raiseAnimation;

@property (nonatomic, assign) BOOL isPushCamera;

@property (nonatomic, strong) EZCameraNaviAnimation* cameraNaviAnim;
//This is a successful pattern I have explored several years ago.
@property (nonatomic, strong) EZQueryBlock queryBlock;

//either user are dragging or the tableview is scrolling,
//This scrolling is true.
@property (nonatomic, assign) BOOL isScrolling;

@property (nonatomic, strong) EZEventBlock cameraClicked;

@property (nonatomic, strong) EZEventBlock alertClicked;

@property (nonatomic, strong) UIButton* moreButton;

@property (nonatomic, strong) DLCImagePickerController* picker;

//How many photos are taken.
@property (nonatomic, assign) int newlyCreated;

@property (nonatomic, strong) EZPhoto* observedTarget;

@property (nonatomic, assign) BOOL isLoadingMoreData;

@property (nonatomic, assign) BOOL isFirstCompleted;

@property (nonatomic, strong) id holder;

@property (nonatomic, strong) NSMutableArray* selfBackup;

@property (nonatomic, strong) EZEventBlock menuClicked;

@property (nonatomic, assign) BOOL alreadyExecuted;

@property (nonatomic, strong) UIView* leftContainer;

@property (nonatomic, strong) EZClickView* leftCyleButton;

@property (nonatomic, strong) UILabel* leftText;

@property (nonatomic, strong) UIView* leftMessageCount;

@property (nonatomic, strong) EZHairButton* rightCycleButton;

@property (nonatomic, strong) UILabel* networkStatus;

@property (nonatomic, assign) int totalCount;

//How many photos are just place holder
@property (nonatomic, assign) int fillCount;


@property (nonatomic, assign) int newMessageCount;
//@property (nonatomic, strong) NSMutableArray* unhandledNotes;

- (void) storeCurrent;
//Where do we begin
//It used to save the memory consumption
- (void) raiseCamera:(EZDisplayPhoto*)photo indexPath:(NSIndexPath*)indexPath;

- (void) raiseCamera:(EZDisplayPhoto*)disPhoto indexPath:(NSIndexPath*)indexPath personID:(NSString*)personID;

- (void) refreshVisibleCell;

@end
