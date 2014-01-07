//
//  DLCImagePickerController.h
//  DLCImagePickerController
//
//  Created by Dmitri Cherniak on 8/14/12.
//  Copyright (c) 2012 Dmitri Cherniak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "DLCBlurOverlayView.h"
#import "EZSoundEffect.h"

typedef enum {
    //This is the initial status
    kCameraNormal,
    //Detect a half turn, we will have another time count
    kCameraHalfTurn,
    //Will not do anything during this period
    //Turned Dormant
    kCameraTurnDormant,
    
    //
    kSelfShotDormant,
    kSelfShot,
    //Mean I am in the turned status
    kCameraCapturing,
    kSelfCaptured,
    kSelfCapturedAgain,
    //Only do the turn for the self captured.
    kNormalCaptured
} EZCameraTurnStatus;

@class DLCImagePickerController;

@protocol DLCImagePickerDelegate <NSObject>
@optional

//This method will get called when user take a image.
- (void)takePicture:(DLCImagePickerController*)picker imageInfo:(NSDictionary*)info;
- (void)imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(DLCImagePickerController *)picker;
@end

@interface DLCImagePickerController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate> 


//The job front camera will have to do. 
@property (nonatomic, strong) EZEventBlock frontCameraCompleted;

@property (nonatomic, assign) EZCameraTurnStatus turnStatus;
@property (nonatomic, weak) IBOutlet GPUImageView *imageView;
@property (nonatomic, weak) id <DLCImagePickerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UISlider* blurSize;
@property (nonatomic, weak) IBOutlet UISlider* blurRate;
@property (nonatomic, weak) IBOutlet UILabel* blurSizeText;
@property (nonatomic, weak) IBOutlet UILabel* blurRateText;



@property (nonatomic, weak) IBOutlet UIButton *photoCaptureButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;

@property (nonatomic, weak) IBOutlet UIButton *cameraToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *blurToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *filtersToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *libraryToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *flashToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *retakeButton;


@property (nonatomic, weak) IBOutlet UIScrollView *filterScrollView;
@property (nonatomic, weak) IBOutlet UIImageView *filtersBackgroundImageView;
@property (nonatomic, weak) IBOutlet UIView *photoBar;
@property (nonatomic, weak) IBOutlet UIView *topBar;
//This view act as a flash for the self shot camera.
@property (nonatomic, strong) UIView* flashView;

@property (nonatomic, strong) DLCBlurOverlayView *blurOverlayView;
@property (nonatomic, strong) UIImageView *focusView;

@property (nonatomic, assign) CGFloat outputJPEGQuality;
@property (nonatomic, assign) CGSize requestedImageSize;
@property (nonatomic, assign) BOOL senseRotate;

@property (nonatomic, strong) EZSoundEffect* pageTurn;
@property (nonatomic, strong) EZSoundEffect* shotReady;
@property (nonatomic, strong) EZSoundEffect* shotVoice;

@property (nonatomic, strong) NSMutableArray* storedMotionDelta;

//What's the purpose of this method?
//The purpose is to make sure if we are using the automatic shot or not.
//If it is, we will switch back to front facing.
@property (nonatomic, assign) BOOL selfShot;

//If current camera point forward
@property (nonatomic, assign) BOOL isFrontCamera;

@property (nonatomic, assign) BOOL isVisible;

//This is the image which shot with torch, I will render it with torch filter
@property (nonatomic, assign) BOOL isImageWithFlash;


//This method will change the turnStatus
- (void) captureTurnedImage;

-(void) becomeVisible:(BOOL)isFront;
- (void) becomeInvisible;

- (IBAction) slideChanged:(id)sender;

- (IBAction) changeColor:(id)sender;

@end
