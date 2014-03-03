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
#import <GPUImageCrosshatchFilter.h>
#import <GPUImageCrosshairGenerator.h>
#import "EZPhoto.h"
#import "EZDataUtil.h"
#import "UIImageView+AFNetworking.h"
#import "EZMessageCenter.h"
#import "EZDisplayPhoto.h"
#import "EZShapeCover.h"
#import "EZExtender.h"
#import "EZClickImage.h"
#import "GPUImageSharpenFilter.h"
#import "EZSkinSharpen.h"
#import "EZSharpenGaussian.h"
#import "EZKeyboadUtility.h"

//#include <vector>

#define kStaticBlurSize 2.0f

#define RotateBackground [UIColor blackColor]

@interface EZMotionRecord : NSObject 

@property (nonatomic, strong) CMAttitude* attitude;

@property (nonatomic, assign) CGFloat turnedAngle;

@property (nonatomic, strong) NSDate* currentTime;

@end

@implementation EZMotionRecord
@end


#define liveTongSetting @[pointValue(0.0, 0.0), pointValue(0.125, 0.125), pointValue(0.25, 0.25), pointValue(0.5, 0.525), pointValue(0.75, 0.770), pointValue(1.0, 1.0)]

#define faceTongSetting @[pointValue(0.0, 0.0), pointValue(0.125, 0.135), pointValue(0.25, 0.275), pointValue(0.5, 0.54), pointValue(0.75, 0.770), pointValue(1.0, 1.0)]



@implementation DLCImagePickerController {
    GPUImageStillCamera * stillCamera;
    GPUImageWhiteBalanceFilter* whiteBalancerFilter;
    //GPUImageSaturationFilter *contrastfilter;
    EZCycleTongFilter* tongFilter;
    GPUImageToneCurveFilter* flashFilter;
    //GPUImageToneCurveFilter* darkFilter;
    UIGestureRecognizer* tapRecognizer;
    GPUImageHueFilter* hueFilter;
    GPUImageOutput<GPUImageInput> *blurFilter;
    GPUImageCropFilter *cropFilter;
    GPUImageFilter* simpleFilter;
    EZSharpenGaussian* sharpenGaussian;
    EZSharpenGaussian* sharpenGaussianSec;
    //EZCycleDiminish* cycleDarken;
    //EZFaceBlurFilter* faceBlurFilter;
    EZNightBlurFilter* darkBlurFilter;
    
    EZColorBrighter* redEnhanceFilter;
    
    
    //Store the matchedPhoto so that I can remove the unmatched later.
    NSMutableArray* matchedPhotos;
    
    //GPUImagePrewittEdgeDetectionFilter * edgeFilter;
    //EZFaceBlurFilter2* dynamicBlurFilter;
    //EZHomeGaussianFilter* biBlurFilter;
    EZHomeBlendFilter* finalBlendFilter;
    EZHomeBlendFilter* secBlendFilter;
    EZHomeBiBlur* skinBlurFilter;
    //Used as the beginning of the filter
    EZDoubleOutFilter* orgFiler;
    GPUImageFilter* filter;
    UIImageOrientation currentOrientation;
    EZSaturationFilter* fixColorFilter;
    EZSaturationFilter* secFixColorFilter;
    GPUImageFilter* skinBrighter;
    EZSkinSharpen* bigSharpenFilter;
    EZSkinSharpen* smallSharpenFilter;
    GPUImagePicture *staticPicture;
    NSMutableArray* tongParameters;
    NSMutableArray* redAdjustments;
    NSMutableArray* greenAdjustments;
    NSMutableArray* blueAdjustments;
    EZShapeCover* shapeCover;
    EZClickImage* rotateView;
    UIView* rotateContainer;
    UIView* roundBackground;
    
    EZDisplayPhoto* disPhoto;
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
    UIButton* quitButton;
    EZClickView* smileDetected;
    UIImageView* blackView;
    UIView* blackCover;
    CGSize orgFocusSize;
    UIView* capturingBlack;
    
    CGPoint prevPanPoint;
    //Cross hair experiment
    //GPUImageCrosshatchFilter* crossHairFilter;
    GPUImageCrosshairGenerator* crossHairFilter;
    //To switch the camera
    EZEventBlock faceCovered;
    
    //Why do like this?
    //So that I could have the functionality
    UIView* textInputRegion;
    UIButton* cancelText;
    CGFloat toolRegionY;
    
    UIView* chatRegion;
    UILabel* chatText;
    EZClickImage* authorIcon;
    //The icon for the matched user
    EZClickImage* otherIcon;
    EZEventBlock keyboardRaiseHandler;
    EZEventBlock keyboardHideHandler;
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
    //blurOverlayView,
    outputJPEGQuality,
    requestedImageSize;

-(void) prepareStaticFilter:(EZFaceResultObj*)fobj image:(UIImage*)img{
    _detectFace = false;
    
    CGFloat dark = 100;//[self getISOSpeedRating];
    hueFilter.hue = 350.0;
    //GPUImageFilter* firstFilter = nil;
    [tongFilter setRgbCompositeControlPoints:liveTongSetting];
    if(dark >= 400){
        //[tongFilter addTarget:darkBlurFilter];
        //firstFilter = (GPUImageFilter*)darkBlurFilter;
        //[staticPicture addTarget:darkBlurFilter];
        [staticPicture addTarget:redEnhanceFilter];
        [redEnhanceFilter addTarget:hueFilter];
        [hueFilter addTarget:tongFilter];
    }else{
        [staticPicture addTarget:redEnhanceFilter];
        [redEnhanceFilter addTarget:hueFilter];
        [hueFilter addTarget:tongFilter];
    }
    EZDEBUG(@"Prepare new static image get called, flash image:%i, image size:%@, dark:%f", _isImageWithFlash, NSStringFromCGSize(img.size), dark);
    //GPUImageFilter* imageFilter = secFixColorFilter;
    whiteBalancerFilter.temperature = 5000.0;
    if(!_disableFaceBeautify && (fobj || stillCamera.isFrontFacing || _shotMode == kSelfShotMode)){
        [tongFilter setRgbCompositeControlPoints:faceTongSetting];
        [tongFilter addTarget:finalBlendFilter];
        [finalBlendFilter addTarget:filter];
    
        secBlendFilter.blurFilter.distanceNormalizationFactor = 20.0;
        secBlendFilter.blurFilter.blurSize = 3.0;
        secBlendFilter.miniRealRatio = 0.1;
        secBlendFilter.imageMode = 0;
        secBlendFilter.skinColorFlag = 1;
        
        finalBlendFilter.blurFilter.distanceNormalizationFactor = 15.0;
        finalBlendFilter.blurFilter.blurSize = 0.5;//fobj.orgRegion.size.width;
        finalBlendFilter.miniRealRatio = 0;
        finalBlendFilter.imageMode = 0;
        finalBlendFilter.skinColorFlag = 1;
        //finalBlendFilter.showFace = 1;
        finalBlendFilter.faceRegion = @[@(fobj.orgRegion.origin.x), @(fobj.orgRegion.origin.x + fobj.orgRegion.size.width), @(fobj.orgRegion.origin.y), @(fobj.orgRegion.origin.y + fobj.orgRegion.size.height)];
        //finalBlendFilter.smallBlurFilter.blurSize = blurAspectRatio * blurCycle;
        EZDEBUG(@"Will adjusted Face");
    }else{
        [tongFilter addTarget:filter];
        //[hueFilter addTarget:filter];
        EZDEBUG(@"No face find out");
    }
    //kSystemSoundID_Vibrate
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


- (void) setupOtherFilters
{
    hueFilter = [[GPUImageHueFilter alloc] init];
    hueFilter.hue = 355;
    EZDEBUG(@"adjust:%f", hueFilter.hue);
    orgFiler = [[EZDoubleOutFilter alloc] init];
    filter = [[GPUImageFilter alloc] init];
    simpleFilter = [[GPUImageFilter alloc] init];
    secFixColorFilter = [self createBlueStretchFilter];
    //[secFixColorFilter updateAllConfigure];
    //[secFixColorFilter ]
    //secFixColorFilter.redEnhanceLevel = 0.6;
    fixColorFilter = [self createRedStretchFilter];
    //[fixColorFilter updateAllConfigure];
    //fixColorFilter.redEnhanceLevel = 0.6;
    redEnhanceFilter = [self createRedEnhanceFilter];
    //finalBlendFilter = [[EZHomeBlendFilter alloc] initWithFilters];   //[self createFaceBlurFilter];
    //secBlendFilter = [self createFaceBlurFilter];
    secBlendFilter = [[EZHomeBlendFilter alloc] initWithTongFilter:[self createTongFilter]];
    //secBlendFilter.imageMode = 3;
    finalBlendFilter = [[EZHomeBlendFilter alloc] initWithFilter:secBlendFilter];
    [finalBlendFilter.tongFilter setRgbCompositeControlPoints:faceTongSetting];
    //cycleDarken = [[EZCycleDiminish alloc] init];
    
}

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

- (id) initWithFront:(BOOL)frontFacing
{
    _frontFacing = frontFacing;
    return [self initWithNibName:@"DLCImagePicker" bundle:nil];
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
    [self.photoCaptureButton setEnabled:NO];
    [self captureImageInner:YES];
    [self removeCaptureView];
    [self changeButtonStatus:YES];

    //[self setupButton]
}

//Will adjust the blur level
- (IBAction) slideChanged:(id)sender
{
    [self adjustSlideValue:sender];
    [staticPicture processImage];
}


- (void) adjustSlideValue:(id)sender
{
    
    //CGFloat rotateAngle = -180.0;
    //finalBlendFilter.blurFilter.distanceNormalizationFactor = 7.01;
    //finalBlendFilter.
    if(sender == _redPoint){
        
        //dynamicBlurFilter.realRatio = _blurRate.value;
        finalBlendFilter.blurFilter.blurSize = _redPoint.value*5;
        //finalBlendFilter.smallBlurFilter.blurSize = blurAspectRatio * _redPoint.value * 5;
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


//Temporary strategy, Will change it later.

//Will match the photo
- (void) startPreFetch:(EZPhoto*)localPhoto imageSuccess:(EZEventBlock)imageSuccess
{
    [[EZDataUtil getInstance] exchangePhoto:nil success:^(EZPhoto* pt){
        EZDEBUG("Find prematched photo:%@, srcID:%@, uploaded flag:%i", pt.screenURL, pt.srcPhotoID, pt.uploaded);
        UIImageView* uw = [UIImageView new];
        [uw preloadImageURL:str2url(pt.screenURL) success:^(UIImage* obj){
            EZDEBUG(@"preload success:%@", pt.screenURL);
                //UIImageView* immd = [UIImageView new];
                //[weakRef setImageWithURL:str2url(pt.screenURL)];
                //[immd setImageWithURL:str2url(pt.screenURL)];
            localPhoto.prefetchDone = YES;
            EZDEBUG(@"test preload result");
            if(imageSuccess){
                imageSuccess(obj);
            }
        } failed:^(id err){
                EZDEBUG(@"Prefetch failure:%@", err);
                localPhoto.prefetchDone = YES;
        }];
        if(localPhoto.photoRelations.count > 0){
            [matchedPhotos addObjectsFromArray:localPhoto.photoRelations];
        }
        localPhoto.photoRelations = @[pt];
    } failure:^(NSError* err){
        EZDEBUG(@"Prematch error:%@", err);
    }];

}


- (void) preMatchPhoto
{
    //__weak DLCImagePickerController* weakSelf = self;
    //Why do this?
    //Create a closure.
    _shotPhoto = [[EZPhoto alloc] init];
    EZPhoto* localPhoto = _shotPhoto;
    [self startPreFetch:localPhoto imageSuccess:nil];
}

//This method is no more necessary.
- (void) cancelPrematchPhoto:(EZPhoto*)matchedPt
{
    //EZDEBUG(@"Start cancel prev match call:%@", matchedPt.photoID);
    //if(_shotPhoto.photoRelations.count){
    //    EZPhoto* matched = [_shotPhoto.photoRelations objectAtIndex:0];
    EZDEBUG(@"Cancle prefetch");
    [[EZDataUtil getInstance] cancelPrematchPhoto:matchedPt success:^(id success){
        EZDEBUG(@"cancel:%@ success", matchedPt.photoID);
    } failure:^(id err){
        EZDEBUG(@"Cancel Failure:%@", err);
    }];
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

//Test Monty Hall issue without the host knew about the which door the goat hide
- (void) executeGame
{
    CGFloat winCount = 0;
    //Why do I have rawCount, because I want to know if I have winning position
    //When find the host don't get the hit.
    CGFloat rawCount = 0;
    CGFloat hostWin = 0;
    CGFloat gamerWin = 0;
    for(int i = 0; i < 10000; i ++){
        int realPos = rand()%3;
        int gamerPos = rand()%3;
        //int hostPos = (rand()%2 + gamerPos)%3;
        int hostPos = rand()%3;
        while (hostPos == gamerPos) {
            hostPos = rand()%3;
        }
        if(hostPos == realPos){
            ++hostWin;
            continue;
        }else if(gamerPos != realPos){
            ++rawCount;
            ++winCount;
        }else if(gamerPos == realPos){
            ++gamerWin;
            ++rawCount;
        }
    }
    EZDEBUG(@"Switch Winning rate:%f, host win:%f, gamer win:%f", winCount/rawCount, hostWin/10000.0, gamerWin/10000.0);
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

- (GPUImageFilter*) createSkinBrighter
{
    EZSkinBrighter* res =  [[EZSkinBrighter alloc] init];
    [res setRgbCompositeControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.125), pointValue(0.25, 0.31), pointValue(0.5, 0.545), pointValue(0.75, 0.785), pointValue(1.0, 1.0)]];
    [res setRedControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.13), pointValue(0.25, 0.26), pointValue(0.5, 0.51), pointValue(0.75, 0.76), pointValue(1.0, 0.99)]];
    [res setBlueControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.118), pointValue(0.25, 0.243), pointValue(0.5, 0.493), pointValue(0.75, 0.743), pointValue(1.0, 0.995)]];
    //[_skinBrighter setRedControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.130), pointValue(0.25, 0.255), pointValue(0.5, 0.505), pointValue(0.75, 0.755), pointValue(1.0, 1.0)]];
    //[_skinBrighter setBlueControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.120), pointValue(0.25, 0.245), pointValue(0.5, 0.495), pointValue(0.75, 0.745), pointValue(1.0, 1.0)]];
    return res;
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
    //faceBlender.smallBlurFilter.blurSize = 0.05;
    faceBlender.blurRatio = 0.0;
    faceBlender.edgeFilter.threshold = 0.4;
    return faceBlender;
}

- (EZCycleTongFilter*) createTongFilter
{
    GPUImageToneCurveFilter* resFilter = [[GPUImageToneCurveFilter alloc] init];
    [resFilter setRgbCompositeControlPoints:@[pointValue(0.0, 0.0), pointValue(0.125, 0.125), pointValue(0.25, 0.25), pointValue(0.5, 0.525), pointValue(0.75, 0.770), pointValue(1.0, 1.0)]];
    [resFilter setRedControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.13), pointValue(0.25, 0.26), pointValue(0.5, 0.51), pointValue(0.75, 0.76), pointValue(1.0, 0.99)]];
    [resFilter setBlueControlPoints:@[pointValue(0.0, 0.0),pointValue(0.125, 0.118), pointValue(0.25, 0.243), pointValue(0.5, 0.493), pointValue(0.75, 0.743), pointValue(1.0, 0.995)]];
    return resFilter;
}

- (EZColorBrighter*) createRedEnhanceFilter
{
    EZColorBrighter* res = [[EZColorBrighter alloc] init];
    res.redEnhanceLevel = 0.65; //0.725
    res.redRatio = 0.95;
    
    res.blueEnhanceLevel = 0.6;
    res.blueRatio = 0.2;
    
    res.greenEnhanceLevel = 0.6;//0.8
    res.greenRatio = 1.3;
    
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
    //[self startMobileMotion];
    [[EZMessageCenter getInstance] registerEvent:EZFaceCovered block:faceCovered];
    [self preMatchPhoto];
    [[EZUIUtility sharedEZUIUtility] enableProximate:YES];
}

- (void) setupButton
{
    [self.photoCaptureButton setTitleColor:RGBCOLOR(43, 43, 43) forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:RGBCOLOR(43, 43, 43) forState:UIControlStateNormal];
    [self.configButton setTitleColor:RGBCOLOR(43, 43, 43) forState:UIControlStateNormal];
}

- (void) viewDidLoad
{
    [EZUIUtility sharedEZUIUtility].cameraRaised = true;
    [super viewDidLoad];
    
    //self.view.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    _senseRotate = true;
    //_recordedMotions = [[NSMutableArray alloc] init];
    _flashView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _flashView.backgroundColor = [UIColor whiteColor];
    _flashMode = 2;
    
    [self setupFlashFilter];
    [self setupDarkFilter];
    [self setupButton];
    matchedPhotos = [[NSMutableArray alloc] init];
    _storedMotionDelta = [[NSMutableArray alloc] init];
    self.wantsFullScreenLayout = YES;
    _pageTurn = [[EZSoundEffect alloc] initWithSoundNamed:@"page_turn.aiff"];
    _shotReady = [[EZSoundEffect alloc] initWithSoundNamed:@"shot_voice.aiff"];
    _shotVoice = [[EZSoundEffect alloc] initWithSoundNamed:@"shot.wav"];
    
    bigSharpenFilter = [[EZSkinSharpen alloc] init];
    bigSharpenFilter.sharpenSize = 3.2;
    bigSharpenFilter.sharpenRatio = 0.2;
    bigSharpenFilter.sharpenBar = 0.1;
    
    smallSharpenFilter = [[EZSkinSharpen alloc] init];
    smallSharpenFilter.sharpenSize = 1.6;
    smallSharpenFilter.sharpenRatio = 0.2;
    smallSharpenFilter.sharpenBar = 0.1;
    
    
    sharpenGaussian = [[EZSharpenGaussian alloc] init];
    sharpenGaussianSec = [[EZSharpenGaussian alloc] init];
    
    //sharpenFilter.sharpness = 0.3;
    
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
    
    __weak DLCImagePickerController* weakSelf = self;
    faceCovered = ^(NSNumber* status){
        [weakSelf coverStatusChange:status.intValue];
    };
    //self.blurOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //self.blurOverlayView.alpha = 0;
    //[self.imageView addSubview:self.blurOverlayView];
    
    //No issue.
    hasBlur = NO;
    //we need a crop filter for the live video
    float widthAspect = [UIScreen mainScreen].bounds.size.width/[UIScreen mainScreen].bounds.size.height;
    EZDEBUG(@"The width aspect ratio is:%f", widthAspect);
    [self setupOtherFilters];
    [self setupTongFilter];
    skinBrighter = [self createSkinBrighter];
    imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    EZDEBUG(@"The imageView frame:%@", NSStringFromCGRect(imageView.frame));
    //[self setupEdgeDetector];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self setupCamera];
    });
    //[self startFaceCapture];
    [self setupUI];
    [self createTextField];
    [self setupKeyboard];
}

- (void) longCoverStart
{
    EZDEBUG(@"Will start the long cover");
    __weak DLCImagePickerController* weakSelf = self;
    _cancelShot = false;
    if(!_coverTapView){
        _coverTapView = [[EZClickView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        _coverTapView.backgroundColor = [UIColor blackColor];
        _coverTapView.enableTouchEffects = NO;
    }
    [TopView addSubview:_coverTapView];
    _coverTapView.pressedBlock  = ^(id obj){
        EZDEBUG(@"Will cover shot");
        weakSelf.cancelShot = true;
        //[_shotVoice play];
        [weakSelf.coverTapView removeFromSuperview];
        if(weakSelf.coverStatus == kCoverShotting){
            weakSelf.coverStatus = kCoverInit;
        }
        
        UILabel* cancelInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 320, 30)];
        cancelInfo.font = [UIFont boldSystemFontOfSize:18];
        cancelInfo.textColor = [UIColor whiteColor];
        cancelInfo.textAlignment = NSTextAlignmentCenter;
        cancelInfo.text = macroControlInfo(@"Self shot cancelled");
        [TopView addSubview:cancelInfo];
        dispatch_later(1.2, ^(){
            [cancelInfo removeFromSuperview];
        });
        
    };
    
    if(stillCamera.isFrontFacing){
        [self switchCamera];
    }
    [self startCoverCapture];
}

- (void) coverStatusChange:(int)status
{
    __weak DLCImagePickerController* weakSelf = self;
    EZDEBUG(@"face status:%i", status);
    if(isStatic){
        EZDEBUG(@"Quit for static");
        _coverStatus = kCoverInit;
        return;
    }
    if(_coverStatus == kCoverShotting){
        EZDEBUG(@"quit for shotting");
        return;
    }
    if(_coverStatus == kCoverInit && status == 1){
        EZDEBUG(@"Will start long cover");
        _coverStatus = kCoverStart;
        _longCover = ^(id obj){
            [weakSelf longCoverStart];
        };
        dispatch_later(1.0, ^(){
            if(_longCover){
                _coverStatus = kCoverShotting;
                _longCover(nil);
            }
        });
        //dispatch_later(0.5, ^(){});
    }else if(_coverStatus == kCoverStart && status == 0){
        _coverStatus = kCoverInit;
        _longCover = nil;
        [self switchCamera];
    }
    //[weakSelf switchCamera];
}

-(void)viewDidLoadOld {
    [EZUIUtility sharedEZUIUtility].cameraRaised = true;
    [super viewDidLoad];
    
    //self.view.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    _senseRotate = true;
    //_recordedMotions = [[NSMutableArray alloc] init];
    _flashView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _flashView.backgroundColor = [UIColor whiteColor];
    _flashMode = 2;

    [self setupFlashFilter];
    [self setupDarkFilter];
    [self setupButton];
    matchedPhotos = [[NSMutableArray alloc] init];
    _storedMotionDelta = [[NSMutableArray alloc] init];
    self.wantsFullScreenLayout = YES;
    _pageTurn = [[EZSoundEffect alloc] initWithSoundNamed:@"page_turn.aiff"];
    _shotReady = [[EZSoundEffect alloc] initWithSoundNamed:@"shot_voice.aiff"];
    _shotVoice = [[EZSoundEffect alloc] initWithSoundNamed:@"shot.wav"];
    
    bigSharpenFilter = [[EZSkinSharpen alloc] init];
    bigSharpenFilter.sharpenSize = 3.2;
    bigSharpenFilter.sharpenRatio = 0.2;
    bigSharpenFilter.sharpenBar = 0.1;
    
    smallSharpenFilter = [[EZSkinSharpen alloc] init];
    smallSharpenFilter.sharpenSize = 1.6;
    smallSharpenFilter.sharpenRatio = 0.2;
    smallSharpenFilter.sharpenBar = 0.1;
    
    
    sharpenGaussian = [[EZSharpenGaussian alloc] init];
    sharpenGaussianSec = [[EZSharpenGaussian alloc] init];
    
    //sharpenFilter.sharpness = 0.3;
    
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
    
    //self.blurOverlayView = [[DLCBlurOverlayView alloc] initWithFrame:CGRectMake(0, 0,
	//																			self.imageView.frame.size.width,
//																				self.imageView.frame.size.height)];
    __weak DLCImagePickerController* weakSelf = self;
    faceCovered = ^(NSNumber* status){
        EZDEBUG(@"face status:%i", status.intValue);
        [weakSelf switchCamera];
    };
    //self.blurOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //self.blurOverlayView.alpha = 0;
    //[self.imageView addSubview:self.blurOverlayView];
    
    //No issue.
    hasBlur = NO;
    //we need a crop filter for the live video
    float widthAspect = [UIScreen mainScreen].bounds.size.width/[UIScreen mainScreen].bounds.size.height;
    EZDEBUG(@"The width aspect ratio is:%f", widthAspect);
    [self setupOtherFilters];
    [self setupTongFilter];
    skinBrighter = [self createSkinBrighter];
    imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    EZDEBUG(@"The imageView frame:%@", NSStringFromCGRect(imageView.frame));
    //[self setupEdgeDetector];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self setupCamera];
    });
    //[self startFaceCapture];
    [self setupUI];
    [self createTextField];
    [self setupKeyboard];
    
}

- (void) createChatRegion
{
    if(!chatRegion){
        chatRegion = [[UIView alloc] initWithFrame:CGRectMake(5, 100, 310, 80)];
        chatRegion.backgroundColor = [UIColor clearColor];
    
        chatText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 20)];
        chatText.font = [UIFont boldSystemFontOfSize:16];
        chatText.textAlignment = NSTextAlignmentRight;
        [chatText setTextColor:[UIColor whiteColor]];
    
        authorIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(265, 0, 35, 35)];
        authorIcon.backgroundColor = [UIColor whiteColor];
        [authorIcon enableRoundImage];
        [authorIcon setImageWithURL:str2url([EZDataUtil getInstance].currentLoginPerson.avatar)];
        [chatRegion addSubview:chatText];
        [chatRegion addSubview:authorIcon];
        //[self.view addSubview:chatRegion];
    }
    //[self.view addSubview:chatRegion];
    
}

- (void) setupKeyboard
{
    __weak DLCImagePickerController* weakSelf = self;
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    EZClickView* cancelKeyboard = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 320, appFrame.size.height - textInputRegion.bounds.size.height)];
    cancelKeyboard.backgroundColor = [UIColor clearColor];//RGBA(128, 0, 0, 128);
    cancelKeyboard.enableTouchEffects = false;
    cancelKeyboard.releasedBlock = ^(id obj){
        EZDEBUG(@"cancel clicked");
        weakSelf.hideTextInput = false;
        [weakSelf.textField resignFirstResponder];
        //[self hideKeyboard:NO];
    };
    keyboardRaiseHandler = ^(id obj){
        EZKeyboadUtility* keyUtil = [EZKeyboadUtility getInstance];
        CGRect keyFrame = [keyUtil keyboardFrameToView:weakSelf.view];
        CGFloat smallGap = keyUtil.gapHeight;
        EZDEBUG(@"keyboard raised:%@, appFrame:%@, smallGap:%f",NSStringFromCGRect(keyFrame), NSStringFromCGRect(appFrame), smallGap);

        if(abs(smallGap) > 0){
            [weakSelf liftWithBottom:smallGap time:0.3 complete:nil];
        }else{
            //weakSelf.toolBarRegion.hidden = TRUE;
            [weakSelf.view addSubview:cancelKeyboard];
            [weakSelf liftWithBottom:-keyFrame.size.height time:0.3 complete:nil];
        }
    };
    
    keyboardHideHandler = ^(id obj){
        [cancelKeyboard removeFromSuperview];
        //[weakSelf liftWithBottom:-keyFrame.size.height time:0.6];
        [weakSelf hideKeyboard:weakSelf.hideTextInput complete:nil];
        
    };
    //[[EZMessageCenter getInstance] registerEvent:EZ block:
    _centerButtonY = [EZDataUtil getInstance].centerButton.frame.origin.y;
    [[EZMessageCenter getInstance] registerEvent:EventKeyboardWillRaise block:keyboardRaiseHandler];
    [[EZMessageCenter getInstance] registerEvent:EventKeyboardWillHide block:keyboardHideHandler];

}

//I will check if have the text field or not.
- (void) hideKeyboard:(BOOL)hideTextRegion complete:(EZEventBlock)complete
{
    
    [UIView animateWithDuration:0.4  animations:^(){
        if(hideTextRegion){
            //[EZDataUtil getInstance].centerButton.y = _centerButtonY;
            [self showTextField:NO];
        }else{
            //[EZDataUtil getInstance].centerButton.y = _centerButtonY - textInputRegion.frame.size.height;
        }
        self.view.y = 0;
    } completion:^(BOOL completed){
        //_toolBarRegion.hidden = FALSE;
        if(hideTextRegion){
            //[self showTextField:NO];
        }
        if(complete){
            complete(nil);
        }
    }];
}
     
- (void) liftWithBottom:(CGFloat)delta time:(CGFloat)timeval complete:(EZEventBlock)complete
{
    //textFieldShouldReturn
    [UIView animateWithDuration:timeval delay:0.0 options:UIViewAnimationOptionCurveLinear  animations:^(){
        //[[EZDataUtil getInstance].centerButton moveY:delta];
        [self.view moveY:delta];
        //cancelButton
    } completion:^(BOOL completed){
        if(complete){
            complete(nil);
        }
    }];

}

- (void) cancelText:(UIButton*)button
{
    EZDEBUG(@"The text is:%@", _textField.text);
    //[field resignFirstResponder];
    _textField.text = @"";
}

- (void) createTextField
{
    CGRect bounds = [UIScreen mainScreen].applicationFrame;
    textInputRegion = [[UIView alloc] initWithFrame:CGRectMake(0, bounds.size.height, 320, 44)];
    textInputRegion.backgroundColor = [UIColor whiteColor];
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 310, 44)];
    _textField.placeholder = macroControlInfo(@"Say something");
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeySend;
    //cancelText = [[UIButton alloc] initWithFrame:CGRectMake(255, 0, 60, 44)];
    //[cancelText setTitle:macroControlInfo(@"Cancel-Text") forState:UIControlStateNormal];
    //[cancelText setTitleColor:RGBCOLOR(128, 128, 128) forState:UIControlStateNormal];
    //[cancelText addTarget:self action:@selector(cancelText:) forControlEvents:UIControlEventTouchUpInside];
    //[textInputRegion addSubview:cancelText];
    [textInputRegion addSubview:_textField];
    [self.view addSubview:textInputRegion];
}

/**
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return true;
}
**/

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    EZDEBUG(@"Rotate back");
    //if(!_turnedImage){
    //    _turnedImage = TRUE;
        //[self rotateCurrentImage:[disPhoto.photo getScreenImage]];
    //}
}


- (BOOL)textFieldShouldReturn:(UITextField *)textFd
{
    CGRect bound = self.view.bounds;
    EZDEBUG(@"Should return:%@", _textField.text);
    _hideTextInput = false;
    if(![_textField.text isEmpty]){
        [disPhoto.photo.conversations addObject:@{
                                                  @"text":_textField.text,
                                                  @"date":[NSDate date]
                                                }];
        EZDEBUG(@"added input to photo:%@", disPhoto.photo.conversations);
        [self createChatRegion];
        chatText.text = _textField.text;
        [chatText enableTextWrap];
        chatRegion.y = bound.size.height;
        EZDEBUG(@"show avatar:%@", currentLoginUser.avatar);
        [authorIcon setImageWithURL:str2url(currentLoginUser.avatar)];
        [self.view addSubview:chatRegion];
        dispatch_later(0.3, ^(){
        [UIView animateWithDuration:0.35 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^(){
            chatRegion.y =  bound.size.height - (bound.size.height - 320)/2.0 + 10.0;
        } completion:^(BOOL completed){
            //[chatRegion removeFromSuperview];
        }];
        });
        _textField.text = @"";

        
    }
    _hideTextInput = true;
    dispatch_later(2.0, ^(){
            //[self savePhoto];
            //[self retakePhoto:nil];
            [self takePhoto:nil];
            [chatRegion removeFromSuperview];
            //[self showTextField:NO];
    });
    [textFd resignFirstResponder];
    return true;
}

- (void) showTextField:(BOOL)show
{
    EZDEBUG(@"show text field:%i", show);
    CGRect bounds = [UIScreen mainScreen].applicationFrame;
    //usingSpringWithDamping:0.5 initialSpringVelocity:0.5
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut  animations:^(){
        if(show){
            //_toolBarRegion.y = _toolBarRegion.frame.origin.y - 44;
            textInputRegion.y = bounds.size.height - 44;
            //[[EZDataUtil getInstance].centerButton moveY:-44];
            _toolBarRegion.alpha = 0;
            [EZDataUtil getInstance].centerButton.alpha = 0;
        }else{
            textInputRegion.y = bounds.size.height;
            _toolBarRegion.alpha = 1.0;
            //[[EZDataUtil getInstance].centerButton moveY:44];
            [EZDataUtil getInstance].centerButton.alpha = 1.0;
        }
    } completion:^(BOOL completed){
        
    }];
}

- (void) setupUI
{
    __weak DLCImagePickerController* weakSelf = self;
     CGRect bound = [UIScreen mainScreen].bounds;
    shapeCover = [[EZShapeCover alloc] initWithFrame:imageView.frame];
    EZDEBUG(@"initial frame:%@", NSStringFromCGRect(imageView.frame));
    shapeCover.userInteractionEnabled = TRUE;
    tapRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapRecognizer addTarget:self action:@selector(handleTapToFocus:)];
    [shapeCover addGestureRecognizer:tapRecognizer];
    [self.view addSubview:shapeCover];
    //quitButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 10, 60, 44)];
    //[quitButton setTitle:@"退出" forState:UIControlStateNormal];
    //[quitButton addTarget:self action:@selector(quit:) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:quitButton];
    
    
    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(5, bound.size.height - 44 - 10, 60, 44)];
    [cancelButton setTitle:@"退出" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.center = CGPointMake(5+30, 80 - 35);
    //cancelButton.hidden = NO;
    
    _configButton = [[UIButton alloc] initWithFrame:CGRectMake(320 - 60 - 5, bound.size.height - 44 - 10, 60, 44)];
    [_configButton setTitle:@"设置" forState:UIControlStateNormal];
    [_configButton addTarget:self action:@selector(configClicked:) forControlEvents:UIControlEventTouchUpInside];
    _configButton.center = CGPointMake(315 - 30 - 5, 80 - 35);
    
    _toolBarRegion = [[UIView alloc] initWithFrame:CGRectMake(0, bound.size.height - 80, 320, 80)];
    _toolBarRegion.backgroundColor = [UIColor clearColor];
    [_toolBarRegion addSubview:cancelButton];
    [_toolBarRegion addSubview:_configButton];
    [self.view addSubview:_toolBarRegion];
    
    rotateContainer = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 310, 310)];
    [rotateContainer enableRoundImage];
    rotateContainer.alpha = 0.0;
    [self.view addSubview:rotateContainer];
    
    rotateView = [[EZClickImage alloc] initWithFrame:CGRectMake(0, 0, 310, 310)];
    rotateView.contentMode = UIViewContentModeScaleAspectFill;
    [rotateView enableRoundImage];
    //rotateView.alpha = 1.0;
    rotateView.pressedBlock = ^(id obj){
        [weakSelf changePhoto];
        
    };
    [rotateContainer addSubview:rotateView];
    _isFrontCamera = false;
    retakeButton = cancelImage;
    topBar.backgroundColor = RGBA(255, 255, 255, 128);
    _oldBlock = [EZDataUtil getInstance].centerButton.releasedBlock;
    [EZDataUtil getInstance].centerButton.releasedBlock = ^(id obj){
        [weakSelf takePhoto:nil];
    };
}


- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if(!_firstTime){
        _firstTime = true;
        EZDEBUG(@"imageView.bounds:%@", NSStringFromCGRect(imageView.frame));
        shapeCover.frame = imageView.frame;
        //shapeCover.backgroundColor = [UIColor blackColor];
        [shapeCover digHole:310 color:[UIColor blackColor] opacity:0.4];
        CGFloat adjustedY = (imageView.frame.size.height - 310)/2.0 - 10.0;
        //roundBackground.frame = imageView.frame;
        rotateContainer.y = adjustedY;
        toolRegionY = _toolBarRegion.frame.origin.y;
    }

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
            return;
        }
    }
    if(absDelta > 0.95){
        EZDEBUG(@"Will rotate for %f, _turnStatus:%i", absDelta, _turnStatus);
        if(_turnStatus == kCameraNormal && stillCamera.isFrontFacing){
            //EZDEBUG(@"I am in half turn now");
            //if(stillCamera.isFrontFacing){
            EZDEBUG(@"Will start capture now, isFront:%i", stillCamera.isFrontFacing);
            _turnStatus = kSelfShotDormant;
            dispatch_later(0.5,  ^(void){
                EZDEBUG(@"shot started:%i", _turnStatus);
                if(_turnStatus == kSelfShotDormant){
                    _turnStatus = kCameraCapturing;
                    [_pageTurn play];
                    if(stillCamera.isFrontFacing){
                        [self switchCameraInner];
                    }
                }
            });
        }
    }
   
}

- (void) addCaptureView
{
    if(!capturingBlack){
        capturingBlack = [[UIView alloc] initWithFrame:imageView.bounds];
        capturingBlack.backgroundColor = [UIColor blackColor];
    }
    [imageView addSubview:capturingBlack];
}

- (void) removeCaptureView
{
    [capturingBlack removeFromSuperview];
}

- (void) startCoverCapture
{
    dispatch_later(0.3, ^(){
        [_shotReady play];
    });
    [self performSelector:@selector(takePhoto:)
               withObject:nil
               afterDelay:3.0];
}



- (void) startTurnCapture
{
    //[self addCaptureView];
    dispatch_later(0.3, ^(){
        [_shotReady play];
    });
    [self performSelector:@selector(captureTurnedImage)
               withObject:nil
               afterDelay:3.0];
}


- (void) startMobileMotion
{
    __weak DLCImagePickerController* weakSelf = self;
    [[EZMotionUtility getInstance] registerHandler:^(EZMotionData* md){
        [weakSelf handleMobileMotion:md];
    } key:@"CameraMotion" type:kEZRotation];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    EZDEBUG(@"Becaming invisible");
    [self becomeInvisible];
    EZDEBUG(@"invisible now");
    [EZUIUtility sharedEZUIUtility].cameraRaised = false;
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
    [[EZMessageCenter getInstance] unregisterEvent:EZFaceCovered forObject:faceCovered];
    [[EZMessageCenter getInstance] unregisterEvent:EventKeyboardWillRaise forObject:keyboardRaiseHandler];
    [[EZMessageCenter getInstance] unregisterEvent:EventKeyboardWillHide forObject:keyboardHideHandler];
    [self hideKeyboard:YES complete:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:false];
    [EZDataUtil getInstance].centerButton.releasedBlock = _oldBlock;
}

-(void) setupCamera {
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        //Has camera
        stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:(_frontFacing?AVCaptureDevicePositionFront:AVCaptureDevicePositionBack)];
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
            _detectedFaceObj = fres;
            NSArray* res = [self adjustFrameForOrienation:faceRegion orientation:orientation];
            CGPoint poi = [[res objectAtIndex:0] CGPointValue];
            CGFloat distP = [self calDistance:_prevFocusPoint current:poi];
            _prevFocusPoint = poi;
            CGRect fixFrame = [[res objectAtIndex:1] CGRectValue];
            EZDEBUG(@"Find face at:%@, frame:%@, disP:%f, adjustFocus:%i", NSStringFromCGRect(faceRegion), NSStringFromCGRect(fixFrame), distP, (distP>20));
            if(distP > 20){
                dispatch_main(^(){
                    if(!isStatic){
                        [self focusCamera:poi frame:fixFrame expose:false];
                    }
                    _detectingFace = false;
                    if(_turnStatus == kCameraCapturing){
                        _turnStatus = kFaceCaptured;
                        [self startTurnCapture];
                    }
                });
            }else{
                _detectingFace = false;
            }
        }else{
            _detectingFace = false;
            _detectedFaceObj = nil;
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
    EZDEBUG(@"Prepare live filter");
    _detectFace = true;
    //[self startFaceCapture];
    hueFilter.hue = 350;
    
    [tongFilter setRgbCompositeControlPoints:liveTongSetting];
    [stillCamera addTarget:orgFiler];
    [orgFiler addTarget:redEnhanceFilter];
    [redEnhanceFilter addTarget:hueFilter];
    [hueFilter addTarget:tongFilter];
    [tongFilter addTarget:filter];
    [filter addTarget:self.imageView];
    [filter prepareForImageCapture];
}

- (EZClickView*) createSmileButton
{
    CGRect bound = [UIScreen mainScreen].bounds;
    EZClickView* smile = [[EZClickView alloc] initWithFrame:CGRectMake(160 + (204.0 - 66.0)/2, bound.size.height-66.0-50, 66.0, 66.0)];
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


-(void) prepareStaticFilter {
    [self prepareStaticFilter:nil image:nil];
}

-(void) removeAllTargets {
    [stillCamera removeAllTargets];
    [staticPicture removeAllTargets];
    [whiteBalancerFilter removeAllTargets];
    [cropFilter removeAllTargets];
    [tongFilter removeAllTargets];
    [skinBrighter removeAllTargets];
    [darkBlurFilter removeAllTargets];
    [simpleFilter removeAllTargets];
    [redEnhanceFilter removeAllTargets];
    [smallSharpenFilter removeAllTargets];
    [bigSharpenFilter removeAllTargets];
    //blur
    [blurFilter removeAllTargets];
    [hueFilter removeAllTargets];
    [finalBlendFilter removeAllTargets];
    [orgFiler removeAllTargets];
    [filter removeAllTargets];
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
    //[flashToggleButton setImage:[UIImage imageNamed:flashFile] forState:UIControlStateNormal];
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
		//CGSize frameSize = self.blurOverlayView.frame.size;
		//self.blurOverlayView.circleCenter = CGPointMake(excludePoint.x * frameSize.width, excludePoint.y * frameSize.height);
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
    //_selfShot = false;
    _turnStatus = kCameraNormal;
    [self switchCameraOnly];
}

-(void) switchCameraInner {
    //[_pageTurn play];
    [self switchCameraOnly];
}

- (void) switchCameraOnly {
    //[self.cameraToggleButton setEnabled:NO];
    [stillCamera rotateCamera];
    //[self.cameraToggleButton setEnabled:YES];
    
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
    if(!stillCamera.isFrontFacing && _flashMode > 0 &&
       [stillCamera.inputCamera hasTorch]){
        EZDEBUG(@"Flash mode is :%i", _flashMode);
        _isImageWithFlash = true;
        if(_flashMode == 1){
            EZDEBUG(@"Manual mode");
            if ([stillCamera.inputCamera lockForConfiguration:nil]){
                [stillCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
                [stillCamera.inputCamera unlockForConfiguration];
            }
            [self performSelector:@selector(captureImage)
                   withObject:nil
                   afterDelay:0.8];
        }else{
            EZDEBUG(@"Flash auto mode");
            if ([stillCamera.inputCamera lockForConfiguration:nil]){
                [stillCamera.inputCamera setTorchMode:AVCaptureTorchModeAuto];
                [stillCamera.inputCamera unlockForConfiguration];
            }
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
    //EZDEBUG(@"Captured meta data:%@", photoMeta);
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
    
    if(!_detectedFaceObj){
        UIImage* detectImage = img;
        //if(!stillCamera.isFrontFacing){
            //detectImage = [img changeOriention:UIImageOrientationUp];
        //}
        EZDEBUG(@"Capture the flip is:%i, flipped orientation:%i, orginal:%i, staticOrientation:%i", flip, detectImage.imageOrientation, img.imageOrientation, staticPictureOriginalOrientation);

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
    }
    [self prepareStaticFilter:_detectedFaceObj image:img];
    [staticPicture processImage];
    
    UIImage* currentImage = [self getPhotoAndUpload];
    //if(_detectedFaceObj){
    //    currentImage = [currentImage resizedImageWithMaximumSize:currentImage.size antialias:true];
    //}
    [self removeAllTargets];
    staticPicture = nil;
    [self prepareRotateImage:currentImage];
    //[self showTextField:YES];
    if(_shotPhoto.photoRelations.count){
        EZPhoto* matched = [_shotPhoto.photoRelations objectAtIndex:0];
        EZDEBUG(@"prefetch image:%@", matched.screenURL);
        
        [[EZDataUtil getInstance] prefetchImage:matched.screenURL success:^(UIImage* image){
            //[rotateView.layer removeAllAnimations];
            EZDEBUG(@"image fetched back");
            //dispatch_later(0.5,
                        //^(){
                               //[self stopRotateImage:image];
                        //       _showOther = YES;
            
                         //  });
            _otherImage = image;
            _flipStatus = kStoredPhoto;
             //[self rotateCurrentImage:image];
        } failure:^(id err){
            EZDEBUG(@"Failed to get image:%@, url:%@", err, matched.screenURL);
            //[self hideRotateImage];
            _flipStatus = kStoredPhoto;
        }];
    }else{
        ///dispatch_later(0.5, ^(){
        //    EZDEBUG(@"Did find matched photo");
        //    [self stopRotateImage:nil];
        //});
    }
    EZDEBUG(@"started spin animation");
    isStatic = true;
    if(_coverStatus == kCoverShotting){
        _coverStatus = kCoverInit;
    }
    //_takingPhoto = false;
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

//For fix the memory leakage
- (BOOL) haveDetectedFace
{
    return (!_disableFaceBeautify && (_detectedFaceObj || stillCamera.isFrontFacing || _shotMode == kSelfShotMode));
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
            //BOOL antialias = [weakSelf haveDetectedFace];
            fullImg = [fullImg resizedImageWithMinimumSize:CGSizeMake(fullImg.size.width/2.0, fullImg.size.height/2.0) antialias:NO];
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

- (UILabel*) createBalanceLabel
{
    UILabel* balance = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 30)];
    balance.font = [UIFont boldSystemFontOfSize:18];
    balance.textColor = [UIColor whiteColor];
    balance.textAlignment = NSTextAlignmentCenter;
    return  balance;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"clicked button:%i", buttonIndex);
    if(buttonIndex == 0){
        [self switchCamera];
    }else if(buttonIndex == 1){
        [self toggleFlash:nil];
    }else if(buttonIndex == 2){
        _disableFaceBeautify = !_disableFaceBeautify;
    }
}




- (IBAction) configClicked:(id)sender
{
    //if(_flipStatus == kTakingPhoto){
    //NSString* cameraSwitch = @"翻转摄像头";
    //redEnhanceFilter.brightMode = !redEnhanceFilter.brightMode;
    EZDEBUG(@"Current bright Mode:%i", redEnhanceFilter.brightMode);
    [staticPicture processImage];
        NSString* flashMode = @"闪光灯:自动";
        if(_flashMode == 0){
            flashMode = @"闪光灯:关闭";
        }else if(_flashMode == 1){
            flashMode = @"闪光灯:打开";
        }
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"相机设置" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"翻转摄像头",flashMode,(_disableFaceBeautify?@"打开美化":@"关闭美化"), nil];
        [actionSheet showInView:self.view];
    
}


- (void) changePhoto
{
    /**
    if(_flipStatus == kTakedPhoto){
        [self startRotateImage:nil];
        [self startPreFetch:_shotPhoto imageSuccess:^(UIImage* img){
            [self stopRotateImage:img];
        }];
    }
     **/
    if(_flipStatus != kTakedPhoto){
        EZDEBUG(@"Quit for not take photo");
        return;
    }
    EZDEBUG(@"Showother:%i", _showOther);
    if(_showOther){
        _showOther = false;
        [self rotateCurrentImage:disPhoto.photo.getScreenImage];
        [self showTextField:YES];
    }else{
        _showOther = true;
        [self rotateCurrentImage:_otherImage];
        [self showTextField:NO];
    }
}

- (void) fakeAnimation:(UIImage*)image
{
    //UIView* snapView = [rotateView snapshotViewAfterScreenUpdates:NO];
    //UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    
    //[rotateContainer insertSubview:snapView aboveSubview:rotateView];
    rotateView.image = image;
    
    //[UIView flipTransition:snapView dest:rotateView container:rotateContainer isLeft:YES duration:0.5 complete:^(id obj){
//        [snapView removeFromSuperview];
//    }];
    
    //[view removeFromSuperview];
    //[snapView removeFromSuperview];
    EZDEBUG(@"Just remove a rotate view");
    /**
    [UIView animateWithDuration:0.1 animations:^(){
        rotateView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    } completion:^(BOOL completed){
        
    }];
     **/
}

- (void) rotateCurrentImage:(UIImage*)image
{
    UIView* snapView = [rotateView snapshotViewAfterScreenUpdates:NO];
    [rotateContainer insertSubview:snapView aboveSubview:rotateView];
    rotateView.image = image;
    [UIView flipTransition:snapView dest:rotateView container:rotateContainer isLeft:YES duration:0.5 complete:^(id obj){
        [snapView removeFromSuperview];
    }];
}
//Don't rotate, only get rotation ready.
- (void) prepareRotateImage:(UIImage*)image
{
    if(image){
        rotateView.image = image;
    }
    shapeCover.backgroundColor = RotateBackground;
    [UIView animateWithDuration:0.3 animations:^(){
        //shapeCover.backgroundColor = RotateBackground;
        rotateContainer.alpha = 1.0;
    }];
}

- (void) hideRotateImage
{
    //roundBackground.alpha = 0.0;
    shapeCover.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.3 animations:^(){
        //shapeCover.backgroundColor = [UIColor clearColor];
        rotateContainer.alpha = 0.0;
    }];
    //[rotateContainer.layer removeAllAnimations];
}

- (void) startRotateImage:(UIImage*)image
{
    //roundBackground.alpha = 1.0;
    [self prepareRotateImage:image];
    [rotateView runSpinAnimation:2.0 rotations:2.0 repeat:1000.0];

}

- (void) stopRotateImage:(UIImage*)image;
{
    if(image){
        rotateView.image = image;
    }
    [rotateContainer.layer removeAllAnimations];
}



- (IBAction) panHandler:(id)sender
{
    
}

- (IBAction) panHandlerOld:(id)sender
{
    if(!isStatic){
        return;
    }
    CGPoint tapPoint = [sender locationInView:imageView];
    UILabel* label = (UILabel*)[imageView viewWithTag:20140203];
    if ([sender state] == UIGestureRecognizerStateBegan) {
        //[self showBlurOverlay:YES];
        //[gpu setBlurSize:0.0f];
        //if (isStatic) {
        //    [staticPicture processImage];
        //}
        
        if(!label){
            label = [self createBalanceLabel];
            label.tag = 20140203;
            [imageView addSubview:label];
        }
        label.alpha = 1.0;
        label.text = int2str(whiteBalancerFilter.temperature);
        prevPanPoint = tapPoint;
        //return;
    }else
    
    if ([sender state] == UIGestureRecognizerStateChanged) {
        CGFloat miniTemp = 4000.0;
        CGFloat maxTemp = 8000.0;
        CGFloat delta = tapPoint.x - prevPanPoint.x;
        CGFloat change = whiteBalancerFilter.temperature + (delta/320.0) * (maxTemp - miniTemp);
        if(change < miniTemp){
            change = miniTemp;
        }else if(change > maxTemp){
            change = maxTemp;
        }
        EZDEBUG(@"old Value:%i, new Value:%f",whiteBalancerFilter.temperature, change);
        whiteBalancerFilter.temperature = change;
        label.text = int2str(whiteBalancerFilter.temperature);
        [staticPicture processImage];
        prevPanPoint = tapPoint;

    }else
    
    if([sender state] == UIGestureRecognizerStateEnded){
        //[gpu setBlurSize:kStaticBlurSize];
        dispatch_later(0.5, ^(){
            [UIView animateWithDuration:0.3 animations:^(){
                label.alpha = 0.0;
            }];
        });
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
        EZHomeBlendFilter* faceBlur = [[EZHomeBlendFilter alloc] initWithFilters:nil]; //[self createFaceBlurFilter];
        [res addObject:faceBlur];
        //[secFixColorFilter addTarget:finalBlendFilter];
        [res addObject:[self createRedStretchFilter]];
        [res addObject:[self createBlueStretchFilter]];
        [res addObject:[self createRedEnhanceFilter]];
        CGFloat blurCycle = 3.0 * fobj.orgRegion.size.width;
        CGFloat adjustedFactor = 13.0;//MAX(17 - 10 * fobj.orgRegion.size.width, 13.0);
        faceBlur.blurFilter.distanceNormalizationFactor = adjustedFactor;
        faceBlur.blurFilter.blurSize = 1.0;/// blurCycle;
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
    [_coverTapView removeFromSuperview];
    if(_cancelShot){
        _cancelShot = false;
        EZDEBUG(@"Cancel shotting");
        return;
    }
    if(_takingPhoto){
        return;
    }
    [self.photoCaptureButton setEnabled:NO];
    if (!isStatic) {
        _detectedFaceObj = nil;
        _takingPhoto = TRUE;
        _showOther = NO;
        _isSaved = NO;
        isStatic = YES;
        _turnedImage = FALSE;
        [self changeButtonStatus:YES];
        _toolBarRegion.alpha = 0;
        _isImageWithFlash = NO;
        [self prepareForCapture];
    }else{
        if(!_isSaved){
            _isSaved = true;
            [self savePhoto];
            [self changePhoto];
            //[self fakeAnimation:nil];
            cancelButton.hidden = YES;
        }else{
            cancelButton.hidden = NO;
            [[EZMessageCenter getInstance]postEvent:EZTakePicture attached:disPhoto];
            [self completedProcess];
            //[self fakeAnimation];
            //[self fakeAnimation:nil];
            [self retakePhoto:nil];
            [self changeButtonStatus:NO];
            
        }
    }
}

- (void) savePhoto
{
    _flipStatus = kTakedPhoto;
    ++_imageCount;
    //[self confirmCurrentMatch];
    //[self showTextField:NO];
    //[self hideKeyboard];
    [self triggerUpload];
    //_savedPhoto = _shotPhoto;
    _shotPhoto = nil;
    
}


- (void) cancelAll:(EZPhoto*)photo
{
    for(EZPhoto* ph in photo.photoRelations){
        [self cancelPrematchPhoto:ph];
    }
    //for(EZPhoto* ph in matchedPhotos){
    //    [self cancelPrematchPhoto:ph];
    //}
}

- (void) triggerUpload
{
    EZDEBUG(@"trigger pending upload");
    [[EZDataUtil getInstance].pendingUploads addObject:disPhoto.photo];
}

//Mean all the upload and things completed.
- (void) completedProcess
{
    [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:@{@"displayPhoto":disPhoto}];
    [[EZDataUtil getInstance] uploadPendingPhoto];
}

//Mean I accept current image with a match
- (void) confirmCurrentMatch
{
    EZDEBUG(@"before store the image");
    [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:@{@"displayPhoto":disPhoto}];
    EZDEBUG(@"pending upload");
    [[EZDataUtil getInstance].pendingUploads addObject:disPhoto.photo];
    [[EZDataUtil getInstance] uploadPendingPhoto];
    EZDEBUG(@"complete pending call");
    [self innerCancel];
     EZDEBUG(@"The photoID to update is:%@, prevMatched count:%i", disPhoto.photo.photoID, matchedPhotos.count);
    //for(EZPhoto* ph in matchedPhotos){
    //    [self cancelPrematchPhoto:ph];
    //}
}

- (UIImage*) getPhotoAndUpload
{
    UIImage *currentFilteredVideoFrame = nil;
    GPUImageOutput<GPUImageInput> *processUpTo;
    processUpTo = filter;
    if(stillCamera.isFrontFacing){
        currentFilteredVideoFrame = [processUpTo imageFromCurrentlyProcessedOutputWithOrientation:staticPictureOriginalOrientation];
        //EZDEBUG(@"The current orienation:%i, static orientatin:%i", currentFilteredVideoFrame.imageOrientation, staticPictureOriginalOrientation);
        currentFilteredVideoFrame = [currentFilteredVideoFrame rotateByOrientation:staticPictureOriginalOrientation];
    }else{
        currentFilteredVideoFrame = [processUpTo imageFromCurrentlyProcessedOutputWithOrientation:UIImageOrientationUp];
        
    }
    
    EZDEBUG(@"image size:%f, %f, matchPhotoID:%@", currentFilteredVideoFrame.size.width, currentFilteredVideoFrame.size.height, _shotPhoto.photoID);
    //EZPhoto* tmpMatch = _matchedPhoto;
    [self createPhoto:currentFilteredVideoFrame orgData:photoMeta shotPhoto:_shotPhoto success:^(EZDisplayPhoto* dp){
        
        //[self preMatchPhoto];
        disPhoto = dp;
        _takingPhoto = false;
        _toolBarRegion.alpha = 1;
    }];
    
    return currentFilteredVideoFrame;
}

- (void) createPhoto:(UIImage*)img orgData:(NSDictionary*)orgdata shotPhoto:(EZPhoto*)shotPhoto success:(EZEventBlock)success
{
    EZDEBUG(@"Store image get called");
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSMutableDictionary* metadata =[[NSMutableDictionary alloc] init];
    if(metadata){
        [metadata setDictionary:orgdata];
    }
    EZDEBUG(@"Recived metadata:%@, actual orientation:%i", metadata, img.imageOrientation);
    [metadata setValue:@(img.imageOrientation) forKey:@"Orientation"];
    [library writeImageToSavedPhotosAlbum:img.CGImage metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error2)
     {
         //report_memory(@"After writing to library");
         if (error2) {
             EZDEBUG(@"ERROR: the image failed to be written");
         }
         else {
             EZDEBUG(@"Stored image to album assetURL: %@", assetURL);
             [[EZDataUtil getInstance] assetURLToAsset:assetURL success:^(ALAsset* result){
                 EZDEBUG(@"Transfer the image to EZDisplayPhoto successfully");
                 EZDisplayPhoto* displayPhoto = [[EZDisplayPhoto alloc] init];
                 displayPhoto.isFront = true;
                 //EZPhoto* ep = [[EZPhoto alloc] init];
                 //ed.pid = ++[EZDataUtil getInstance].photoCount;
                 EZPhoto* ep = shotPhoto;
                 ep.asset = result;
                 ep.assetURL = assetURL.absoluteString;
                 ep.isLocal = true;
                 ep.createdTime = [NSDate date];
                 displayPhoto.photo = ep;
                 displayPhoto.photo.owner = [EZDataUtil getInstance].currentLoginPerson;
                 //EZDEBUG(@"Before size");
                 ep.size = [result defaultRepresentation].dimensions;
                 //Why setup the flag here?
                 //Because the user will interact with the photo from now on
                 ep.matchCompleted = TRUE;
                 EZDEBUG(@"after size:%f, %f", ep.size.width, ep.size.height);
                 success(displayPhoto);
             }];
         }
     }];

}

-(IBAction) retakePhoto:(UIButton *)button {
    [self preMatchPhoto];
    [self hideRotateImage];
    smileDetected.alpha = 0.0;
    _turnStatus = kCameraNormal;
    [self.retakeButton setHidden:YES];
    [self.libraryToggleButton setHidden:NO];
    staticPictureOriginalOrientation = UIImageOrientationUp;
    isStatic = NO;
    [self removeAllTargets];
    staticPicture = nil;
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]
       && stillCamera
       && [stillCamera.inputCamera hasTorch]) {
        [self.flashToggleButton setEnabled:YES];
    }
    //[self setFilter:selectedFilter];
    [self prepareFilter];
    EZDEBUG(@"selfShot:%i, front:%i", _selfShot, stillCamera.isFrontFacing);
    if(_selfShot && !stillCamera.isFrontFacing){
        [stillCamera rotateCamera];
    }
    [stillCamera startCameraCapture];
    [self.cameraToggleButton setEnabled:YES];
    
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

//Only call it when the static
- (void) changeButtonStatus:(BOOL)staticFlag
{
    EZDEBUG(@"The button status:%i", staticFlag);
    if(staticFlag){
        //self.cancelButton.hidden = FALSE;
        [self.cancelButton setTitle:@"重拍" forState:UIControlStateNormal];
        //[self.photoCaptureButton setTitle:@"保存" forState:UIControlStateNormal];
        [self.configButton setTitle:@"保存" forState:UIControlStateNormal];
        [self.photoCaptureButton setEnabled:YES];
        self.configButton.hidden = YES;
    }else{
        [self.cancelButton setTitle:@"退出" forState:UIControlStateNormal];
        //self.cancelButton.hidden = TRUE;
        //[self.photoCaptureButton setTitle:@"按这里拍摄" forState:UIControlStateNormal];
        //self.configButton.hidden = NO;
        [self.configButton setTitle:@"设置" forState:UIControlStateNormal];
        [self.photoCaptureButton setEnabled:YES];
        self.configButton.hidden = NO;
    }
    
}

- (void) innerCancel
{
    EZUIUtility.sharedEZUIUtility.cameraClickButton.releasedBlock = nil;
    [self dismissViewControllerAnimated:YES completion:^(){
        EZDEBUG(@"DLCCamera Will get dismissed");
    }];
    //[self cancelPrematchPhoto];
    [self.delegate imagePickerControllerDidCancel:self imageCount:_imageCount];
}

-(IBAction) cancelClicked:(id)sender {
    EZDEBUG(@"Cancel get called");
    EZPhoto* currentPhoto = _shotPhoto;
    if(isStatic){
        //_hideTextInput = TRUE;
        //[self stopRotateImage:nil];
        //[self hideRotateImage];
        if(_takingPhoto){
            return;
        }
        _flipStatus = kTakingPhoto;
        [self retakePhoto:nil];
        //This will trigger the view update?
        rotateView.image = nil;
        [self changeButtonStatus:NO];
    }else{
        [self innerCancel];
    }
    //[self cancelPrematchPhoto:currentPhoto];
    [self cancelAll:currentPhoto];
}

- (void) quit:(id)sender
{
    
}

- (void) switchDisplayImage
{
    int imageMode = finalBlendFilter.imageMode + 1;
    if(imageMode > 2){
        imageMode = 0;
    }
    //finalBlendFilter.imageMode = imageMode;
    finalBlendFilter.imageMode = imageMode;
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
            //[self.blurOverlayView setCircleCenter:tapPoint];
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
    EZDEBUG(@"Exposure mode:%i", [device isExposureModeSupported:AVCaptureExposureModeAutoExpose]);
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:pointOfInterest];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            if(expose){
                if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                    EZDEBUG(@"Expose clicked");
                    [device setExposurePointOfInterest:pointOfInterest];
                    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                    //[device setExposureMode:AVCaptureExposureModeAutoExpose];
                    //
                    //dispatch_later(0.2, ^(){
                    //    NSError *err;
                    //    if ([device lockForConfiguration:&err]) {
                    //        [device setExposureMode:AVCaptureExposureModeLocked];
                    //    }
                    //});
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
            //self.blurOverlayView.circleCenter = CGPointMake(midpoint.x, midpoint.y);
            CGFloat radius = MAX(MIN(sender.scale*[gpu excludeCircleRadius], 0.6f), 0.15f);
            //self.blurOverlayView.radius = radius*320.f;
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
            //self.blurOverlayView.alpha = 0.6;
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
            //self.blurOverlayView.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }
}


-(void) flashBlurOverlay {
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        //self.blurOverlayView.alpha = 0.6;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
            //self.blurOverlayView.alpha = 0;
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
    //self.blurOverlayView = nil;
    //self.focusView = nil;
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
