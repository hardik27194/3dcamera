//
//  EZHairButton.h
//  FeatherCV
//
//  Created by xietian on 14-4-4.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZClickImage.h"

@interface EZHairButton : EZClickImage

@property (nonatomic, strong) UIView* horizon;

@property (nonatomic, strong) UIView* vertical;

- (void) setButtonStyle:(BOOL)isSelf;

@end
