//
//  DLCImagePickerController.m
//  DLCImagePickerController
//
//  Created by Dmitri Cherniak on 8/14/12.
//  Copyright (c) 2012 Dmitri Cherniak. All rights reserved.
//

#import <GPUImagePrewittEdgeDetectionFilter.h>
#import <GPUImageSobelEdgeDetectionFilter.h>
#import <GPUImageThresholdEdgeDetectionFilter.h>
#import <GPUImageToneCurveFilter.h>

#import "DLCImagePickerController.h"
#import "DLCGrayscaleContrastFilter.h"
#import "EZFaceBlurFilter.h"
#import "EZFaceBlurFilter2.h"
#import "EZMotionUtility.h"
#import "EZSoundEffect.h"
#import "EZCycleDiminish.h"
#import "GPUImageHueFilter.h"
#import "EZNightBlurFilter.h"
#import "EZFaceUtilWrapper.h"
#import "EZFaceResultObj.h"
#import "EZSaturationFilter.h"
#import "EZHomeBiBlur.h"
#import "EZHomeGaussianFilter.h"
#import "EZHomeEdgeFilter.h"
#import "EZHomeBlendFilter.h"
#import "EZThreadUtility.h"
#import "EZDoubleOutFilter.h"
#import "EZFileUtil.h"
#import "EZUIUtility.h"
#import "EZColorBrighter.h"
#import "EZCycleTongFilter.h"

//#include <vector>

#define kStaticBlurSize 2.0f
@interface EZMotionRecord : NSObject 

@property (nonatomic, strong) CMAttitude* attitude;

@property (nonatomic, assign) CGFloat turnedAngle;

@property (nonatomic, strong) NSDate* currentTime;

@end

@implementation EZMotionRecord
@end


@implementation DLCImagePickerController {
    GPUImageStillCamera * stillCamera;
    GPUImageWhiteBalanceFilter* whiteBalancerFilter;
    //GPUImageSaturationFilter *contrastfilter;
    EZCycleTongFilter* tongFilter;
    GPUImageToneCurveFilter* flashFilter;
    //GPUImageToneCurveFilter* darkFilter;
    
    GPUImageHueFilter* hueFilter;
    GPUImageOutput<GPUImageInput> *blurFilter;
    GPUImageCropFilter *cropFilter;
    GPUImageFilter* simpleFilter;
    //EZCycleDiminish* cycleDarken;
    //EZFaceBlurFilter* faceBlurFilter;
    EZNightBlurFilter* darkBlurFilter;
    
    EZColorBrighter* redEnhanceFilter;
    
    //GPUImagePrewittEdgeDetectionFilter * edgeFilter;
    //EZFaceBlurFilter2* dynamicBlurFilter;
    //EZHomeGaussianFilter* biBlurFilter;
    EZHomeBlendFilter* finalBlendFilter;
    //Used as the beginning of the filter
    EZDoubleOutFilter* orgFiler;
    GPUImageFilter* filter;
    UIImageOrientation currentOrientation;
    EZSaturationFilter* fixColorFilter;
    EZSaturationFilter* secFixColorFilter;
    GPUImagePicture *staticPicture;
    NSMutableArray* tongParameters;
    NSMutableArray* redAdjustments;
    NSMutableArray* greenAdjustments;
    NSMutableArray* blueAdjustments;
    
    //For the edge detectors
    NSArray* edgeDectectors;
    NSArray* edgeDectectorNames;
    NSInteger currentEdge;
    
    //NSMutableArray* _recordedMotions;
    CMAttitude* _prevMotion;
    //The meta data for the photo
    NSDictionary* photoMeta;
    UIImageOrientation staticPictureOriginalOrientation;
    BOOL isStatic;
    BOOL hasBlur;
    int selectedFilter;
    CGFloat blurAspectRatio;
    CGFloat globalBlur;
    CGFloat faceBlurBase;
    CGFloat faceChangeGap;
    
    UIImageView* testView;
    UIImageView* testView2;
    dispatch_once_t showLibraryOnceToken;
    
    //The button will cancel image
    UIButton* cancelImage;
    
    EZClickView* smileDetected;
    UIImageView* blackView;
    UIView* blackCover;
    CGSize orgFocusSize;
}

@synthesize delegate,
    imageView,
    cameraToggleButton,
    photoCaptureButton,
    blurToggleButton,
    flashToggleButton,
    cancelButton,
    retakeButton,
    filtersToggleButton,
    libraryToggleButton,
    filterScrollView,
    filtersBackgroundImageView,
    photoBar,
    topBar,
    blurOverlayView,
    outputJPEGQuality,
    requestedImageSize;

-(void) sharedInit {
	outputJPEGQuality = 1.0;
	requestedImageSize = CGSizeZero;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self sharedInit];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self sharedInit];
	}
	return self;
}

-(id) init {
    return [self initWithNibName:@"DLCImagePicker" bundle:nil];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

//This method will change the turnStatus
//It will change the status to captured
- (void) captureTurnedImage
{
    _turnStatus = kSelfCaptured;
    _selfShot = true;
    [self captureImageInner:YES];
}

//Will adjust the blur level
- (IBAction) slideChanged:(id)sender
{
    [self adjustSlideValue:sender];
    [staticPicture processImage];
}

- (void) adjustLine
{
    CGFloat pixelSize = 0.0005;//MAX(0.05/50.00, 0.0005);
    _blueGapText.text = [NSString stringWithFormat:@"%f", _blueGap.value/500.0];
    EZDEBUG(@"calculate value:%f", pixelSize);
    CGFloat previousWidth = finalBlendFilter.edgeFilter.texelWidth;
    CGFloat previousHeight = finalBlendFilter.edgeFilter.texelHeight;
    
    if(previousHeight > previousWidth){
        double aspectRatio = previousHeight/previousWidth;
        finalBlendFilter.edgeFilter.texelHeight = aspectRatio * pixelSize;
        finalBlendFilter.edgeFilter.texelWidth = pixelSize;// _blueGap.value/500.0;
    }else{
        double aspectRatio = previousWidth/previousHeight;
        finalBlendFilter.edgeFilter.texelHeight = pixelSize;
        finalBlendFilter.edgeFilter.texelWidth = aspectRatio * pixelSize;// _blueGap.value/500.0;
        
    }
    EZDEBUG(@"previous %@, %@, current:%@, %@",[NSNumber numberWithDouble:previousWidth], [NSNumber numberWithDouble:previousHeight],[NSNumber numberWithDouble:finalBlendFilter.edgeFilter.texelWidth],[NSNumber numberWithDouble:finalBlendFilter.edgeFilter.texelHeight]
            );

}

- (void) adjustSlideValue:(id)sender
{
    
    //CGFloat rotateAngle = -180.0;
    //finalBlendFilter.blurFilter.distanceNormalizationFactor = 7.01;
    //finalBlendFilter.
    if(sender == _redPoint){
        
        //dynamicBlurFilter.realRatio = _blurRate.value;
        finalBlendFilter.blurFilter.blurSize = _redPoint.value*5;
        finalBlendFilter.smallBlurFilter.blurSize = blurAspectRatio * _redPoint.value * 5;
        _redText.text = [NSString stringWithFormat:@"%f",_redPoint.value * 5];
    }else if(sender == _yellowPoint){
        //finalBlendFilter.blurFilter.distanceNormalizationFactor = _yellowPoint.value * 50;
        _yellowText.text = [NSString stringWithFormat:@"%f", _yellowPoint.value * 50];
    }else if(sender == _bluePoint){
        //finalBlendFilter.smallBlurFilter.blurSize = _bluePoint.value;
        _blueText.text = [NSString stringWithFormat:@"%f",_bluePoint.value];
    }else if(sender == _redGap){
        //finalBlendFilter.blurRatio = _redGap.value;
        //finalBlendFilter.blurRatio = _redGap.value;
        //fixColorFilter.redRatio = _redGap.value;
        _redGapText.text = [NSString stringWithFormat:@"%f", _redGap.value];
    }else if(sender == _blueGap){
        //fixColorFilter.redEnhanceLevel = _blueGap.value;
        _blueGapText.text = [NSString stringWithFormat:@"%f", _blueGap.value*2.0];
        finalBlendFilter.edgeFilter.threshold = _blueGap.value * 2.0;
        /**
        CGFloat pixelSize = MAX(_blueGap.value/50.00, 0.0005);
        _blueGapText.text = [NSString stringWithFormat:@"%f", _blueGap.value/500.0];
        CGFloat previousWidth = finalBlendFilter.edgeFilter.texelWidth;
        CGFloat previousHeight = finalBlendFilter.edgeFilter.texelHeight;
        
        if(previousHeight > previousWidth){
            double aspectRatio = previousHeight/previousWidth;
            finalBlendFilter.edgeFilter.texelHeight = aspectRatio * pixelSize;
            finalBlendFilter.edgeFilter.texelWidth = pixelSize;// _blueGap.value/500.0;
        }else{
            double aspectRatio = previousWidth/previousHeight;
            finalBlendFilter.edgeFilter.texelHeight = pixelSize;
            finalBlendFilter.edgeFilter.texelWidth = aspectRatio * pixelSize;// _blueGap.value/500.0;

        }
        EZDEBUG(@"previous %@, %@, current:%@, %@",[NSNumber numberWithDouble:previousWidth], [NSNumber numberWithDouble:previousHeight],[NSNumber numberWithDouble:finalBlendFilter.edgeFilter.texelWidth],[NSNumber numberWithDouble:finalBlendFilter.edgeFilter.texelHeight]
                );
         **/
    }
    
}


//The flash filter will get setup here.
- (void) setupDarkFilter
{
    darkBlurFilter = [self createNightFilter];
}


- (EZNightBlurFilter*) createNightFilter
{
    EZNightBlurFilter* nightFt =  [[EZNightBlurFilter alloc] init];
    nightFt.blurSize = 1.5;
    nightFt.realRatio = 0.8;
    return nightFt;
}

- (GPUImageToneCurveFilter*) createFlashFilter
{
    GPUImageToneCurveFilter* flashFt = [[GPUImageToneCurveFilter alloc] init];
    [flashFt setRgbCompositeControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.273), pointValue(0.5, 0.524), pointValue(0.75, 0.774), pointValue(1.0, 1.0)]];
    [flashFt setRedControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.2615), pointValue(0.5, 0.512), pointValue(0.75, 0.762), pointValue(1, 1)]];
    [flashFt setGreenControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.186), pointValue(0.5, 0.436), pointValue(0.75, 0.654), pointValue(1, 1)]];
    [flashFt setBlueControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.253), pointValue(0.5, 0.5), pointValue(0.75, 0.8), pointValue(1, 1)]];
    return flashFt;
}

- (EZSaturationFilter*) createRedStretchFilter
{
    EZSaturationFilter* stretchFilter = [[EZSaturationFilter alloc] init];
    stretchFilter.lowRed = 30.4;
    stretchFilter.midYellow = -25.3;
    stretchFilter.highBlue = -85;
    stretchFilter.yellowRedDegree = 3.0;////4.6/2.0;
    stretchFilter.yellowBlueDegree = 0.0;//10.9/2.0;
    return stretchFilter;
}

- (EZSaturationFilter*) createBlueStretchFilter
{
    EZSaturationFilter* stretchFilter = [[EZSaturationFilter alloc] init];
    stretchFilter.lowRed = -130;
    stretchFilter.midYellow = -195;//old 185
    stretchFilter.highBlue = -245;
    stretchFilter.yellowRedDegree = 5.0;
    stretchFilter.yellowBlueDegree = 20.0;
    return stretchFilter;
}

- (EZHomeBlendFilter*) createFaceBlurFilter
{
    EZHomeBlendFilter* faceBlender = [[EZHomeBlendFilter alloc] init];
    blurAspectRatio = 0.20/3.0;
    globalBlur = 3.0;
    faceChangeGap = 2.8;
    faceBlurBase = 0.3;
    faceBlender.blurFilter.blurSize = globalBlur;//Original value
    faceBlender.blurFilter.distanceNormalizationFactor = 13;
    faceBlender.smallBlurFilter.blurSize = 0.05;
    faceBlender.blurRatio = 0.3;
    faceBlender.edgeFilter.threshold = 0.4;
    return faceBlender;
}

- (EZCycleTongFilter*) createTongFilter
{
    EZCycleTongFilter* resFilter = [[EZCycleTongFilter alloc] init];
    
    [resFilter setRgbCompositeControlPoints:@[pointValue(0.0, 0.0), pointValue(0.125, 0.120), pointValue(0.25, 0.25), pointValue(0.5, 0.5368), pointValue(0.75, 0.7775), pointValue(1.0, 1.0)]];
    [resFilter setRedControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.26), pointValue(0.5, 0.5), pointValue(0.75, 0.75), pointValue(1.0, 0.99)]];
    [resFilter setGreenControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.135), pointValue(0.25, 0.25), pointValue(0.5, 0.5), pointValue(0.75, 0.75), pointValue(1.0, 0.995)]];
    [resFilter setBlueControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.25), pointValue(0.5, 0.5), pointValue(0.75, 0.75), pointValue(1.0, 1.0)]];
    return resFilter;
}

- (EZColorBrighter*) createRedEnhanceFilter
{
    EZColorBrighter* res = [[EZColorBrighter alloc] init];
    res.redEnhanceLevel = 0.6;
    res.redRatio = 0.25;
    
    res.blueEnhanceLevel = 0.6;
    res.blueRatio = 0.4;
    return res;
}

- (void) setupFlashFilter
{
    flashFilter = [self createFlashFilter];
}


- (void) setupColorAdjust
{
    [_redPoint rotateAngle:-M_PI_2];
    [_bluePoint rotateAngle:-M_PI_2];
    [_yellowPoint rotateAngle:-M_PI_2];
    [_redGap rotateAngle:-M_PI_2];
    [_blueGap rotateAngle:-M_PI_2];
    _redPoint.value = 0.6;
    _yellowPoint.value = 0.12;
    _bluePoint.value = 0.2;
    _redGap.value = 0.1;
    _blueGap.value = 0.2;
   
    [self adjustSlideValue:_redPoint];
    [self adjustSlideValue:_yellowPoint];
    [self adjustSlideValue:_bluePoint];
    [self adjustSlideValue:_redGap];
    [self adjustSlideValue:_blueGap];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    EZDEBUG(@"DLCImage view really appear");
    __weak DLCImagePickerController* weakSelf = self;
    EZUIUtility.sharedEZUIUtility.cameraClickButton.pressedBlock = ^(id sender){
        [weakSelf takePhoto:nil];
    };
    _isVisible = TRUE;
    [self startMobileMotion];
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    //self.view.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    _senseRotate = true;
    //_recordedMotions = [[NSMutableArray alloc] init];
    _flashView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _flashView.backgroundColor = [UIColor whiteColor];
    [self setupFlashFilter];
    [self setupDarkFilter];
    _storedMotionDelta = [[NSMutableArray alloc] init];
    self.wantsFullScreenLayout = YES;
    _pageTurn = [[EZSoundEffect alloc] initWithSoundNamed:@"page_turn.aiff"];
    _shotReady = [[EZSoundEffect alloc] initWithSoundNamed:@"shot_voice.aiff"];
    _shotVoice = [[EZSoundEffect alloc] initWithSoundNamed:@"shot.wav"];
    
    //set background color
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"micro_carbon"]];
    
    self.photoBar.backgroundColor = [UIColor colorWithPatternImage:
                                     [UIImage imageNamed:@"photo_bar"]];
    
    self.topBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"photo_bar"]];
    //button states
    [self.blurToggleButton setSelected:NO];
    [self.filtersToggleButton setSelected:NO];
    
    staticPictureOriginalOrientation = UIImageOrientationUp;
    
    
    self.focusView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"focus-crosshair"]];
	[self.view addSubview:self.focusView];
	self.focusView.alpha = 0;
    orgFocusSize = self.focusView.frame.size;
    
    self.blurOverlayView = [[DLCBlurOverlayView alloc] initWithFrame:CGRectMake(0, 0,
																				self.imageView.frame.size.width,
																				self.imageView.frame.size.height)];
    self.blurOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.blurOverlayView.alpha = 0;
    [self.imageView addSubview:self.blurOverlayView];
    
    
    //No issue.
    
    hasBlur = NO;
    //we need a crop filter for the live video
    float widthAspect = [UIScreen mainScreen].bounds.size.width/[UIScreen mainScreen].bounds.size.height;
    EZDEBUG(@"The width aspect ratio is:%f", widthAspect);
    [self setupOtherFilters];
    [self setupTongFilter];

    
    imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    EZDEBUG(@"The imageView frame:%@", NSStringFromCGRect(imageView.frame));
    //[self setupEdgeDetector];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self setupCamera];
    });
    [self startFaceCapture];
    CGRect bound = [UIScreen mainScreen].bounds;
    
    
    cancelImage = [[UIButton alloc] initWithFrame:CGRectMake(30, bound.size.height - 75, 60, 50)];
    [cancelImage setTitle:@"取消" forState:UIControlStateNormal];
    //[cancelImage setAttributedTitle: forState:];
    cancelImage.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.view addSubview:cancelImage];
    cancelImage.hidden = YES;
    [cancelImage addTarget:self action:@selector(retakePhoto:) forControlEvents:UIControlEventTouchUpInside];
    _isFrontCamera = false;
    retakeButton = cancelImage;
    
    //UIView* barBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    //barBackground.backgroundColor = RGBCOLOR(255, 255, 128);
    //[self.view addSubview:barBackground];
    topBar.backgroundColor = RGBA(255, 255, 255, 128);
    
}

- (void) setupOtherFilters
{
    hueFilter = [[GPUImageHueFilter alloc] init];
    hueFilter.hue = 355;
    EZDEBUG(@"adjust:%f", hueFilter.hue);
    orgFiler = [[EZDoubleOutFilter alloc] init];
    //cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0f, 0.0f, 1.0, 0.75)];
    //edgeFilter = [[GPUImagePrewittEdgeDetectionFilter alloc] init];
    
    filter = [[GPUImageFilter alloc] init];
    secFixColorFilter = [self createBlueStretchFilter];
    //[secFixColorFilter updateAllConfigure];
    //[secFixColorFilter ]
    //secFixColorFilter.redEnhanceLevel = 0.6;
    fixColorFilter = [self createRedStretchFilter];
    //[fixColorFilter updateAllConfigure];
    //fixColorFilter.redEnhanceLevel = 0.6;
    redEnhanceFilter = [self createRedEnhanceFilter];
    finalBlendFilter = [self createFaceBlurFilter];
    //cycleDarken = [[EZCycleDiminish alloc] init];

    simpleFilter = [[GPUImageFilter alloc] init];
}

- (void) setupTongFilter
{
    tongFilter = [self createTongFilter];
}

- (void) clearMotionEffects:(EZMotionData*)md attr:(CMAttitude*)attr
{
    [md.storedMotion removeAllObjects];
    for(int i = 1; i < 51; i++){
        [md.storedMotion addObject:attr];
    }
}

//Get all the different sign.
- (CGFloat) getAllDifferentSign:(NSArray*)attrs current:(CGFloat)current limit:(int)limit
{
    CGFloat res = 0;
    for(int i = 2; i < MIN(limit, attrs.count); i++){
        CMAttitude* delta = [attrs objectAtIndex:attrs.count - i];
        if(delta.quaternion.y * current <= 0){
            res += delta.quaternion.y;
        }else{
            break;
        }
    }
    return res;
}

//I will obey this rule, only when I visible, it make sense to register the handle.
- (void) handleMobileMotion:(EZMotionData*)md
{
    //EZDEBUG(@"motion turn is main:%i", [NSThread currentThread].isMainThread);
    //CMAttitude* cur = md.currentMotion;
    if(!_prevMotion){
        _prevMotion = md.currentMotion;
        return;
    }
    
    CMAttitude* deltaMotion = [md.currentMotion copy];
    [deltaMotion multiplyByInverseOfAttitude:_prevMotion];
    _prevMotion = md.currentMotion;
    [_storedMotionDelta addObject:deltaMotion];
    if(_storedMotionDelta.count > 80){
        [_storedMotionDelta removeObjectAtIndex:0];
    }
    if(_storedMotionDelta.count < 2){
        return;
    }
    if(isStatic){
        return;
    }
    CMAttitude* prevDelta = [_storedMotionDelta objectAtIndex:_storedMotionDelta.count - 2];
    if(deltaMotion.quaternion.y*prevDelta.quaternion.y >= 0){
        //EZDEBUG(@"quit for prev delta:%f, current delta:%f", prevDelta.quaternion.y, deltaMotion.quaternion.y);
        return;
    }
    CGFloat totalDelta = [self getAllDifferentSign:_storedMotionDelta current:deltaMotion.quaternion.y limit:50];
    //EZDEBUG(@"Total delta is:%f", totalDelta);
    CGFloat absDelta = fabsf(totalDelta);
    if(_turnStatus == kCameraHalfTurn || _turnStatus == kSelfShotDormant){
        //EZDEBUG(@"switch to face shot:%i", _turnStatus);
        if(absDelta > 0.3){
            EZDEBUG(@"Will turn the camera, is front:%i", stillCamera.isFrontFacing);
            _turnStatus = kCameraNormal;
            //[self clearMotionEffects:md attr:md.currentMotion];
            /**
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
             EZDEBUG(@"Dormant is timeout");
             if(_turnStatus == kCameraTurnDormant){
             _turnStatus = kCameraNormal;
             }
             });
             **/
            //[md.storedMotion removeAllObjects];
            //if(!stillCamera.isFrontFacing){
            //[_pageTurn play];
            //[self switchCameraInner];
            return;
        }
    }
    if(absDelta > 0.95){
        EZDEBUG(@"Will rotate for %f, _turnStatus:%i", absDelta, _turnStatus);
        //[stillCamera rotateCamera];
        
        //[md.storedMotion removeAllObjects];
        //[self clearMotionEffects:md attr:md.currentMotion];
        //So we will just ignore the capturing?
        //User expecting have another action
        if(_turnStatus == kCameraNormal && stillCamera.isFrontFacing){
            EZDEBUG(@"I am in half turn now");
            //if(stillCamera.isFrontFacing){
            EZDEBUG(@"Will start capture now, isFront:%i", stillCamera.isFrontFacing);
            _turnStatus = kSelfShotDormant;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                EZDEBUG(@"shot started:%i", _turnStatus);
                if(_turnStatus == kSelfShotDormant){
                    _turnStatus = kCameraCapturing;
                    [_pageTurn play];
                    if(stillCamera.isFrontFacing){
                        [self switchCameraInner];
                    }
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [_shotReady play];
                    });
                    
                    [self performSelector:@selector(captureTurnedImage)
                               withObject:nil
                               afterDelay:3.0];
                }
            });
        }
    }
   
}

- (void) startMobileMotion
{
    __weak DLCImagePickerController* weakSelf = self;
    [[EZMotionUtility getInstance] registerHandler:^(EZMotionData* md){
        [weakSelf handleMobileMotion:md];
    } key:@"CameraMotion" type:kEZRotation];
}


//This is historic relics now.
//I will remove it during the last commit.
-(void) becomeVisible:(BOOL)isFront
{
    
    _isVisible = true;
    __weak DLCImagePickerController* weakSelf = self;
    if(_senseRotate){
        [[EZMotionUtility getInstance] registerHandler:^(EZMotionData* md){
            [weakSelf handleMobileMotion:md];
        } key:@"CameraMotion" type:kEZRotation];
    }
    EZDEBUG(@"BecomeVisible get called, isFront:%i, current:%i", isFront, stillCamera.isFrontFacing);
    if(isFront && !stillCamera.isFrontFacing){
        [self switchCamera];
    }else if(!isFront && stillCamera.isFrontFacing){
        [self switchCamera];
    }
    //EZDEBUG(@"After call capture:%i",stillCamera.isFrontFacing);
    //[stillCamera startCameraCapture];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self becomeInvisible];
}


- (void) becomeInvisible
{
    EZDEBUG(@"BecomeInvisible get called");
    //[super viewDidDisappear:animated];
    _quitFaceDetection = true;
    _senseRotate = false;
    [stillCamera stopCameraCapture];
    [self removeAllTargets];
    [[EZMotionUtility getInstance] unregisterHandler:@"CameraMotion"];
    _isVisible = false;
    [[UIApplication sharedApplication] setStatusBarHidden:false];
}

-(void) setupCamera {
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        // Has camera
        
        stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        //stillCamera.horizontallyMirrorFrontFacingCamera = TRUE;
        runOnMainQueueWithoutDeadlocking(^{
            [stillCamera startCameraCapture];
            if([stillCamera.inputCamera hasTorch]){
                [self.flashToggleButton setEnabled:YES];
            }else{
                [self.flashToggleButton setEnabled:NO];
            }
            
            AVCaptureDevice *device = stillCamera.inputCamera;
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                NSError *error;
                //[device lockForConfiguration];
                if ([device lockForConfiguration:&error]) {
                    [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                    [device unlockForConfiguration];
                }
                
            }
            EZDEBUG(@"Setup the camera for auto focus");
            [self prepareFilter];
        });
    } else {
        runOnMainQueueWithoutDeadlocking(^{
            // No camera awailable, hide camera related buttons and show the image picker
            self.cameraToggleButton.hidden = YES;
            self.photoCaptureButton.hidden = YES;
            self.flashToggleButton.hidden = YES;
            // Show the library picker
//            [self switchToLibrary:nil];
//            [self performSelector:@selector(switchToLibrary:) withObject:nil afterDelay:0.5];
            [self prepareFilter];
        });
    }
   
}

-(void) filterClicked:(UIButton *) sender {
    for(UIView *view in self.filterScrollView.subviews){
        if([view isKindOfClass:[UIButton class]]){
            [(UIButton *)view setSelected:NO];
        }
    }
    
    [sender setSelected:YES];
    [self removeAllTargets];
    
    selectedFilter = sender.tag;
    //[self setFilter:sender.tag];
    [self prepareFilter];
}


-(void) prepareFilter {    
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        isStatic = YES;
    }
    
    if (!isStatic) {
        [self prepareLiveFilter];
    } else {
        [self prepareStaticFilter];
    }
}

- (CGFloat) getISOSpeedRating
{
    NSDictionary* exif = [stillCamera.currentCaptureMetadata objectForKey:@"{Exif}"];
    NSArray* isoRating = [exif objectForKey:@"ISOSpeedRatings"];
    CGFloat res = -1.0;
    if(isoRating && isoRating.count > 0){
        res = [[isoRating objectAtIndex:0] floatValue];
    }
    
    return res;
}


- (CGFloat) getFacalLength
{
    NSDictionary* exif = [stillCamera.currentCaptureMetadata objectForKey:@"{Exif}"];
    NSNumber* isoRating = [exif objectForKey:@"FocalLength"];
    CGFloat res = 500.0;
    if(isoRating){
        res = [isoRating floatValue];
    }
    
    return res;
}

- (void) generateTestImage:(UIImage*)capturedImage
{
    if(_faceCaptureTest){
        _faceCaptureTest.image = capturedImage;
    }else{
        _faceCaptureTest = [[UIImageView alloc] initWithFrame:CGRectMake(0, 400, 50, 50)];
        _faceCaptureTest.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:_faceCaptureTest];
        _faceCaptureTest.image = capturedImage;
    }
}


- (NSArray*) adjustFrameForOrienation:(CGRect)faceRegion orientation:(UIImageOrientation)orientation
{
    CGFloat width = faceRegion.size.width * self.imageView.frame.size.width;
    CGFloat height = faceRegion.size.height * self.imageView.frame.size.height;
    width = MIN(width, height);
    height = width;
    CGFloat px = faceRegion.origin.x * self.imageView.frame.size.width;
    CGFloat py = faceRegion.origin.y * self.imageView.frame.size.height;
    EZDEBUG(@"image orientation value:%i", orientation);
    if(orientation == UIImageOrientationUp){
        EZDEBUG(@"image orientation up");
        
    }else if(orientation == UIImageOrientationRight){
        //width = faceRegion.size.width * self.imageView.frame.size.height;
        width = faceRegion.size.width * self.imageView.frame.size.height;
        height = faceRegion.size.height * self.imageView.frame.size.width;
        width = MIN(width, height);
        height = width;
        px = faceRegion.origin.x * self.imageView.frame.size.height;
        py = faceRegion.origin.y * self.imageView.frame.size.width;
        CGFloat tmpWidth = width;
        width = height;
        height = tmpWidth;
        CGFloat tmpX = px;
        px = py;
        py = self.imageView.frame.size.height - tmpX - tmpWidth;
        EZDEBUG(@"image orientation right");
    }else if(orientation == UIImageOrientationLeft){
        EZDEBUG(@"image orientation left");
        width = faceRegion.size.width * self.imageView.frame.size.height;
        height = faceRegion.size.height * self.imageView.frame.size.width;
        width = MIN(width, height);
        height = width;
        px = faceRegion.origin.x * self.imageView.frame.size.height;
        py = faceRegion.origin.y * self.imageView.frame.size.width;
        CGFloat tmpWidth = width;
        width = height;
        height = tmpWidth;
        CGFloat tmpY = py;
        py = px;
        px = self.imageView.frame.size.width - tmpY - width;
        
    }
    
    CGPoint interestPoint = CGPointMake(px + 0.5 * width, py + 0.5*height);
    CGRect frame = CGRectMake(px, py, width, height);
    CGRect fixFrame = [self.view convertRect:frame fromView:self.imageView];
    return @[[NSValue valueWithCGPoint:interestPoint], [NSValue valueWithCGRect:fixFrame]];

}

- (CGFloat) calDistance:(CGPoint)prev current:(CGPoint)current
{
    CGFloat deltaX = (current.x - prev.x) * (current.x - prev.x);
    CGFloat deltaY = (current.y - prev.y) * (current.y - prev.y);
    return sqrtf(deltaX + deltaY);
}

- (void) startDetectFace
{
    if(!(_detectFace && _isVisible && !_detectingFace && !isStatic)){
        return;
    }
     _detectingFace = TRUE;
    UIImage* capturedImage = orgFiler.blackFilter.imageFromCurrentlyProcessedOutput; //[imageView contentAsImage];
    UIImageOrientation orientation = capturedImage.imageOrientation;
    if(capturedImage.size.width <= 0){
        _detectingFace = false;
        return;
    }
    capturedImage = [capturedImage rotateByOrientation:capturedImage.imageOrientation];
    NSArray* result = [EZFaceUtilWrapper detectFace:capturedImage ratio:0.005];
        EZDEBUG(@"Let's test the image size:%@, face result:%i", NSStringFromCGSize(capturedImage.size), result.count);
        if(result.count > 0){
            EZFaceResultObj* fres = [result objectAtIndex:0];
            CGRect faceRegion = fres.orgRegion;
            NSArray* res = [self adjustFrameForOrienation:faceRegion orientation:orientation];
            CGPoint poi = [[res objectAtIndex:0] CGPointValue];
            CGFloat distP = [self calDistance:_prevFocusPoint current:poi];
            _prevFocusPoint = poi;
            CGRect fixFrame = [[res objectAtIndex:1] CGRectValue];
            EZDEBUG(@"Find face at:%@, frame:%@, disP:%f, adjustFocus:%i", NSStringFromCGRect(faceRegion), NSStringFromCGRect(fixFrame), distP, (distP>8));
            if(distP > 8){
                dispatch_main(^(){
                    [self focusCamera:poi frame:fixFrame expose:TRUE];
                    _detectingFace = false;
                });
            }else{
                _detectingFace = false;
            }
        }else{
            _detectingFace = false;
        }
}

- (void) startFaceCapture
{
    [[EZThreadUtility getInstance] executeBlockInQueue:^(){
        EZDEBUG(@"Start capture faces");
        while (!_quitFaceDetection) {
            @autoreleasepool {
                [self startDetectFace];
            }
            [NSThread sleepForTimeInterval:1.0];
        }
        EZDEBUG(@"Quit face detection");
    } isConcurrent:TRUE];
}

-(void) prepareLiveFilter {
    _detectFace = true;
    //[self startFaceCapture];
    hueFilter.hue = 353;
    [stillCamera addTarget:orgFiler];
    [orgFiler addTarget:hueFilter];
    [hueFilter addTarget:tongFilter];
    //[tongFilter addTarget:fixColorFilter];
    //[fixColorFilter addTarget:secFixColorFilter];
    [tongFilter addTarget:redEnhanceFilter];
    //[orgFiler addTarget:tongFilter];
    //[tongFilter addTarget:fixColorFilter];
    //[orgFiler addTarget:finalBlendFilter];
    //[fixColorFilter addTarget:filter];
    //[finalBlendFilter addTarget:filter];
    [redEnhanceFilter addTarget:filter];
    [filter addTarget:self.imageView];
    [filter prepareForImageCapture];
}

- (EZClickView*) createSmileButton
{
    CGRect bound = [UIScreen mainScreen].bounds;
    EZClickView* smile = [[EZClickView alloc] initWithFrame:CGRectMake(160 + (204.0 - 66.0)/2, bound.size.height-66.0-24, 66.0, 66.0)];
    [smile enableRoundImage];
    smile.backgroundColor = RGBA(200, 100, 20, 128);
    return smile;
}


- (BOOL) getImageMode
{
    return finalBlendFilter.imageMode;
}

- (void) setImageMode:(int)imgMode
{
    finalBlendFilter.imageMode = imgMode;
    [staticPicture processImage];
    //finalBlendFilter.imageMode = 2;
}

-(void) prepareStaticFilter:(EZFaceResultObj*)fobj image:(UIImage*)img{
    _detectFace = false;
    
    CGFloat dark = [self getISOSpeedRating];
    hueFilter.hue = 358.0;
    //GPUImageFilter* firstFilter = nil;
    if(dark >= 400){
        //[tongFilter addTarget:darkBlurFilter];
        //firstFilter = (GPUImageFilter*)darkBlurFilter;
        [staticPicture addTarget:darkBlurFilter];
        [darkBlurFilter addTarget:tongFilter];
        [tongFilter addTarget:hueFilter];
    }else{
        [staticPicture addTarget:tongFilter];
        [tongFilter addTarget:hueFilter];
    }
    //[tongFilter addTarget:fixColorFilter];
    //[fixColorFilter addTarget:secFixColorFilter];
    EZDEBUG(@"Prepare new static image get called, flash image:%i, image size:%@, dark:%f", _isImageWithFlash, NSStringFromCGSize(img.size), dark);
    //GPUImageFilter* imageFilter = secFixColorFilter;
    if(fobj || stillCamera.isFrontFacing){
        [hueFilter addTarget:finalBlendFilter];
        //[secFixColorFilter addTarget:finalBlendFilter];
        [finalBlendFilter addTarget:fixColorFilter];
        [fixColorFilter addTarget:secFixColorFilter];
        [secFixColorFilter addTarget:redEnhanceFilter];
        [redEnhanceFilter addTarget:filter];
        CGFloat blurCycle = 1.5;
        if(fobj){
            blurCycle = 3.25 * fobj.orgRegion.size.width;
            //if(fobj.orgRegion.size.width > 0.5){
                //blurCycle = 1.2 * blurCycle;
            //}
        }else{
            fobj = [[EZFaceResultObj alloc] init];
            fobj.orgRegion = CGRectMake(0.1, 0.1, 0.3, 0.3);
            blurCycle = 0.9;
        }
        CGFloat adjustedFactor = 14.0;//MAX(17 - 10 * fobj.orgRegion.size.width, 13.0);
        finalBlendFilter.blurFilter.distanceNormalizationFactor = adjustedFactor;
        finalBlendFilter.blurFilter.blurSize = blurCycle;
        finalBlendFilter.imageMode = 2;
        //finalBlendFilter.smallBlurFilter.blurSize = blurAspectRatio * blurCycle;
        EZDEBUG(@"Will blur face:%@, blurCycle:%f, adjustedColor:%f", NSStringFromCGRect(fobj.orgRegion), blurCycle, adjustedFactor);
        //finalBlendFilter.imageMode = 0;
        if(!smileDetected){
            smileDetected = [self createSmileButton];
            [self.view addSubview:smileDetected];
        }
        smileDetected.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^(){
            smileDetected.alpha = 1.0;
        }];
        __weak DLCImagePickerController* weakSelf = self;
        //__weak EZClickView* weakButton = smileDetected;
        smileDetected.releasedBlock = ^(id obj){
            //blender.imageMode = 2;
            if([weakSelf getImageMode] == 0){
                [weakSelf setImageMode:2];
                weakSelf.detectedFaceObj = nil;
            }else{
                [weakSelf setImageMode:0];
                weakSelf.detectedFaceObj = fobj;
            }
            //So that the whole image will not get affected.
            //weakSelf.detectedFaceObj = nil;
            //weakButton.hidden = TRUE;
        };
    }else{
        [hueFilter addTarget:fixColorFilter];
        [fixColorFilter addTarget:secFixColorFilter];
        [secFixColorFilter addTarget:redEnhanceFilter];
        [redEnhanceFilter addTarget:filter];
    }
    [filter addTarget:self.imageView];
    GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
    switch (staticPictureOriginalOrientation) {
        case UIImageOrientationLeft:
            imageViewRotationMode = kGPUImageRotateRight;
            break;
        case UIImageOrientationRight:
            imageViewRotationMode = kGPUImageRotateLeft;
            break;
        case UIImageOrientationDown:
            imageViewRotationMode = kGPUImageRotate180;
            break;
        default:
            imageViewRotationMode = kGPUImageNoRotation;
            break;
    }
    if(stillCamera.isFrontFacing){
        [self.imageView setInputRotation:kGPUImageNoRotation atIndex:0];
    }else{
        [self.imageView setInputRotation:imageViewRotationMode atIndex:0];
    }
    [staticPicture processImage];
}


-(void) prepareStaticFilter {
    [self prepareStaticFilter:nil image:nil];
}

-(void) removeAllTargets {
    [stillCamera removeAllTargets];
    [staticPicture removeAllTargets];
    //[whiteBalancerFilter removeAllTargets];
    [cropFilter removeAllTargets];
    [tongFilter removeAllTargets];
    //[cycleDarken removeAllTargets];
    //[biBlurFilter removeAllTargets];
    [fixColorFilter removeAllTargets];
    //[dynamicBlurFilter removeAllTargets];
    //[edgeFilter removeAllTargets];
    //edgeFilter.hasOverriddenImageSizeFactor = false;
    //regular filter
    [filter removeAllTargets];
    [darkBlurFilter removeAllTargets];
    //[contrastfilter removeAllTargets];
    //[faceBlurFilter removeAllTargets];
    [simpleFilter removeAllTargets];
    //[darkFilter removeAllTargets];
    [secFixColorFilter removeAllTargets];
    [redEnhanceFilter removeAllTargets];
    //blur
    [blurFilter removeAllTargets];
    [hueFilter removeAllTargets];
    [finalBlendFilter removeAllTargets];
    [orgFiler removeAllTargets];
}

-(IBAction)switchToLibrary:(id)sender {
    
    if (!isStatic) {
        // shut down camera
        [stillCamera stopCameraCapture];
        [self removeAllTargets];
    }
    
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}



-(IBAction)toggleFlash:(UIButton *)button{
    ++_flashMode;
    if(_flashMode > 2){
        _flashMode = 0;
    }
    NSString* flashFile = @"flash-off";
    if(_flashMode == 1){
        flashFile = @"flash";
    }else if(_flashMode == 2){
        flashFile = @"flash-auto";
    }
    [flashToggleButton setImage:[UIImage imageNamed:flashFile] forState:UIControlStateNormal];
    //[button setSelected:!button.selected];
}

-(IBAction) toggleBlur:(UIButton*)blurButton {
    
    [self.blurToggleButton setEnabled:NO];
    [self removeAllTargets];
    
    if (hasBlur) {
        hasBlur = NO;
        [self showBlurOverlay:NO];
        [self.blurToggleButton setSelected:NO];
    } else {
        if (!blurFilter) {
            blurFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
            [(GPUImageGaussianSelectiveBlurFilter*)blurFilter setExcludeCircleRadius:80.0/320.0];
            [(GPUImageGaussianSelectiveBlurFilter*)blurFilter setExcludeCirclePoint:CGPointMake(0.5f, 0.5f)];
            //[(GPUImageGaussianSelectiveBlurFilter*)blurFilter setBlurSize:kStaticBlurSize];
            [(GPUImageGaussianSelectiveBlurFilter*)blurFilter setAspectRatio:1.0f];
        }
        hasBlur = YES;
        CGPoint excludePoint = [(GPUImageGaussianSelectiveBlurFilter*)blurFilter excludeCirclePoint];
		CGSize frameSize = self.blurOverlayView.frame.size;
		self.blurOverlayView.circleCenter = CGPointMake(excludePoint.x * frameSize.width, excludePoint.y * frameSize.height);
        [self.blurToggleButton setSelected:YES];
        [self flashBlurOverlay];
    }
    
    [self prepareFilter];
    [self.blurToggleButton setEnabled:YES];
}

-(IBAction) switchCamera {
    EZDEBUG(@"Switch is front:%i, orientation:%i", stillCamera.isFrontFacing, stillCamera.horizontallyMirrorFrontFacingCamera);
    //if(!stillCamera.isFrontFacing){
    //    _turnStatus = kSelfShot;
    //}
    [self switchCameraOnly];
}

-(void) switchCameraInner {
    //[_pageTurn play];
    [self switchCameraOnly];
}

- (void) switchCameraOnly {
    [self.cameraToggleButton setEnabled:NO];
    [stillCamera rotateCamera];
    [self.cameraToggleButton setEnabled:YES];
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && stillCamera) {
        if ([stillCamera.inputCamera hasFlash] && [stillCamera.inputCamera hasTorch]) {
            [self.flashToggleButton setEnabled:YES];
        } else {
            [self.flashToggleButton setEnabled:NO];
        }
    }

}
-(void) prepareForCapture {
    __weak DLCImagePickerController* weakSelf = self;
    [stillCamera.inputCamera lockForConfiguration:nil];
    if(!stillCamera.isFrontFacing && _flashMode > 0 &&
       [stillCamera.inputCamera hasTorch]){
        EZDEBUG(@"Flash mode is :%i", _flashMode);
        _isImageWithFlash = true;
        if(_flashMode == 1){
            EZDEBUG(@"Manual mode");
            [stillCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
            [self performSelector:@selector(captureImage)
                   withObject:nil
                   afterDelay:0.8];
        }else{
            EZDEBUG(@"Flash auto mode");
            [stillCamera.inputCamera setTorchMode:AVCaptureTorchModeAuto];
            [self captureImage];
        }
        
    }else if(stillCamera.isFrontFacing){ //Later I will have the flashMode check, now just light up the screen
        EZDEBUG(@"I will add _flashView");
        [_shotVoice play];
        _flashView.alpha = 0;
        CGFloat oldBright = [UIScreen mainScreen].brightness;
        [UIScreen mainScreen].brightness = 1;
        [self.view addSubview:_flashView];
        [UIView animateWithDuration:0.3 animations:^(){
            weakSelf.flashView.alpha = 1;
        } completion:^(BOOL completed){
            //[self captureImage];
        }];
        [self performSelector:@selector(captureImage) withObject:nil afterDelay:0.3];
        //[self performSelector:@selector(captureImage) withObject:nil afterDelay:0.8];
        _frontCameraCompleted = ^(id obj){
            EZDEBUG(@"Front camera completed");
            [weakSelf.flashView removeFromSuperview];
            [UIScreen mainScreen].brightness = oldBright;
            /**
            [UIView animateWithDuration:0.3 animations:^(){
                weakSelf.flashView.alpha = 0;
            } completion:^(BOOL finished) {
                [weakSelf.flashView removeFromSuperview];
                [UIScreen mainScreen].brightness = oldBright;
            }];
             **/
        };
        
    }else{
        [self captureImage];
    }
}

-(void)captureImage{
    _selfShot = false;
    if(!blackView){
        blackCover = [[UIView alloc] initWithFrame:imageView.bounds];
        blackCover.backgroundColor = [UIColor blackColor];
        //blackView = [[UIImageView alloc] initWithFrame:imageView.bounds];
        //[[UIView alloc]initWithFrame:imageView.bounds];
        //blackView.contentMode = UIViewContentModeScaleAspectFill;
        //blackView.backgroundColor = [UIColor blackColor];
        
    }
    //blackView.image = filter.imageFromCurrentlyProcessedOutput;
    //blackView.alpha = 1.0;
    blackCover.alpha = 1.0;
    //[imageView addSubview:blackView];
    [imageView addSubview:blackCover];
    [UIView animateWithDuration:4.0 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
        blackCover.alpha = 0;
    } completion:^(BOOL complete){
        [blackCover removeFromSuperview];
    }];
    [self captureImageInner:NO];
}

- (void) completeImage:(UIImage*)img flip:(BOOL)flip error:(NSError*)error
{
    photoMeta = stillCamera.currentCaptureMetadata;
    EZDEBUG(@"Captured meta data:%@", photoMeta);
    [stillCamera.inputCamera unlockForConfiguration];
    [stillCamera stopCameraCapture];
    [self removeAllTargets];
    if(!stillCamera.isFrontFacing){
        //img = [img resizedImageWithMaximumSize:CGSizeMake(img.size.width/2.0, img.size.height/2.0)];
        EZDEBUG(@"After shrink:%@", NSStringFromCGSize(img.size));
    }else{
        EZDEBUG(@"Rotate before static:%i, static orientation:%i", img.imageOrientation, staticPictureOriginalOrientation);
        //img = [img rotate:staticPictureOriginalOrientation];
        if(_frontCameraCompleted){
            _frontCameraCompleted(nil);
        }
        _frontCameraCompleted = nil;
    }

    staticPicture = [[GPUImagePicture alloc] initWithImage:img smoothlyScaleOutput:NO];
    staticPictureOriginalOrientation = img.imageOrientation;
    
    //UIImageView* iview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 400, 100, 100)];
    //iview.image = flipped;
    _detectedFaceObj = nil;
    
    UIImage* detectImage = img;
    //if(!stillCamera.isFrontFacing){
        //detectImage = [img changeOriention:UIImageOrientationUp];
    //}
    EZDEBUG(@"Capture the flip is:%i, flipped orientation:%i, orginal:%i, staticOrientation:%i", flip, detectImage.imageOrientation, img.imageOrientation, staticPictureOriginalOrientation);
    //UIImageView* faceView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 100, 100)];
    //faceView.image = detectImage;
    //[imageView addSubview:faceView];
    NSArray* faces = [EZFaceUtilWrapper detectFace:detectImage ratio:0.01];
    EZFaceResultObj* firstObj = nil;
    if(faces.count > 0){
        for(EZFaceResultObj* fobj in faces){
            if(fobj.orgRegion.size.width > firstObj.orgRegion.size.width){
                firstObj = fobj;
            }
        }
        //firstObj = [faces objectAtIndex:0];
    }
    _detectedFaceObj = firstObj;
    [self prepareStaticFilter:_detectedFaceObj image:img];
    CGSize imageSize = img.size;
    
    //dispatch_later(0.1, ^(){
    /**
    if(firstObj){
       CGSize textureSize = [self adjustEdgeWidth:imageSize orientation:staticPictureOriginalOrientation];
        finalBlendFilter.edgeFilter.texelWidth = textureSize.width;
        finalBlendFilter.edgeFilter.texelHeight = textureSize.height;
    }
     **/
    if(firstObj){
        CGFloat orgWidth = finalBlendFilter.edgeFilter.texelWidth;
        CGFloat orgHeight = finalBlendFilter.edgeFilter.texelHeight;
        CGFloat lineWidth = 1.0/imageSize.width;
        CGFloat lineHeight = 1.0/imageSize.height;
        if(staticPictureOriginalOrientation == UIImageOrientationUp || staticPictureOriginalOrientation == UIImageOrientationDown || staticPictureOriginalOrientation == UIImageOrientationDownMirrored || staticPictureOriginalOrientation == UIImageOrientationUpMirrored){
            
        }else{
            CGFloat tmpWidth = lineWidth;
            lineWidth = lineHeight;
            lineHeight = tmpWidth;
        }
        finalBlendFilter.edgeFilter.texelHeight = lineHeight * 2.0;
        finalBlendFilter.edgeFilter.texelWidth = lineWidth * 2.0;
        EZDEBUG(@"Reprocess width:%f, height:%f, original width:%f, height:%f, image Orientation:%i, calculated width:%f, height:%f",  finalBlendFilter.edgeFilter.texelWidth,  finalBlendFilter.edgeFilter.texelHeight, orgWidth, orgHeight, staticPictureOriginalOrientation, lineWidth, lineHeight);
    }
    [staticPicture processImage];
    /**
    [UIView animateWithDuration:0.2 animations:^(){
        blackView.alpha = 0;
    } completion:^(BOOL complete){
        [blackView removeFromSuperview];
        blackView.image = nil;
    }];
    **/
    [self.retakeButton setHidden:NO];
    [self.photoCaptureButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.photoCaptureButton setImage:nil forState:UIControlStateNormal];
    [self.photoCaptureButton setEnabled:YES];
    isStatic = true;
    [blackCover removeFromSuperview];
}

- (CGSize) adjustEdgeWidth:(CGSize)imageSize orientation:(UIImageOrientation)orienation
{
  
    CGFloat lineWidth = 1.0/imageSize.width;
    CGFloat lineHeight = 1.0/imageSize.height;
    if(orienation == UIImageOrientationUp || orienation == UIImageOrientationDown || orienation == UIImageOrientationDownMirrored || orienation == UIImageOrientationUpMirrored){
        
    }else{
        CGFloat tmpWidth = lineWidth;
        lineWidth = lineHeight;
        lineHeight = tmpWidth;
    }
    return CGSizeMake(lineWidth, lineHeight);
}

- (void) handleFullImage:(UIImage*)img
{
    photoMeta = stillCamera.currentCaptureMetadata;
    EZDEBUG(@"Captured meta data:%@", photoMeta);
    currentOrientation = img.imageOrientation;
    img = [img resizedImageWithMinimumSize:CGSizeMake(980.0, 980.0)];
    [[EZThreadUtility getInstance] executeBlockInQueue:^(){
        _imageSize = img.size;
        _highResImageFile = [EZFileUtil saveImageToDocument:img filename:@"fullsize.png"];
        EZDEBUG(@"Will save image to the document:%@, %@", NSStringFromCGSize(_imageSize), _highResImageFile);
    } isConcurrent:YES];
}

-(void)captureImageInner:(BOOL)flip {
    _detectFace = false;
    __weak DLCImagePickerController* weakSelf = self;
    void (^completion)(UIImage *, NSError *) = ^(UIImage *img, NSError *error) {
        [weakSelf completeImage:img flip:flip error:error];
    };
    
    
    _highResImageFile = nil;
    _imageSize = CGSizeMake(0, 0);

    AVCaptureDevicePosition currentCameraPosition = stillCamera.inputCamera.position;
    Class contextClass = NSClassFromString(@"GPUImageContext") ?: NSClassFromString(@"GPUImageOpenGLESContext");
    if ((currentCameraPosition != AVCaptureDevicePositionFront) || (![contextClass supportsFastTextureUpload])) {
        //EZDEBUG(@"Prepare for the capture");
        //UIImage *img = [orgFiler imageFromCurrentlyProcessedOutput];
        EZDEBUG(@"Get current image");
        [self removeAllTargets];
        [stillCamera addTarget:simpleFilter];
        GPUImageFilter *finalFilter = simpleFilter;
        [finalFilter prepareForImageCapture];
        EZDEBUG(@"Capture before get inside");
        void (^fullImageProcess)(UIImage *, NSError *) = ^(UIImage *fullImg, NSError* error) {
            //[weakSelf handleFullImage:fullImg];
            UIImageOrientation prevOrient = fullImg.imageOrientation;
            fullImg = [fullImg resizedImageWithMinimumSize:CGSizeMake(980.0, 980.0)];
            EZDEBUG(@"tailored full size length:%@, prevOrient:%i, current orientation:%i", NSStringFromCGSize(fullImg.size), prevOrient, fullImg.imageOrientation);
            completion(fullImg, nil);
        };
        [stillCamera capturePhotoAsImageProcessedUpToFilter:finalFilter withCompletionHandler:fullImageProcess];
        EZDEBUG(@"Capture without crop");
    } else {
        // A workaround inside capturePhotoProcessedUpToFilter:withImageOnGPUHandler: would cause the above method to fail,
        // so we just grap the current crop filter output as an aproximation (the size won't match trough)  
        EZDEBUG(@"Will try to get from crop");
        UIImage *img = [orgFiler imageFromCurrentlyProcessedOutput];
        EZDEBUG(@"Capture with crop, image size:%@", NSStringFromCGSize(img.size));
        completion(img, nil);
    }
}

//This is for process image step wise
- (NSArray*) prepareImageFilter:(EZFaceResultObj*)fobj imageSize:(CGSize)size
{
    //[self removeAllTargets];
    NSMutableArray* res = [[NSMutableArray alloc] init];
    CGFloat dark = [self getISOSpeedRating];
    //GPUImageFilter* firstFilter = nil;
    if(dark >= 400){
        [res addObject:[self createNightFilter]];
    }
    [res addObject:[self createTongFilter]];
    //[tongFilter addTarget:fixColorFilter];
    //[fixColorFilter addTarget:secFixColorFilter];
    EZDEBUG(@"Prepare new static image get called, flash image:%i, image size:%@, dark:%f", _isImageWithFlash, NSStringFromCGSize(size), dark);
    //GPUImageFilter* imageFilter = secFixColorFilter;
    //fobj = [[EZFaceResultObj alloc] init];
    //fobj.orgRegion = CGRectMake(0, 0, 0.3, 0.3);
    if(fobj){
        //[tongFilter addTarget:finalBlendFilter];
        EZHomeBlendFilter* faceBlur = [self createFaceBlurFilter];
        [res addObject:faceBlur];
        //[secFixColorFilter addTarget:finalBlendFilter];
        [res addObject:[self createRedStretchFilter]];
        [res addObject:[self createBlueStretchFilter]];
        [res addObject:[self createRedEnhanceFilter]];
        CGFloat blurCycle = 3.0 * fobj.orgRegion.size.width;
        CGFloat adjustedFactor = 13.0;//MAX(17 - 10 * fobj.orgRegion.size.width, 13.0);
        faceBlur.blurFilter.distanceNormalizationFactor = adjustedFactor;
        faceBlur.blurFilter.blurSize = blurCycle;
        //CGSize edgeSize = [self adjustEdgeWidth:_imageSize orientation:staticPictureOriginalOrientation];
        //faceBlur.edgeFilter.texelWidth = edgeSize.width;
        //faceBlur.edgeFilter.texelHeight = edgeSize.height;
        //finalBlendFilter.smallBlurFilter.blurSize = blurAspectRatio * blurCycle;
        EZDEBUG(@"Will blur face:%@, blurCycle:%f, adjustedColor:%f", NSStringFromCGRect(fobj.orgRegion), blurCycle, adjustedFactor);
        faceBlur.imageMode = 0;
    }else{
        [res addObject:[self createRedStretchFilter]];
        [res addObject:[self createBlueStretchFilter]];
        [res addObject:[self createRedEnhanceFilter]];
    }
    return res;
}

-(IBAction) takePhoto:(id)sender{
    smileDetected.alpha = 0;
    [self.photoCaptureButton setEnabled:NO];
    EZDEBUG(@"Take photo get called, is static:%i, before adjust:%f", isStatic, [UIScreen mainScreen].brightness);
    //[[UIScreen mainScreen]setBrightness:1.0];
    //EZDEBUG(@"After adjust:%f", [UIScreen mainScreen].brightness);
    
    if (!isStatic) {
        isStatic = YES;
        _isImageWithFlash = NO;
        [self.libraryToggleButton setHidden:YES];
        [self.cameraToggleButton setEnabled:NO];
        [self.flashToggleButton setEnabled:NO];
        [self prepareForCapture];
        
    } else {
        UIImage *currentFilteredVideoFrame = nil;
        if(_highResImageFile){
            [[EZThreadUtility getInstance] executeBlockInQueue:^(){
            NSArray* filters = [self prepareImageFilter:_detectedFaceObj imageSize:_imageSize];
            UIImage* orgImage = [UIImage imageWithContentsOfFile:_highResImageFile];
            //orgImage = [orgImage resizedImageWithMaximumSize:CGSizeMake(orgImage.size.width, orgImage.size.height/2.0)];//[orgImage resizedImageWithMaximumSize:CGSizeMake(orgImage.size.width/2.0,orgImage.size.height/2.0)] ;
            //orgImage = [orgImage croppedImageWithRect:CGRectMake(0, 0, orgImage.size.width/2.0, orgImage.size.height/2.0)];
            EZDEBUG(@"stored file:%@,The org size file:%@",_highResImageFile, NSStringFromCGSize(orgImage.size));
            //finalBlendFilter.imageMode = 0;
            //[EZFileUtil deleteFile:_highResImageFile];
            UIImage* processed = [EZFileUtil saveEffectsImage:orgImage effects:filters piece:9 orientation:currentOrientation];
            //[EZFileUtil deleteFile:_highResImageFile];
            
            EZDEBUG(@"background processed size:%@", NSStringFromCGSize(processed.size));
            NSDictionary *info = @{@"image":processed};
                if(photoMeta){
                    info = @{@"image":processed, @"metadata":photoMeta};
                }
                //[info setValue:currentFilteredVideoFrame forKey:@"image"];
                EZDEBUG(@"image size:%f, %f", processed.size.width, processed.size.height);
                [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:info];
                
            /**
            if(!testView){
                testView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 150, 200)];
                testView.contentMode = UIViewContentModeScaleAspectFit;
                [self.view addSubview:testView];
            }
            testView.image = currentFilteredVideoFrame;
            **/
            orgImage = nil;
            } isConcurrent:YES];
            [self retakePhoto:retakeButton];
            [self.photoCaptureButton setEnabled:YES];
            return;
        }else{
            GPUImageOutput<GPUImageInput> *processUpTo;
            processUpTo = filter;
            EZDEBUG(@"Before call process image");
            [staticPicture processImage];
            EZDEBUG(@"After call process image");
            //if(!stillCamera.isFrontFacing){
            
            if(stillCamera.isFrontFacing){
                currentFilteredVideoFrame = [processUpTo imageFromCurrentlyProcessedOutputWithOrientation:staticPictureOriginalOrientation];
                EZDEBUG(@"The current orienation:%i, static orientatin:%i", currentFilteredVideoFrame.imageOrientation, staticPictureOriginalOrientation);
                currentFilteredVideoFrame = [currentFilteredVideoFrame rotateByOrientation:staticPictureOriginalOrientation];
            }else{
                currentFilteredVideoFrame = [processUpTo imageFromCurrentlyProcessedOutputWithOrientation:UIImageOrientationUp];
                //currentFilteredVideoFrame = staticPicture
                EZDEBUG(@"Before shink:%@", NSStringFromCGSize(currentFilteredVideoFrame.size));
            }
        //}
        }
        //std::vector<EZFaceResult*> faces;
        //EZFaceUtil faceUtil = singleton<EZFaceUtil>();
        //NSArray* faces = [EZFaceUtilWrapper detectFace:currentFilteredVideoFrame ratio:0.25];
        //EZDEBUG(@"detected face:%i", faces.count);
        NSDictionary *info = @{@"image":currentFilteredVideoFrame};
        if(photoMeta){
            info = @{@"image":currentFilteredVideoFrame, @"metadata":photoMeta};
        }
        //[info setValue:currentFilteredVideoFrame forKey:@"image"];
        EZDEBUG(@"image size:%f, %f", currentFilteredVideoFrame.size.width, currentFilteredVideoFrame.size.height);
        [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:info];
        [self retakePhoto:retakeButton];
        [self.photoCaptureButton setEnabled:YES];

    }
}

-(IBAction) retakePhoto:(UIButton *)button {
    smileDetected.alpha = 0.0;
    _turnStatus = kCameraNormal;
    [self.retakeButton setHidden:YES];
    [self.libraryToggleButton setHidden:NO];
    staticPicture = nil;
    staticPictureOriginalOrientation = UIImageOrientationUp;
    isStatic = NO;
    [self removeAllTargets];
    EZDEBUG(@"selfShot:%i, front:%i", _selfShot, stillCamera.isFrontFacing);
    if(_selfShot && !stillCamera.isFrontFacing){
        [stillCamera rotateCamera];
    }
    [stillCamera startCameraCapture];
    [self.cameraToggleButton setEnabled:YES];
    
    
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]
       && stillCamera
       && [stillCamera.inputCamera hasTorch]) {
        [self.flashToggleButton setEnabled:YES];
    }
    
    [self.photoCaptureButton setImage:[UIImage imageNamed:@"camera-icon"] forState:UIControlStateNormal];
    [self.photoCaptureButton setTitle:nil forState:UIControlStateNormal];
    
    if ([self.filtersToggleButton isSelected]) {
        [self hideFilters];
    }
    EZDEBUG(@"The selectedFilter is:%i", selectedFilter);
    //[self setFilter:selectedFilter];
    [self prepareFilter];
}

- (void) testImageSave
{
    EZHomeBlendFilter* hb = [[EZHomeBlendFilter alloc] init];
    GPUImageFilter* finalFilter = [[GPUImageFilter alloc] init];
    UIImage* orgImage = [UIImage imageNamed:@"smile_face.png"];
    UIImage* filteredImage = [EZFileUtil saveEffectsImage:orgImage effects:@[hb, finalFilter] piece:6 orientation:0];
    EZDEBUG(@"Filtered image:%@", NSStringFromCGSize(filteredImage.size));
    if(testView == nil){
        testView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 150, 200)];
        testView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:testView];
        
        testView2 = [[UIImageView alloc] initWithFrame:CGRectMake(160, 100, 150, 200)];
        testView2.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:testView2];
    }
    testView.image = filteredImage;
    testView2.image = orgImage;
}


-(IBAction) cancel:(id)sender {
    EZDEBUG(@"Cancel get called");
    EZUIUtility.sharedEZUIUtility.cameraClickButton.releasedBlock = nil;
    [self dismissViewControllerAnimated:YES completion:^(){
        EZDEBUG(@"DLCCamera Will get dismissed");
    }];

}

- (void) switchDisplayImage
{
    int imageMode = finalBlendFilter.smallBlurFilter.imageMode + 1;
    if(imageMode > 2){
        imageMode = 0;
    }
    //finalBlendFilter.imageMode = imageMode;
    finalBlendFilter.smallBlurFilter.imageMode = imageMode;
    EZDEBUG(@"I will store the image mode:%i, texelWidth:%f. texelHeight:%f", finalBlendFilter.imageMode, finalBlendFilter.edgeFilter.texelWidth, finalBlendFilter.edgeFilter.texelHeight);
    finalBlendFilter.edgeFilter.texelWidth = finalBlendFilter.edgeFilter.texelWidth;
    finalBlendFilter.edgeFilter.texelHeight = finalBlendFilter.edgeFilter.texelHeight;
    [staticPicture processImage];
    EZDEBUG(@"After call process image");
}


-(IBAction) handlePan:(UIGestureRecognizer *) sender {
    if (hasBlur) {
        CGPoint tapPoint = [sender locationInView:imageView];
        GPUImageGaussianSelectiveBlurFilter* gpu =
            (GPUImageGaussianSelectiveBlurFilter*)blurFilter;
        
        if ([sender state] == UIGestureRecognizerStateBegan) {
            [self showBlurOverlay:YES];
            //[gpu setBlurSize:0.0f];
            if (isStatic) {
                [staticPicture processImage];
            }
        }
        
        if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged) {
            //[gpu setBlurSize:0.0f];
            [self.blurOverlayView setCircleCenter:tapPoint];
            [gpu setExcludeCirclePoint:CGPointMake(tapPoint.x/320.0f, tapPoint.y/320.0f)];
        }
        
        if([sender state] == UIGestureRecognizerStateEnded){
            //[gpu setBlurSize:kStaticBlurSize];
            [self showBlurOverlay:NO];
            if (isStatic) {
                [staticPicture processImage];
            }
        }
    }
}


- (IBAction) handleTapToFocus:(UITapGestureRecognizer *)tgr{
    //[self switchEdges];
	if (!isStatic && tgr.state == UIGestureRecognizerStateRecognized) {
		CGPoint location = [tgr locationInView:self.imageView];
		
		CGPoint pointOfInterest = CGPointMake(.5f, .5f);
		CGSize frameSize = [[self imageView] frame].size;
		if ([stillCamera cameraPosition] == AVCaptureDevicePositionFront) {
            location.x = frameSize.width - location.x;
		}
		pointOfInterest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
        CGPoint center = [tgr locationInView:self.view];
        CGRect focusFrame = CGRectMake(center.x - self.focusView.width/2.0, center.y - self.focusView.height/2.0, orgFocusSize.width, orgFocusSize.height);
        [self focusCamera:pointOfInterest frame:focusFrame expose:TRUE];
    }
}

- (void) focusCamera:(CGPoint)pointOfInterest frame:(CGRect)focusFrame expose:(BOOL)expose
{
    AVCaptureDevice *device = stillCamera.inputCamera;
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:pointOfInterest];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            if(expose){
                if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                    [device setExposurePointOfInterest:pointOfInterest];
                    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                }
            }
            [device unlockForConfiguration];
        } else {
            NSLog(@"ERROR = %@", error);
        }
    }
    
    self.focusView.alpha = 1;
    self.focusView.frame = focusFrame;
    [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
        self.focusView.alpha = 0;
    } completion:nil];


}


-(IBAction) handlePinch:(UIPinchGestureRecognizer *) sender {
    if (hasBlur) {
        CGPoint midpoint = [sender locationInView:imageView];
        GPUImageGaussianSelectiveBlurFilter* gpu =
            (GPUImageGaussianSelectiveBlurFilter*)blurFilter;
        
        if ([sender state] == UIGestureRecognizerStateBegan) {
            [self showBlurOverlay:YES];
            //[gpu setBlurSize:0.0f];
            if (isStatic) {
                [staticPicture processImage];
            }
        }
        
        if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged) {
            //[gpu setBlurSize:0.0f];
            [gpu setExcludeCirclePoint:CGPointMake(midpoint.x/320.0f, midpoint.y/320.0f)];
            self.blurOverlayView.circleCenter = CGPointMake(midpoint.x, midpoint.y);
            CGFloat radius = MAX(MIN(sender.scale*[gpu excludeCircleRadius], 0.6f), 0.15f);
            self.blurOverlayView.radius = radius*320.f;
            [gpu setExcludeCircleRadius:radius];
            sender.scale = 1.0f;
        }
        
        if ([sender state] == UIGestureRecognizerStateEnded) {
            //[gpu setBlurSize:kStaticBlurSize];
            [self showBlurOverlay:NO];
            if (isStatic) {
                [staticPicture processImage];
            }
        }
    }
}

-(void) showFilters {
    [self.filtersToggleButton setSelected:YES];
    self.filtersToggleButton.enabled = NO;
    CGRect imageRect = self.imageView.frame;
    imageRect.origin.y -= 34;
    CGRect sliderScrollFrame = self.filterScrollView.frame;
    sliderScrollFrame.origin.y -= self.filterScrollView.frame.size.height;
    CGRect sliderScrollFrameBackground = self.filtersBackgroundImageView.frame;
    sliderScrollFrameBackground.origin.y -=
    self.filtersBackgroundImageView.frame.size.height-3;
    
    self.filterScrollView.hidden = NO;
    self.filtersBackgroundImageView.hidden = NO;
    [UIView animateWithDuration:0.10
                          delay:0.05
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.imageView.frame = imageRect;
                         self.filterScrollView.frame = sliderScrollFrame;
                         self.filtersBackgroundImageView.frame = sliderScrollFrameBackground;
                     } 
                     completion:^(BOOL finished){
                         self.filtersToggleButton.enabled = YES;
                     }];
}

-(void) hideFilters {
    [self.filtersToggleButton setSelected:NO];
    CGRect imageRect = self.imageView.frame;
    imageRect.origin.y += 34;
    CGRect sliderScrollFrame = self.filterScrollView.frame;
    sliderScrollFrame.origin.y += self.filterScrollView.frame.size.height;
    
    CGRect sliderScrollFrameBackground = self.filtersBackgroundImageView.frame;
    sliderScrollFrameBackground.origin.y += self.filtersBackgroundImageView.frame.size.height-3;
    
    [UIView animateWithDuration:0.10
                          delay:0.05
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.imageView.frame = imageRect;
                         self.filterScrollView.frame = sliderScrollFrame;
                         self.filtersBackgroundImageView.frame = sliderScrollFrameBackground;
                     } 
                     completion:^(BOOL finished){
                         
                         self.filtersToggleButton.enabled = YES;
                         self.filterScrollView.hidden = YES;
                         self.filtersBackgroundImageView.hidden = YES;
                     }];
}

-(IBAction) toggleFilters:(UIButton *)sender {
    sender.enabled = NO;
    if (sender.selected){
        [self hideFilters];
    } else {
        [self showFilters];
    }
    
}

-(void) showBlurOverlay:(BOOL)show{
    if(show){
        [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
            self.blurOverlayView.alpha = 0.6;
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
            self.blurOverlayView.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }
}


-(void) flashBlurOverlay {
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        self.blurOverlayView.alpha = 0.6;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
            self.blurOverlayView.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

-(void) dealloc {
    EZDEBUG(@"DLC dealloced");
    [self removeAllTargets];
    stillCamera = nil;
    cropFilter = nil;
    filter = nil;
    blurFilter = nil;
    staticPicture = nil;
    self.blurOverlayView = nil;
    //self.focusView = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    //[stillCamera stopCameraCapture];
    [super viewWillDisappear:animated];
    
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (outputImage == nil) {
        outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (outputImage) {
        staticPicture = [[GPUImagePicture alloc] initWithImage:outputImage smoothlyScaleOutput:YES];
        staticPictureOriginalOrientation = outputImage.imageOrientation;
        isStatic = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.cameraToggleButton setEnabled:NO];
        [self.flashToggleButton setEnabled:NO];
        [self prepareStaticFilter];
        [self.photoCaptureButton setHidden:NO];
        [self.photoCaptureButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.photoCaptureButton setImage:nil forState:UIControlStateNormal];
        [self.photoCaptureButton setEnabled:YES];
        if(![self.filtersToggleButton isSelected]){
            [self showFilters];
        }

    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (!isStatic) {
        [self retakePhoto:nil];
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#endif

@end
