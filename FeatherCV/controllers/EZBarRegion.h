//
//  EZBarRegion.h
//  FeatherCV
//
//  Created by xietian on 14-2-13.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "EZClickImage.h"

@interface EZBarRegion : UIView

//Used to toggle between lock and unlock status
@property (nonatomic, strong) UIButton* unlockButton;

@property (nonatomic, strong) EZClickImage* selfIcon;

@property (nonatomic, strong) EZClickImage* otherIcon;

@property (nonatomic, strong) UILabel* location;

@property (nonatomic, strong) UILabel* time;

@property (nonatomic, strong) EZEventBlock buttonClicked;


@end
