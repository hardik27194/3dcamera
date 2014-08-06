//
//  SCCaptureCameraController.h
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-16.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCCaptureSessionManager.h"
#import "EZShotTask.h"
#import "EZStoredPhoto.h"

@interface SCCaptureCameraController : UIViewController
@property (nonatomic, assign) CGRect previewRect;
@property (nonatomic, assign) BOOL isStatusBarHiddenBeforeShowCamera;
@property (nonatomic, strong) UILabel* shotText;
@property (nonatomic, assign) NSInteger proposedNumber;
@property (nonatomic, assign) NSInteger currentCount;
@property (nonatomic, strong) UIImageView* shotImages;

@property (nonatomic, strong) EZShotTask* shotTask;
@property (nonatomic, strong) UIButton* confirmButton;

@end
