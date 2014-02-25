//
//  EZUIUtility.h
//  Feather
//
//  Created by xietian on 13-10-15.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZAppConstants.h"
#import "EZClickView.h"
//#import "DLCImagePickerController.h"



//Put UI related functionality here
//@class EZClickView;
@interface EZUIUtility : NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) BOOL cameraRaised;

@property (nonatomic, assign) BOOL stopRotationRaise;

//The trigger by slide will affect whether I will use the turning functionality or not.
@property (nonatomic, assign) BOOL triggerBySlide;

@property (nonatomic, strong) EZEventBlock completed;

@property (nonatomic, strong) NSMutableArray* showMenuItems;

@property (nonatomic, weak) UIWindow* mainWindow;

//each time camera Click Button is visible, I will add my own process
@property (nonatomic, strong) EZClickView* cameraClickButton;

@property (nonatomic, strong) NSArray* colors;

//This method will get called by the EZClickView.
//If pass nil mean pick color randomly.
- (UIColor*) getBackgroundColor:(UIColor*)color;

- (void) raiseCamera:(BOOL)isAlbum controller:(UIViewController*)controller completed:(EZEventBlock)block;

//This window will be disappear after some time
- (void) raiseInfoWindow:(NSString*)title info:(NSString*)info;

- (UIImagePickerController*) getCamera:(BOOL)isAlbum slide:(BOOL)slide completed:(EZEventBlock)block;

//Why do I use this?
//I want to get the controller to present my modal view.
+ (UIViewController*) topMostController;
//+ (EZUIUtility*) getInstance;
SINGLETON_FOR_HEADER(EZUIUtility);

@end
