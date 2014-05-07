//
//  EZUIUtility.m
//  Feather
//
//  Created by xietian on 13-10-15.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZUIUtility.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "EZMessageCenter.h"
#import "EZShapeCover.h"
#import <MessageUI/MessageUI.h>
#import "EZClickImage.h"
#import "EZHairButton.h"
#import "EZDataUtil.h"

#define ColorTransparent 80
@implementation EZUIUtility

SINGLETON_FOR_CLASS(EZUIUtility)

- (id) init
{
    self = [super init];
    _cameraRaised = false;
    _colors = @[RGBA(255, 0, 0, ColorTransparent), RGBA(127, 127, 0, ColorTransparent), RGBA(127, 0, 127, ColorTransparent), RGBA(0, 255, 0, ColorTransparent), RGBA(0, 0, 255, ColorTransparent)];
    return self;
}


- (UIView*) createGradientView
{
    
    UIView* gradientView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    gradientView.backgroundColor = [UIColor clearColor];
    gradientView.userInteractionEnabled = FALSE;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    //gradient.cornerRadius = 7;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)RGBA(0, 0, 0, 60).CGColor,
                       (id)RGBA(0, 0, 0, 0).CGColor,
                       (id)RGBA(0, 0, 0, 0).CGColor,
                       (id)RGBA(0, 0, 0, 60).CGColor,
                       nil];
    gradient.locations = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0f],
                          [NSNumber numberWithFloat:0.4],
                          [NSNumber numberWithFloat:0.6],
                          [NSNumber numberWithFloat:1.0],
                          nil];
    
    [[gradientView layer] insertSublayer:gradient atIndex:0];
    return gradientView;
}

- (void) quitClicked:(id)obj
{
    EZDEBUG(@"quitClicked");
    //[MobClick event:EZInviteFriend label:[NSString stringWithFormat:@"%@,quit", currentLoginID]];
    if(_messageQuit){
        _messageQuit(nil);
        _messageQuit = nil;
    }
    
}

- (void) sendMessge:(NSString *)phone content:(NSString *)content presenter:(UIViewController*)presenter completed:(EZEventBlock)completed
{
    
    __weak EZUIUtility* weakSelf = self;
    //dispatch_later(0.15, (^(){
        [MobClick event:EZInviteFriend label:currentLoginID];
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
    UIView* brand = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, 64)];
    brand.backgroundColor = [UIColor whiteColor];
    UIButton* quitButton = [[UIButton alloc] initWithFrame:CGRectMake(CurrentScreenWidth - 50, 20, 44, 50)];
    [quitButton setTitle:@"退出" forState:UIControlStateNormal];
    [quitButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [quitButton setTitleColor:EZAppleBlue forState:UIControlStateNormal];
    [quitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [brand addSubview:quitButton];
    [quitButton addTarget:self action:@selector(quitClicked:) forControlEvents:UIControlEventTouchUpInside];
    [controller.view addSubview:brand];
    _messageQuit = ^(id obj){
        [weakSelf messageComposeViewController:controller didFinishWithResult:0];
    };
    //[controller.view insertSubview:brand atIndex:0];
    //controller.view.backgroundColor = [UIColor blueColor];
    //UIBarButtonItem* barItem
    //controller.navigationItem.rightBarButtonItem. = [UIColor redColor];
    if([MFMessageComposeViewController canSendText])
    {
        
        _messageCompletion = completed;
        controller.body = content;
        controller.recipients = [NSArray arrayWithObjects:phone, nil];
        controller.messageComposeDelegate = self;
        [presenter presentViewController:controller animated:YES completion:nil];

        controller.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:quitButton];
    }
    //}));
}
                   

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    
    [MobClick event:EZInviteFriend label:[NSString stringWithFormat:@"%@,%i", currentLoginID, result]];
    EZDEBUG(@"Finish message compose:%i", result);
    [controller dismissViewControllerAnimated:YES completion:nil];
    if(_completed){
        _completed(@(result));
    }
}


+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (UIColor*) getBackgroundColor:(UIColor*)color
{
    if(color){
        return color;
    }
    
    int idx = rand() % _colors.count;
    return [_colors objectAtIndex:idx];
}


- (UIView*) createHoleView
{
    EZShapeCover* shapeCover = [[EZShapeCover alloc] initWithFrame:[UIScreen mainScreen].bounds];
    CGPoint centerPoint = CGPointMake(CurrentScreenWidth/2.0, CurrentScreenHeight/2.0 + CenterUpShift);
    [shapeCover digHole:310 center:centerPoint color:[UIColor blackColor] opacity:1.0];
    return shapeCover;
}

- (void) gravityDrop:(UIView*)container from:(UIView*)fromView to:(UIView*)toView
{
    
        // no other transitions are allowed until this one finishes
        //self.navigationController.toolbar.userInteractionEnabled = NO;
        
    
    CGRect startFrame = fromView.frame;//self.view.frame;
    CGRect endFrame = toView.frame;
        
        // the start position is below the bottom of the visible frame
        startFrame.origin.y = -startFrame.size.height;
        endFrame.origin.y = 0;
        
        toView.frame = startFrame;
        
        //NSArray *priorConstraints = self.priorConstraints;
        [container addSubview:toView];
        [UIView animateWithDuration:1.0f
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:5.0
                            options:0
                         animations:^{ toView.frame = endFrame; }
                         completion:^(BOOL finished) {
                             // slide down animation finished, remove the older view and the constraints
                             //
                             //if (priorConstraints != nil)
                             //    [self.view removeConstraints:priorConstraints];
                             [fromView removeFromSuperview];
                             
                             //self.navigationController.toolbar.userInteractionEnabled = YES;
                         }];
}

- (UIImagePickerController*) getCamera:(BOOL)isAlbum slide:(BOOL)slide completed:(EZEventBlock)block
{
    if ([UIImagePickerController isSourceTypeAvailable:
                            UIImagePickerControllerSourceTypeCamera] == NO
                          && !isAlbum)
        return nil;
    _triggerBySlide = slide;
    //[UIApplication sharedApplication].statusBarHidden = true;
    _completed = block;
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    EZDEBUG(@"Slide:%i", slide);
    
    cameraUI.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if(isAlbum){
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }else{
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        if(slide){
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    
    //[UIImagePickerController availableMediaTypesForSourceType:
    // UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;
    return cameraUI;
}

- (void) raiseCamera:(BOOL)isAlbum controller:(UIViewController *)controller completed:(EZEventBlock)block allowEditing:(BOOL)allowEditing
{
    if ((([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        && !isAlbum))
        return;
    //[UIApplication sharedApplication].statusBarHidden = true;
    _completed = block;
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if(isAlbum){
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }else{
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    
    //[UIImagePickerController availableMediaTypesForSourceType:
    // UIImagePickerControllerSourceTypeCamera];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = allowEditing;
    cameraUI.delegate = self;
    [controller presentViewController:cameraUI animated:YES completion:nil];
    
}

- (UILabel*) createNumberLabel
{
    UILabel* numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, 16, 16)];
    numberLabel.font = [UIFont boldSystemFontOfSize:10];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.backgroundColor = RGBCOLOR(249, 49, 55);
    numberLabel.textColor = [UIColor whiteColor];
    //numberLabel.text = @"1";
    [numberLabel enableRoundEdge];
    return numberLabel;
}

- (EZHairButton*) createShotButton
{
    EZHairButton* clickView =  [[EZHairButton alloc] initWithFrame:CGRectMake(CurrentScreenWidth - 46 - 10, 30, 46, 46)];
    return clickView;
}

- (EZClickImage*) createShotButtonOld
{
    EZClickImage* clickView =  [[EZClickImage alloc] initWithFrame:CGRectMake(CurrentScreenWidth - 46 - 10, 30, 46, 46)];
    //[[EZCenterButton alloc] initWithFrame:CGRectMake(255, 23, 60,60) cycleRadius:21 lineWidth:2];
    //clickView.backgroundColor = RGBA(255, 255, 255, 120);
    //clickView.layer.borderColor = [UIColor whiteColor].CGColor;
    //clickView.layer.borderWidth = 2.0;
    [clickView enableRoundImage];
    clickView.enableTouchEffects = YES;
    
    UIView* horizon = [[UIView alloc] initWithFrame:CGRectMake(30, 30, 31, 1)];
    horizon.backgroundColor = ClickedColor;// [UIColor whiteColor];
    
    UIView* vertical = [[UIView alloc] initWithFrame:CGRectMake(30, 30, 1, 31)];
    vertical.backgroundColor = ClickedColor; //[UIColor whiteColor];
    
    horizon.center = CGPointMake(23, 23);
    vertical.center = CGPointMake(23, 23);
    [clickView addSubview:horizon];
    [clickView addSubview:vertical];
    clickView.backgroundColor = ButtonWhiteColor;
    return clickView;
}


- (EZClickImage*) createLargeShotButton
{
    
    CGFloat radius = 120;
    EZClickImage* clickView =  [[EZClickImage alloc] initWithFrame:CGRectMake(0, 0, radius, radius)];
    //[[EZCenterButton alloc] initWithFrame:CGRectMake(255, 23, 60,60) cycleRadius:21 lineWidth:2];
    //clickView.backgroundColor = RGBA(255, 255, 255, 120);
    //clickView.layer.borderColor = [UIColor whiteColor].CGColor;
    //clickView.layer.borderWidth = 2.0;
    //[clickView enableRoundImage];
    clickView.enableTouchEffects = NO;
    
    UIView* horizon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, radius, 2)];
    horizon.backgroundColor = [UIColor whiteColor];//ClickedColor;//
    UIView* vertical = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, radius)];
    vertical.backgroundColor = [UIColor whiteColor];//ClickedColor; //[UIColor whiteColor];
    
    horizon.center = CGPointMake(radius/2.0, radius/2.0);
    vertical.center = CGPointMake(radius/2.0, radius/2.0);
    [clickView addSubview:horizon];
    [clickView addSubview:vertical];
    clickView.backgroundColor = [UIColor clearColor];//ButtonWhiteColor;
    return clickView;
}


- (EZClickImage*) createBackShotButton
{
    
    CGFloat radius = 120;
    CGFloat outerRadius = radius+10;
    EZClickImage* clickView =  [[EZClickImage alloc] initWithFrame:CGRectMake(0, 0, outerRadius, outerRadius)];
    //[[EZCenterButton alloc] initWithFrame:CGRectMake(255, 23, 60,60) cycleRadius:21 lineWidth:2];
    //clickView.backgroundColor = RGBA(255, 255, 255, 120);
    //clickView.layer.borderColor = [UIColor whiteColor].CGColor;
    //clickView.layer.borderWidth = 2.0;
    //[clickView enableRoundImage];
    clickView.enableTouchEffects = NO;
    
    UIView* horizon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, radius, 2)];
    horizon.backgroundColor = ClickedColor;//
    UIView* vertical = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, radius)];
    vertical.backgroundColor = ClickedColor; //[UIColor whiteColor];
    
    horizon.center = CGPointMake(outerRadius/2.0, outerRadius/2.0);
    vertical.center = CGPointMake(outerRadius/2.0, outerRadius/2.0);
    [clickView addSubview:horizon];
    [clickView addSubview:vertical];
    clickView.backgroundColor = ButtonWhiteColor;
    [clickView enableRoundImage];
    return clickView;
}

- (void)proximityStateChanged:(NSNotification *)note
{
    if ( !note ) {
        //[self setFaceDownOnSurface:NO];
        EZDEBUG(@"Don't have notes");
        //return;
    }else{
        EZDEBUG(@"notes name:%@, user information:%@", note.name, note.userInfo);
    }
    
    UIDevice *device = [UIDevice currentDevice];
    //BOOL newProximityState = device.proximityState;
    EZDEBUG(@"state is:%i", device.proximityState);
    if(device.proximityState == 0){
        [[EZMessageCenter getInstance] postEvent:EZTriggerCamera attached:nil];
    }
     [[EZMessageCenter getInstance] postEvent:EZFaceCovered attached:@(device.proximityState)];
}

- (void) enableProximate:(BOOL)enable
{
    UIDevice *device = [UIDevice currentDevice];
    if ( enable ) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateChanged:) name:UIDeviceProximityStateDidChangeNotification object:nil];
        device.proximityMonitoringEnabled = YES;
    } else {
        device.proximityMonitoringEnabled = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [UIApplication sharedApplication].statusBarHidden = false;
    [info objectForKey:
     UIImagePickerControllerEditedImage];
    if(_completed){
        _completed([info objectForKey:UIImagePickerControllerEditedImage]);
    }
    /**
    _cameraRaised = false;
    [UIApplication sharedApplication].statusBarHidden = false;
    //[picker dismissViewControllerAnimated:YES completion:nil];
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    EZDEBUG(@"Media type:%@", mediaType);
    UIImage *originalImage;//, *editedImage, *imageToUse;
    originalImage = (UIImage *) [info objectForKey:
                                 UIImagePickerControllerOriginalImage];
    [[EZMessageCenter getInstance] postEvent:EZCameraCompleted attached:originalImage];
    if(_completed){
       
        //[[picker parentViewController] dismissModalViewControllerAnimated: YES];
        //[picker release];
        _completed(originalImage);
    }
     **/
}

- (void) showErrorInfo:(NSString*)errorInfo delay:(CGFloat)delay view:(UIView*)view
{
    UILabel* failureMsg = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, CurrentScreenWidth, 44)];
    failureMsg.textAlignment = NSTextAlignmentCenter;
    failureMsg.textColor = [UIColor whiteColor];
    failureMsg.font = [UIFont boldSystemFontOfSize:16];
    failureMsg.text = errorInfo;
    if(view){
        [view addSubview:failureMsg];
    }else{
        [TopView addSubview:failureMsg];
    }
    dispatch_later(delay, ^(){
        [failureMsg removeFromSuperview];
    });
}


- (void) raiseInfoWindow:(NSString*)title info:(NSString *)info
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:info delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    [alertView show];
    
    dispatch_later(1.5, ^(){
        [alertView dismissWithClickedButtonIndex:-1 animated:YES];
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    /**
    //[picker dismissViewControllerAnimated:YES completion:nil];
    [[EZMessageCenter getInstance] postEvent:EZCameraCompleted attached:nil];
    _cameraRaised = false;
    **/
    //[UIApplication sharedApplication].statusBarHidden = false;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

@end
