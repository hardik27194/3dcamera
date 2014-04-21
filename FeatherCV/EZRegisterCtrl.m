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

- (void) setInputField:(UITextField*)textField
{
    textField.textAlignment = NSTextAlignmentCenter;
    textField.textColor = [UIColor whiteColor];
    textField.font = [UIFont systemFontOfSize:12];
    //textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    textField.returnKeyType = UIReturnKeyNext;
    textField.delegate = self;
    
    UIView* mobileWrap = [self createWrap:textField.frame];
    [self.view addSubview:mobileWrap];
    [self.view addSubview:textField];
    
    
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
    NSString *content =  @"羽毛 帮你快速收集好友照片。灵感源自中国儿童游戏丢手绢。你拍照的瞬间，一起拍摄的照片会立即出现在背后。"; //macroControlInfo(@"Feather is a flying organ. Imagination can free you from the physical limitation");
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
    
    _uploadAvatar = [[EZClickImage alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 64.0)/2.0, 175.0 + startGap, 64.0, 64.0)];
    UILabel* addTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64, 20)];
    addTitle.center = CGPointMake(32, 32);
    addTitle.textAlignment = NSTextAlignmentCenter;
    addTitle.textColor = [UIColor whiteColor];
    addTitle.font = [UIFont systemFontOfSize:14];
    addTitle.text = @"添加头像";
    addTitle.center = _uploadAvatar.center;
    [self.view addSubview:addTitle];
    _uploadAvatar.layer.borderColor = [UIColor whiteColor].CGColor;
    _uploadAvatar.layer.borderWidth = 1.0;
    [_uploadAvatar enableRoundImage];
    _uploadAvatar.pressedBlock = ^(id obj){
        //[weakSelf uploadAvatar];
        UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:macroControlInfo(@"Choose Avatar") delegate:weakSelf cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Album", nil];
        [action showInView:weakSelf.view];
    };
    
    [self.view addSubview:_uploadAvatar];
    
    _name = [[UITextField alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 206.0)/2.0, 253 + startGap, 206.0, 40)];
    [self setInputField:_name];
    _name.keyboardType = UIKeyboardTypeDefault;
    _namePlaceHolder = [self createPlaceHolder:_name];
    _namePlaceHolder.text = macroControlInfo(@"Name");
    [self.view addSubview:_namePlaceHolder];
    
    NSString* deviceName = [[UIDevice currentDevice] name];
    if([deviceName isNotEmpty]){
        _name.text = deviceName;
        _namePlaceHolder.hidden = YES;
    }
    
    _mobileField = [[UITextField alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 206.0)/2.0, 306.0 + startGap, 206.0, 40)];
    [self setInputField:_mobileField];
    _mobilePlaceHolder = [self createPlaceHolder:_mobileField];
    _mobileField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _mobilePlaceHolder.text = macroControlInfo(@"Mobile Number");
    [self.view addSubview:_mobilePlaceHolder];
    
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 206.0)/2.0, 360 + startGap, 206, 40)];
    [self setInputField:_passwordField];
    _passwordField.returnKeyType = UIReturnKeyJoin;
    _passwordPlaceHolder = [self createPlaceHolder:_passwordField];
    _passwordPlaceHolder.text = macroControlInfo(@"Password");
    [self.view addSubview:_passwordPlaceHolder];
    
    
    
    _registerButton = [[UIButton alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 246.0)/2.0, 414 + startGap, 246.0, 40.0)];
    //[_registerButton enableRoundImage];
    _registerButton.layer.cornerRadius = _registerButton.height/2.0;
    _registerButton.backgroundColor = ButtonWhiteColor;//EZButtonGreen;
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_registerButton setTitle:macroControlInfo(@"Register") forState:UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(registerClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerButton];
    
    _passwordButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 468 + startGap, 100, 40)];//400
    [_passwordButton setTitle:macroControlInfo(@"Password") forState:UIControlStateNormal];
    [_passwordButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_passwordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_passwordButton addTarget:self action:@selector(passwordSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    _seperator = [[UIView alloc] initWithFrame:CGRectMake(160, 468 + startGap + 13, 1, 14)];
    _seperator.backgroundColor = [UIColor whiteColor];
    //_loginButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 353 + startGap, 100, 40)];
    
    _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 468 + startGap, 100, 40)];//455
    [_loginButton setTitle:macroControlInfo(@"Login") forState:UIControlStateNormal];
    [_loginButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(registerSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_loginButton];
    [self.view addSubview:_seperator];
    [self.view addSubview:_passwordButton];
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
    if(![textField.text isEmpty]){
        if(textField == _name){
            [_mobileField becomeFirstResponder];
            self.currentFocused = _mobileField;
            [self liftWithBottom:self.prevKeyboard isSmall:NO time:0.3 complete:nil];
        }
        if(textField == _mobileField){
            [_passwordField becomeFirstResponder];
            self.currentFocused = _passwordField;
            [self liftWithBottom:self.prevKeyboard isSmall:NO time:0.3 complete:nil];
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
    
    if(_uploadAvatar.image == nil){
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:@"请上传头像" info:nil];
        return;

    }
    
    _registerBlock = ^(id obj){
        
        NSString* currentID = [EZDataUtil getInstance].currentPersonID;
        NSDictionary* registerInfo = @{
                                       @"name":name,
                                       @"mobile":mobile,
                                       @"password":password,
                                       @"personID":currentID?currentID:@"",
                                       @"avatar":weakSelf.avatarURL?weakSelf.avatarURL:@""
                                       };
        
        
        UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        activity.center = weakSelf.view.center;
        [weakSelf.view addSubview:activity];
        [activity startAnimating];
        
        UIView* coverView = [[UIView alloc] initWithFrame:weakSelf.view.bounds];
        coverView.backgroundColor = [UIColor clearColor];
        [weakSelf.view addSubview:coverView];
        [[EZDataUtil getInstance] registerUser:registerInfo success:^(EZPerson* person){
            [activity stopAnimating];
            [activity removeFromSuperview];
            [coverView removeFromSuperview];
            //[self dismissViewControllerAnimated:YES completion:nil];
            //_registerTitle.text = macroControlInfo(@"Register success");
            //[[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"Register success") info: macroControlInfo(@"Congradulation")];
            
            //[weakSelf dismissViewControllerAnimated:YES completion:nil];
            //[[EZDataUtil getInstance] setCurrentLoginPerson:person];
            //[[EZDataUtil]]
            [[EZMessageCenter getInstance] postEvent:EZUserAuthenticated attached:person];
            
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
            EZDEBUG(@"Register error:%@", err);
            [activity stopAnimating];
            [activity removeFromSuperview];
            [coverView removeFromSuperview];
            [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:@"注册失败" info:@"请检查后重试"];
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
