//
//  EZRegisterPage.m
//  BabyCare
//
//  Created by xietian on 14-8-4.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZRegisterCtrl.h"
//#import "EZExtender.h"
#import "EZTextField.h"

#define EZSmsCodeColor RGBCOLOR(65, 210, 193)

@interface EZRegisterCtrl()

@end

@implementation EZRegisterCtrl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if([textField.text isNotEmpty]){
        int nextTag = textField.tag + 1;
        UITextField* nextField = (UITextField*)[textField.superview viewWithTag:nextTag];
        if(nextField){
            [nextField becomeFirstResponder];
            self.currentFocused = nextField;
            [self liftWithBottom:100 isSmall:NO time:0.3 complete:nil];
        }else{
            [textField resignFirstResponder];
            [self sendRequest:nil];
        }
    }
    return true;
}

- (UIView*) createWrap:(CGRect)frame background:(UIImage*)background
{
    //UIView* wrapView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x - 19.0, frame.origin.y + 1.0, frame.size.width + 38.0, 38)];
    UIImageView* wrapView = [[UIImageView alloc] initWithFrame:CGRectMake(22, frame.origin.y, frame.size.width, frame.size.height)];
    wrapView.contentMode = UIViewContentModeScaleToFill;
    //UIImageView* iconView = [[UIImageView alloc] initWithImage:icon];
    //[iconView setPosition:CGPointMake(16, (frame.size.height - icon.size.height)/2.0)];
    //[wrapView addSubview:iconView];
    wrapView.image = [background resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    return wrapView;
}

- (void) sendSmsCode:(id)obj
{
    //EZDEBUG(@"Sms code send");
    _sendSmsCode.enabled = false;
    _countDown.hidden = false;
    _smsCodeCounter = 60;
    [self updateCounter];
    
}

- (void) updateCounter
{
    if(_smsCodeCounter > 0){
        --_smsCodeCounter;
        _countDown.text = int2str(_smsCodeCounter);
    }else{
        _sendSmsCode.enabled = true;
        _countDown.hidden = true;
        return;
    }
    
    dispatch_later(1.0, ^(){
        [self updateCounter];
    });
}

- (void) sendRequest:(id)obj
{
    EZDEBUG(@"send request");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    EZDEBUG(@"start view did load");
    //self.view.backgroundColor = VinesGray;
    CGFloat startGap = 0;
    if(!isRetina4){
        startGap = -40.0;
    }
    UIView* navBar = [self createNavHeader:@"注册"];
    [self.view addSubview:navBar];
    UIView* holder = [[UIView alloc] initWithFrame:CGRectMake(0, 64, CurrentScreenWidth, CurrentScreenHeight - 64)];
    holder.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:holder];
    
    _nickName = [self createTextField:CGRectMake(22, 20, 180, EZPasswordInputHeight) holderText:@"昵称" keyboardType:UIKeyboardTypeDefault returnType:UIReturnKeyNext];
    _nickName.tag = 1;
    [holder addSubview:_nickName];
    _nickName.delegate = self;
    
    _mobileNumber = [self createTextField:CGRectMake(22, _nickName.bottom + 12, 180, EZPasswordInputHeight) holderText:@"手机号" keyboardType:UIKeyboardTypeNumbersAndPunctuation returnType:UIReturnKeyNext];
    [holder addSubview:_mobileNumber];
    _mobileNumber.tag = 2;
    _sendSmsCode = [UIButton createButton:CGRectMake(210, _nickName.bottom + 17, 100, 34) font:[UIFont systemFontOfSize:15] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
    _sendSmsCode.layer.cornerRadius = 17;
    [_sendSmsCode setBackgroundColor:EZSmsCodeColor];
    [_sendSmsCode setTitle:@"发送验证码" forState:UIControlStateNormal];
    [_sendSmsCode addTarget:self action:@selector(sendSmsCode:) forControlEvents:UIControlEventTouchUpInside];
    //_sendSmsCode.tag = 3;
    [holder addSubview:_sendSmsCode];
    
    
    _mobileSmsCode = [self createTextField:CGRectMake(22, _mobileNumber.bottom + 12 , 180, EZPasswordInputHeight) holderText:@"手机验证码" keyboardType:UIKeyboardTypeNumbersAndPunctuation returnType:UIReturnKeyNext];
    _mobileSmsCode.tag = 3;
    [holder addSubview:_mobileSmsCode];
    
    _countDown = [UILabel createLabel:CGRectMake(210, _mobileNumber.bottom + 12, 80, EZPasswordInputHeight) font:[UIFont systemFontOfSize:16] color:RGBCOLOR(54, 193, 191)];
    _countDown.textAlignment = NSTextAlignmentCenter;
    [holder addSubview:_countDown];
    
    _password = [self createTextField:CGRectMake(22, _mobileSmsCode.bottom + 12, 276, EZPasswordInputHeight) holderText:@"密码" keyboardType:UIKeyboardTypeDefault returnType:UIReturnKeyNext];
    _password.tag = 4;
    [holder addSubview:_password];
    
    _confirmPassword = [self createTextField:CGRectMake(22, _password.bottom + 12, 276, EZPasswordInputHeight) holderText:@"重复密码" keyboardType:UIKeyboardTypeDefault returnType:UIReturnKeySend];
    _confirmPassword.tag = 5;
    [holder addSubview:_confirmPassword];
    
    _sendBtn = [UIButton createButton:CGRectMake(22, _confirmPassword.bottom + 24, 276, EZPasswordInputHeight) font:[UIFont boldSystemFontOfSize:18] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
    [_sendBtn setTitle:@"确  认" forState:UIControlStateNormal];
    [_sendBtn setBackgroundImage:[UIImage imageNamed:@"btn"] forState:UIControlStateNormal];
    [_sendBtn setBackgroundImage:[UIImage imageNamed:@"btn_sel"] forState:UIControlStateHighlighted];
    [_sendBtn addTarget:self action:@selector(sendRequest:) forControlEvents:UIControlEventTouchUpInside];
    [holder addSubview:_sendBtn];
}

- (UITextField*) createTextField:(CGRect)frame holderText:(NSString*)holderText keyboardType:(UIKeyboardType)keyboardType returnType:(UIReturnKeyType)returnType
{
    UITextField* mobileField = [EZTextField creatTextField:frame textColor:EZLoginInputTextColor font:[UIFont systemFontOfSize:14] alignment:NSTextAlignmentLeft borderColor:nil padding:CGSizeMake(10, 0)];
    mobileField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:holderText attributes:@{NSForegroundColorAttributeName: EZLoginInputTextColor}];
    [mobileField setBackground:[[UIImage imageNamed:@"inputbox_s"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    mobileField.keyboardType = keyboardType;
    mobileField.returnKeyType = returnType;
    mobileField.delegate = self;
    //UILabel* mobilePlaceHolder = [self createPlaceHolder:mobileField];
    //mobilePlaceHolder.text = holderText;
    //mobileField.placeholder = holderText;
    //[self.view addSubview:mobilePlaceHolder];
    return mobileField;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
