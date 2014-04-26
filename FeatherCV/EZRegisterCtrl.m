//
//  EZRegisterCtrl.m
//  FeatherCV
//
//  Created by xietian on 14-3-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZRegisterCtrl.h"
#import "EZDataUtil.h"
#import "EZPerson.h"
#import "EZMessageCenter.h"
#import "EZClickImage.h"
#import "EZLoginController.h"

@interface EZRegisterCtrl ()

@end

@implementation EZRegisterCtrl


- (id) init
{
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    EZDEBUG(@"init called");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    EZDEBUG(@"init completed");
    return self;
}

- (void) updateImage:(UIImage*)image
{
    [_uploadAvatar setImage:image];
    _uploadingAvatar = TRUE;
    [[EZDataUtil getInstance] uploadAvatar:image success:^(NSString* url){
        EZDEBUG(@"avatar url:%@", url);
        currentLoginUser.avatar = url;
        _avatarURL = url;
        _uploadingAvatar = false;
        if(_registerBlock){
            _registerBlock(nil);
        }
    } failure:^(id err){
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"Upload avatar failed") info:@"Please try avatar upload later"];
        _uploadingAvatar = false;
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"index:%i", buttonIndex);
    if(buttonIndex == 2){
        return;
    }
    
    __weak EZRegisterCtrl* weakSelf = self;
    [[EZUIUtility sharedEZUIUtility] raiseCamera:buttonIndex controller:self completed:^(UIImage* image){
        EZDEBUG(@"will upload image:%@", NSStringFromCGSize(image.size));
        [weakSelf updateImage:[image resizedImageWithMinimumSize:CGSizeMake(90, 90) antialias:YES]];
        
    } allowEditing:YES];
    
}

- (void) setInputField:(UITextField*)textField container:(UIView*)container
{
    textField.textAlignment = NSTextAlignmentCenter;
    textField.textColor = [UIColor whiteColor];
    textField.font = [UIFont systemFontOfSize:12];
    //textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    textField.returnKeyType = UIReturnKeyNext;
    textField.delegate = self;
    
    UIView* mobileWrap = [self createWrap:textField.frame];
    [container addSubview:mobileWrap];
    [container addSubview:textField];
    
    
}


- (UIView*) createRegisterView:(CGFloat)startGap
{
    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 175.0 + startGap, CurrentScreenWidth, CurrentScreenHeight - 175.0 - startGap)];
    containerView.backgroundColor = [UIColor clearColor];
    __weak EZRegisterCtrl* weakSelf = self;
    _uploadAvatar = [[EZClickImage alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 64.0)/2.0, 0, 64.0, 64.0)];
    UILabel* addTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64, 20)];
    addTitle.center = CGPointMake(32, 32);
    addTitle.textAlignment = NSTextAlignmentCenter;
    addTitle.textColor = [UIColor whiteColor];
    addTitle.font = [UIFont systemFontOfSize:12];
    addTitle.text = @"添加头像";
    addTitle.center = _uploadAvatar.center;
    [containerView addSubview:addTitle];

    _uploadAvatar.layer.borderColor = [UIColor whiteColor].CGColor;
    _uploadAvatar.layer.borderWidth = 1.0;
    [_uploadAvatar enableRoundImage];
    _uploadAvatar.pressedBlock = ^(id obj){
        //[weakSelf uploadAvatar];
        UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:macroControlInfo(@"Choose Avatar") delegate:weakSelf cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Album", nil];
        [action showInView:weakSelf.view];
    };
    
    [containerView addSubview:_uploadAvatar];
    _name = [[UITextField alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 206.0)/2.0, 88.0, 206.0, 40)];
    [self setInputField:_name container:containerView];
    _name.keyboardType = UIKeyboardTypeDefault;
    _namePlaceHolder = [self createPlaceHolder:_name];
    _namePlaceHolder.text = macroControlInfo(@"Name");
    [containerView addSubview:_namePlaceHolder];
    
    //NSString* deviceName = [[UIDevice currentDevice] name];
    //if([deviceName isNotEmpty]){
    //    _name.text = deviceName;
    //    _namePlaceHolder.hidden = YES;
    //}
    
    
    /**
    _mobileField = [[UITextField alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 206.0)/2.0, 131.0, 206.0, 40)];
    [self setInputField:_mobileField];
    _mobilePlaceHolder = [self createPlaceHolder:_mobileField];
    _mobileField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _mobilePlaceHolder.text = macroControlInfo(@"Mobile Number");
    [self.view addSubview:_mobilePlaceHolder];
    **/
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 206.0)/2.0, 148, 206, 40)];
    [self setInputField:_passwordField container:containerView];
    _passwordField.returnKeyType = UIReturnKeyJoin;
    [_passwordField setPlainPassword];
    _passwordPlaceHolder = [self createPlaceHolder:_passwordField];
    _passwordPlaceHolder.text = macroControlInfo(@"PassCode");
    [containerView addSubview:_passwordPlaceHolder];
    
    
    
    _registerButton = [[UIButton alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 246.0)/2.0, 208.0, 246.0, 40.0)];
    //[_registerButton enableRoundImage];
    _registerButton.layer.cornerRadius = _registerButton.height/2.0;
    _registerButton.backgroundColor = ButtonWhiteColor;//EZButtonGreen;
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_registerButton setTitle:macroControlInfo(@"Complete") forState:UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(registerClicked:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:_registerButton];
    /**
    _passwordButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 468 + startGap, 100, 40)];//400
    [_passwordButton setTitle:macroControlInfo(@"Password") forState:UIControlStateNormal];
    [_passwordButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_passwordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_passwordButton addTarget:self action:@selector(passwordSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    _seperator = [[UIView alloc] initWithFrame:CGRectMake(160, 468 + startGap + 13, 1, 14)];
    _seperator.backgroundColor = [UIColor whiteColor];
    //_loginButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 353 + startGap, 100, 40)];
    
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 211.0, CurrentScreenWidth, 40.0)];//455
    [_loginButton setTitle:macroControlInfo(@"Login") forState:UIControlStateNormal];
    [_loginButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(registerSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    [containerView addSubview:_loginButton];
     **/
    //[containerView addSubview:_seperator];
    //[containerView addSubview:_passwordButton];
    return containerView;
}

- (UIView*) createSmsView:(CGFloat)startGap
{
    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 180.0 + startGap, CurrentScreenWidth, CurrentScreenHeight - 175.0 - startGap)];
    containerView.backgroundColor = [UIColor clearColor];
    __weak EZRegisterCtrl* weakSelf = self;
    
     _mobileField = [[UITextField alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 206.0)/2.0, 50, 206.0, 40)];
     [self setInputField:_mobileField container:containerView];
     _mobilePlaceHolder = [self createPlaceHolder:_mobileField];
     _mobileField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
     _mobileField.returnKeyType = UIReturnKeyDone;
     _mobilePlaceHolder.text = macroControlInfo(@"Mobile Number");
    
     [containerView addSubview:_mobilePlaceHolder];
     
    
    
    _sendVerifyCode = [[UIButton alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 246.0)/2.0, 110.0, 246.0, 40.0)];
    //[_registerButton enableRoundImage];
    _sendVerifyCode.layer.cornerRadius = _sendVerifyCode.height/2.0;
    _sendVerifyCode.backgroundColor = ButtonWhiteColor;//EZButtonGreen;
    [_sendVerifyCode setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendVerifyCode.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_sendVerifyCode setTitle:macroControlInfo(@"请求短信验证码") forState:UIControlStateNormal];
    [_sendVerifyCode addTarget:self action:@selector(sendCode:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:_sendVerifyCode];

    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 170.0, CurrentScreenWidth, 40.0)];//455
    [_loginButton setTitle:macroControlInfo(@"Login") forState:UIControlStateNormal];
    [_loginButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_loginButton addTarget:self action:@selector(registerSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    [containerView addSubview:_loginButton];

    
    /**
     _passwordField = [[UITextField alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 206.0)/2.0, 170, 206, 40)];
     [self setInputField:_passwordField container:containerView];
     _passwordField.returnKeyType = UIReturnKeyDone;
     _passwordPlaceHolder = [self createPlaceHolder:_passwordField];
     _passwordPlaceHolder.text = macroControlInfo(@"短信验证码");
     //_passwordField.delegate = self;
     [containerView addSubview:_passwordPlaceHolder];
    
    
    _confirmCode = [[UIButton alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 246.0)/2.0, 230.0, 246.0, 40.0)];
    //[_registerButton enableRoundImage];
    _confirmCode.layer.cornerRadius = _confirmCode.height/2.0;
    _confirmCode.backgroundColor = ButtonWhiteColor;//EZButtonGreen;
    [_confirmCode setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmCode.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_confirmCode setTitle:macroControlInfo(@"确认验证码") forState:UIControlStateNormal];
    [_confirmCode addTarget:self action:@selector(confirmCode:) forControlEvents:UIControlEventTouchUpInside];
     **/
    [containerView addSubview:_confirmCode];
    /**
     _passwordButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 468 + startGap, 100, 40)];//400
     [_passwordButton setTitle:macroControlInfo(@"Password") forState:UIControlStateNormal];
     [_passwordButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
     [_passwordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [_passwordButton addTarget:self action:@selector(passwordSwitch:) forControlEvents:UIControlEventTouchUpInside];
     
     _seperator = [[UIView alloc] initWithFrame:CGRectMake(160, 468 + startGap + 13, 1, 14)];
     _seperator.backgroundColor = [UIColor whiteColor];
     //_loginButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 353 + startGap, 100, 40)];
     
     _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 211.0, CurrentScreenWidth, 40.0)];//455
     [_loginButton setTitle:macroControlInfo(@"Login") forState:UIControlStateNormal];
     [_loginButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
     [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [_loginButton addTarget:self action:@selector(registerSwitch:) forControlEvents:UIControlEventTouchUpInside];
     
     [containerView addSubview:_loginButton];
     **/
    //[containerView addSubview:_seperator];
    //[containerView addSubview:_passwordButton];
    return containerView;
}


- (void) switchToNext
{
    //[UIView animateWithDuration:0.3 animations:^(){
        //_smsView.x = -CurrentScreenWidth;
        //_originalView.x = 0;
    [_scrollContainer scrollRectToVisible:CGRectMake(CurrentScreenWidth, 0, CurrentScreenWidth, CurrentScreenHeight) animated:YES];
    //} completion:^(BOOL completed){
        //UIPageControl*
        
    //}];
}

- (void) sendCode:(id)obj
{
    //EZDEBUG(@"Send code get called");
    if([_mobileField.text isNotEmpty]){
    [self startActivity];
    if([_mobileField.text isNotEmpty]){
        [[EZDataUtil getInstance] requestSmsCode:_mobileField.text success:^(id obj){
            [self stopActivity];
            [self switchToNext];
        } failure:^(id err){
            [self stopActivity];
            EZDEBUG(@"The error detail:%@", err);
        }];
    }else{
        EZDEBUG(@"empty mobile field");
    }
    }else{
        [_mobileField becomeFirstResponder];
    }
}

- (void) confirmCode:(id)obj
{
    EZDEBUG(@"Confirm code get called");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int pos = scrollView.contentOffset.x/CurrentScreenWidth;
    EZDEBUG(@"Position %i", pos);
    _pageControl.currentPage = pos;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    EZDEBUG(@"start view did load");
    self.view.backgroundColor = VinesGray;
    CGFloat startGap = 0;
    if(!isRetina4){
        startGap = -40.0;
    }
    __weak EZRegisterCtrl* weakSelf = self;
    _titleInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 65.0 + startGap, CurrentScreenWidth, 40)];
    _titleInfo.textAlignment = NSTextAlignmentCenter;
    _titleInfo.textColor = [UIColor whiteColor];
    _titleInfo.font = [UIFont systemFontOfSize:35];
    _titleInfo.text = macroControlInfo(@"羽毛");
    
    _introduction = [[UITextView alloc] initWithFrame:CGRectMake(30, 110.0 + startGap, CurrentScreenWidth - 30.0 * 2, 55)];
    _introduction.textAlignment = NSTextAlignmentCenter;
    _introduction.textColor = [UIColor whiteColor];
    //_introduction.font = [UIFont systemFontOfSize:8];
    _introduction.backgroundColor = [UIColor clearColor];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //paragraphStyle.lineHeightMultiple = 15.0f;
    paragraphStyle.maximumLineHeight = 15.0f;
    paragraphStyle.minimumLineHeight = 15.0f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSString *content =  EZPurposeInfo; //macroControlInfo(@"Feather is a flying organ. Imagination can free you from the physical limitation");
    NSDictionary *attribute = @{
                                NSParagraphStyleAttributeName : paragraphStyle,
                                NSForegroundColorAttributeName: [UIColor whiteColor],
                                NSFontAttributeName:[UIFont systemFontOfSize:12]
                                };
    
    //[_introduction enableTextWrap];
    _introduction.attributedText = [[NSAttributedString alloc] initWithString:content attributes:attribute];
    [self.view addSubview:_titleInfo];
    [self.view addSubview:_introduction];
    _introduction.editable = FALSE;
    
    
    _originalView = [self createRegisterView:startGap];
    _originalView.x = CurrentScreenWidth;
    
    _scrollContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
    _scrollContainer.backgroundColor = [UIColor clearColor];
    _scrollContainer.pagingEnabled = YES;
    _scrollContainer.delegate = self;
    
    _scrollContainer.contentSize = CGSizeMake(CurrentScreenWidth* 2, CurrentScreenHeight);
    _scrollContainer.showsHorizontalScrollIndicator = NO;
    _scrollContainer.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollContainer];
    
    [_scrollContainer addSubview:_originalView];
    
    _smsView = [self createSmsView:startGap];
    [_scrollContainer addSubview:_smsView];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CurrentScreenHeight - 30.0, CurrentScreenWidth, 10.0)];
    [self.view addSubview:_pageControl];
    _pageControl.numberOfPages = 2;
    _pageControl.currentPage = 0;
    
    /**
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
     **/
    //[self setupKeyboard];
	// Do any additional setup after loading the view.
}

- (void) registerClicked:(id)obj
{
    //EZDEBUG(@"Register get clicked");
    [self startRegister:_name.text mobile:_mobileField.text password:_passwordField.text];
}

- (void) passwordSwitch:(id)obj
{
    EZDEBUG(@"password switch get called");
}

- (void) registerSwitch:(id)obj
{
    EZDEBUG(@"register called %@", self.presentingViewController);
    if(self.navigationController.viewControllers.count > 1){
        EZDEBUG(@"Mean this is a register");
        //[self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
    
        EZLoginController* login = [[EZLoginController alloc] init];
        //login.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //[self dismissViewControllerAnimated:NO completion:^(){
        //[self presentViewController:login animated:YES completion:nil];
        [self.navigationController pushViewController:login animated:YES];
       // }];
    }
    //[self presentViewController:login animated:YES completion:nil];
}



- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if([textField.text isNotEmpty]){
        if(textField == _name){
            [_passwordField becomeFirstResponder];
            self.currentFocused = _passwordField;
            [self liftWithBottom:self.prevKeyboard isSmall:NO time:0.3 complete:nil];
        }
        if(textField == _mobileField){
            //[_passwordField becomeFirstResponder];
            //self.currentFocused = _passwordField;
            //[self liftWithBottom:self.prevKeyboard isSmall:NO time:0.3 complete:nil];
            [textField resignFirstResponder];
            [self sendCode:_mobileField.text];
        }else if(textField == _passwordField){
            //[_password becomeFirstResponder];
            [self startRegister:_name.text mobile:_mobileField.text password:_passwordField.text];
            [textField resignFirstResponder];
        }
    }
    return true;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField{
    //_currentFocused = textField;
    [super textFieldDidBeginEditing:textField];
    //[self shouldHideCheck:textField];
    [self hidePlaceHolder:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //[self shouldHideCheck:textField];
    return true;
}

- (void) hidePlaceHolder:(UITextField*)textField
{
    if(_name == textField){
        _namePlaceHolder.hidden = YES;
    }else if(_passwordField == textField){
        _passwordPlaceHolder.hidden = YES;
    }else if(_mobileField == textField){
        _mobilePlaceHolder.hidden = YES;
    }
}

- (void) shouldHideCheck:(UITextField*)textField
{
    //[super textFieldShouldEndEditing:textField];
    if(_name == textField){
        if([_name.text isEmpty]){
            _namePlaceHolder.hidden = NO;
        }
    }else if(_passwordField == textField){
        if([_passwordField.text isEmpty]){
            _passwordPlaceHolder.hidden = NO;
        }
    }else if(_mobileField == textField){
        if([_mobileField.text isEmpty]){
            _mobilePlaceHolder.hidden = NO;
        }
    }

}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //[self shouldHideCheck:textField];
    if(_name == textField){
        if([_name.text isEmpty]){
            _namePlaceHolder.hidden = NO;
        }
    }else if(_passwordField == textField){
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




- (void) startRegister:(NSString*)name mobile:(NSString*)mobile password:(NSString*)password
{
    
    __weak EZRegisterCtrl* weakSelf = self;
    if([name isEmpty]){
        [_name becomeFirstResponder];
        return;
    }
    if([mobile isEmpty]){
        [_mobileField becomeFirstResponder];
        return;
    }
    if([password isEmpty]){
        [_passwordField becomeFirstResponder];
        return;
    }
    
    if(![_avatarURL isNotEmpty]){
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:@"请上传头像" info:nil];
        return;
    }
    
    [self startActivity];
    
    _registerBlock = ^(id obj){
        
        NSString* currentID = [EZDataUtil getInstance].currentPersonID;
        NSDictionary* registerInfo = @{
                                       @"name":name,
                                       @"mobile":mobile,
                                       @"passCode":password,
                                       @"personID":currentID?currentID:@"",
                                       @"avatar":weakSelf.avatarURL?weakSelf.avatarURL:@""
                                       };
        
        
            [[EZDataUtil getInstance] registerUser:registerInfo success:^(EZPerson* person){
            //[self dismissViewControllerAnimated:YES completion:nil];
            //_registerTitle.text = macroControlInfo(@"Register success");
            //[[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"Register success") info: macroControlInfo(@"Congradulation")];
            
            //[weakSelf dismissViewControllerAnimated:YES completion:nil];
            //[[EZDataUtil getInstance] setCurrentLoginPerson:person];
            //[[EZDataUtil]]
            [[EZMessageCenter getInstance] postEvent:EZUserAuthenticated attached:person];
            [weakSelf startActivity];
            /**
            UIViewController* presenting = weakSelf.presentingViewController;
            
            [weakSelf dismissViewControllerAnimated:YES completion:^(){
                EZDEBUG(@"presenting class:%@", weakSelf.presentingViewController);
                if([presenting isKindOfClass:[EZLoginController class]]){
                    [presenting dismissViewControllerAnimated:NO completion:nil];
                }
            }];
             **/
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        } error:^(id err){
            [weakSelf stopActivity];
            NSInteger errorCode = err2StatusCode(err);
            EZDEBUG(@"Register error:%@, errorCode:%i", err, errorCode);
            NSString* errorMsg = @"请检查后重试";
            if(errorCode == 406){
                errorMsg = @"填写手机号";
            }else if(errorCode == 407){
                errorMsg = @"短信验证码错";
            }else if(errorCode == 408){
                errorMsg = @"该手机已注册";
            }
            [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:@"注册失败" info:errorMsg];
        }];
    };

    
    if(_avatarURL == nil){
        //[[EZUIUtility sharedEZUIUtility] raiseInfoWindow:@"请上传头像" info:nil];
        if(_uploadingAvatar){
            EZDEBUG(@"Are uploading the url");
        }else{
            _registerBlock(nil);
        }
        return;
    }
    _registerBlock(nil);
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
