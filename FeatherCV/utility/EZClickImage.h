//
//  EZClickImage.h
//  ShowHair
//
//  Created by xietian on 13-3-24.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZConstants.h"
@interface EZClickImage : UIImageView

@property (nonatomic, strong) EZEventBlock pressedBlock;

@property (nonatomic, strong) EZEventBlock releasedBlock;

@property (nonatomic, strong) UIImage* backupImage;

@property (nonatomic, assign) BOOL enableTouchEffects;

@end
