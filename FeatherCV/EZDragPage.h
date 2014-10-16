//
//  EZDragPage.h
//  3DCamera
//
//  Created by xietian on 14-8-30.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RACollectionViewReorderableTripletLayout.h"

@class EZShotTask;
//@class RACollectionViewReorderableTripletLayout
@interface EZDragPage : UIViewController <RACollectionViewDelegateReorderableTripletLayout, RACollectionViewReorderableTripletLayoutDataSource>

//@property (nonatomic, strong) RACollectionViewReorderableTripletLayout* layout;

@property (nonatomic, strong) NSMutableArray* storedPhotos;

@property (nonatomic, assign) BOOL isEditMode;

@property (nonatomic, strong) EZShotTask* task;

@property (nonatomic, strong) RACollectionViewReorderableTripletLayout* cellLayout;

@property (nonatomic, strong) EZEventBlock confirmClicked;

@property (nonatomic, strong) EZEventBlock addClicked;

@property (nonatomic, strong) UIButton* titleChangeBtn;

@property (nonatomic, weak) UICollectionView* collectionView;

@property (nonatomic, assign) BOOL isDragMode;

//@property (nonatomic, strong) UIButton* delBtn;
- (id) initWithTask:(EZShotTask*)task mode:(BOOL)isEditMode;
@end
