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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) startRegister:(NSString*)name mobile:(NSString*)mobile password:(NSString*)password
{
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
    } error:^(id err){
        EZDEBUG(@"Register error:%@", err);
    }];
    
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(![textField.text isEmpty]){
        if(textField == _mobile){
            [_name becomeFirstResponder];
        }else if(textField == _name){
            [_password becomeFirstResponder];
        }else{
            [self startRegister:_name.text mobile:_mobile.text password:_password.text];
        }
        return true;
    }else{
        return false;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
