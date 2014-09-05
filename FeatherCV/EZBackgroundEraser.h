//
//  EZBackgroundEraser.h
//  3DCamera
//
//  Created by xietian on 14-9-4.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

struct EZGrabHandler;
@interface EZBackgroundEraser : UIView{
    //EZGrabCut* gradCut;
    struct EZGrabHandler* grabHandler;
}

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image;

@property (nonatomic, strong) UIImageView* imageView;

@property (nonatomic, strong) UIImage* orgImage;

@property (nonatomic, strong) UIImage* curImage;

@property (nonatomic, assign) EZSelectStatus selectStatus;

@property (nonatomic, strong) UIView* selectRegion;

@property (nonatomic, assign) BOOL effectiveTouch;

@property (nonatomic, assign) CGPoint touchBegin;

@property (nonatomic, strong) UIView* horizonBar;

@property (nonatomic, strong) UIView* verticalBar;

@end
