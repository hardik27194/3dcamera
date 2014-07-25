//
//  EZProfileView.m
//  FeatherCV
//
//  Created by xietian on 14-7-7.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZProfileView.h"
#import "EZClickImage.h"
#import "EZToolStripe.h"
#import "EZDataUtil.h"

#define leftPadding 25


@implementation EZProfileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSDictionary* parameter = nil;
    [textField resignFirstResponder];
    if(![textField.text isNotEmpty]){
        return YES;
    }
    if(_name == textField){
        parameter = @{@"name":textField.text};
    }else if(_signature == textField){
        parameter = @{@"signature":textField.text};
    }
    
    [[EZDataUtil getInstance] updatePerson:parameter success:^(id obj){
        EZDEBUG(@"success updated");
    } failure:^(id err){
        EZDEBUG(@"error to update");
    }];
    return true;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    EZDEBUG(@"did end editing");
    [textField resignFirstResponder];
}

- (id) init
{
    return [self initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, EZProfileImageHeight + EZToolStripeHeight)];
}

- (void) setIsEditing:(BOOL)isEditing
{
    _name.userInteractionEnabled = isEditing;
    _signature.userInteractionEnabled = isEditing;
    _headIcon.userInteractionEnabled = isEditing;
}


- (void) setupView
{
    
    _headIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, EZProfileImageHeight)];
    _headIcon.backgroundColor = [UIColor grayColor];
    _headIcon.contentMode = UIViewContentModeScaleAspectFill;
    _headIcon.clipsToBounds = YES;
    [self addSubview:_headIcon];
    
    UIView* darkerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, EZProfileImageHeight)];
    darkerView.backgroundColor = RGBA(0, 0, 0, 26);
    [_headIcon addSubview:darkerView];

    _name = [[UITextField alloc] initWithFrame:CGRectMake(leftPadding, 238, CurrentScreenWidth - 2 * leftPadding, 43)];
    _name.font = [UIFont systemFontOfSize:43];
    _name.textColor = [UIColor whiteColor];
    _name.returnKeyType = UIReturnKeyDone;
    [self addSubview:_name];
    _name.delegate = self;
    _signature = [[UITextField alloc] initWithFrame:CGRectMake(leftPadding, 293, CurrentScreenWidth - 2 * leftPadding, 13)];
    _signature.font = [UIFont boldSystemFontOfSize:13];
    _signature.textColor = [UIColor whiteColor];
    _signature.returnKeyType = UIReturnKeyDone;
    [self addSubview:_signature];
    _signature.delegate = self;
    
    _touchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(leftPadding, 318, 25, 25)];
    _touchIcon.contentMode = UIViewContentModeScaleAspectFill;
    _touchIcon.clipsToBounds = YES;
    _touchIcon.image = [UIImage imageNamed:@"finger_print"];
    [self addSubview:_touchIcon];
    
    _touchCount = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding + 25 + 3, 318, 100, 15)];
    _touchCount.font = [UIFont systemFontOfSize:12];//[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15];
    _touchCount.textColor = [UIColor whiteColor];
    [self addSubview:_touchCount];
    
    
    _toolStripe = [[EZToolStripe alloc] initWithFrame:CGRectMake(0, EZProfileImageHeight, CurrentScreenWidth, EZToolStripeHeight)];
    [self addSubview:_toolStripe];
    
    self.isEditing = false;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
