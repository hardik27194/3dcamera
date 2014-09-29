//
//  EZSignView.h
//  3DCamera
//
//  Created by xietian on 14-9-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kPauseSign,
    kPlaySign,
    kStopSign
} EZSignType;

@interface EZSignView : UIView

@property (nonatomic, assign) EZSignType signType;

@property (nonatomic, strong) UIView* signView;

@end
