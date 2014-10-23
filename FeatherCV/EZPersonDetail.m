//
//  EZPersonDetail.m
//  3DCamera
//
//  Created by xietian on 14-10-23.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZPersonDetail.h"
#import "EZDataUtil.h"
#import "EZTextField.h"

@interface EZPersonDetail ()

@end

@implementation EZPersonDetail

- (id) initWithPerson:(EZPerson *)person
{
    self = [super initWithNibName:nil bundle:nil];
    _person = person;
    _isEditable = [currentLoginID isEqualToString:_person.personID];
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


- (void) sendRequest:(id)obj
{
    EZDEBUG(@"send request");
    [self startActivity];
    NSString* nickName = _nickName.text;
    
    
    [[EZDataUtil getInstance] updatePerson:@{@"name":nickName, @"personID":_person.personID} success:^(EZPerson* obj){
        currentLoginUser.name = nickName;
        [self stopActivity];
        //[self.navigationController popToRootViewControllerAnimated:YES];
        //[[EZMessageCenter getInstance] postEvent:EZUserAuthenticated attached:obj];
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:BIINFO(@"更新成功") info:@""];
    } failure:^(id err){
        EZDEBUG(@"Failed to register %@", err);
        [self stopActivity];
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:BIINFO(@"更新失败") info:BIINFO(@"稍后再试")];
        
    }];
    
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
    UIView* navBar = [self createNavHeader:@"用户信息"];
    [self.view addSubview:navBar];
    UIView* holder = [[UIView alloc] initWithFrame:CGRectMake(0, 64, CurrentScreenWidth, CurrentScreenHeight - 64)];
    holder.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:holder];
    
    _nickName = [self createTextField:CGRectMake(22, 20, 180, EZPasswordInputHeight) holderText:@"昵称" keyboardType:UIKeyboardTypeDefault returnType:UIReturnKeyNext];
    _nickName.tag = 1;
    [holder addSubview:_nickName];
    _nickName.delegate = self;
    _nickName.text = _person.name;
    _nickName.enabled = _isEditable;
    
    if(_isEditable){
    _mobileNumber = [self createTextField:CGRectMake(22, _nickName.bottom + 12, 180, EZPasswordInputHeight) holderText:@"手机号" keyboardType:UIKeyboardTypeNumbersAndPunctuation returnType:UIReturnKeyNext];
    [holder addSubview:_mobileNumber];
    _mobileNumber.text = _person.mobile;
    _mobileNumber.tag = 2;
        
       
    }
    
   /**
    _password = [self createTextField:CGRectMake(22, _mobileNumber.bottom + 12, 276, EZPasswordInputHeight) holderText:@"密码" keyboardType:UIKeyboardTypeDefault returnType:UIReturnKeyNext];
    _password.tag = 3;
    _password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [holder addSubview:_password];
    }
    **/
    /**
     _confirmPassword = [self createTextField:CGRectMake(22, _password.bottom + 12, 276, EZPasswordInputHeight) holderText:@"重复密码" keyboardType:UIKeyboardTypeDefault returnType:UIReturnKeySend];
     _confirmPassword.tag = 5;
     [holder addSubview:_confirmPassword];
     **/
    
    if(_isEditable){
    
     CGFloat btnPos = _mobileNumber.bottom + 24;
    
    
    _sendBtn = [UIButton createButton:CGRectMake(22, btnPos, CurrentScreenWidth - 44, EZPasswordInputHeight) font:[UIFont boldSystemFontOfSize:18] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
    [_sendBtn setTitle:@"确认修改" forState:UIControlStateNormal];
    [_sendBtn setBackgroundImage:[UIImage imageNamed:@"btn"] forState:UIControlStateNormal];
    [_sendBtn setBackgroundImage:[UIImage imageNamed:@"btn_sel"] forState:UIControlStateHighlighted];
    [_sendBtn addTarget:self action:@selector(sendRequest:) forControlEvents:UIControlEventTouchUpInside];
    [holder addSubview:_sendBtn];
    
    
        _quitBtn = [UIButton createButton:CGRectMake(22, _sendBtn.bottom + 24, CurrentScreenWidth - 44, EZPasswordInputHeight) font:[UIFont boldSystemFontOfSize:18] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
        
        [_quitBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        [_quitBtn setBackgroundImage:[UIImage imageNamed:@"btn"] forState:UIControlStateNormal];
        [_quitBtn setBackgroundImage:[UIImage imageNamed:@"btn_sel"] forState:UIControlStateHighlighted];
        [_quitBtn addTarget:self action:@selector(quitLogin:) forControlEvents:UIControlEventTouchUpInside];
        [holder addSubview:_quitBtn];
        
    }
}

- (void) refreshValue
{
    _nickName.text = _person.name;
    _mobileNumber.text = _person.mobile;
}

- (void) quitLogin:(id)obj
{
    //[[EZDataUtil getInstance] l]
    [[EZDataUtil getInstance] setCurrentPersonID:nil];
    [[EZDataUtil getInstance] setCurrentLoginPerson:nil];
    [[EZDataUtil getInstance] triggerLogin:^(id obj){
        _person = currentLoginUser;
        [self refreshValue];
    } failure:^(id err){
        EZDEBUG(@"login failed:%@", err);
    } reason:@"" isLogin:YES];
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
