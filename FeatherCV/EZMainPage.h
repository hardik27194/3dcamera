//
//  EZMainPage.h
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DLCImagePickerController.h"

@class EZScrollerView;
@interface EZMainPage : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate>//UICollectionViewController

- (EZMainPage*) initPage:(NSArray*)arr;

@property (nonatomic, strong) UICollectionViewFlowLayout* layout;

@property (nonatomic, strong) NSMutableArray* uploadedPhotos;

@property (nonatomic, strong) UICollectionView* collectionView;

@property (nonatomic, strong) UILabel* dateLabel;

@property (nonatomic, assign) NSInteger selectedCount;

@property (nonatomic, strong) NSDate* date;

//@property (nonatomic, strong) NSMutableArray* uploadedPhotos;

@end
