//
//  EZToolStripe.h
//  FeatherCV
//
//  Created by xietian on 14-7-7.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZInfoButton;
@interface EZToolStripe : UIView

//Which category get choosing?
@property (nonatomic, assign) NSInteger currentPos;

@property (nonatomic, strong) EZEventBlock clicked;

@property (nonatomic, strong) NSArray* infoButtons;

//@property (nonatomic)

//@property (nonatomic, assign) NSInteger currentPos;

@end
