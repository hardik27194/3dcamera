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
#import "EZRegisterCtrl.h"
#import "EZPasswordFetcher.h"


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



- (UIView*) createWrap:(CGRect)frame icon:(UIImage*)icon background:(UIImage*)background
{
    //UIView* wrapView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x - 19.0, frame.origin.y + 1.0, frame.size.width + 38.0, 38)];
    UIImageView* wrapView = [[UIImageView alloc] initWithFrame:CGRectMake(22, frame.origin.y, CurrentScreenWidth - 44, frame.size.height)];
    wrapView.contentMode = UIViewContentModeScaleToFill;
    UIImageView* iconView = [[UIImageView alloc] initWithImage:icon];
    [iconView setPosition:CGPointMake(16, (frame.size.height - icon.size.height)/2.0)];
    [wrapView addSubview:iconView];
    wrapView.image = [background resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    return wrapView;
}

- (void) qqLogin:(id)obj
{
    EZDEBUG(@"qq login get called");
}

- (void) weLogin:(id)obj
{
    EZDEBUG(@"we chat login");
}

- (void) forgetClicked:(id)obj
{
    EZDEBUG(@"forget clicked");
    EZPasswordFetcher* psFetcher = [[EZPasswordFetcher alloc] init];
    [self.navigationController pushViewController:psFetcher animated:YES];
}

- (UIButton*) createIconButton:(CGRect)frame icon:(NSString*)icon text:(NSString*)text
{
    UIButton* qqLogin = [[UIButton alloc] initWithFrame:frame];
    UIImageView* qqIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    [qqIcon setPosition:CGPointMake(16, (40-qqIcon.image.size.height)/2.0)];
    UILabel* titleText = [UILabel createLabel:CGRectMake(50, 0, 70, 40) font:[UIFont boldSystemFontOfSize:14] color:[UIColor whiteColor]];
    titleText.text = text;
    [qqLogin addSubview:qqIcon];
    [qqLogin addSubview:titleText];
    [self.view addSubview:qqLogin];
    [qqLogin setBackgroundColor:RGBA(255, 255, 255, 80)];
    qqLogin.layer.cornerRadius = qqLogin.height/2.0;
    qqLogin.clipsToBounds = YES;
    //[qqLogin addTarget:self action:@selector(qqLogin:) forControlEvents:UIControlEventTouchUpInside];
    return qqLogin;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = VinesGray;
    CGFloat startGap = 0;
    CGFloat shinkage = 0;
    if(!isRetina4){
        startGap = -30.0;
        shinkage = - 50;
    }
    
    
    _mobileIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _mobileIcon.contentMode = UIViewContentModeScaleAspectFill;
    _mobileIcon.image = [UIImage imageNamed:@"demo_avatar_jobs"];
    [_mobileIcon setPosition:CGPointMake((CurrentScreenWidth - _mobileIcon.width)/2.0, 83.0 + startGap)];
    [_mobileIcon enableRoundImage];
    [self.view addSubview:_mobileIcon];
    
    
    _mobileField = [[UITextField alloc ]initWithFrame:CGRectMake(62, 195.0 + startGap, 200.0, 45)];
    UIView* mobileWrap = [self createWrap:_mobileField.frame icon:[UIImage imageNamed:@"icon_user"] background:[UIImage imageNamed:@"inputbox_s"]];
    [self.view addSubview:mobileWrap];
    [self.view addSubview:_mobileField];
    
    _mobileField.textAlignment = NSTextAlignmentLeft;
    _mobileField.textColor = EZLoginInputTextColor;
    _mobileField.font = [UIFont systemFontOfSize:14];
    _mobileField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _mobileField.returnKeyType = UIReturnKeyNext;
    _mobileField.delegate = self;
    _mobilePlaceHolder = [self createPlaceHolder:_mobileField];
    _mobilePlaceHolder.text = macroControlInfo(@"Mobile Number");
    [self.view addSubview:_mobilePlaceHolder];
    
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(62, 253 + startGap, 200, 45)];
    UIView* passWrap = [self createWrap:_passwordField.frame icon:[UIImage imageNamed:@"icon_pw"] background:[UIImage imageNamed:@"inputbox_s"]];
    _passwordField.textAlignment = NSTextAlignmentLeft;
    _passwordField.textColor = EZLoginInputTextColor;
    _passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //_passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwordField.font = [UIFont systemFontOfSize:14];
    _passwordField.delegate = self;
    _passwordField.returnKeyType = UIReturnKeyDone;
    //[_passwordField setPlainPassword];
    _passwordPlaceHolder = [self createPlaceHolder:_passwordField];
    _passwordPlaceHolder.text = macroControlInfo(@"Password");
    [self.view addSubview:passWrap];
    [self.view addSubview:_passwordPlaceHolder];
    [self.view addSubview:_passwordField];
    
    
    _registerButton = [UIButton  createButton:CGRectMake(22, 322 + startGap, 276, 45.0) font:[UIFont boldSystemFontOfSize:18] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
    [_registerButton setBackgroundImage:[UIImage imageNamed:@"btn"] forState:UIControlStateNormal];
    [_registerButton setBackgroundImage:[UIImage imageNamed:@"btn_sel"] forState:UIControlStateHighlighted];
    [_registerButton setTitle:macroControlInfo(@"Login") forState:UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(registerClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerButton];
    
    
    UIButton* qqLogin = [self createIconButton:CGRectMake(22, 390 + startGap, 128, 40) icon:@"logo_qq" text:@"QQ登录"];
    [qqLogin addTarget:self action:@selector(qqLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qqLogin];
    
    
    UIButton* wechatLogin = [self createIconButton:CGRectMake(170, 390 + startGap, 128, 40) icon:@"logo_wechat" text:@"微信登录"];
    [wechatLogin addTarget:self action:@selector(weLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wechatLogin];
    
    
    UIView* buttonRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 505+startGap, CurrentScreenWidth, 40)];
    buttonRegion.backgroundColor = [UIColor clearColor];
    [self.view addSubview:buttonRegion];
    
    UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(CurrentScreenWidth/2.0, 9, 1, 22)];
    sep.backgroundColor = RGBA(255, 255, 255, 80);
    [buttonRegion addSubview:sep];
    
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth/2.0, 40)];
    [_loginButton setTitle:macroControlInfo(@"Register") forState:UIControlStateNormal];
    [_loginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    _loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(registerSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [buttonRegion addSubview:_loginButton];
    
    UIButton* forgetPassword = [[UIButton alloc] initWithFrame:CGRectMake(CurrentScreenWidth/2.0, 0, CurrentScreenWidth/2.0, 40)];
    [forgetPassword setTitle:macroControlInfo(@"Forget Password") forState:UIControlStateNormal];
    [forgetPassword.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    forgetPassword.titleLabel.textAlignment = NSTextAlignmentCenter;
    [forgetPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [forgetPassword addTarget:self action:@selector(forgetClicked:) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:_registerButton];
    //[self.view addSubview:_passwordButton];
    [buttonRegion addSubview:forgetPassword];
    [self.view addSubview:buttonRegion];
    
    //[self.view addSubview:_seperator];
    //[self setupKeyboard];
	// Do any additional setup after loading the view.
}

- (void) sendCode:(id)obj
{
    //EZDEBUG(@"Send code get called");
    __weak EZLoginController* weakSelf = self;
    if([_mobileField.text isNotEmpty]){
        [self startActivity];
        if([_mobileField.text isNotEmpty]){
            [[EZDataUtil getInstance] requestSmsCode:_mobileField.text success:^(id obj){
                [weakSelf stopActivity];
                //[self switchToNext];
                weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:weakSelf selector:@selector(timerTick:) userInfo:nil repeats:YES];
                weakSelf.counter = 0;
                weakSelf.sendVerifyCode.enabled = NO;

            } failure:^(id err){
                [weakSelf stopActivity];
                EZDEBUG(@"The error detail:%@", err);
            }];
        }else{
            EZDEBUG(@"empty mobile field");
        }
    }else{
        [_mobileField becomeFirstResponder];
    }
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


- (void) dealloc
{
    EZDEBUG(@"dealloc login");
}


- (void) registerSwitch:(id)obj
{
    EZDEBUG(@"switch to register called %@", self.presentingViewController);
    //[self dismissViewControllerAnimated:YES completion:nil];
    if(self.navigationController.viewControllers.count > 1){
        EZDEBUG(@"Already presented in register");
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        //[self dismissViewControllerAnimated:NO completion:^(){
        EZRegisterCtrl* registerCtrl = [[EZRegisterCtrl alloc] init];
        //registerCtrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //[self presentViewController:registerCtrl animated:YES completion:nil];
        [self.navigationController pushViewController:registerCtrl animated:YES];
        //}];
    }
}

- (void) startLogin:(NSString*)mobile password:(NSString*)password
{
    
    EZLoginController* weakSelf = self;
    if([_mobileField.text isEmpty]){
        [_mobileField becomeFirstResponder];
        return;
    }
    if([_passwordField.text isEmpty]){
        [_passwordField becomeFirstResponder];
        return;
    }
   
    
    //NSString* currentID = [EZDataUtil getInstance].currentPersonID;

    NSDictionary* loginInfo = @{
                                   @"mobile":mobile,
                                   @"password":password
                                   };
    
    EZDEBUG(@"Login info:%@", loginInfo);
    UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activity.center = self.view.center;
    [self.view addSubview:activity];
    [activity startAnimating];
    UIView* coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    coverView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:coverView];
    [[EZDataUtil getInstance] loginUser:loginInfo success:^(EZPerson* person){
        //[[EZMessageCenter getInstance] postEvent:EZAlbumImageUpdate attached:nil];
        [activity stopAnimating];
        [activity removeFromSuperview];
        [coverView removeFromSuperview];
        EZDEBUG(@"Login success, name:%@", person);
        //[[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"Login success") info: macroControlInfo(@"Congradulation")];
        
        /**
        UIViewController* presenting = self.presentingViewController;
        [weakSelf dismissViewControllerAnimated:YES completion:^(){
            EZDEBUG(@"presenting class:%@", presenting);
            if([presenting isKindOfClass:[EZRegisterCtrl class]]){
                [presenting dismissViewControllerAnimated:NO completion:nil];
            }
        }];
         **/
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        [[EZMessageCenter getInstance] postEvent:EZUserAuthenticated attached:person];
    } error:^(id err){
        EZDEBUG(@"Register error:%@", err);
        [activity stopAnimating];
        [activity removeFromSuperview];
        [coverView removeFromSuperview];
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"Login failure") info:macroControlInfo(@"Check password and mobile number")];
    }];
    
    
}



- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(![textField.text isEmpty]){
        if(textField == _mobileField){
            [_passwordField becomeFirstResponder];
            self.currentFocused = _passwordField;
            [self liftWithBottom:self.prevKeyboard isSmall:NO time:0.3 complete:nil];
            //CGFloat heightGap = _passwordField.frame.origin.y - _mobileField.frame.origin.y;
            
            
        }else if(textField == _passwordField){
            //[_password becomeFirstResponder];
            [self startLogin:_mobileField.text password:_passwordField.text];
            [textField resignFirstResponder];
        }
    }
    return true;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //[self shouldHideCheck:textField];
    return true;
}

- (void) shouldHideCheck:(UITextField*)textField
{
    if(_passwordField == textField){
        if(![_passwordField.text isEmpty]){
            _passwordPlaceHolder.hidden = YES;
        }
    }else if(_mobileField == textField){
        if(![_passwordField.text isEmpty]){
            _passwordPlaceHolder.hidden = YES;
        }
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField{
    //_currentFocused = textField;
    [super textFieldDidBeginEditing:textField];
    if(_passwordField == textField){
        //if(![_passwordField.text isEmpty]){
            _passwordPlaceHolder.hidden = YES;
        //}
    }else if(_mobileField == textField){
        //if(![_passwordField.text isEmpty]){
            _mobilePlaceHolder.hidden = YES;
        //}
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
