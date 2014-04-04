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


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = VinesGray;
    CGFloat startGap = 0;
    if(!isRetina4){
        startGap = -30.0;
    }
    _titleInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 146.0 + startGap, CurrentScreenWidth, 37)];
    _titleInfo.textAlignment = NSTextAlignmentCenter;
    _titleInfo.textColor = [UIColor whiteColor];
    _titleInfo.font = [UIFont systemFontOfSize:35];
    _titleInfo.text = macroControlInfo(@"羽毛");
    
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
    NSString *content = @"羽毛 帮你快速收集好友照片。灵感源自中国儿童游戏丢手绢。你拍照的瞬间，一起拍摄的照片会立即出现在背后。";
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
    _registerButton.backgroundColor = EZButtonGreen;
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_registerButton setTitle:macroControlInfo(@"Login") forState:UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(registerClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _passwordButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 353 + startGap, 100, 40)];//400
    [_passwordButton setTitle:macroControlInfo(@"Password") forState:UIControlStateNormal];
    [_passwordButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_passwordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_passwordButton addTarget:self action:@selector(passwordSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    _seperator = [[UIView alloc] initWithFrame:CGRectMake(160, 353 + startGap + 13, 1, 14)];
    _seperator.backgroundColor = [UIColor whiteColor];
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 353 + startGap, 100, 40)];
    [_loginButton setTitle:macroControlInfo(@"Register") forState:UIControlStateNormal];
    [_loginButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(registerSwitch:) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:_registerButton];
    [self.view addSubview:_passwordButton];
    [self.view addSubview:_loginButton];
    [self.view addSubview:_seperator];
    //[self setupKeyboard];
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
    EZDEBUG(@"switch to register called %@", self.presentingViewController);
    //[self dismissViewControllerAnimated:YES completion:nil];
    if([self.presentingViewController isKindOfClass:[EZRegisterCtrl class]]){
        [self dismissViewControllerAnimated:YES completion:^(){
        }];
        EZDEBUG(@"Already presented in register");
    }else{
        //[self dismissViewControllerAnimated:NO completion:^(){
        EZRegisterCtrl* registerCtrl = [[EZRegisterCtrl alloc] init];
        registerCtrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:registerCtrl animated:YES completion:nil];
        //}];
    }
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
        [activity stopAnimating];
        [activity removeFromSuperview];
        [coverView removeFromSuperview];
        EZDEBUG(@"Login success, name:%@", person);
        //[[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"Login success") info: macroControlInfo(@"Congradulation")];
        UIViewController* presenting = self.presentingViewController;
        [weakSelf dismissViewControllerAnimated:YES completion:^(){
            EZDEBUG(@"presenting class:%@", presenting);
            if([presenting isKindOfClass:[EZRegisterCtrl class]]){
                [presenting dismissViewControllerAnimated:NO completion:nil];
            }
        }];
        [[EZMessageCenter getInstance] postEvent:EZUserAuthenticated attached:person];
    } error:^(id err){
        EZDEBUG(@"Register error:%@", err);
        [activity stopAnimating];
        [activity removeFromSuperview];
        [coverView removeFromSuperview];
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"Login failure") info:macroControlInfo(@"Check network and try later")];
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