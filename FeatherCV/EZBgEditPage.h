//
//  EZBgEditPage.h
//  3DCamera
//
//  Created by xietian on 14-9-4.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

struct EZGrabHandler;
//@class EZBackgroundEraser;
@interface EZBgEditPage : UIViewController{
    //EZGrabCut* gradCut;
    struct EZGrabHandler* grabHandler;
}

@property (nonatomic, strong) UIView* toolBar;

@property (nonatomic, strong) UIImageView* imageView;

@property (nonatomic, strong) UIImage* orgImage;

@property (nonatomic, strong) UIImage* curImage;

@property (nonatomic, assign) EZSelectStatus selectStatus;

@property (nonatomic, strong) UIView* selectRegion;

@property (nonatomic, assign) BOOL effectiveTouch;

@property (nonatomic, assign) CGPoint touchBegin;

@property (nonatomic, strong) EZEventBlock confirmedBlock;


- (id) initWithImage:(UIImage*)image;

@end
