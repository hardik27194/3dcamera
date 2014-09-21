//
//  EZEraserPage.h
//  3DCamera
//
//  Created by xietian on 14-9-19.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZBackgroundEraser;
@class EZStoredPhoto;

@interface EZEraserPage : UIViewController

@property (nonatomic, strong) EZBackgroundEraser* eraserView;

@property (nonatomic, strong) UIImage* orgImage;
@property (nonatomic, strong) EZStoredPhoto* photo;

@property (nonatomic, strong) EZEventBlock confirmed;

//- (id) initWithImage:(UIImage*)img;
- (id) initWithPhoto:(EZStoredPhoto*)photo orgImage:(UIImage*)img;

@end
