//
//  EZRegisterController.m
//  FeatherCV
//
//  Created by xietian on 14-2-21.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZRegisterController.h"
#import "EZDataUtil.h"
#import "EZPerson.h"

@interface EZRegisterController ()

@end

@implementation EZRegisterController


- (id) init
{
    return [self initWithNibName:@"EZRegisterController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) updateImage:(UIImage*)image
{
    [_uploadAvatar setImage:image];
    [[EZDataUtil getInstance] uploadAvatar:image success:^(NSString* url){
        EZDEBUG(@"avatar url:%@", url);
        currentLoginUser.avatar = url;
    } failure:^(id err){
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"Upload avatar failed") info:@"Please try avatar upload later"];
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"index:%i", buttonIndex);
    if(buttonIndex == 2){
        return;
    }
    
    __weak EZRegisterController* weakSelf = self;
    [[EZUIUtility sharedEZUIUtility] raiseCamera:buttonIndex controller:self completed:^(UIImage* image){
        EZDEBUG(@"will upload image:%@", NSStringFromCGSize(image.size));
        [weakSelf updateImage:[image resizedImageWithMinimumSize:CGSizeMake(90, 90) antialias:YES]];
        
    } allowEditing:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = VinesGray;
    CGFloat radius = 50;
    _uploadAvatar = [[EZClickImage alloc] initWithFrame:CGRectMake(CurrentScreenWidth/2.0 - radius, 280, radius * 2.0, radius * 2.0)];
    _uploadAvatar.image = PlaceHolderSmall;
    _uploadAvatar.layer.borderWidth = 4;
    _uploadAvatar.layer.borderColor = [UIColor whiteColor].CGColor;
    [_uploadAvatar enableRoundImage];
    
    __weak EZRegisterController* weakSelf = self;
    _uploadAvatar.pressedBlock = ^(id obj){
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"上传头像" delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"相册", nil];
        [actionSheet showInView:weakSelf.view];
    };
    [self.view addSubview:_uploadAvatar];
    // Do any additional setup after loading the view from its nib.
}


- (void) startRegister:(NSString*)name mobile:(NSString*)mobile password:(NSString*)password
{
    
    __weak EZRegisterController* weakSelf = self;
    if([name isEmpty]){
        [_name becomeFirstResponder];
        return;
    }
    if([mobile isEmpty]){
        [_mobile becomeFirstResponder];
    }
    if([password isEmpty]){
        [_password becomeFirstResponder];
    }
    
    NSString* currentID = [EZDataUtil getInstance].currentPersonID;
    NSDictionary* registerInfo = @{
      @"name":name,
      @"mobile":mobile,
      @"password":password,
      @"personID":currentID?currentID:@""
    };
    
    [[EZDataUtil getInstance] registerUser:registerInfo success:^(EZPerson* person){
        EZDEBUG(@"Register success");
        if(_completedBlock){
            _completedBlock(person);
        }
        //[self dismissViewControllerAnimated:YES completion:nil];
        _registerTitle.text = macroControlInfo(@"Register success");
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"Register success") info: macroControlInfo(@"Congradulation")];
        EZClickImage* successButton = [[EZClickImage alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 80.0)/2.0, 390, 80, 80)];
        successButton.backgroundColor = randBack(nil);
        [self.view addSubview:successButton];
        [successButton enableRoundImage];
        successButton.pressedBlock = ^(id obj){
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            if(weakSelf.dismissBlock){
                weakSelf.dismissBlock(nil);
            }
        };
    } error:^(id err){
        EZDEBUG(@"Register error:%@", err);
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:@"注册失败" info:@"请检查后重试"];
    }];
    
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(![textField.text isEmpty]){
        if(textField == _mobile){
            [_name becomeFirstResponder];
        }else if(textField == _name){
            [_password becomeFirstResponder];
        }else{
            [self startRegister:_name.text mobile:_mobile.text password:_password.text];
            [textField resignFirstResponder];
        }
        return true;
    }else{
        return false;
    }

}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
