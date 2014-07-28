//
//  EZRecordMain.h
//  BabyCare
//
//  Created by xietian on 14-7-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    kInputMode,
    kAdjustSetting
} EZOperationMode;

@interface EZRecordMain : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>//UICollectionViewController

@property (nonatomic, strong) NSArray* descs;

@property (nonatomic, strong) NSArray* recorders;

@property (nonatomic, strong) UICollectionView* collectionView;

@property (nonatomic, strong) UILabel* dateLabel;

@property (nonatomic, assign) EZOperationMode mode;

@property (nonatomic, assign) NSInteger selectedCount;

- (EZRecordMain*) initPage:(NSArray*)arr records:(NSArray*)record mode:(EZOperationMode)mode;



@end
