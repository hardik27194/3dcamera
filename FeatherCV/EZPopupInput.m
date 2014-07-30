//
//  EZPopupInput.m
//  BabyCare
//
//  Created by xietian on 14-7-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZPopupInput.h"
#import "EZInputItem.h"
#import "EZCustomButton.h"


#define EZGrayInputTextColor RGBCOLOR(110,110, 110)

#define EZPopupBorderColor RGBCOLOR(54, 193, 191)

#define EZAlertColor RGBCOLOR(255, 27, 129)

#define EZBorderColor RGBCOLOR(94, 199, 196)


@implementation EZPopupInput

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) deleteCalled:(id)obj
{
    EZDEBUG(@"delete get called");
}

- (void) renderInputs
{
    CGFloat beginYPos = EZPopHeaderHeight;
    for(EZInputItem* item in _inputItems){
        UIView* inputView = [self renderToView:item];
        [inputView setY:beginYPos];
        beginYPos += EZInputItemHeight;
        [self addSubview:inputView];
    }
    if(_haveDelete){
        beginYPos = self.bounds.size.height - EZInputItemHeight;
        UIView* border = [[UIView alloc] initWithFrame:CGRectMake(0, beginYPos, self.bounds.size.width, 1)];
        beginYPos++;
        UIButton* deleteButton = [UIButton createButton:CGRectMake(0, beginYPos, self.bounds.size.width, 48) font:[UIFont boldSystemFontOfSize:17] color:EZAlertColor align:NSTextAlignmentCenter];
        
        [deleteButton addTarget:self action:@selector(deleteCalled:) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton setTitle:@"删除该记录" forState:UIControlStateNormal];
        UIImageView* garbageCan = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_delete"]];
        [garbageCan setPosition:CGPointMake(CurrentScreenWidth/2.0 - 80.0, (EZInputItemHeight - garbageCan.height)/2.0)];
        [deleteButton addSubview:garbageCan];
        [self addSubview:border];
        [self addSubview:deleteButton];
    }
}

- (UIView*) renderToView:(EZInputItem*)item
{
    UIView* inputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, EZInputItemHeight)];
    inputView.backgroundColor = randBack(nil);
    UILabel* inputName = [UILabel createLabel:CGRectMake(14, (EZInputItemHeight - 17)/2.0, 150, 17) font:[UIFont systemFontOfSize:15] color:EZGrayInputTextColor];
    [inputView addSubview:inputName];
    inputName.text = item.inputName;
    CGFloat width = [inputName.text sizeWithAttributes:@{NSFontAttributeName:inputName.font}].width;
    EZDEBUG(@"adjusted width:%f", width);
    [inputName setWidth:width];
    if(item.type == kFloatValue || item.type == kStringValue){
        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(self.bounds.size.width - 110, (EZInputItemHeight - 30)/2.0, 100, 30)];
        textField.textColor = EZGrayInputTextColor;
        textField.font = [UIFont systemFontOfSize:17];
        textField.textAlignment = NSTextAlignmentRight;
        textField.layer.cornerRadius = 5;
        textField.layer.borderColor = EZBorderColor.CGColor;
        if(item.type == kFloatValue){
            textField.keyboardType = UIKeyboardTypeNumberPad;
            NSNumber* num = item.defaultValue;
            if(num){
                textField.text = [NSString stringWithFormat:@"%i", num.intValue];
            }else{
                textField.text = @"0";
            }
            textField.keyboardType = UIKeyboardTypeDefault;
        }else{
            if(item.defaultValue){
                textField.text = [NSString stringWithFormat:@"%@", item.defaultValue];
            }else{
                textField.text = @"";
            }
            
        }
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = item;
        [inputView addSubview:textField];
        
    }else if(item.type == kDateValue){
        UIButton* dateButton = [UIButton createButton:CGRectMake(self.bounds.size.width - 170, 5, 160, 30) font:[UIFont systemFontOfSize:17] color:EZGrayInputTextColor align:NSTextAlignmentRight];
        [dateButton addTarget:item action:@selector(raiseDatePicker:) forControlEvents:UIControlEventTouchUpInside];
        [inputView addSubview:dateButton];
    }
    return inputView;
}

- (id) initWithTitle:(NSString*)title  inputItems:(NSArray*)inputItems haveDelete:(BOOL)haveDelete saveBlock:(EZEventBlock)saveBlock deleteBlock:(EZEventBlock)deleteBlock
{
    //self = [super ]
    
    int count = inputItems.count;
    if(haveDelete){
        count += 1;
    }
    CGFloat bodyHeight = count * EZInputItemHeight;
    if(bodyHeight < EZMinimiumHeight){
        bodyHeight = EZMinimiumHeight;
    }
    
    _haveDelete = haveDelete;
    self = [super initWithFrame:CGRectMake(0, 0, EZInputViewWidth, bodyHeight + EZPopHeaderHeight)];
    EZDEBUG(@"final height:%f, bounds:%f, bodyHeight:%f, count:%i", bodyHeight+EZPopHeaderHeight, self.bounds.size.height, bodyHeight, count);
    self.title.text = title;
    _inputItems = inputItems;
    [self renderInputs];
    return self;
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
