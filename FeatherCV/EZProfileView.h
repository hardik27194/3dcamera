//
//  EZProfileView.h
//  FeatherCV
//
//  Created by xietian on 14-7-7.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZToolStripe;
@interface EZProfileView : UIView

//Following method will be used
@property (nonatomic, assign) EZContactDisplayType displayType;
@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) UITextField* name;
@property (nonatomic, strong) UITextField* signature;
@property (nonatomic, strong) UILabel* touchCount;
@property (nonatomic, strong) UIImageView* touchIcon;
@property (nonatomic, strong) EZClickImage* headIcon;
@property (nonatomic, strong) EZToolStripe* toolStripe;

@end
