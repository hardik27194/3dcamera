//
//  EZLoginController.m
//  FeatherCV
//
//  Created by xietian on 14-3-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZLoginController.h"
#import "EZDataUtil.h"
#import "EZMessageCenter.h"
#import "EZKeyboadUtility.h"
#import "EZExtender.h"

@interface EZLoginController ()

@end

@implementation EZLoginController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[[EZKeyboadUtility getInstance] add]
    [super viewWillAppear:animated];
    [[EZMessageCenter getInstance] registerEvent:EventKeyboardWillRaise block:_keyboardRaiseHandler];
    [[EZMessageCenter getInstance] registerEvent:EventKeyboardWillHide block:_keyboardHideHandler];

}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = VinesGray;
    CGFloat startGap = 100;
    _titleInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 146.0 + startGap, CurrentScreenWidth, 37)];
    _titleInfo.textAlignment = NSTextAlignmentCenter;
    _titleInfo.textColor = [UIColor whiteColor];
    _titleInfo.font = [UIFont systemFontOfSize:35];
    _titleInfo.text = macroControlInfo(@"Welcome");
    
    _introduction = [[UITextView alloc] initWithFrame:CGRectMake(37, 190.0 + startGap, CurrentScreenWidth - 37.0 * 2, 40)];
    _introduction.textAlignment = NSTextAlignmentCenter;
    _introduction.textColor = [UIColor whiteColor];
    //_introduction.font = [UIFont systemFontOfSize:8];
    _introduction.backgroundColor = [UIColor clearColor];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //paragraphStyle.lineHeightMultiple = 15.0f;
    paragraphStyle.maximumLineHeight = 15.0f;
    paragraphStyle.minimumLineHeight = 15.0f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSString *content = macroControlInfo(@"Feather is a flying organ. Feather can set you free from your physical limitation, just like feather free the bird from the constraints of the gravity. Most important of all");
    NSDictionary *attribute = @{
                                NSParagraphStyleAttributeName : paragraphStyle,
                                NSForegroundColorAttributeName: [UIColor whiteColor],
                                NSFontAttributeName:[UIFont systemFontOfSize:10]
                                };
    
    //[_introduction enableTextWrap];
    _introduction.attributedText = [[NSAttributedString alloc] initWithString:content attributes:attribute];
    [self.view addSubview:_titleInfo];
    [self.view addSubview:_introduction];
    _introduction.editable = FALSE;
    
    _mobileField = [[UITextField alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 206.0)/2.0, 245.0 + startGap, 206.0, 40)];
    UIView* mobileWrap = [self createWrap:_mobileField.frame];
    [self.view addSubview:mobileWrap];
    [self.view addSubview:_mobileField];
    
    _mobileField.textAlignment = NSTextAlignmentCenter;
    _mobileField.textColor = [UIColor whiteColor];
    _mobileField.font = [UIFont systemFontOfSize:12];
    _mobileField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _mobileField.returnKeyType = UIReturnKeyNext;
    _mobileField.delegate = self;
    _mobilePlaceHolder = [self createPlaceHolder:_mobileField];
    _mobilePlaceHolder.text = macroControlInfo(@"Mobile Number");
    [self.view addSubview:_mobilePlaceHolder];
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 206.0)/2.0, 300 + startGap, 206, 40)];
    
    UIView* passWrap = [self createWrap:_passwordField.frame];
    _passwordField.textAlignment = NSTextAlignmentCenter;
    _passwordField.textColor = [UIColor whiteColor];
    
    _passwordField.font = [UIFont systemFontOfSize:13];
    _passwordField.delegate = self;
    _passwordField.returnKeyType = UIReturnKeyJoin;
    _passwordPlaceHolder = [self createPlaceHolder:_passwordField];
    _passwordPlaceHolder.text = macroControlInfo(@"Password");
    [self.view addSubview:passWrap];
    [self.view addSubview:_passwordPlaceHolder];
    [self.view addSubview:_passwordField];
    
    
    _registerButton = [[UIButton alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 246.0)/2.0, 353 + startGap, 246.0, 40.0)];
    //[_registerButton enableRoundImage];
    _registerButton.layer.cornerRadius = _registerButton.height/2.0;
    _registerButton.backgroundColor = RGBCOLOR(39, 174, 97);
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_registerButton setTitle:macroControlInfo(@"Login") forState:UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(registerClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _passwordButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 400 + startGap, 100, 40)];
    [_passwordButton setTitle:macroControlInfo(@"Password") forState:UIControlStateNormal];
    [_passwordButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_passwordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_passwordButton addTarget:self action:@selector(passwordSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    _seperator = [[UIView alloc] initWithFrame:CGRectMake(160, 400 + startGap + 13, 1, 14)];
    _seperator.backgroundColor = [UIColor whiteColor];
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 400 + startGap, 100, 40)];
    [_loginButton setTitle:macroControlInfo(@"Register") forState:UIControlStateNormal];
    [_loginButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(registerSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerButton];
    [self.view addSubview:_passwordButton];
    [self.view addSubview:_loginButton];
    [self.view addSubview:_seperator];
    [self setupKeyboard];
	// Do any additional setup after loading the view.
}

- (void) registerClicked:(id)obj
{
    //EZDEBUG(@"Register get clicked");
    [self startLogin:_mobileField.text password:_passwordField.text];
}

- (void) passwordSwitch:(id)obj
{
    EZDEBUG(@"password switch get called");
}

- (void) registerSwitch:(id)obj
{
    EZDEBUG(@"register called");
}

- (void) startLogin:(NSString*)mobile password:(NSString*)password
{
    
    __weak EZLoginController* weakSelf = self;
    if([_mobileField.text isEmpty]){
        [_mobileField becomeFirstResponder];
        return;
    }
    if([_passwordField.text isEmpty]){
        [_passwordField becomeFirstResponder];
    }
   
    
    //NSString* currentID = [EZDataUtil getInstance].currentPersonID;

    NSDictionary* loginInfo = @{
                                   @"mobile":mobile,
                                   @"password":password
                                   };
    
    EZDEBUG(@"Login info:%@", loginInfo);
    UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    activity.center = self.view.center;
    [self.view addSubview:activity];
    [activity startAnimating];
    [[EZDataUtil getInstance] loginUser:loginInfo success:^(EZPerson* person){
        [activity stopAnimating];
        [activity removeFromSuperview];
        EZDEBUG(@"Login success, name:%@", person);
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"Login success") info: macroControlInfo(@"Congradulation")];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        [[EZMessageCenter getInstance] postEvent:EZUserAuthenticated attached:person];
        
    } error:^(id err){
        EZDEBUG(@"Register error:%@", err);
        [activity stopAnimating];
        [activity removeFromSuperview];
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"Login failure") info:macroControlInfo(@"Check network and try later")];
    }];
    
    
}



- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(![textField.text isEmpty]){
        if(textField == _mobileField){
            [_passwordField becomeFirstResponder];
            _currentFocused = _passwordField;
            [self liftWithBottom:_prevKeyboard isSmall:NO time:0.3 complete:nil];
        }else if(textField == _passwordField){
            //[_password becomeFirstResponder];
            [self startLogin:_mobileField.text password:_passwordField.text];
            [textField resignFirstResponder];
        }
    }
    return true;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField{
    _currentFocused = textField;
    if(_passwordField == textField){
        _passwordPlaceHolder.hidden = YES;
    }else if(_mobileField == textField){
        _mobilePlaceHolder.hidden = YES;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(_passwordField == textField){
        if([_passwordField.text isEmpty]){
            _passwordPlaceHolder.hidden = NO;
        }
    }else if(_mobileField == textField){
        if([_mobileField.text isEmpty]){
            _mobilePlaceHolder.hidden = NO;
        }
        
    }
    return true;
}


//--- Screen raise logic
- (void) setupKeyboard
{
    __weak EZLoginController* weakSelf = self;
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    EZClickView* cancelKeyboard = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 320, appFrame.size.height)];
    cancelKeyboard.backgroundColor = [UIColor clearColor];//RGBA(128, 0, 0, 128);
    cancelKeyboard.enableTouchEffects = false;
    cancelKeyboard.releasedBlock = ^(id obj){
        EZDEBUG(@"cancel clicked");
        //weakSelf.hideTextInput = false;
        //[weakSelf.textField resignFirstResponder];
        //[self hideKeyboard:NO];
        [_currentFocused resignFirstResponder];
    };
    _keyboardRaiseHandler = ^(id obj){
        
        EZKeyboadUtility* keyUtil = [EZKeyboadUtility getInstance];
        CGRect keyFrame = [keyUtil keyboardFrameToView:weakSelf.view];
        CGFloat smallGap = keyUtil.gapHeight;
        EZDEBUG(@"keyboard raised:%@, appFrame:%@, smallGap:%f",NSStringFromCGRect(keyFrame), NSStringFromCGRect(appFrame), smallGap);
        
        if(abs(smallGap) > 0){
            //[weakSelf lift:smallGap time:0.3 complete:nil];
            //[weakSelf ]
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
    
    if(small){
        
        CGFloat viewY = self.view.frame.origin.y;
        CGFloat relativeDelta = deltaGap + viewY;
        EZDEBUG(@"small gap get called, old y:%f, gap:%f, relative delta:%f", _prevKeyboard, deltaGap, relativeDelta);
        if(relativeDelta > 0){
            relativeDelta = 0;
        }
        if(viewY < 0.0){
            [UIView animateWithDuration:0.3 animations:^(){
                [self.view setY:relativeDelta];
            } completion:^(BOOL completed){
                if(complete){
                    complete(nil);
                }
            }];
        }else if(deltaGap < 0.0){
            CGRect focusFrame = _currentFocused.frame;
            CGFloat leftGap = self.view.height - focusFrame.origin.y - focusFrame.size.height;
            CGFloat delta = leftGap - _prevKeyboard - abs(deltaGap);
            EZDEBUG(@"Will raise keyboard to:%f, prevKeyboard:%f", delta, _prevKeyboard);
            if(delta < 0){
                [UIView animateWithDuration:timeval delay:0.0 options:UIViewAnimationOptionCurveLinear  animations:^(){
                    [self.view setY:delta];
                } completion:^(BOOL completed){
                    if(complete){
                        complete(nil);
                    }
                }];
            }
            
        }
        
    }else{
        CGRect focusFrame = _currentFocused.frame;
        CGFloat leftGap = self.view.height - focusFrame.origin.y - focusFrame.size.height;
        EZDEBUG(@"The focused frame is:%@, leftGap:%f", NSStringFromCGRect(focusFrame), leftGap);
        CGFloat delta = leftGap - deltaGap;
        _prevKeyboard = deltaGap;
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
