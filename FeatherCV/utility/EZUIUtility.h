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
#import <MessageUI/MessageUI.h>
#import "EZPinchController.h"

@class EZShapeCover;
@class EZClickImage;
@class EZHairButton;
//Put UI related functionality here
//@class EZClickView;
@interface EZUIUtility : NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) EZPinchController* pinchControl;
@property (nonatomic, assign) BOOL cameraRaised;

@property (nonatomic, assign) BOOL stopRotationRaise;

//The trigger by slide will affect whether I will use the turning functionality or not.
@property (nonatomic, assign) BOOL triggerBySlide;

@property (nonatomic, strong) EZEventBlock completed;

@property (nonatomic, strong) EZEventBlock messageCompletion;

@property (nonatomic, strong) EZEventBlock messageQuit;

@property (nonatomic, strong) NSMutableArray* showMenuItems;

@property (nonatomic, weak) UIWindow* mainWindow;

//each time camera Click Button is visible, I will add my own process
@property (nonatomic, strong) EZClickView* cameraClickButton;

@property (nonatomic, strong) NSArray* colors;

@property (nonatomic, strong) UIImage* fullHeart;

@property (nonatomic, strong) UIImage* emptyHeart;

@property (nonatomic, strong) UIImage* leftHeart;

@property (nonatomic, strong) UIImage* rightHeart;

@property (nonatomic, strong) UIImage* pressedHeart;

//This method will get called by the EZClickView.
//If pass nil mean pick color randomly.
- (UIColor*) getBackgroundColor:(UIColor*)color;


- (EZShapeCover*) createHoleView;

//This window will be disappear after some time
- (void) raiseInfoWindow:(NSString*)title info:(NSString*)info;

- (void) showErrorInfo:(NSString*)errorInfo delay:(CGFloat)delay view:(UIView*)view;

- (UIImagePickerController*) getCamera:(BOOL)isAlbum slide:(BOOL)slide completed:(EZEventBlock)block;

- (void) raiseCamera:(BOOL)isAlbum controller:(UIViewController *)controller completed:(EZEventBlock)block allowEditing:(BOOL)allowEditing;

- (void) sendMessge:(NSString*)phone content:(NSString*)content presenter:(UIViewController*)presenter completed:(EZEventBlock)completed;

- (void) enableProximate:(BOOL)enable;

- (UILabel*) createNumberLabel;

- (EZHairButton*) createShotButton;

- (UIButton*) createHeartButton:(EZFilterType)filterType;

- (EZClickImage*) createLargeShotButton;

- (EZClickImage*) createBackShotButton;

- (UIView*) createGradientView;
//Why do I use this?
//I want to get the controller to present my modal view.
+ (UIViewController*) topMostController;

+ (void) adjustFontSizeToFillItsContents:(UITextView*)textView miniFont:(int)miniFont maxFont:(int)maxFont;

+ (void) verticalCentering:(UITextView*)textView height:(CGFloat)actualHeight;
//+ (EZUIUtility*) getInstance;
SINGLETON_FOR_HEADER(EZUIUtility);

@end
