//
//  EZKeyboardController.m
//  FeatherCV
//
//  Created by xietian on 14-3-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZKeyboardController.h"
#import "EZKeyboadUtility.h"
#import "EZMessageCenter.h"
#import "UIImage+ImageEffects.h"


@interface EZKeyboardController ()

@end

@implementation EZKeyboardController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupKeyboard];
    
    EZDEBUG(@"updated navigation delegate:%i", (int)self.navigationController);
    
    
    self.navigationController.delegate = self;
    self.navigationController.transitioningDelegate = self;
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.image = [UIImage imageNamed:@"background.png"]; //createBlurImage:20];
    _cameraNaviAnim = [[EZCameraNaviAnimation alloc] init];
    UIView* blackCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    blackCover.backgroundColor = ClickedColor;//RGBA(0, 0, 0, 50);
    //[self.view addSubview:imageView];
    self.view.backgroundColor = ClickedColor;
    [self.view addSubview:blackCover];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[[EZKeyboadUtility getInstance] add]
    //[super viewWillAppear:animated];
    //__weak EZKeyboardController* weakSelf = self;
    [[EZMessageCenter getInstance] registerEvent:EventKeyboardWillRaise block:_keyboardRaiseHandler];
    [[EZMessageCenter getInstance] registerEvent:EventKeyboardWillHide block:_keyboardHideHandler];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    __weak EZKeyboardController* weakSelf = self;
    //weakSelf.navigationController.delegate = nil;
    //weakSelf.navigationController.transitioningDelegate = nil;
    [[EZMessageCenter getInstance] unregisterEvent:EventKeyboardWillRaise forObject:_keyboardRaiseHandler];
    [[EZMessageCenter getInstance] unregisterEvent:EventKeyboardWillHide forObject:_keyboardHideHandler];
}


- (UIView*) createWrap:(CGRect)frame
{
    UIView* wrapView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x - 19.0, frame.origin.y + 1.0, frame.size.width + 38.0, 38)];
    wrapView.backgroundColor = [UIColor clearColor];
    //wrapView.layer.cornerRadius = 19;
    wrapView.layer.borderColor = [UIColor whiteColor].CGColor;
    wrapView.layer.borderWidth = 1.0;
    //[wrapView enableRoundImage];
    wrapView.layer.cornerRadius = wrapView.height/2.0;
    return wrapView;
}

- (UILabel*) createPlaceHolder:(UITextField*)textField
{
    UILabel* placeHolder = [[UILabel alloc] initWithFrame:textField.frame];
    placeHolder.textAlignment = textField.textAlignment;
    placeHolder.textColor = textField.textColor;
    placeHolder.font = textField.font;
    return placeHolder;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField{
    EZDEBUG(@"Current focused changed");
    _currentFocused = textField;
}
//--- Screen raise logic
- (void) setupKeyboard
{
    __weak EZKeyboardController* weakSelf = self;
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    EZClickView* cancelKeyboard = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 320, appFrame.size.height)];
    cancelKeyboard.backgroundColor = [UIColor clearColor];//RGBA(128, 0, 0, 128);
    cancelKeyboard.enableTouchEffects = false;
    cancelKeyboard.releasedBlock = ^(id obj){
        EZDEBUG(@"cancel clicked, %@", weakSelf.currentFocused);
        //weakSelf.hideTextInput = false;
        //[weakSelf.textField resignFirstResponder];
        //[self hideKeyboard:NO];
        
        [weakSelf.currentFocused resignFirstResponder];
    };
    _keyboardRaiseHandler = ^(id obj){
        
        EZKeyboadUtility* keyUtil = [EZKeyboadUtility getInstance];
        CGRect keyFrame = [keyUtil keyboardFrameToView:weakSelf.view];
        CGFloat smallGap = keyUtil.gapHeight;
        EZDEBUG(@"keyboard raised:%@, appFrame:%@, smallGap:%f",NSStringFromCGRect(keyFrame), NSStringFromCGRect(appFrame), smallGap);
        
        if(abs(smallGap) > 0){
            //[weakSelf lift:smallGap time:0.3 complete:nil];
            //[weakSelf ]
            if(smallGap < 0){
                weakSelf.haveDelta = true;
                weakSelf.smallGap = abs(smallGap);
            }else{
                weakSelf.haveDelta = false;
                //weakSelf.smallGap = sm;
            }
            [weakSelf liftWithBottom:smallGap isSmall:YES time:0.3 complete:nil];
        }else{
            //weakSelf.toolBarRegion.hidden = TRUE;
            [weakSelf.view addSubview:cancelKeyboard];
            [weakSelf liftWithBottom:keyFrame.size.height isSmall:NO  time:0.3 complete:nil];
        }
        //[EZDataUtil getInstance].centerButton.alpha = 0.0;
    };
    
    _keyboardHideHandler = ^(id obj){
        [cancelKeyboard removeFromSuperview];
        //[weakSelf liftWithBottom:-keyFrame.size.height time:0.6];
        [weakSelf hideKeyboard:nil];
        //[EZDataUtil getInstance].centerButton.alpha = 1.0;
        
    };
    //[[EZMessageCenter getInstance] registerEvent:EZ block:
    //_centerButtonY = [EZDataUtil getInstance].centerButton.frame.origin.y;
    
}

//I will check if have the text field or not.
- (void) hideKeyboard:(EZEventBlock)complete
{
    
    [UIView animateWithDuration:0.4  animations:^(){
        self.view.y = 0;
    } completion:^(BOOL completed){
        if(complete){
            complete(nil);
        }
    }];
}


- (void) liftWithBottom:(CGFloat)deltaGap isSmall:(BOOL)small time:(CGFloat)timeval complete:(EZEventBlock)complete
{
    CGFloat shiftY =  0;
    if(small){
        CGFloat viewY = self.view.frame.origin.y;
        CGFloat relativeDelta = deltaGap + viewY;
        //EZDEBUG(@"small gap get called, old y:%f, gap:%f, relative delta:%f", _prevKeyboard, deltaGap, relativeDelta);
        if(relativeDelta > 0){
            relativeDelta = 0;
        }
        if(viewY < 0.0){
            [UIView animateWithDuration:0.3 animations:^(){
                [self.view setY:relativeDelta - shiftY];
            } completion:^(BOOL completed){
                if(complete){
                    complete(nil);
                }
            }];
        }else if(deltaGap < 0.0){
            CGRect focusFrame = [self.view convertRect:_currentFocused.frame fromView:_currentFocused.superview];
            CGFloat leftGap = self.view.height - focusFrame.origin.y - focusFrame.size.height;
            CGFloat delta = leftGap - _prevKeyboard - abs(deltaGap);
            //EZDEBUG(@"Will raise keyboard to:%f, prevKeyboard:%f", delta, _prevKeyboard);
            if(delta < 0){
                [UIView animateWithDuration:timeval delay:0.0 options:UIViewAnimationOptionCurveLinear  animations:^(){
                    [self.view setY:delta - shiftY];
                } completion:^(BOOL completed){
                    if(complete){
                        complete(nil);
                    }
                }];
            }
            
        }
        
    }else{
        CGRect focusFrame = [self.view convertRect:_currentFocused.frame fromView:_currentFocused.superview];
        CGFloat leftGap = self.view.height - focusFrame.origin.y - focusFrame.size.height;
        
        CGFloat delta = leftGap - deltaGap;
        _prevKeyboard = deltaGap;
        if(_haveDelta){
            delta = leftGap - deltaGap - _smallGap;
        }
        //EZDEBUG(@"The focused frame is:%@, leftGap:%f,deltaGap:%f,delta:%f  smallGap:%f, haveDelta:%i", NSStringFromCGRect(focusFrame), leftGap,deltaGap,delta,_smallGap, _haveDelta);
        if(delta < 0){
            //textFieldShouldReturn
            [UIView animateWithDuration:timeval delay:0.0 options:UIViewAnimationOptionCurveLinear  animations:^(){
                [self.view setY:delta];
            } completion:^(BOOL completed){
                if(complete){
                    complete(nil);
                }
            }];
        }
    }
}



#pragma mark - Navigation Controller Delegate

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    EZDEBUG(@"Exactly before transition");
    
    switch (operation) {
        case UINavigationControllerOperationPush:
           // if(_isPushCamera){
                _cameraNaviAnim.type = AnimationTypePresent;
                return _cameraNaviAnim;
        case UINavigationControllerOperationPop:
                _cameraNaviAnim.type = AnimationTypeDismiss;
                return _cameraNaviAnim;
        default: return nil;
    }
    
}

-(id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    
    EZDEBUG(@"Somebody ask if I am interactive transition or not");
    /**
     if ([animationController isKindOfClass:[ScaleAnimation class]]) {
     ScaleAnimation *controller = (ScaleAnimation *)animationController;
     if (controller.isInteractive) return controller;
     else return nil;
     } else return nil;
     **/
    return nil;
}


- (void) startActivity
{
    
    if(!_activity){
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        _activity.center = self.view.center;
        [self.view addSubview:_activity];
    }
    _activity.hidden = NO;
    [_activity startAnimating];
    
    if(!_coverView){
        _coverView = [[UIView alloc] initWithFrame:self.view.bounds];
        _coverView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_coverView];
    }else{
        [self.view addSubview:_coverView];
    }
    //_coverView.hidden = YES;
}

- (void)timerTick:(NSTimer *)timer
{
    // Timers are not guaranteed to tick at the nominal rate specified, so this isn't technically accurate.
    // However, this is just an example to demonstrate how to stop some ongoing activity, so we can live with that inaccuracy.
    //self.timerLabel.text = [NSString stringWithFormat:@"%02.0f:%02.0f:%04.1f", hours, minutes, seconds];
    //_sendVerifyCode.enabled = NO
    _counter ++;
    if(_counter > 60){
        [_timer invalidate];
        _sendVerifyCode.enabled = YES;
        [_sendVerifyCode setTitle:macroControlInfo(@"请求短信验证码") forState:UIControlStateNormal];
    }else{
        [_sendVerifyCode setTitle:[NSString stringWithFormat:@"%i秒后重发",(60 - _counter)] forState:UIControlStateNormal];
    }
    
}


- (void) stopActivity
{
    [_activity stopAnimating];
    //[activity removeFromSuperview];
    _activity.hidden = YES;
    [_coverView removeFromSuperview];
    
}



@end
