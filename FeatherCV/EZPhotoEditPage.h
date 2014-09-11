//
//  EZPhotoEditPage.h
//  3DCamera
//
//  Created by xietian on 14-8-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>


#define FlexibleItemBar [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]
@class EZShotTask;
@class EZStoredPhoto;
@class EZInfoDotView;
@class EZPhotoInfo;
@interface EZPhotoEditPage : UIViewController<UIAlertViewDelegate>

@property (nonatomic, strong) UIImageView* imageView;

@property (nonatomic, strong) UILabel* posText;

@property (nonatomic, strong) UIView* toolBar;

@property (nonatomic, strong) UIButton* deleteBtn;

@property (nonatomic, strong) UIButton* titleButton;

@property (nonatomic, strong) UIButton* replaceBtn;

@property (nonatomic, strong) UIButton* adjustSequence;

@property (nonatomic, strong) UIButton* addButton;

@property (nonatomic, assign) CGFloat prevX;

@property (nonatomic, assign) CGPoint touchBegin;

//@property (nonatomic, strong) EZS
@property (nonatomic, assign) NSInteger currentPos;

@property (nonatomic, strong) NSMutableArray* photos;

@property (nonatomic, strong) EZShotTask* task;

@property (nonatomic, strong) EZPhotoInfo* photoInfo;

@property (nonatomic, strong) UIAlertView* deleteAlert;

@property (nonatomic, assign) BOOL showShot;

@property (nonatomic, strong) EZEventBlock deletedClicked;

@property (nonatomic, weak) UIView* pointCover;

@property (nonatomic, weak) EZInfoDotView* dotView;

@property (nonatomic, strong) NSMutableArray* dotViews;

- (id) initWithTask:(EZShotTask*)tasks pos:(NSInteger)pos;

- (id) initWithShot:(NSArray*)photos pos:(NSInteger)pos deletedBlock:(EZEventBlock)deletedBlock;

@end
