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
#import "EZFaceResultObj.h"
#import "EZSharpenGaussianNormal.h"

@class EZClickImage;
@class EZHairButton;

typedef enum {
    kNormalMode,
    kSelfShotMode,
    kQuickShotMode
} EZShotMode;


typedef enum {
    kTakingPhoto,
    kStoredPhoto,
    kTakedPhoto,
    kMatchAgain,
} EZFlipStatus;

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
    
    //When the face detected after turned the camera
    kFaceCaptured,
    kSelfCaptured,
    kSelfCapturedAgain,
    //Only do the turn for the self captured.
    kNormalCaptured
} EZCameraTurnStatus;


typedef enum {
    kCoverInit,
    kCoverStart,
    kCoverCancelled,
    kCoverShotting
}EZCoverStatus;

typedef enum {
    kInitialUploading,
    kUploading,
    kUploadingSuccess,
    kUploadingFailure
}EZUploadingStatus;

@class EZUpArrow;
@class EZPhoto;
@class EZDisplayPhoto;
@class DLCImagePickerController;
@class EZEnlargedView;

@protocol DLCImagePickerDelegate <NSObject>
@optional

//This method will get called when user take a image.
- (void)takePicture:(DLCImagePickerController*)picker imageInfo:(NSDictionary*)info;
- (void)imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(DLCImagePickerController *)picker imageCount:(int)imageCount;
@end

@interface DLCImagePickerController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>


//The job front camera will have to do. 
@property (nonatomic, strong) EZEventBlock frontCameraCompleted;

@property (nonatomic, assign) EZCameraTurnStatus turnStatus;
@property (nonatomic, strong) IBOutlet GPUImageView *imageView;
@property (nonatomic, weak) id <DLCImagePickerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UISlider* redPoint;
@property (nonatomic, weak) IBOutlet UISlider* yellowPoint;
@property (nonatomic, weak) IBOutlet UISlider* bluePoint;
@property (nonatomic, weak) IBOutlet UISlider* redGap;
@property (nonatomic, weak) IBOutlet UISlider* blueGap;
@property (nonatomic, weak) IBOutlet UILabel* redText;
@property (nonatomic, weak) IBOutlet UILabel* yellowText;
@property (nonatomic, weak) IBOutlet UILabel* blueText;
@property (nonatomic, weak) IBOutlet UILabel* redGapText;
@property (nonatomic, weak) IBOutlet UILabel* blueGapText;
@property (nonatomic, weak) IBOutlet UIButton *photoCaptureButton;
@property (nonatomic, strong) UILabel* instrTitle;


@property (nonatomic, strong) EZUpArrow* upArrow;

@property (nonatomic, strong) EZEnlargedView* quitCrossButton;

@property (nonatomic, strong) EZEventBlock quitBlock;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *configButton;

@property (nonatomic, weak) IBOutlet UIButton *cameraToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *blurToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *filtersToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *libraryToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *flashToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *retakeButton;
@property (nonatomic, strong) EZEventBlock captureComplete;

@property (nonatomic, weak) IBOutlet UIScrollView *filterScrollView;
@property (nonatomic, weak) IBOutlet UIImageView *filtersBackgroundImageView;
@property (nonatomic, weak) IBOutlet UIView *photoBar;

@property (nonatomic, assign) EZUploadingStatus uploadStatus;

@property (nonatomic, strong) EZEventBlock uploadSuccessBlock;

@property (nonatomic, strong) EZEventBlock uploadFailureBlock;

@property (nonatomic, strong) UIButton* upperCancel;

//The place which will hold all the tool bar
@property (nonatomic, strong) UIView* toolBarRegion;

@property (nonatomic, strong) UIView* toolBarNewRegion;


@property (nonatomic, weak) IBOutlet UIView *topBar;
//This view act as a flash for the self shot camera.
@property (nonatomic, strong) UIView* flashView;

//@property (nonatomic, strong) DLCBlurOverlayView *blurOverlayView;
@property (nonatomic, strong) UIImageView *focusView;

//@property (nonatomic, strong) UIImageView *rotateView;

@property (nonatomic, strong) UIView* cycleView;

@property (nonatomic, assign) CGFloat outputJPEGQuality;
@property (nonatomic, assign) CGSize requestedImageSize;
@property (nonatomic, assign) BOOL senseRotate;
//If the image have saved
@property (nonatomic, assign) BOOL isSaved;

@property (nonatomic, assign) BOOL isUploading;

@property (nonatomic, strong) EZSoundEffect* pageTurn;
@property (nonatomic, strong) EZSoundEffect* shotReady;
@property (nonatomic, strong) EZSoundEffect* shotVoice;
//@property (nonatomic, strong) EZDisplayPhoto* disPhoto;

@property (nonatomic, strong) NSMutableArray* storedMotionDelta;
@property (nonatomic, assign) BOOL quitFaceDetection;
@property (nonatomic, assign) EZShotMode shotMode;
@property (nonatomic, strong) UIProgressView* progressView;

@property (nonatomic, assign) int imageCount;
@property (nonatomic, assign) EZFlipStatus flipStatus;

@property (nonatomic, strong) EZClickImage* otherIcon;

//I will need this flag to check if the image is showing our self or not.
@property (nonatomic, assign) BOOL showOther;

@property (nonatomic, strong) UIImage* otherImage;
//@property (nonatomic, strong) EZPhoto* matchedPhoto;
//The purpose is to carry all the remote operation result
@property (nonatomic, strong) EZPhoto* shotPhoto;

@property (nonatomic, assign) BOOL isPhotoRequest;

@property (nonatomic, strong) EZEventBlock refreshTable;

@property (nonatomic, strong) UIButton* backButton;

//Keep this photo for input text
@property (nonatomic, strong) EZDisplayPhoto* savedPhoto;

//The status machine to coordinate the action of the hand
@property (nonatomic, assign) EZCoverStatus coverStatus;

//@property (nonatomic, assign) EZEventBlock longCoverTmp;

@property (nonatomic, strong) EZEventBlock longCover;

@property (nonatomic, strong) EZClickView* coverTapView;

@property (nonatomic, strong) EZClickView* shotButton;

@property (nonatomic, assign) BOOL cancelShot;

@property (nonatomic, strong) UIBarButtonItem* leftBarButton;
//0 mean off
//1 mean on
//2 mean auto
@property (nonatomic, assign) int flashMode;

//What's the purpose of this method?
//The purpose is to make sure if we are using the automatic shot or not.
//If it is, we will switch back to front facing.
@property (nonatomic, assign) BOOL selfShot;
//If current camera point forward
@property (nonatomic, assign) BOOL isFrontCamera;

@property (nonatomic, assign) BOOL isVisible;

@property (nonatomic, strong) EZClickImage* authorIcon;

//This is the image which shot with torch, I will render it with torch filter
@property (nonatomic, assign) BOOL isImageWithFlash;

//Whether detect face in live or not
@property (nonatomic, assign) BOOL detectFace;

//While I am detecting the face
@property (nonatomic, assign) BOOL detectingFace;

@property (nonatomic, assign) BOOL increasedLine;

@property (nonatomic, strong) UIImageView* faceCaptureTest;

@property (nonatomic, strong) NSString* highResImageFile;

@property (nonatomic, strong) EZFaceResultObj* detectedFaceObj;

@property (nonatomic, assign) CGSize imageSize;

@property (nonatomic, assign) CGPoint prevFocusPoint;

@property (nonatomic, assign) BOOL frontFacing;

@property (nonatomic, assign) BOOL disableFaceBeautify;

//Will pervent the duoble click from happening.
@property (nonatomic, assign) BOOL takingPhoto;

@property (nonatomic, assign) CGFloat centerButtonY;
@property (nonatomic, assign) CGFloat buttonRegionY;
@property (nonatomic, assign) CGFloat textFieldY;

@property (nonatomic, assign) CGSize cameraAspectSize;

@property (nonatomic, strong) UITextField* textField;
@property (nonatomic, strong) UILabel* textPlaceHolder;

@property (nonatomic, strong) EZDisplayPhoto* disPhoto;

@property (nonatomic, strong) EZSharpenGaussianNormal* sharpenGaussian;

@property (nonatomic, strong) EZEventBlock oldPressBlock;
@property (nonatomic, strong) EZEventBlock oldReleaseBlock;

//This is a flag determine that if we hide the text or not
@property (nonatomic, assign) BOOL hideTextInput;
//The flip animation
@property (nonatomic, assign) BOOL turnedImage;

@property (nonatomic, assign) BOOL firstTime;

@property (nonatomic, assign) NSString* personID;

@property (nonatomic, weak) IBOutlet UIView* cameraRotateContainer;
//This method will change the turnStatus
- (void) captureTurnedImage;
-(void) becomeVisible:(BOOL)isFront;
- (void) becomeInvisible;

-(IBAction) switchCamera;

- (IBAction) slideChanged:(id)sender;

- (IBAction) changeColor:(id)sender;

- (IBAction) panHandler:(id)sender;

- (IBAction) configClicked:(id)sender;



- (id) initWithFront:(BOOL)frontFacing;

@end
