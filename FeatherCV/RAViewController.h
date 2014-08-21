//
//  RAViewController.h
//  RACollectionViewTripletLayout-Demo
//
//  Created by Ryo Aoyama on 5/25/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RACollectionViewReorderableTripletLayout.h"

@class EZShotTask;
@interface RAViewController : UIViewController <RACollectionViewDelegateReorderableTripletLayout, RACollectionViewReorderableTripletLayoutDataSource>

//@property (nonatomic, strong) RACollectionViewReorderableTripletLayout* layout;

@property (nonatomic, strong) NSMutableArray* storedPhotos;

@property (nonatomic, strong) EZShotTask* task;

@property (nonatomic, strong) EZEventBlock confirmClicked;

//@property (nonatomic, strong) UIButton* delBtn;
- (id) initWithTask:(EZShotTask*)task;

@end
