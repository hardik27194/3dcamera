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
@interface EZDragPage : UIViewController <RACollectionViewDelegateReorderableTripletLayout, RACollectionViewReorderableTripletLayoutDataSource>

//@property (nonatomic, strong) RACollectionViewReorderableTripletLayout* layout;

@property (nonatomic, strong) NSMutableArray* storedPhotos;

@property (nonatomic, strong) EZShotTask* task;

@property (nonatomic, strong) EZEventBlock confirmClicked;

//@property (nonatomic, strong) UIButton* delBtn;
- (id) initWithTask:(EZShotTask*)task;
@end
