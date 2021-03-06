//
//  EZCaptureCameraController.m
//  3DCamera
//
//  Created by xietian on 14-8-24.
//  Copyright (c) 2014年 tiange. All rights reserved.
//
#import "EZCaptureCameraController.h"
#import "SCSlider.h"
#import "SCCommon.h"
#import "SVProgressHUD.h"
#import "EZFileUtil.h"
#import "EZMessageCenter.h"
#import "EZSoundEffect.h"
#import "RBVolumeButtons.h"
#import "SCNavigationController.h"
#import "EZPhotoEditPage.h"
#import "UIButton+AFNetworking.h"
#import "EZDragPage.h"
#import "EZFrontFrame.h"
#import "EZPalate.h"
#import "EZSignView.h"
#import "EZShotSetting.h"
#import "EZConfigure.h"

//static void * CapturingStillImageContext = &CapturingStillImageContext;
//static void * RecordingContext = &RecordingContext;
//static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

#define SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE      0   //对焦框是否一直闪到对焦完成

#define SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA   1   //没有拍照功能的设备，是否给一张默认图片体验一下

//height
#define CAMERA_TOPVIEW_HEIGHT   44  //title
#define CAMERA_MENU_VIEW_HEIGH  44  //menu

//color
#define bottomContainerView_UP_COLOR     [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.f]       //bottomContainerView的上半部分
#define bottomContainerView_DOWN_COLOR   [UIColor colorWithRed:68/255.0f green:68/255.0f blue:68/255.0f alpha:1.f]       //bottomContainerView的下半部分
#define DARK_GREEN_COLOR        [UIColor colorWithRed:10/255.0f green:107/255.0f blue:42/255.0f alpha:1.f]    //深绿色
#define LIGHT_GREEN_COLOR       [UIColor colorWithRed:143/255.0f green:191/255.0f blue:62/255.0f alpha:1.f]    //浅绿色


//对焦
#define ADJUSTINT_FOCUS @"adjustingFocus"
#define LOW_ALPHA   0.7f
#define HIGH_ALPHA  1.0f

//typedef enum {
//    bottomContainerViewTypeCamera    =   0,  //拍照页面
//    bottomContainerViewTypeAudio     =   1   //录音页面
//} BottomContainerViewType;

@interface EZCaptureCameraController () {
    int alphaTimes;
    CGPoint currTouchPoint;
}

@property (nonatomic, strong) SCCaptureSessionManager *captureManager;

@property (nonatomic, strong) UIView *topContainerView;//顶部view
@property (nonatomic, strong) UILabel *topLbl;//顶部的标题

@property (nonatomic, strong) UIView *bottomContainerView;//除了顶部标题、拍照区域剩下的所有区域
@property (nonatomic, strong) UIView *cameraMenuView;//网格、闪光灯、前后摄像头等按钮
@property (nonatomic, strong) NSMutableSet *cameraBtnSet;

@property (nonatomic, strong) UIView *doneCameraUpView;
@property (nonatomic, strong) UIView *doneCameraDownView;

//对焦
@property (nonatomic, strong) UIImageView *focusImageView;

@property (nonatomic, strong) SCSlider *scSlider;

//@property (nonatomic) id runtimeErrorHandlingObserver;
//@property (nonatomic) BOOL lockInterfaceRotation;

@end

#define EZCountDownSetting @"CountDownSetting"

@implementation EZCaptureCameraController

#pragma mark -------------life cycle---------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        alphaTimes = -1;
        currTouchPoint = CGPointZero;
        _cameraBtnSet = [[NSMutableSet alloc] init];
    }
    return self;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void) showConfigure
{
    if(_shotType == kShotToReplace){
        _proposedNumber = 1;
        _shotPalate.total = 1;
        [self setManualMode:TRUE];
        return;
    }
    
    [self setManualMode:FALSE];
    EZShotSetting* shotConfigre = [[EZShotSetting alloc] initWithFrame:CGRectMake(20, 100, CurrentScreenWidth - 40, 220)];
    shotConfigre.cancelled = ^(id obj){
        [self dismissBtnPressed:obj];
    };
    [shotConfigre showInView:self.view aniamted:NO confirmed:^(id obj){
        EZConfigure* configure = [EZConfigure sharedEZConfigure];
        EZDEBUG(@"delay:%f, count:%i, isMute:%i", configure.shotDelay, configure.shotCount, configure.isMute);
        _proposedNumber = configure.shotCount;
        _totalCountDown = configure.shotDelay;
        _shotPalate.total = _proposedNumber;
    } isTouchDimiss:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _totalCountDown =  [EZConfigure sharedEZConfigure].shotDelay; //[[NSUserDefaults standardUserDefaults] integerForKey:EZCountDownSetting];
    _proposedNumber = [EZConfigure sharedEZConfigure].shotCount;
    
    __weak EZCaptureCameraController* weakSelf = self;
    //navigation bar
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    //status bar
    //notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOrientationChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:kNotificationOrientationChange object:nil];
    _shotPrepareVoice = [[EZSoundEffect alloc] initWithSoundNamed:@"shot_voice2.aiff"];
    //session manager
    SCCaptureSessionManager *manager = [[SCCaptureSessionManager alloc] init];
    
    /**
    _buttonStealer = [[RBVolumeButtons alloc] init];
    _buttonStealer.upBlock = ^{
        EZDEBUG(@"volume up");
        [weakSelf takePictureBtnPressed:nil];
    };
    _buttonStealer.downBlock = ^{
        EZDEBUG(@"volume down");
        [weakSelf takePictureBtnPressed:nil];
    };
     **/
    //[_buttonStealer startStealingVolumeButtonEvents];
    //AvcaptureManager
    if (CGRectEqualToRect(_previewRect, CGRectZero)) {
        self.previewRect = CGRectMake(0, 0, SC_APP_SIZE.width, SC_APP_SIZE.width + CAMERA_TOPVIEW_HEIGHT);
    }
    [manager configureWithParentLayer:self.view previewRect:_previewRect];
    self.captureManager = manager;
    [self addTopViewWithText:@""];
    [self addbottomContainerView];
    [self addFocusView];
    [self addCameraCover];
    [self addPinchGesture];
    [self addCameraMenuView];
    [self showConfigure];
    [_captureManager.session startRunning];
    
#if SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [SVProgressHUD showErrorWithStatus:@"设备不支持拍照功能，给个妹纸给你喵喵T_T"];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CAMERA_TOPVIEW_HEIGHT, self.view.frame.size.width, self.view.frame.size.width)];
        imgView.clipsToBounds = YES;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"meizi" ofType:@"jpg"]];
        [self.view addSubview:imgView];
    }
#endif
    
    
}

- (void) setDelayChangeButton:(NSInteger)countDown
{
    [_changeDelayBtn setTitle:[NSString stringWithFormat:@"延时:%i秒", _totalCountDown] forState:UIControlStateNormal];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    //[_buttonStealer startStealingVolumeButtonEvents];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:FALSE];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    if (!self.navigationController) {
        if ([UIApplication sharedApplication].statusBarHidden != _isStatusBarHiddenBeforeShowCamera) {
            [[UIApplication sharedApplication] setStatusBarHidden:_isStatusBarHiddenBeforeShowCamera withAnimation:UIStatusBarAnimationSlide];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOrientationChange object:nil];
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device isFocusPointOfInterestSupported]) {
        [device removeObserver:self forKeyPath:ADJUSTINT_FOCUS context:nil];
    }
#endif
    
    self.captureManager = nil;
    //[_buttonStealer stopStealingVolumeButtonEvents];
}


#pragma mark -------------UI---------------
//顶部标题
- (void)addTopViewWithText:(NSString*)text {
    if (!_topContainerView) {
        CGRect topFrame = CGRectMake(0, 0, SC_APP_SIZE.width, CAMERA_TOPVIEW_HEIGHT);
        
        UIView *tView = [[UIView alloc] initWithFrame:topFrame];
        tView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tView];
        self.topContainerView = tView;
        
        UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, topFrame.size.width, topFrame.size.height)];
        emptyView.backgroundColor = [UIColor blackColor];
        emptyView.alpha = 0.4f;
        [_topContainerView addSubview:emptyView];
        
        topFrame.origin.x += 10;
        _shotText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, topFrame.size.height)];
        _shotText.backgroundColor = [UIColor clearColor];
        _shotText.textColor = [UIColor whiteColor];
        _shotText.font = [UIFont systemFontOfSize:22.f];
        //[_topContainerView addSubview:_shotText];
        
        
        _shotStatusSign = [[EZSignView alloc] initWithFrame:CGRectMake(15, 15, topFrame.size.height - 30, topFrame.size.height - 30)];
        _shotStatusSign.signType = kStopSign;
        //[_topContainerView addSubview:_shotStatusSign];
        
        _toggleMode = [UIButton createButton:CGRectMake(100, 0, CurrentScreenWidth - 200, 44) font:[UIFont boldSystemFontOfSize:17] color:ClickedColor align:NSTextAlignmentCenter];
        [_toggleMode addTarget:self action:@selector(toggleClicked) forControlEvents:UIControlEventTouchUpInside];
        [_topContainerView addSubview:_toggleMode];
        [self setManualMode:_isManual];
        
        //_statusText = [UILabel createLabel:CGRectMake(100, 0, 120, topFrame.size.height) font:[UIFont systemFontOfSize:22] color:[UIColor whiteColor]];
        //[_topContainerView addSubview:_statusText];
        
        /**
         _confirmButton = [UIButton createButton:CGRectMake(CurrentScreenWidth - 70, 0, 60, 44) font:[UIFont systemFontOfSize:17] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
         [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
         [_confirmButton addTarget:self action:@selector(confirmClicked:) forControlEvents:UIControlEventTouchUpInside];
         [_topContainerView addSubview:_confirmButton];
         **/
        /**
        [self buildButton:CGRectMake(CurrentScreenWidth - 44, 0, 44, 44)
             normalImgStr:@"share2"
          highlightImgStr:@""
           selectedImgStr:@""
                   action:@selector(shareClicked:)
               parentView:_topContainerView];
        **/
        
        self.topLbl = _shotText;
    }
    _topLbl.text = text;
}

- (void) coverClicked:(id)obj
{
    [UIView animateWithDuration:0.4 animations:^(){
        //EZDEBUG(@"")
        _dropDown.height = 0;
        [self.view viewWithTag:1349].alpha = 0.0;
    } completion:^(BOOL completed){
        _dropDown.hidden = YES;
        [[self.view viewWithTag:1349] removeFromSuperview];
    }];

}

- (void) shareClicked:(id)obj
{
    if(_dropDown.hidden){
        _dropDown.hidden = false;
        [self.view createCoverView:1349 color:RGBACOLOR(70, 70, 70, 128) below:_dropDown tappedTarget:self action:@selector(coverClicked:)];
        [UIView animateWithDuration:0.4 animations:^(){
            _dropDown.height = 44 * 4;
        }];
    }else{
        [self coverClicked:nil];
    }
}

- (void) toggleClicked
{
    [self setManualMode:!_isManual];
}



- (void) setManualMode:(BOOL)isManual
{
    _isManual = isManual;
    if(_isManual){
        //[_toggleMode setTitle:@"手动" forState:UIControlStateNormal];
        _manualSwitch.on = false;
        _shotStatusSign.hidden = YES;
        _switchLabel.text = @"手动拍摄";
    }else{
        //[_toggleMode setTitle:@"自动" forState:UIControlStateNormal];
        _manualSwitch.on = true;
        _shotStatusSign.hidden = NO;
        _switchLabel.text = @"自动拍摄";
    }
}

//bottomContainerView，总体
- (void)addbottomContainerView {
    
    CGFloat bottomY = _captureManager.previewLayer.frame.origin.y + _captureManager.previewLayer.frame.size.height;
    CGRect bottomFrame = CGRectMake(0, bottomY, SC_APP_SIZE.width, SC_APP_SIZE.height - bottomY);
    
    UIView *view = [[UIView alloc] initWithFrame:bottomFrame];
    view.backgroundColor = bottomContainerView_UP_COLOR;
    [self.view addSubview:view];
    self.bottomContainerView = view;
}


- (void) savePressed:(id)obj
{
    [self setIsPaused:true];
    if(_confirmClicked){
        if(_shotType == kShotToReplace){
            //_confirmClicked(_photo);
            _confirmClicked(_shottedPhotoURL);
            [self dismissBtnPressed:nil];
        }else{
            //_confirmClicked(_shotTask);
            EZDEBUG(@"save clicked");
            EZDragPage* dragPage = [[EZDragPage alloc] initWithTask:_shotTask mode:NO];
            dragPage.confirmClicked = ^(NSNumber* num){
                if([num boolValue]){
                    EZDEBUG(@"confirm clicked");
                    if(_confirmClicked){
                        _confirmClicked(_shotTask);
                    }
                }
                int pos = self.navigationController.viewControllers.count - 3;
                EZDEBUG(@"The view pos is:%i", pos);
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:pos] animated:YES];
            };
            [self.navigationController pushViewController:dragPage animated:YES];
        }
    }else{
         [self dismissBtnPressed:nil];
    }
   }

- (void) updateShotText
{
    _shotText.text = [NSString stringWithFormat:@"%i/%i", _currentCount, _proposedNumber];
    //_shotLabel.text = int2str(_proposedNumber - _currentCount);
    _shotPalate.total = _proposedNumber;
    _shotPalate.occupied = _currentCount;
    
}

- (void) deletePos:(NSInteger)pos
{
    if(_shotType == kShotToReplace){
        _shottedPhotoURL = nil;
        [_shotImages setImage:nil forState:UIControlStateNormal];
        
    }else{
        --_currentCount;
        [self updateShotText];
        [_shotTask.photos removeObjectAtIndex:pos];
        if(_shotTask.photos.count){
            EZStoredPhoto* photo = [_shotTask.photos objectAtIndex:_shotTask.photos.count - 1];
            //[_shotImages setImageURL]
            //[_shotImages setImageURL:str2url(photo.localFileURL) forState:UIControlStateNormal];
            [_shotImages setImageForState:UIControlStateNormal withURL:str2url(photo.localFileURL)];
        }else{
            [_shotImages setImage:nil forState:UIControlStateNormal];
        }
    }
    
}

- (void) showResult:(id)sender
{
    NSArray* photos = nil;
    if(_shotStatus == kShotting){
        [self setIsPaused:true];
    }
    if(_shotType == kShotToReplace){
        EZStoredPhoto* sp = [[EZStoredPhoto alloc] init];
        sp.localFileURL = _shottedPhotoURL;
        sp.remoteURL = _shottedPhotoURL;
        photos = @[sp];
    }else{
        photos = _shotTask.photos;
    }
    EZPhotoEditPage* ep = [[EZPhotoEditPage alloc] initWithShot:photos pos:photos.count - 1 deletedBlock:^(NSNumber* pos){
        [self deletePos:[pos intValue]];
    }];
    [self.navigationController pushViewController:ep animated:YES];
    
}

- (void) manualSwitched:(UISwitch*)switcher
{
    //_isManual = switcher.on;
    [self setManualMode:!switcher.on];
}


//拍照菜单栏
- (void)addCameraMenuView {
    
    //拍照按钮
    CGFloat downH = (isLongScreenSize ? CAMERA_MENU_VIEW_HEIGH : 15);
    CGFloat cameraBtnLength = 90;
    _shotBtn = [self buildButton:CGRectMake((SC_APP_SIZE.width - cameraBtnLength) / 2, (_bottomContainerView.frame.size.height - downH - cameraBtnLength) / 2 , cameraBtnLength, cameraBtnLength)
                    normalImgStr:@"shot_s.png"
                 highlightImgStr:@""//"shot_h.png"
                  selectedImgStr:@""
                          action:@selector(takePictureBtnPressed:)
                      parentView:_bottomContainerView];
    
    
    
    
    _manualSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    _manualSwitch.center = CGPointMake(CurrentScreenWidth - 40, _shotBtn.center.y);
    [_manualSwitch addTarget:self action:@selector(manualSwitched:) forControlEvents:UIControlEventValueChanged];
    [_bottomContainerView addSubview:_manualSwitch];
    
    UILabel* btnLabel = [UILabel createLabel:CGRectMake(0, 0, 60, 20) font:[UIFont boldSystemFontOfSize:12] color:[UIColor whiteColor]];
    btnLabel.text = @"自动拍摄";
    btnLabel.textAlignment = NSTextAlignmentCenter;
    btnLabel.center = CGPointMake(_manualSwitch.center.x, _shotBtn.center.y - 30);
    [_bottomContainerView addSubview:btnLabel];
    _switchLabel = btnLabel;
    
    _shotPalate = [[EZPalate alloc] initWithFrame:_shotBtn.bounds activeColor:[UIColor whiteColor] inactiveColor:[UIColor blackColor] background:[UIColor clearColor] total:_proposedNumber];
    [_shotBtn addSubview:_shotPalate];
    _shotPalate.userInteractionEnabled = false;
    _shotLabel = [UILabel createLabel:_shotBtn.bounds font:[UIFont boldSystemFontOfSize:28] color:[UIColor whiteColor]];
    _shotLabel.textAlignment = NSTextAlignmentCenter;
    [_shotBtn addSubview:_shotLabel];
    
    CGFloat pos = (_bottomContainerView.frame.size.height - 45)/2.0;
    pos = isLongScreenSize?pos-20:pos - 30;
    _shotImages = [UIButton createButton:CGRectMake(20, pos, 60, 60) font:[UIFont systemFontOfSize:10] color:[UIColor whiteColor] align:NSTextAlignmentCenter];//[[UIImageView alloc] initWithFrame:CGRectMake(20, _bottomContainerView.frame.size.height - downH - cameraBtnLength, 45 , 45)];
    _shotImages.layer.cornerRadius = 5;
    _shotImages.clipsToBounds = TRUE;
    _shotImages.backgroundColor = [UIColor clearColor];
    _shotImages.contentMode = UIViewContentModeScaleAspectFill;
    [_bottomContainerView addSubview:_shotImages];
    [_shotImages addTarget:self action:@selector(showResult:) forControlEvents:UIControlEventTouchUpInside];
    
    //_changeDelayBtn = [UIButton createButton:CGRectMake(_bottomContainerView.width - 20 - 75, pos, 75, 44) font:[UIFont boldSystemFontOfSize:16] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
    //[self setDelayChangeButton:_totalCountDown];
    //[_changeDelayBtn addTarget:self action:@selector(changeDelay) forControlEvents:UIControlEventTouchUpInside];
    //[_bottomContainerView addSubview:_changeDelayBtn];
    
    //拍照的菜单栏view（屏幕高度大于480的，此view在上面，其他情况在下面）
    CGFloat menuViewY = SC_DEVICE_SIZE.height - CAMERA_MENU_VIEW_HEIGH;
    UIView *menuView = [[UIView alloc] initWithFrame:CGRectMake(0, menuViewY, self.view.frame.size.width, CAMERA_MENU_VIEW_HEIGH)];
    menuView.backgroundColor = [UIColor clearColor];//(isHigherThaniPhone4_SC ? bottomContainerView_DOWN_COLOR : [UIColor clearColor]);
    [self.view addSubview:menuView];
    self.cameraMenuView = menuView;
    [self addMenuViewButtons];
    
    _dropDown = [[UIView alloc] initWithFrame:CGRectMake(CurrentScreenWidth - 44, 44, 44, 44*4)];
    _dropDown.backgroundColor = [UIColor clearColor];//RGBCOLOR(100, 100, 100);
    //_dro
    _dropDown.hidden = YES;
    _dropDown.clipsToBounds = true;
    [self.view addSubview:_dropDown];
    [self createDropDownButtons];
}

- (void) createDropDownButtons
{
    //@"camera_line.png",
    NSMutableArray *normalArr = [[NSMutableArray alloc] initWithObjects:@"flashing_off.png",  @"switch_camera.png", nil];
    NSMutableArray *highlightArr = [[NSMutableArray alloc] initWithObjects:@"", @"", nil];
    NSMutableArray *selectedArr = [[NSMutableArray alloc] initWithObjects:@"",  @"switch_camera_h.png", nil];
    
    //NSMutableArray *actionArr = [[NSMutableArray alloc] initWithObjects:@"dismissBtnPressed:", @"gridBtnPressed:", @"switchCameraBtnPressed:", @"savePressed:", nil];
    
    NSMutableArray *actionArr = [[NSMutableArray alloc] initWithObjects:@"flashBtnPressed:", @"switchCameraBtnPressed:", nil];

    for (int i = 0; i < actionArr.count; i++) {

        if([[actionArr objectAtIndex:i] isNotEmpty]){
            UIButton * btn = [self buildButton:CGRectMake(i == 0?10:CurrentScreenWidth - 54, _bottomContainerView.height - 44, 44, 44)
                                  normalImgStr:[normalArr objectAtIndex:i]
                               highlightImgStr:[highlightArr objectAtIndex:i]
                                selectedImgStr:[selectedArr objectAtIndex:i]
                                        action:NSSelectorFromString([actionArr objectAtIndex:i])
                                    parentView:_bottomContainerView];
            
            btn.showsTouchWhenHighlighted = YES;
            //[_cameraBtnSet addObject:btn];
        }
    }

}

- (void) changeDelay
{
    UIActionSheet* ac = [[UIActionSheet alloc] initWithTitle:@"拍摄延时(秒)" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    
    [ac showInView:self.view];
    ac.delegate = self;
}

//拍照菜单栏上的按钮
- (void)addMenuViewButtons {
    NSMutableArray *normalArr = [[NSMutableArray alloc] initWithObjects:@"header_btn_cancel.png", @"camera_line.png", @"switch_camera.png", @"header_btn_save.png", nil];
    NSMutableArray *highlightArr = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", nil];
    NSMutableArray *selectedArr = [[NSMutableArray alloc] initWithObjects:@"", @"camera_line_h.png", @"switch_camera_h.png", @"", nil];
    
    //NSMutableArray *actionArr = [[NSMutableArray alloc] initWithObjects:@"dismissBtnPressed:", @"gridBtnPressed:", @"switchCameraBtnPressed:", @"savePressed:", nil];
    
    NSMutableArray *actionArr = [[NSMutableArray alloc] initWithObjects:@"dismissBtnPressed:", @"", @"", @"savePressed:", nil];
    
    //@"flashBtnPressed:"
    CGFloat eachW = SC_APP_SIZE.width / actionArr.count;
    
    [SCCommon drawALineWithFrame:CGRectMake(eachW, 0, 1, CAMERA_MENU_VIEW_HEIGH) andColor:rgba_SC(102, 102, 102, 1.0000) inLayer:_cameraMenuView.layer];
    
    [SCCommon drawALineWithFrame:CGRectMake(eachW * 3, 0, 1, CAMERA_MENU_VIEW_HEIGH) andColor:rgba_SC(102, 102, 102, 1.0000) inLayer:_cameraMenuView.layer];
    
    
    //屏幕高度大于480的，后退按钮放在_cameraMenuView；小于480的，放在_bottomContainerView
    for (int i = 0; i < actionArr.count; i++) {
        
        CGFloat theH = (!isHigherThaniPhone4_SC && i == 0 ? _bottomContainerView.frame.size.height : CAMERA_MENU_VIEW_HEIGH);
        UIView *parent = (!isHigherThaniPhone4_SC && i == 0 ? _bottomContainerView : _cameraMenuView);
        if([[actionArr objectAtIndex:i] isNotEmpty]){
        UIButton * btn = [self buildButton:CGRectMake(eachW * i, 0, eachW, theH)
                              normalImgStr:[normalArr objectAtIndex:i]
                           highlightImgStr:[highlightArr objectAtIndex:i]
                            selectedImgStr:[selectedArr objectAtIndex:i]
                                    action:NSSelectorFromString([actionArr objectAtIndex:i])
                                parentView:_topContainerView];
        
        btn.showsTouchWhenHighlighted = YES;
        
        [_cameraBtnSet addObject:btn];
        }
    }
}

- (UIButton*)buildButton:(CGRect)frame
            normalImgStr:(NSString*)normalImgStr
         highlightImgStr:(NSString*)highlightImgStr
          selectedImgStr:(NSString*)selectedImgStr
                  action:(SEL)action
              parentView:(UIView*)parentView {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (normalImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:normalImgStr] forState:UIControlStateNormal];
    }
    if (highlightImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:highlightImgStr] forState:UIControlStateHighlighted];
    }
    if (selectedImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:selectedImgStr] forState:UIControlStateSelected];
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:btn];
    
    return btn;
}

//对焦的框
- (void)addFocusView {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"touch_focus_x.png"]];
    imgView.alpha = 0;
    [self.view addSubview:imgView];
    self.focusImageView = imgView;
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device isFocusPointOfInterestSupported]) {
        [device addObserver:self forKeyPath:ADJUSTINT_FOCUS options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
#endif
}

//拍完照后的遮罩
- (void)addCameraCover {
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SC_APP_SIZE.width, 0)];
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    self.doneCameraUpView = upView;
    
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, _bottomContainerView.frame.origin.y, SC_APP_SIZE.width, 0)];
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    self.doneCameraDownView = downView;
    
    _countDownTitle = [UILabel createLabel:CGRectMake(0, 70, CurrentScreenWidth, 100) font:[UIFont fontWithName:@"HelveticaNeue-Light" size:100] color:[UIColor whiteColor]];
    _countDownTitle.textAlignment = NSTextAlignmentCenter;
    _countDownTitle.text = @"0";
    _countDownTitle.alpha = 0.8;
    _countDownTitle.hidden = YES;
    [self.view addSubview:_countDownTitle];
    
    
    _frontFrame = [[EZFrontFrame alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenWidth)];
    [self.view addSubview:_frontFrame];
    _frontFrame.hidden = YES;
    
}

- (void) createShotStatusSign
{
    // [[EZCanvas alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    
}

- (void)showCameraCover:(BOOL)toShow {
    
    [UIView animateWithDuration:0.38f animations:^{
        CGRect upFrame = _doneCameraUpView.frame;
        upFrame.size.height = (toShow ? SC_APP_SIZE.width / 2 + CAMERA_TOPVIEW_HEIGHT : 0);
        _doneCameraUpView.frame = upFrame;
        
        CGRect downFrame = _doneCameraDownView.frame;
        downFrame.origin.y = (toShow ? SC_APP_SIZE.width / 2 + CAMERA_TOPVIEW_HEIGHT : _bottomContainerView.frame.origin.y);
        downFrame.size.height = (toShow ? SC_APP_SIZE.width / 2 : 0);
        _doneCameraDownView.frame = downFrame;
    }];
}

//伸缩镜头的手势
- (void)addPinchGesture {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinch];
    
    //横向
    //    CGFloat width = _previewRect.size.width - 100;
    //    CGFloat height = 40;
    //    SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake((SC_APP_SIZE.width - width) / 2, SC_APP_SIZE.width + CAMERA_MENU_VIEW_HEIGH - height, width, height)];
    
    //竖向
    CGFloat width = 40;
    CGFloat height = _previewRect.size.height - 100;
    SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake(_previewRect.size.width - width, (_previewRect.size.height + CAMERA_MENU_VIEW_HEIGH - height) / 2, width, height) direction:SCSliderDirectionVertical];
    slider.alpha = 0.f;
    slider.minValue = MIN_PINCH_SCALE_NUM;
    slider.maxValue = MAX_PINCH_SCALE_NUM;
    
    WEAKSELF_SC
    [slider buildDidChangeValueBlock:^(CGFloat value) {
        [weakSelf_SC.captureManager pinchCameraViewWithScalNum:value];
    }];
    [slider buildTouchEndBlock:^(CGFloat value, BOOL isTouchEnd) {
        [weakSelf_SC setSliderAlpha:isTouchEnd];
    }];
    
    [self.view addSubview:slider];
    
    self.scSlider = slider;
}

void c_slideAlpha() {
    
}

- (void)setSliderAlpha:(BOOL)isTouchEnd {
    if (_scSlider) {
        _scSlider.isSliding = !isTouchEnd;
        
        if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
            double delayInSeconds = 3.88;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
                    [UIView animateWithDuration:0.3f animations:^{
                        _scSlider.alpha = 0.f;
                    }];
                }
            });
        }
    }
}

#pragma mark -------------touch to focus---------------
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
//监听对焦是否完成了
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:ADJUSTINT_FOCUS]) {
        BOOL isAdjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
        //        SCDLog(@"Is adjusting focus? %@", isAdjustingFocus ? @"YES" : @"NO" );
        //        SCDLog(@"Change dictionary: %@", change);
        if (!isAdjustingFocus) {
            alphaTimes = -1;
        }
    }
}

- (void)showFocusInPoint:(CGPoint)touchPoint {
    
    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        int alphaNum = (alphaTimes % 2 == 0 ? HIGH_ALPHA : LOW_ALPHA);
        self.focusImageView.alpha = alphaNum;
        alphaTimes++;
        
    } completion:^(BOOL finished) {
        
        if (alphaTimes != -1) {
            [self showFocusInPoint:currTouchPoint];
        } else {
            self.focusImageView.alpha = 0.0f;
        }
    }];
}
#endif

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //    [super touchesBegan:touches withEvent:event];
    
    alphaTimes = -1;
    
    UITouch *touch = [touches anyObject];
    currTouchPoint = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(_captureManager.previewLayer.bounds, currTouchPoint) == NO) {
        return;
    }
    
    [_captureManager focusInPoint:currTouchPoint];
    
    //对焦框
    [_focusImageView setCenter:currTouchPoint];
    _focusImageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    [UIView animateWithDuration:0.1f animations:^{
        _focusImageView.alpha = HIGH_ALPHA;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [self showFocusInPoint:currTouchPoint];
    }];
#else
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _focusImageView.alpha = 1.f;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _focusImageView.alpha = 0.f;
        } completion:nil];
    }];
#endif
}

#pragma mark -------------button actions---------------
//拍照页面，拍照按钮

- (void) appendPhoto:(NSString*)photoFile
{
    EZDEBUG(@"shot type:%i", _shotType);
    if(_shotType == kNormalShotTask){
        if(!_shotTask){
            _shotTask = [[EZShotTask alloc] init];
        }
        EZStoredPhoto* storedPhoto = [[EZStoredPhoto alloc] init];
        storedPhoto.localFileURL = photoFile;
        storedPhoto.remoteURL = photoFile;
        storedPhoto.sequence = _currentCount;
        if(!_frontFrame.hidden){
            storedPhoto.frontRegion = _frontFrame.getFinalFrame;
        }
        [_shotTask.photos addObject:storedPhoto];
    }else if(_shotType == kShotToReplace){
        //_photo.localFileURL = photoFile;
        if(_shottedPhotoURL){
            [EZFileUtil deleteFile:url2fullpath(_shottedPhotoURL)];
        }
        _shottedPhotoURL = photoFile;
    }
    
}
- (void)takePictureBtnPressed:(UIButton*)sender
{
    
    
    EZDEBUG(@"Capturing is:%i, isPaused:%i, manual:%i, shotType:%i", _shotStatus, _isPaused, _isManual, _shotType);
    if(_isManual){
        if(_currentCount == _proposedNumber){
            ++_proposedNumber;
        }
        if(_shotType == kShotToReplace){
            _proposedNumber = 1;
        }
        //++_currentCount;
        [self innerShot:sender];
        return;
    }
    
    //Mean click for the first time
    if(_shotStatus == kShotInit){
        _isPaused = true;
    }
    [self setIsPaused:!_isPaused];
    //if(_shotType == kShotSingle){
    
    //}else{
    if(_shotStatus == kShotting){
        return;
    }
    
    EZDEBUG(@"proposed:%f, %i, status:%i", _proposedNumber, _currentCount, _shotStatus);
    if(_proposedNumber == _currentCount && !_isManual && _shotType != kShotToReplace){
        _shotStatus = kShotInit;
        ++_proposedNumber;
        [self setIsPaused:NO];
        EZDEBUG(@"setPause to false:%i",_isPaused);
    }
    
    [self innerShot:sender];
    //_areCapturing = true;
    //[_shotPrepareVoice play];
    //dispatch_later(3.0, ^(){
    //    [self innerShot:sender];
    //});
    //}
}

- (void) setIsPaused:(BOOL)pause
{
    _isPaused = pause;
    //[_cameraBtnSet]
    //if(_shotStatus == kShotting){
    _shotStatusSign.hidden = NO;
    if(_isPaused){
        [_shotBtn setImage:[UIImage  imageNamed:@"shot_s"] forState:UIControlStateNormal];
        _shotLabel.hidden = YES;
        _shotStatusSign.signType = kPauseSign;
    }else{
        //[_shotBtn setImage:[UIImage  imageNamed:@"shot_pause_s"] forState:UIControlStateNormal];
        _shotLabel.hidden = NO;
        _shotStatusSign.signType = kPlaySign;
    }
    //}else{
    //    _isPaused = false;
    //[_shotBtn setImage:@"shot" forState:];
    //    [_shotBtn setImage:[UIImage imageNamed:@"shot_pause"] forState:UIControlStateNormal];
    //}
}

- (void) updateShotStatusText
{
    /**
    if(_shotStatus == kShotInit){
        _shotText.text = @"";
    }else if(_shotStatus == kShotPaused){
        _shotText.text = @"暂停";
    }else if(_shotStatus == kShotting){
        _shotText.text = @"正在拍摄....";
    }
     **/
}

- (void) realShot:(UIButton*)sender
{
#if SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [SVProgressHUD showErrorWithStatus:@"设备不支持拍照功能T_T"];
        return;
    }
#endif
    //sender.userInteractionEnabled = NO;
    //[self showCameraCover:YES];
    
    __block UIActivityIndicatorView *actiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    actiView.center = CGPointMake(self.view.center.x, self.view.center.y - CAMERA_TOPVIEW_HEIGHT);
    [actiView startAnimating];
    [self.view addSubview:actiView];
    
    WEAKSELF_SC
    [_captureManager takePicture:^(UIImage *stillImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //[SCCommon saveImageToPhotoAlbum:stillImage];//存至本机
            [self appendPhoto:file2url([EZFileUtil saveFullImage:stillImage])];
            //_currentCount ++;
            EZDEBUG(@"_currentCount: %i, proposedNumber:%i, _shotType:%i",_currentCount,_proposedNumber, _shotType);
            dispatch_main(^(){
            if(_isManual){
                //_currentCount++;
                _shotStatus = kShotDone;
                [_shotBtn setImage:[UIImage imageNamed:@"shot_s"] forState:UIControlStateNormal];
                _shotLabel.hidden = YES;
                return;
            }
            
            if(_shotType == kNormalShotTask && _currentCount < _proposedNumber){
                [self innerShot:sender];
            }else{
                _shotStatus = kShotDone;
                //_areCapturing = false;
                [_shotBtn setImage:[UIImage imageNamed:@"shot_s"] forState:UIControlStateNormal];
                _shotLabel.hidden = YES;
                _shotStatusSign.hidden = YES;
                //[self setIsManual:true];
                [self setManualMode:TRUE];
                //EZDEBUG(@"complete shot");
                
            }
            });
        });
        
        [actiView stopAnimating];
        [actiView removeFromSuperview];
        actiView = nil;
        [_shotImages setImage:[stillImage resizedImageByHeight:80] forState:UIControlStateNormal];
        ++_currentCount;
        //_shotText.text = int2str(_currentCount);
        [self updateShotText];
        double delayInSeconds = 2.f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            sender.userInteractionEnabled = YES;
            //[weakSelf_SC showCameraCover:NO];
        });
    }];
    
}

//Show the count down message
- (void) showCountDown
{
    //_currentCountDown = 0;
    //_countDownTitle.hidden = NO;
    //_countDownTitle.text = int2str(_currentCount);
    //[self countDownInner];
    _shotLabel.hidden = NO;
    _shotLabel.text = int2str(_totalCountDown - _currentCountDown);
}

- (void) countDownInner
{
   
    EZDEBUG(@"show countDown:%i", _currentCountDown);
    _countDownTitle.text = int2str(_totalCountDown - _currentCountDown);
    if(_currentCountDown > _totalCountDown){
        _countDownTitle.hidden = YES;
    }else{
        dispatch_later(1.0, ^(){
            [self countDownInner];
        });
    }
    ++_currentCountDown;
}

- (void) innerShot:(UIButton*)sender
{
    EZDEBUG(@"inner shot:%i, %i", _isManual, _isPaused);
    if(_isManual){
        [_shotBtn setImage:[UIImage imageNamed:@"shot_s"] forState:UIControlStateNormal];
        [self realShot:sender];
        return;
    }
    
    
    if(_isPaused){
        //_shotText.text = @"暂停";
        EZDEBUG(@"Quit for paused");
        [_shotBtn setImage:[UIImage imageNamed:@"shot_s"] forState:UIControlStateNormal];
        _shotStatus = kShotPaused;
        return;
    }
    _shotStatus = kShotting;
   
    //[self showCountDown];
    [self showCountDown];
    if(_currentCountDown>=_totalCountDown){
        _currentCountDown = 0;
        [self realShot:sender];
    }else{
        if(![EZConfigure sharedEZConfigure].isMute){
            [_shotPrepareVoice play];
        }
        dispatch_later(1.0, ^(){
            [self innerShot:nil];
        });
    }
    ++_currentCountDown;
}

- (void)tmpBtnPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


//拍照页面，"X"按钮
- (void)dismissBtnPressed:(id)sender {
    if(_shotStatus == kShotting){
        //UIAlertView* waiting = [[UIAlertView alloc] initWithTitle:@"等待拍摄结束"  message:@"拍摄结束后退出" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        //[waiting show];
        //return;
    }
    [self setIsPaused:true];
    if (self.navigationController) {
        if (self.navigationController.viewControllers.count == 1) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


//拍照页面，网格按钮
- (void)gridBtnPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    [_captureManager switchGrid:sender.selected];
    
}

//拍照页面，切换前后摄像头按钮按钮
- (void)switchCameraBtnPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    [_captureManager switchCamera:sender.selected];
    //_frontFrame.hidden = !_frontFrame.hidden;
}

//拍照页面，闪光灯按钮
- (void)flashBtnPressed:(UIButton*)sender {
    [_captureManager switchFlashMode:sender];
}

#pragma mark -------------pinch camera---------------
//伸缩镜头
- (void)handlePinch:(UIPinchGestureRecognizer*)gesture {
    
    [_captureManager pinchCameraView:gesture];
    
    if (_scSlider) {
        if (_scSlider.alpha != 1.f) {
            [UIView animateWithDuration:0.3f animations:^{
                _scSlider.alpha = 1.f;
            }];
        }
        [_scSlider setValue:_captureManager.scaleNum shouldCallBack:NO];
        
        if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
            [self setSliderAlpha:YES];
        } else {
            [self setSliderAlpha:NO];
        }
    }
}


//#pragma mark -------------save image to local---------------
////保存照片至本机
//- (void)saveImageToPhotoAlbum:(UIImage*)image {
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//}
//
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    if (error != NULL) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了!" message:@"存不了T_T" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//    } else {
//        SCDLog(@"保存成功");
//    }
//}

#pragma mark ------------notification-------------
- (void)orientationDidChange:(NSNotification*)noti {
    
    //    [_captureManager.previewLayer.connection setVideoOrientation:(AVCaptureVideoOrientation)[UIDevice currentDevice].orientation];
    
    if (!_cameraBtnSet || _cameraBtnSet.count <= 0) {
        return;
    }
    [_cameraBtnSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UIButton *btn = ([obj isKindOfClass:[UIButton class]] ? (UIButton*)obj : nil);
        if (!btn) {
            *stop = YES;
            return ;
        }
        
        btn.layer.anchorPoint = CGPointMake(0.5, 0.5);
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationPortrait://1
            {
                transform = CGAffineTransformMakeRotation(0);
                break;
            }
            case UIDeviceOrientationPortraitUpsideDown://2
            {
                transform = CGAffineTransformMakeRotation(M_PI);
                break;
            }
            case UIDeviceOrientationLandscapeLeft://3
            {
                transform = CGAffineTransformMakeRotation(M_PI_2);
                break;
            }
            case UIDeviceOrientationLandscapeRight://4
            {
                transform = CGAffineTransformMakeRotation(-M_PI_2);
                break;
            }
            default:
                break;
        }
        [UIView animateWithDuration:0.3f animations:^{
            btn.transform = transform;
        }];
    }];
}

#pragma mark ---------rotate(only when this controller is presented, the code below effect)-------------
//<iOS6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationChange object:nil];
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
//iOS6+
- (BOOL)shouldAutorotate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationChange object:nil];
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    //    return [UIApplication sharedApplication].statusBarOrientation;
	return UIInterfaceOrientationPortrait;
}
#endif

@end