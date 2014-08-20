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


typedef enum {
    kShotMultiple,
    kShotSingle
}EZCameraShotMode;

typedef enum {
    kShotInit, //When paused and have no images. for handy tools, I need to make it very fast to edit staff
    kShotPaused,//When would this happen, when user paused for adjust angle
    kShotting
}EZCameraShotStatus;

typedef enum {
    kNormalShotTask,
    kShotToReplace
}EZShotTaskType;


@class RBVolumeButtons;
@class EZSoundEffect;
@interface SCCaptureCameraController : UIViewController
@property (nonatomic, assign) CGRect previewRect;
@property (nonatomic, assign) BOOL isStatusBarHiddenBeforeShowCamera;
@property (nonatomic, strong) UILabel* shotText;
@property (nonatomic, strong) UILabel* statusText;
@property (nonatomic, assign) NSInteger proposedNumber;
@property (nonatomic, assign) NSInteger currentCount;
@property (nonatomic, strong) UIImageView* shotImages;

@property (nonatomic, assign) BOOL areCapturing;
@property (nonatomic, assign) EZCameraShotStatus shotStatus;
@property (nonatomic, assign) EZShotTaskType shotType;
@property (nonatomic, strong) EZStoredPhoto* photo;
@property (nonatomic, strong) EZShotTask* shotTask;
@property (nonatomic, strong) UIButton* confirmButton;
@property (nonatomic, strong) EZSoundEffect* shotPrepareVoice;
@property (nonatomic, strong) RBVolumeButtons* buttonStealer;

@property (nonatomic, strong) EZEventBlock confirmClicked;

//@property (nonatomic, strong) UIButton* confirmButton;


@end
