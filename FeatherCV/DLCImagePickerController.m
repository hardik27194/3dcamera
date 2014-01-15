//
//  DLCImagePickerController.m
//  DLCImagePickerController
//
//  Created by Dmitri Cherniak on 8/14/12.
//  Copyright (c) 2012 Dmitri Cherniak. All rights reserved.
//

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
//#import "EZFaceUtil.h"
//#import "EZFaceResultObj.h"
#import <GPUImagePrewittEdgeDetectionFilter.h>
#import <GPUImageSobelEdgeDetectionFilter.h>
#import <GPUImageThresholdEdgeDetectionFilter.h>
#import "EZHomeEdgeFilter.h"
#import "EZHomeBlendFilter.h"
#import "EZThreadUtility.h"
#import "EZDoubleOutFilter.h"

#import <GPUImageToneCurveFilter.h>
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
    GPUImageSaturationFilter *contrastfilter;
    GPUImageToneCurveFilter* tongFilter;
    GPUImageToneCurveFilter* flashFilter;
    GPUImageToneCurveFilter* darkFilter;
    
    GPUImageHueFilter* hueFilter;
    GPUImageOutput<GPUImageInput> *blurFilter;
    GPUImageCropFilter *cropFilter;
    GPUImageFilter* simpleFilter;
    EZCycleDiminish* cycleDarken;
    EZFaceBlurFilter* faceBlurFilter;
    EZNightBlurFilter* darkBlurFilter;
    
    
    GPUImagePrewittEdgeDetectionFilter * edgeFilter;
    EZFaceBlurFilter2* dynamicBlurFilter;
    EZHomeGaussianFilter* biBlurFilter;
    EZHomeBlendFilter* finalBlendFilter;
    //Used as the beginning of the filter
    EZDoubleOutFilter* orgFiler;
    EZSaturationFilter* filter;
    EZSaturationFilter* fixColorFilter;
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
    dispatch_once_t showLibraryOnceToken;
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

- (void) adjustOldSlideValue:(id)sender
{
    
    CGFloat rotateAngle = -180.0;
    if(sender == _redPoint){
        
        //dynamicBlurFilter.realRatio = _blurRate.value;
        filter.lowRed = rotateAngle + -5.0 + 50.0 * _redPoint.value;
        
        _redText.text = [NSString stringWithFormat:@"%f",rotateAngle + -5 + 50.0 * _redPoint.value];
        
    }else if(sender == _yellowPoint){
        
        filter.midYellow = rotateAngle + -55.0 + 50.0 * _yellowPoint.value;
        
        _yellowText.text = [NSString stringWithFormat:@"%f",rotateAngle + -55 + 50.0 * _yellowPoint.value];
        
    }else if(sender == _bluePoint){
        
        filter.highBlue = rotateAngle + -105.0 + 50.0 * _bluePoint.value;
        
        _blueText.text = [NSString stringWithFormat:@"%f",rotateAngle + -105.0 + 50.0 * _bluePoint.value];
        
    }else if(sender == _redGap){
        
        filter.yellowRedDegree = 20 * _redGap.value;
        
        _redGapText.text = [NSString stringWithFormat:@"%f", 20*_redGap.value];
        
    }else if(sender == _blueGap){
        
        filter.yellowBlueDegree = 20* _blueGap.value;
        
        _blueGapText.text = [NSString stringWithFormat:@"%f", 20* _blueGap.value];
        
    }

}


//The flash filter will get setup here.
- (void) setupDarkFilter
{
    darkFilter = [[GPUImageToneCurveFilter alloc] init];
    [darkFilter setRgbCompositeControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.206), pointValue(0.5, 0.504), pointValue(0.75, 0.774), pointValue(1.0, 1.0)]];
    [darkFilter setRedControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.242), pointValue(0.5, 0.512), pointValue(0.75, 0.762), pointValue(1, 1)]];
    [darkFilter setGreenControlPoints:@[pointValue(0.0, 0.0126), pointValue(0.25, 0.25), pointValue(0.5, 0.5), pointValue(0.75, 0.75), pointValue(1, 1)]];
    [darkFilter setBlueControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.25), pointValue(0.5, 0.5), pointValue(0.75, 0.75), pointValue(1, 1)]];
    
    darkBlurFilter = [[EZNightBlurFilter alloc] init];
    darkBlurFilter.blurSize = 1.0;
    darkBlurFilter.realRatio = 0.8;
    
}

- (void) setupFlashFilter
{
    flashFilter = [[GPUImageToneCurveFilter alloc] init];
    [flashFilter setRgbCompositeControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.273), pointValue(0.5, 0.524), pointValue(0.75, 0.774), pointValue(1.0, 1.0)]];
    [flashFilter setRedControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.2615), pointValue(0.5, 0.512), pointValue(0.75, 0.762), pointValue(1, 1)]];
    [flashFilter setGreenControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.186), pointValue(0.5, 0.436), pointValue(0.75, 0.654), pointValue(1, 1)]];
    [flashFilter setBlueControlPoints:@[pointValue(0.0, 0.0), pointValue(0.25, 0.253), pointValue(0.5, 0.5), pointValue(0.75, 0.8), pointValue(1, 1)]];
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
    _blueGap.value = 0.225;
    //Initial value
    //finalBlendFilter.blurFilter.distanceNormalizationFactor = 7.2;
    //finalBlendFilter.smallBlurFilter.blurSize = 0.2;
    //finalBlendFilter.blurRatio = _redGap.value;
    //finalBlendFilter.edgeBlurFilter.blurSize = _blueGap.value * 2;
    
    [self adjustSlideValue:_redPoint];
    [self adjustSlideValue:_yellowPoint];
    [self adjustSlideValue:_bluePoint];
    [self adjustSlideValue:_redGap];
    [self adjustSlideValue:_blueGap];
}

- (void) setupEdgeDetector
{
    GPUImagePrewittEdgeDetectionFilter * preWit = [[GPUImagePrewittEdgeDetectionFilter alloc] init];
    GPUImageSobelEdgeDetectionFilter* sobel = [[GPUImageSobelEdgeDetectionFilter alloc] init];
    GPUImageThresholdEdgeDetectionFilter* thresholdEdge = [[GPUImageThresholdEdgeDetectionFilter alloc] init];

    currentEdge = 0;
    edgeDectectors = @[preWit, sobel, thresholdEdge];
    edgeDectectorNames = @[@"PreWit", @"Sobel", @"Threshold"];
    _blueGapText.text = [edgeDectectorNames objectAtIndex:currentEdge];
    
}

- (void) clearEdgesTarget
{
    for(GPUImageFilter* gf in edgeDectectors){
        [gf removeAllTargets];
    }
}

- (void) switchEdges
{
    /**
    ++currentEdge;
    if(currentEdge == 3){
        currentEdge = 0;
    }
    _blueGapText.text = [edgeDectectorNames objectAtIndex:currentEdge];
    [self removeAllTargets];
    [self prepareFilter];
    **/
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _senseRotate = true;
    //_recordedMotions = [[NSMutableArray alloc] init];
    _flashView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _flashView.backgroundColor = [UIColor whiteColor];
    [self setupFlashFilter];
    [self setupDarkFilter];
    _storedMotionDelta = [[NSMutableArray alloc] init];

    tongParameters = [[NSMutableArray alloc] init];
    redAdjustments = [[NSMutableArray alloc] init];
    blueAdjustments = [[NSMutableArray alloc] init];
    greenAdjustments = [[NSMutableArray alloc] init];
    [tongParameters addObjectsFromArray:@[pointValue(0.0, 0.0), pointValue(0.25, 0.2816), pointValue(0.5, 0.5868), pointValue(0.75, 0.7949), pointValue(1.0, 1.0)]];
    hueFilter = [[GPUImageHueFilter alloc] init];
    hueFilter.hue = 355;
    EZDEBUG(@"adjust:%f", hueFilter.hue);
    orgFiler = [[EZDoubleOutFilter alloc] init];
    //[_redAdjustments addObjectsFromArray:@[pointValue(0.0, 0.0), pointValue(0.25, 0.2615), pointValue(0.5, 0.512), pointValue(0.75, 0.762), pointValue(1.0, 1.0)]];
    [redAdjustments addObjectsFromArray:@[pointValue(0.0, 0.0), pointValue(0.25, 0.25), pointValue(0.5, 0.5), pointValue(0.75, 0.75), pointValue(1.0, 1.0)]];
    [greenAdjustments addObjectsFromArray:@[pointValue(0.0, 0.0), pointValue(0.25, 0.25), pointValue(0.5, 0.5), pointValue(0.75, 0.75), pointValue(1.0, 1.0)]];
    [blueAdjustments addObjectsFromArray:@[pointValue(0.0, 0.0), pointValue(0.25, 0.25), pointValue(0.5, 0.5), pointValue(0.75, 0.75), pointValue(1.0, 1.0)]];
    
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
    
    
    self.blurOverlayView = [[DLCBlurOverlayView alloc] initWithFrame:CGRectMake(0, 0,
																				self.imageView.frame.size.width,
																				self.imageView.frame.size.height)];
    self.blurOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.blurOverlayView.alpha = 0;
    [self.imageView addSubview:self.blurOverlayView];
    
    hasBlur = NO;
    
    [self loadFilters];
    
    //we need a crop filter for the live video
    float widthAspect = [UIScreen mainScreen].bounds.size.width/[UIScreen mainScreen].bounds.size.height;
    EZDEBUG(@"The width aspect ratio is:%f", widthAspect);
    cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0f, 0.0f, 1.0, 0.75)];
    faceBlurFilter = [[EZFaceBlurFilter alloc] init];//[[EZFaceBlurFilter alloc] init];
    faceBlurFilter.blurSize = 5.0;
    faceBlurFilter.realRatio = 0.80;
    
    edgeFilter = [[GPUImagePrewittEdgeDetectionFilter alloc] init];
    
    dynamicBlurFilter = [[EZFaceBlurFilter2 alloc] init];
    dynamicBlurFilter.blurSize = 1.5;
    dynamicBlurFilter.realRatio = 0.15;
    
    
    filter = [[EZSaturationFilter alloc] init];
    filter.lowRed = -160;
    filter.midYellow = -185;
    filter.highBlue = -235;
    filter.yellowRedDegree = 2.4;
    filter.yellowBlueDegree = 20.0;
    
    
    fixColorFilter = [[EZSaturationFilter alloc] init];
    fixColorFilter.lowRed = 35.4;
    fixColorFilter.midYellow = -30.3;
    fixColorFilter.highBlue = -90;
    fixColorFilter.yellowRedDegree = 4.6;
    fixColorFilter.yellowBlueDegree = 10.9;
    
    
    
    biBlurFilter = [[EZHomeGaussianFilter alloc] init];
    //biBlurFilter.blurSize = 2.5;
    //biBlurFilter.distanceNormalizationFactor = 5.0;
    finalBlendFilter = [[EZHomeBlendFilter alloc] init];
    blurAspectRatio = 0.20/3.0;
    globalBlur = 3.0;
    faceChangeGap = 2.5;
    faceBlurBase = 0.5;
    finalBlendFilter.blurFilter.blurSize = globalBlur;//Original value
    finalBlendFilter.blurFilter.distanceNormalizationFactor = 13;
    finalBlendFilter.smallBlurFilter.blurSize = blurAspectRatio * globalBlur;
    finalBlendFilter.blurRatio = 0.25;
    [self setupColorAdjust];
    //[self adjustLine];
    
    tongFilter = [[GPUImageToneCurveFilter alloc] init];
    cycleDarken = [[EZCycleDiminish alloc] init];
        //faceBlurFilter.blurSize = 2.0;
    //[faceBlurFilter setExcludeCircleRadius:80.0/320.0];
    //[faceBlurFilter setExcludeCirclePoint:CGPointMake(0.5f, 0.5f)];
    //[faceBlurFilter setAspectRatio:1.0f];
    [tongFilter setRgbCompositeControlPoints:tongParameters];
    [tongFilter setRedControlPoints:redAdjustments];
    [tongFilter setGreenControlPoints:greenAdjustments];
    [tongFilter setBlueControlPoints:blueAdjustments];
    simpleFilter = [[GPUImageFilter alloc] init];
    contrastfilter = [[GPUImageSaturationFilter alloc] init];
    whiteBalancerFilter = [[GPUImageWhiteBalanceFilter alloc] init];
    whiteBalancerFilter.temperature = 4880;
    contrastfilter.saturation = 1.2;
    [self setupEdgeDetector];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self setUpCamera];
    });
    [self startFaceCapture];
    _isFrontCamera = false;
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
-(void) becomeVisible:(BOOL)isFront
{
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    _isVisible = true;
    if(_senseRotate){
        [[EZMotionUtility getInstance] registerHandler:^(EZMotionData* md){
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
            /**
            else if(absDelta > 0.7){
                EZDEBUG(@"Half turn get triggered for absDelta:%f", absDelta);
                if(_turnStatus == kCameraNormal){
                    _turnStatus = kCameraHalfTurn;
                }
            }
             **/
            
        } key:@"CameraMotion" type:kEZRotation];
    }
    EZDEBUG(@"BecomeVisible get called, isFront:%i, current:%i", isFront, stillCamera.isFrontFacing);
    if(isFront && !stillCamera.isFrontFacing){
        [self switchCamera];
    }else if(!isFront && stillCamera.isFrontFacing){
        [self switchCamera];
    }
    EZDEBUG(@"After call capture:%i",stillCamera.isFrontFacing);
    [stillCamera startCameraCapture];
    
    //double delayInSeconds = 0.2;
    //dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    //dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
    //});
    
    
}

- (void) becomeInvisible
{
    EZDEBUG(@"BecomeInvisible get called");
    //[super viewDidDisappear:animated];
    [stillCamera stopCameraCapture];
    [[EZMotionUtility getInstance] unregisterHandler:@"CameraMotion"];
    _isVisible = false;
}


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        dispatch_once(&showLibraryOnceToken, ^{
            [self switchToLibrary:nil];
        });
    }
}

-(void) loadFilters {
    for(int i = 0; i < 10; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i + 1]] forState:UIControlStateNormal];
        button.frame = CGRectMake(10+i*(60+10), 5.0f, 60.0f, 60.0f);
        button.layer.cornerRadius = 7.0f;
        
        //use bezier path instead of maskToBounds on button.layer
        UIBezierPath *bi = [UIBezierPath bezierPathWithRoundedRect:button.bounds
                                                 byRoundingCorners:UIRectCornerAllCorners
                                                       cornerRadii:CGSizeMake(7.0,7.0)];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = button.bounds;
        maskLayer.path = bi.CGPath;
        button.layer.mask = maskLayer;
        
        button.layer.borderWidth = 1;
        button.layer.borderColor = [[UIColor blackColor] CGColor];
        
        [button addTarget:self
                   action:@selector(filterClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [button setTitle:@"*" forState:UIControlStateSelected];
        if(i == 0){
            [button setSelected:YES];
        }
		[self.filterScrollView addSubview:button];
	}
	[self.filterScrollView setContentSize:CGSizeMake(10 + 10*(60+10), 75.0)];
}


-(void) setUpCamera {
    
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
    EZDEBUG(@"image orientation value:%i", orientation);
    if(orientation == UIImageOrientationUp){
        EZDEBUG(@"image orientation up");
    }else if(orientation == UIImageOrientationRight){
        EZDEBUG(@"image orientation right");
    }else if(orientation == UIImageOrientationLeft){
        EZDEBUG(@"image orientation left");
    }
    
    CGFloat width = faceRegion.size.width * self.imageView.frame.size.width;
    CGFloat height = faceRegion.size.height * self.imageView.frame.size.height;
    
    CGFloat px = faceRegion.origin.x * self.imageView.frame.size.width;
    CGFloat py = faceRegion.origin.y * self.imageView.frame.size.height;
    CGPoint interestPoint = CGPointMake(px + 0.5 * width, py + 0.5*height);
    CGRect frame = CGRectMake(px, py, width, height);
    CGRect fixFrame = [self.view convertRect:frame fromView:self.imageView];
    return @[[NSValue valueWithCGPoint:interestPoint], [NSValue valueWithCGRect:fixFrame]];

}

- (void) startDetectFace
{
    UIImage* capturedImage = orgFiler.blackFilter.imageFromCurrentlyProcessedOutput; //[imageView contentAsImage];
    UIImageOrientation orientation = capturedImage.imageOrientation;
    capturedImage = [capturedImage rotateByOrientation:capturedImage.imageOrientation];
    /**
    dispatch_main(
    ^(){
        [self generateTestImage:capturedImage];
    });
    **/
    //[[EZThreadUtility getInstance] executeBlockInQueue:^(){
    NSArray* result = [EZFaceUtilWrapper detectFace:capturedImage ratio:0.005];
        EZDEBUG(@"Let's test the image size:%@, face result:%i", NSStringFromCGSize(capturedImage.size), result.count);
        if(result.count > 0){
            EZFaceResultObj* fres = [result objectAtIndex:0];
            CGRect faceRegion = fres.orgRegion;
            NSArray* res = [self adjustFrameForOrienation:faceRegion orientation:orientation];
            CGPoint poi = [[res objectAtIndex:0] CGPointValue];
            CGRect fixFrame = [[res objectAtIndex:1] CGRectValue];
            EZDEBUG(@"Find face at:%@, frame:%@", NSStringFromCGRect(faceRegion), NSStringFromCGRect(fixFrame));
            dispatch_main(^(){
                [self focusCamera:poi frame:fixFrame];
                _detectingFace = false;
            });
            
        }else{
            _detectingFace = false;
        }
    
    //} isConcurrent:YES];
}

- (void) startFaceCapture
{
    [[EZThreadUtility getInstance] executeBlockInQueue:^(){
        EZDEBUG(@"Start capture faces");
        while (TRUE) {
            if(_detectFace && _isVisible && !_detectingFace){
                _detectingFace = TRUE;
                //dispatch_main(^(){
                @autoreleasepool {
                    //[self startDetectFace];
                }
                //});
            }
            [NSThread sleepForTimeInterval:1.0];
        }
    } isConcurrent:TRUE];
}

-(void) prepareLiveFilter {
    _detectFace = true;
    //[self startFaceCapture];
    [stillCamera addTarget:orgFiler];
    //[orgFiler addTarget:hueFilter];
    [orgFiler addTarget:tongFilter];
    [tongFilter addTarget:fixColorFilter];
    //[orgFiler addTarget:finalBlendFilter];
    //[fixColorFilter addTarget:filter];
    //[finalBlendFilter addTarget:filter];
    [fixColorFilter addTarget:filter];
    [filter addTarget:self.imageView];
    [filter prepareForImageCapture];
}

-(void) prepareStaticFilter:(EZFaceResultObj*)fobj image:(UIImage*)img{
    _detectFace = false;
    
    [staticPicture addTarget:fixColorFilter];
    [fixColorFilter addTarget:tongFilter];
    CGFloat dark = [self getISOSpeedRating];
    EZDEBUG(@"Prepare new static image get called, flash image:%i, image size:%@, dark:%f", _isImageWithFlash, NSStringFromCGSize(img.size), dark);
    GPUImageFilter* imageFilter = tongFilter;
    if(dark >= 600){
        [tongFilter addTarget:darkBlurFilter];
        imageFilter = (GPUImageFilter*)darkBlurFilter;
    }
    
    if(fobj){
        [imageFilter addTarget:finalBlendFilter];
        [finalBlendFilter addTarget:filter];
        CGFloat blurCycle = faceBlurBase + faceChangeGap * fobj.orgRegion.size.width;
        finalBlendFilter.blurFilter.blurSize = blurCycle;
        finalBlendFilter.smallBlurFilter.blurSize = blurAspectRatio * blurCycle;
        EZDEBUG(@"Will blur face:%@, blurCycle:%f", NSStringFromCGRect(fobj.orgRegion), blurCycle);
    }else{
        [imageFilter addTarget:filter];
    }

    [filter addTarget:self.imageView];
    GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
    switch (staticPictureOriginalOrientation) {
        case UIImageOrientationLeft:
            imageViewRotationMode = kGPUImageRotateLeft;
            break;
        case UIImageOrientationRight:
            imageViewRotationMode = kGPUImageRotateRight;
            break;
        case UIImageOrientationDown:
            imageViewRotationMode = kGPUImageRotate180;
            break;
        default:
            imageViewRotationMode = kGPUImageNoRotation;
            break;
    }

    [self.imageView setInputRotation:imageViewRotationMode atIndex:0];
    [staticPicture processImage];
}

-(void) prepareStaticFilterOld:(EZFaceResultObj*)fobj image:(UIImage*)img{
    EZDEBUG(@"Prepare static image get called, flash image:%i, image size:%@", _isImageWithFlash, NSStringFromCGSize(img.size));
    /**
    if(_isImageWithFlash){
        [staticPicture addTarget:flashFilter];
        if(_selfShot || stillCamera.isFrontFacing){
            EZDEBUG(@"Will add faceBlurFilter");
            //faceBlurFilter.blurSize = 6;
            [flashFilter addTarget:filter];
            //[faceBlurFilter addTarget:filter];
        }else{
            EZDEBUG(@"Not add faceBlurFilter");
            
            [flashFilter addTarget:filter];
            //[faceBlurFilter addTarget:filter];
        }
        
    }else{
     **/
        //if(fobj){
        CGFloat maxLen = MAX(img.size.width, img.size.height);
        if(maxLen > 1295.0){
            //dynamicBlurFilter.blurSize = 1.8;
        }else if(maxLen > 1279.0){
            //dynamicBlurFilter.blurSize = 1.5;
        }
        
        //if(fobj){
        //[staticPicture addTarget:dynamicBlurFilter];
        //[dynamicBlurFilter addTarget:hueFilter];
        //}else{
        [staticPicture addTarget:hueFilter];
        //}
        //[faceBlurFilter addTarget:filter];
        //}else{
        //EZDEBUG(@"Not add faceBlurFilter");
        //[colorFilter addTarget:filter];
        //}
        
        //[staticPicture addTarget:hueFilter];
        //[cropFilter addTarget:hueFilter];
        [hueFilter addTarget:tongFilter];
        GPUImageFilter* colorFilter = tongFilter;
        CGFloat isoNumber = [self getISOSpeedRating];
        CGFloat focalLength = [self getFacalLength];
        EZDEBUG(@"IsoNumber is:%f, focalLength:%f", isoNumber, focalLength);
        if(isoNumber > 600){
            //[tongFilter addTarget:darkBlurFilter];
            //colorFilter = (GPUImageFilter*)darkBlurFilter;
        }
        [colorFilter addTarget:fixColorFilter];
        //GPUImageFilter* edgeFilter = [edgeDectectors objectAtIndex:currentEdge];
        //[fixColorFilter addTarget:edgeFilter];
        //[edgeFilter addTarget:filter];
        [fixColorFilter addTarget:finalBlendFilter];
        [finalBlendFilter addTarget:filter];
        //[fixColorFilter addTarget:biBlurFilter];
        //[biBlurFilter addTarget:filter];
        //[fixColorFilter addTarget:filter];
       
    //}
    //[whiteBalancerFilter addTarget:filter];
    //[contrastfilter addTarget:filter];
    //[faceBlurFilter addTarget:filter];
    //[faceBlurFilter addTarget:filter];
    
    // blur is terminal filter
    //if (hasBlur) {
    //    [filter addTarget:blurFilter];
    //    [blurFilter addTarget:self.imageView];
    //regular filter is terminal
    //} else {
    
    [filter addTarget:self.imageView];
    //}
    
    GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
    switch (staticPictureOriginalOrientation) {
        case UIImageOrientationLeft:
            imageViewRotationMode = kGPUImageRotateLeft;
            break;
        case UIImageOrientationRight:
            imageViewRotationMode = kGPUImageRotateRight;
            break;
        case UIImageOrientationDown:
            imageViewRotationMode = kGPUImageRotate180;
            break;
        default:
            imageViewRotationMode = kGPUImageNoRotation;
            break;
    }
    
    // seems like atIndex is ignored by GPUImageView...
    [self.imageView setInputRotation:imageViewRotationMode atIndex:0];
    
    
    [staticPicture processImage];
}


-(void) prepareStaticFilter {
    [self prepareStaticFilter:nil image:nil];
    /**
    EZDEBUG(@"Prepare static image get called, flash image:%i", _isImageWithFlash);
    if(_isImageWithFlash){
        [staticPicture addTarget:flashFilter];
        if(_selfShot || stillCamera.isFrontFacing){
            EZDEBUG(@"Will add faceBlurFilter");
            //faceBlurFilter.blurSize = 6;
            [flashFilter addTarget:filter];
            //[faceBlurFilter addTarget:filter];
        }else{
            EZDEBUG(@"Not add faceBlurFilter");
            
            [flashFilter addTarget:filter];
            //[faceBlurFilter addTarget:filter];
        }
        
    }else{
        [staticPicture addTarget:hueFilter];
        //[cropFilter addTarget:hueFilter];
        [hueFilter addTarget:tongFilter];
        GPUImageFilter* colorFilter = tongFilter;
        CGFloat isoNumber = [self getISOSpeedRating];
        CGFloat focalLength = [self getFacalLength];
        EZDEBUG(@"IsoNumber is:%f, focalLength:%f", isoNumber, focalLength);
        if(isoNumber > 600){
            [tongFilter addTarget:darkBlurFilter];
            colorFilter = (GPUImageFilter*)darkBlurFilter;
        }
        
        if(focalLength < 1.5){
            EZDEBUG(@"Will add faceBlurFilter");
            [colorFilter addTarget:dynamicBlurFilter];
            [dynamicBlurFilter addTarget:filter];
            //[faceBlurFilter addTarget:filter];
        }else{
            EZDEBUG(@"Not add faceBlurFilter");
            //[colorFilter addTarget:dynamicBlurFilter];
            //[dynamicBlurFilter addTarget:filter];
            [colorFilter addTarget:dynamicBlurFilter];
            [dynamicBlurFilter addTarget:filter];
        }
    }
    //[whiteBalancerFilter addTarget:filter];
    //[contrastfilter addTarget:filter];
    //[faceBlurFilter addTarget:filter];
    //[faceBlurFilter addTarget:filter];

    // blur is terminal filter
    //if (hasBlur) {
    //    [filter addTarget:blurFilter];
    //    [blurFilter addTarget:self.imageView];
    //regular filter is terminal
    //} else {
        
    [filter addTarget:self.imageView];
    //}
    
    GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
    switch (staticPictureOriginalOrientation) {
        case UIImageOrientationLeft:
            imageViewRotationMode = kGPUImageRotateLeft;
            break;
        case UIImageOrientationRight:
            imageViewRotationMode = kGPUImageRotateRight;
            break;
        case UIImageOrientationDown:
            imageViewRotationMode = kGPUImageRotate180;
            break;
        default:
            imageViewRotationMode = kGPUImageNoRotation;
            break;
    }
    
    // seems like atIndex is ignored by GPUImageView...
    [self.imageView setInputRotation:imageViewRotationMode atIndex:0];

    
    [staticPicture processImage];
     **/
}

-(void) removeAllTargets {
    [stillCamera removeAllTargets];
    [staticPicture removeAllTargets];
    [whiteBalancerFilter removeAllTargets];
    [cropFilter removeAllTargets];
    [tongFilter removeAllTargets];
    [cycleDarken removeAllTargets];
    [biBlurFilter removeAllTargets];
    [fixColorFilter removeAllTargets];
    [dynamicBlurFilter removeAllTargets];
    [edgeFilter removeAllTargets];
    edgeFilter.hasOverriddenImageSizeFactor = false;
    //regular filter
    [filter removeAllTargets];
    [darkBlurFilter removeAllTargets];
    [contrastfilter removeAllTargets];
    [faceBlurFilter removeAllTargets];
    [simpleFilter removeAllTargets];
    [darkFilter removeAllTargets];
    //blur
    [blurFilter removeAllTargets];
    [hueFilter removeAllTargets];
    [self clearEdgesTarget];
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
    [button setSelected:!button.selected];
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
    if(self.flashToggleButton.selected &&
       [stillCamera.inputCamera hasTorch]){
        _isImageWithFlash = true;
        [stillCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
        [self performSelector:@selector(captureImage)
                   withObject:nil
                   afterDelay:0.8];
        
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
    [self captureImageInner:NO];
}

-(void)captureImageInner:(BOOL)flip {
    _detectFace = false;
    void (^completion)(UIImage *, NSError *) = ^(UIImage *img, NSError *error) {
        photoMeta = stillCamera.currentCaptureMetadata;
        EZDEBUG(@"Captured meta data:%@", photoMeta);
        [stillCamera.inputCamera unlockForConfiguration];
        [stillCamera stopCameraCapture];
        [self removeAllTargets];
        
        //UIImage* flipped = img;
        if(!stillCamera.isFrontFacing){
            img = [img resizedImageWithMaximumSize:CGSizeMake(img.size.width/2.0, img.size.height/2.0)];
            EZDEBUG(@"After shrink:%@", NSStringFromCGSize(img.size));
        }else{
            EZDEBUG(@"Rotate before static:%i, static orientation:%i", img.imageOrientation, staticPictureOriginalOrientation);
            //img = [img rotate:staticPictureOriginalOrientation];
            if(_frontCameraCompleted){
                _frontCameraCompleted(nil);
            }
            _frontCameraCompleted = nil;
        }
       
    
        //if(flip){
        //    flipped = [img flipImage];
        //}
        //flipped.imageOrientation = 4;
        staticPicture = [[GPUImagePicture alloc] initWithImage:img smoothlyScaleOutput:NO];
        staticPictureOriginalOrientation = img.imageOrientation;
        
        //UIImageView* iview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 400, 100, 100)];
        //iview.image = flipped;
        
        NSArray* faces = [EZFaceUtilWrapper detectFace:img ratio:0.01];
        EZDEBUG(@"Capture the flip is:%i, flipped orientation:%i, orginal:%i, faces:%i", flip, img.imageOrientation, img.imageOrientation, faces.count);
        EZFaceResultObj* firstObj = nil;
        if(faces.count > 0){
            for(EZFaceResultObj* fobj in faces){
                if(fobj.orgRegion.size.width > firstObj.orgRegion.size.width){
                    firstObj = fobj;
                }
            }
            //firstObj = [faces objectAtIndex:0];
        }
        [self prepareStaticFilter:firstObj image:img];
        dispatch_later(0.5, ^(){
            if(!_increasedLine){
                _increasedLine = true;
                finalBlendFilter.edgeFilter.texelWidth = finalBlendFilter.edgeFilter.texelWidth * 1.2;
                finalBlendFilter.edgeFilter.texelHeight = finalBlendFilter.edgeFilter.texelHeight * 1.2;
            }else{
                finalBlendFilter.edgeFilter.texelWidth = finalBlendFilter.edgeFilter.texelWidth;
                finalBlendFilter.edgeFilter.texelHeight = finalBlendFilter.edgeFilter.texelHeight;
            }
            EZDEBUG(@"Reprocess width:%f, height:%f",  finalBlendFilter.edgeFilter.texelWidth,  finalBlendFilter.edgeFilter.texelHeight);
            [staticPicture processImage];
            //_detectFace = true;
        });
        
        [self.retakeButton setHidden:NO];
        [self.photoCaptureButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.photoCaptureButton setImage:nil forState:UIControlStateNormal];
        [self.photoCaptureButton setEnabled:YES];
        isStatic = true;
        //if(![self.filtersToggleButton isSelected]){
        //    [self showFilters];
        //}
    };
    
    
    AVCaptureDevicePosition currentCameraPosition = stillCamera.inputCamera.position;
    Class contextClass = NSClassFromString(@"GPUImageContext") ?: NSClassFromString(@"GPUImageOpenGLESContext");
    if ((currentCameraPosition != AVCaptureDevicePositionFront) || (![contextClass supportsFastTextureUpload])) {
        // Image full-resolution capture is currently possible just on the final (destination filter), so
        // create a new paralel chain, that crops and resizes our image
        EZDEBUG(@"Prepare for the capture");
        [self removeAllTargets];
        
        //GPUImageCropFilter *captureCrop = [[GPUImageCropFilter alloc] initWithCropRegion:cropFilter.cropRegion];
        //[stillCamera addTarget:faceBlurFilter];
        [stillCamera addTarget:simpleFilter];
        //[tongFilter addTarget:whiteBalancerFilter];
        //[whiteBalancerFilter addTarget:filter];
        GPUImageFilter *finalFilter = simpleFilter;
        
        /**
        if (!CGSizeEqualToSize(requestedImageSize, CGSizeZero)) {
            GPUImageFilter *captureResize = [[GPUImageFilter alloc] init];
            [captureResize forceProcessingAtSize:requestedImageSize];
            [captureCrop addTarget:captureResize];
            finalFilter = captureResize;
        }
        **/
        [finalFilter prepareForImageCapture];
        EZDEBUG(@"Capture before get inside");
        [stillCamera capturePhotoAsImageProcessedUpToFilter:finalFilter withCompletionHandler:completion];
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

-(IBAction) takePhoto:(id)sender{
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
        
        GPUImageOutput<GPUImageInput> *processUpTo;
        
        
        processUpTo = filter;
        
       
        EZDEBUG(@"Before call process image");
        [staticPicture processImage];
        EZDEBUG(@"After call process image");
        
        //if(!stillCamera.isFrontFacing){
        UIImage *currentFilteredVideoFrame = nil;
        
        if(stillCamera.isFrontFacing){
           currentFilteredVideoFrame = [processUpTo imageFromCurrentlyProcessedOutputWithOrientation:staticPictureOriginalOrientation];
            EZDEBUG(@"The current orienation:%i, static orientatin:%i", currentFilteredVideoFrame.imageOrientation, staticPictureOriginalOrientation);
            currentFilteredVideoFrame = [currentFilteredVideoFrame rotateByOrientation:staticPictureOriginalOrientation];
        }else{
            currentFilteredVideoFrame = [processUpTo imageFromCurrentlyProcessedOutputWithOrientation:staticPictureOriginalOrientation];
            //currentFilteredVideoFrame = staticPicture
            EZDEBUG(@"Before shink:%@", NSStringFromCGSize(currentFilteredVideoFrame.size));
            
        }
        //}
        
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

-(IBAction) cancel:(id)sender {
    EZDEBUG(@"Cancel get called");
    //if(isStatic){
    //    [staticPicture processImage];
    //}
    int imageMode = finalBlendFilter.imageMode + 1;
    if(imageMode > 2){
        imageMode = 0;
    }
    finalBlendFilter.imageMode = imageMode;
    EZDEBUG(@"I will store the image mode:%i", finalBlendFilter.imageMode);

    GPUImageOutput<GPUImageInput> *processUpTo;
    processUpTo = filter;
    
    EZDEBUG(@"Before call process image");
    [staticPicture processImage];
    EZDEBUG(@"After call process image");
    
    /**
    //if(!stillCamera.isFrontFacing){
    UIImage *currentFilteredVideoFrame = nil;
    
    if(stillCamera.isFrontFacing){
        currentFilteredVideoFrame = [processUpTo imageFromCurrentlyProcessedOutputWithOrientation:staticPictureOriginalOrientation];
        EZDEBUG(@"The current orienation:%i, static orientatin:%i", currentFilteredVideoFrame.imageOrientation, staticPictureOriginalOrientation);
        currentFilteredVideoFrame = [currentFilteredVideoFrame rotateByOrientation:staticPictureOriginalOrientation];
    }else{
        currentFilteredVideoFrame = [processUpTo imageFromCurrentlyProcessedOutputWithOrientation:staticPictureOriginalOrientation];
        //currentFilteredVideoFrame = staticPicture
        EZDEBUG(@"Before shink:%@", NSStringFromCGSize(currentFilteredVideoFrame.size));
        
    }
    //}
    
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
    [self.delegate imagePickerControllerDidCancel:self];
     **/
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
        CGRect focusFrame = CGRectMake(center.x - self.focusView.width/2.0, center.y - self.focusView.height/2.0, self.focusView.frame.size.width, self.focusView.frame.size.height);
        [self focusCamera:pointOfInterest frame:focusFrame];
    }
}

- (void) focusCamera:(CGPoint)pointOfInterest frame:(CGRect)focusFrame;
{
    AVCaptureDevice *device = stillCamera.inputCamera;
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:pointOfInterest];
            
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            
            /**
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [device setExposurePointOfInterest:pointOfInterest];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
             **/
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
    [stillCamera stopCameraCapture];
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
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
