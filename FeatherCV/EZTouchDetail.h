//
//  EZTouchDetail.h
//  FeatherCV
//
//  Created by xietian on 14-7-13.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

//What's the purpose of this class?
//This class is show the touch detail
@class EZPerson;
@class EZLineDrawingView;
@class EZTouch;

@interface EZTouchDetail : UIViewController

@property (nonatomic, strong) UIImageView* imageDetail;
@property (nonatomic, strong) UIImageView* icon;
@property (nonatomic, strong) UIView* rotateContainer;
@property (nonatomic, strong) UILabel* touchName;
@property (nonatomic, strong) UILabel* touchTime;
@property (nonatomic, strong) UILabel* touchIndication;
@property (nonatomic, strong) EZLineDrawingView* drawView;
@property (nonatomic, strong) UIButton* backButton;

@property (nonatomic, strong) EZPerson* touchPerson;
@property (nonatomic, strong) EZTouch* touch;

@property (nonatomic, assign) BOOL showOtherTouch;

@end
