//
//  EZSimpleClick.h
//  FeatherCV
//
//  Created by xietian on 14-2-24.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZSimpleClick : UIImageView

@property (nonatomic, strong) EZEventBlock tappedBlock;

@property (nonatomic, strong) EZEventBlock longPressed;

@end
