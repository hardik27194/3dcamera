//
//  EZInputItem.m
//  BabyCare
//
//  Created by xietian on 14-7-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZInputItem.h"
#import "EZTextField.h"
#import "EZDataUtil.h"
#import "EZKeyboadUtility.h"
#import "EZMessageCenter.h"
#import "EZImageAdder.h"

@implementation EZInputItem

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //if([textField.text isNotEmpty]){
    //
    //}
    if(_type != kNumberPicker){
        _changedValue = textField.text;
    }
    return true;
}


//Will automatically transfer the the displayed value
//Some smell are going ahead.
- (id) getChangedValue
{
    if(_type == kNumberPicker){
        return @([[_pickerValues objectAtIndex:[_changedValue integerValue]] integerValue]);
    }
    return _changedValue;
}

- (id) getChangedValue:(BOOL)raw
{
    return _changedValue;
}


- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if(_type != kNumberPicker){
        _changedValue = textField.text;
    }
    //[[EZMessageCenter getInstance] unregisterEvent:EventKeyboardWillRaise forObject:_keyboardRaise];
    [self keyboardDismissed];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    EZDEBUG(@"keyboard will raise");
    //if(_floatingKeyboard){
    [[EZMessageCenter getInstance] registerEvent:EventKeyboardWillRaise block:_keyboardRaise isWeak:true];
    //}
    return true;
}





- (void) setPlaceholder:(NSString *)placeholder
{
    _textField.placeholder = placeholder;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(!_notAdjustLength){
        [textField fitContent:NO];
    }
    EZDEBUG(@"origin:%@, added:%@, range:%@", textField.text, string, NSStringFromRange(range));
    if(_type != kNumberPicker){
        if(textField.text){
            _changedValue  = [NSString stringWithFormat:@"%@%@",textField.text,string];
        }else{
            _changedValue = string;
        }
    }
    return true;
}


- (void) valueChanged:(id)obj
{
    if(_valueChanged){
        _valueChanged(obj);
    }
}

- (id) initWithName:(NSString*)inputName type:(EZInputValueType)type defaultValue:(id)defaultValue
{
    return [self initWithName:inputName type:type defaultValue:defaultValue unitName:nil parameterName:nil];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_pickerValues objectAtIndex:row];
}

- (id) initWithName:(NSString*)inputName type:(EZInputValueType)type values:(NSArray*)toggles defaultPos:(NSInteger)pos
{
    self = [super init];
    _inputName = inputName;
    _type = type;
    _defaultValue = @(pos);
    _changedValue = @(pos);
    if(_type == kNumberPicker){
        _pickerValues = toggles;
    }else{
        _togglePos = pos;
        _toggleValue = toggles;
    }
    //_parameterName = paramName;
    return self;

}


- (id) initWithName:(NSString*)inputName type:(EZInputValueType)type defaultValue:(id)defaultValue unitName:(NSString*)unitName parameterName:(NSString*)paramName
{
    self = [super init];
    _inputName = inputName;
    _type = type;
    _defaultValue = defaultValue;
    _changedValue = defaultValue;
    _unitName = unitName;
    _parameterName = paramName;
    __weak EZInputItem* weakSelf = self;
    _keyboardRaise = ^(id obj){
        [weakSelf keyboardRaised];
    };
    
    _keyboardHide = ^(id obj){
        [weakSelf keyboardHided];
    };
    return self;
}

- (void) keyboardHided
{
    if(!_isKeyboardFront){
        return;
    }
    //[[EZMessageCenter getInstance]unregisterEvent:EventKeyboardDidHide forObject:_keyboardHide];
    [self keyboardDismissed];
}

- (void) resignResponder
{
    [_textField resignFirstResponder];
}

- (void) keyboardRaised
{
    if(!_textField.isFirstResponder){
        return;
    }
    CGRect keyRect = [EZKeyboadUtility getInstance].keyboardFrame;
    if(_type == kDateValue){
        keyRect = CGRectMake(0, CurrentScreenHeight - _textField.inputView.height, CurrentScreenWidth, _textField.inputView.height); //_textField.inputView.frame;
    }
     EZDEBUG(@"keyboard rect:%@, isFirst:%i, content:%@, before:%@", NSStringFromCGRect(keyRect), _textField.isFirstResponder, _textField.text, NSStringFromCGRect(_textField.superview.frame));
    if(!_isKeyboardFront){
        _isKeyboardFront = true;
        _oldFrame = _textField.superview.frame;
        _grandPaView = _textField.superview.superview;
        _coverView = [TopView createCoverView:2014 color:_floatingKeyboard?RGBA(70, 70, 70, 220):[UIColor clearColor] below:nil tappedTarget:self action:@selector(resignResponder)];
        CGRect adjustFrame = [_coverView convertRect:_oldFrame fromView:_grandPaView];
        [_coverView addSubview:_textField.superview];
        _textField.superview.frame = adjustFrame;
        if(_floatingKeyboard){
            _coverView.alpha = 0;
            [UIView animateWithDuration:0.3 animations:^(){
                _coverView.alpha = 1.0;
            }];
        }
    }
    
    if(_floatingKeyboard){
        [UIView animateWithDuration:0.3 animations:^(){
            _textField.superview.bottom = keyRect.origin.y;
        }];
    }
    //CGRect keyRect = [EZKeyboadUtility getInstance].keyboardFrame;
   

}



- (void) dismissCover:(UIView*)coverView grandPa:(UIView*)grandPaView
{
    UIView* mockView = [_textField.superview snapshotViewAfterScreenUpdates:NO];
    mockView.frame = _textField.superview.frame;
    [coverView addSubview:mockView];
    [grandPaView addSubview:_textField.superview];
    _textField.superview.frame = _oldFrame;
    
    if(!_floatingKeyboard){
        //CGRect adjustFrame = [coverView convertRect:_oldFrame fromView:grandPaView];
        //coverView.alpha = 0;
        [coverView removeFromSuperview];
        return;
    }
    
    CGRect adjustFrame = [coverView convertRect:_oldFrame fromView:grandPaView];
    [UIView animateWithDuration:0.3 animations:^(){
        coverView.alpha = 0;
        mockView.frame = adjustFrame;
    } completion:^(BOOL finished) {
        [coverView removeFromSuperview];
        //[mockView]
    }];
}

- (void) keyboardDismissed
{
    //if(!_floatingKeyboard){
    //    return;
    //}
    EZDEBUG(@"keyboard dismissed:%i", _isKeyboardFront);
    _isKeyboardFront = false;
    //CGRect keyRect = [EZKeyboadUtility getInstance].keyboardFrame;
    if(_type != kDateValue){
        [[EZMessageCenter getInstance] unregisterEvent:EventKeyboardWillRaise forObject:_keyboardRaise];
    }
    //EZDEBUG(@"dismissed keyboard rect:%@", NSStringFromCGRect(keyRect));
    [self dismissCover:_coverView grandPa:_grandPaView];
}


//How could I knew to which window to raise it?
- (void) raiseDatePicker:(id)obj
{
    if(_pickerRaiser){
        _pickerRaiser(obj);
    }
}

- (void) setDefaultValue:(id)defaultValue
{
    _defaultValue = defaultValue;
    _changedValue = defaultValue;
    _textField.text = defaultValue;
}

- (void) updateDefault:(id) obj
{
    _defaultValue= obj;
    _textField.text = _defaultValue;
    if(self.type == kFloatValue){
        _textField.text = [NSString stringWithFormat:@"%f", [_defaultValue floatValue]];
    }
    if(self.type == kStringValue || self.type == kFloatValue || self.type == kDateValue ||self.type == kTimeValue){
        [_textField fitContent:NO];
    }
    
    if(self.type == kToggleValue){
        [_toggleBtn setTitle:[_toggleValue objectAtIndex:[_defaultValue integerValue]]  forState:UIControlStateNormal];
    }
}

- (void) switchChanged:(UISwitch*) sw{
    EZDEBUG(@"Switch changed to:%i", sw.on);
    if(_valueChanged){
        _valueChanged(sw);
    }
}


- (UIView*) renderToView:(CGRect)frame titleFont:(UIFont*)titleFont titleColor:(UIColor*)titleColor inputFont:(UIFont*)inputFont inputColor:(UIColor*)inputColor
{
    return [self renderToView:frame titleFont:titleFont titleColor:titleColor inputFont:inputFont inputColor:inputColor borderColor:_borderColor];
}


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    EZDEBUG(@"returned picker value:%i", _pickerValues.count);
    return _pickerValues.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    EZDEBUG(@"picker selected value:%@", [_pickerValues objectAtIndex:row]);
    if(_valueChanged){
        _valueChanged(@(row));
    }
}

- (void) clicked:(id)obj
{
    if(_btnClicked){
        _btnClicked(obj);
    }
}


- (UIView*) renderToView:(CGRect)frame titleFont:(UIFont*)titleFont titleColor:(UIColor*)titleColor inputFont:(UIFont*)inputFont inputColor:(UIColor*)inputColor borderColor:(UIColor*)borderColor
{
    
    UIView* inputView = [[UIView alloc]initWithFrame:frame];
    //inputView.backgroundColor = randBack(nil);
    EZInputItem* item = self;
    UILabel* inputName = [UILabel createLabel:CGRectMake(14, (frame.size.height - 17)/2.0, 150, 17) font:titleFont color:titleColor];
    [inputView addSubview:inputName];
    inputName.text = item.inputName;
    UILabel* unitName = nil;
    CGFloat width = [inputName.text sizeWithAttributes:@{NSFontAttributeName:inputName.font}].width;
    EZDEBUG(@"adjusted width:%f", width);
    [inputName setWidth:width];
    
    if(item.type == kSingleButton){
        [inputName removeFromSuperview];
        UIButton* button = [UIButton createButton:CGRectMake(15, 5, inputView.width - 30, inputView.height - 10) title:_inputName font:titleFont color:_btnTextColor align:NSTextAlignmentCenter];
        button.backgroundColor = _btnBackground;
        button.layer.cornerRadius = 5;
        [inputView addSubview:button];
        [button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    }else
    if(item.type == kStringNoTitle){
        UITextField* textField = [EZTextField creatTextField:CGRectMake(0, (frame.size.height - 30)/2.0, frame.size.width, 30) textColor:inputColor font:inputFont alignment:NSTextAlignmentCenter borderColor:borderColor?borderColor:[UIColor clearColor] padding:CGSizeMake(0, 0)];
        textField.text = @"哈哈";
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = item;
        textField.placeholder = _placeholder;
        //[textField fitContent:NO];
        [inputView addSubview:textField];
        _textField = textField;
        //[[EZMessageCenter getInstance] registerEvent:EventKeyboardWillRaise block:_keyboardRaise];
    }else
    if(item.type == kFloatValue || item.type == kStringValue){
        CGFloat leftGap = 5;
        EZDEBUG(@"unitIs:%@, left is:%f", item.unitName, unitName.left);
        UITextField* textField = [EZTextField creatTextField:CGRectMake(frame.size.width - 105 - leftGap, (frame.size.height - 30)/2.0, 100, 30) textColor:inputColor font:inputFont alignment:NSTextAlignmentRight borderColor:borderColor?borderColor:[UIColor clearColor] padding:CGSizeMake(10, 0)];
        
        textField.backgroundColor =borderColor?[UIColor clearColor]:RGBA(255, 255, 255, 80);
        if(item.type == kFloatValue){
            textField.keyboardType = UIKeyboardTypeNumberPad;
            NSNumber* num = item.defaultValue;
            if(num){
                textField.text = [NSString stringWithFormat:@"%i", num.intValue];
            }else{
                textField.text = @"0";
            }
            
        }else{
            textField.keyboardType = UIKeyboardTypeDefault;
            if(item.defaultValue){
                textField.text = [NSString stringWithFormat:@"%@", item.defaultValue];
            }else{
                textField.text = @"";
            }
        }
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = item;
        [textField fitContent:NO];
        [inputView addSubview:textField];
        _textField = textField;
        //[[EZMessageCenter getInstance] registerEvent:EventKeyboardWillRaise block:_keyboardRaise];
        
    }else if(item.type == kBoolValue){
        CGFloat leftGap = 5;
        EZDEBUG(@"unitIs:%@, left is:%f", item.unitName, unitName.left);
        UISwitch* switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(frame.size.width - 60 - leftGap, (frame.size.height - 44)/2.0, 60, 44)];
        switchBtn.on = [_defaultValue boolValue];
        
        //UIButton* toggleBtn = [UIButton createButton:CGRectMake(frame.size.width - 44 - leftGap, (frame.size.height - 44)/2.0, 44, 44) font:[UIFont boldSystemFontOfSize:14] color:inputColor align:NSTextAlignmentCenter];
        //[toggleBtn setTitle:[_toggleValue objectAtIndex:[_defaultValue integerValue]]  forState:UIControlStateNormal];
        //toggleBtn.backgroundColor = [UIColor grayColor];

        [switchBtn addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        [inputView addSubview:switchBtn];
        __weak EZInputItem* weakItem = item;
        item.valueChanged = ^(UISwitch* sw){
            EZDEBUG(@"value change get called");
            weakItem.changedValue = @(sw.on);
        };
    }else if(item.type == kNumberPicker){
        UITextField* textField = [EZTextField creatTextField:CGRectMake(frame.size.width - 110, (frame.size.height - 30)/2.0, 100, 30) textColor:inputColor font:inputFont alignment:NSTextAlignmentRight borderColor:borderColor?borderColor:[UIColor clearColor] padding:CGSizeMake(10, 0)];
        
        textField.text =[_pickerValues objectAtIndex:[_defaultValue integerValue]];
        [textField fitContent:NO];
        
        UIPickerView *dataPicker = [[UIPickerView alloc] init];
        dataPicker.dataSource = self;
        dataPicker.delegate = self;
        
        //[dataPicker addTarget:item action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        //datePicker.tag = indexPath.row;
        
        UIView* raisedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, dataPicker.height + 33)];
        raisedView.backgroundColor = [UIColor whiteColor];
        dataPicker.y = 33;
        [raisedView addSubview:dataPicker];
        UIButton* confirm = [UIButton createButton:CGRectMake(CurrentScreenWidth - 60, 0, 60, 33) font:[UIFont boldSystemFontOfSize:16] color:ClickedColor align:NSTextAlignmentCenter];
        [raisedView addSubview:confirm];
        [confirm setTitle:@"确认" forState:UIControlStateNormal];
        [confirm addTarget:self  action:@selector(pickerConfirmed:) forControlEvents:UIControlEventTouchUpInside];
        
        textField.inputView = raisedView;
        __weak EZInputItem* weakItem = item;
        item.valueChanged = ^(NSNumber* pickedPos){
            EZDEBUG(@"Picked pos:%i", pickedPos.integerValue);
            //if(weakItem.type == )
            weakItem.changedValue = pickedPos;
            textField.text = [weakItem.pickerValues objectAtIndex:pickedPos.integerValue];
        };
        _textField = textField;
        textField.backgroundColor = borderColor?[UIColor clearColor]:RGBA(255, 255, 255, 80);
        [inputView addSubview:textField];
        [[EZMessageCenter getInstance] registerEvent:EventKeyboardWillRaise block:_keyboardRaise isWeak:YES];
        [[EZMessageCenter getInstance] registerEvent:EventKeyboardWillHide block:_keyboardHide isWeak:YES];
    }
    else if(item.type == kDateValue || item.type == kTimeValue){
        UITextField* textField = [EZTextField creatTextField:CGRectMake(frame.size.width - 110, (frame.size.height - 30)/2.0, 100, 30) textColor:inputColor font:inputFont alignment:NSTextAlignmentRight borderColor:borderColor?borderColor:[UIColor clearColor] padding:CGSizeMake(10, 0)];
        
        textField.text =item.type==kDateValue?[[EZDataUtil getInstance].birthDateFormatter stringFromDate:item.defaultValue]:[[EZDataUtil getInstance].generalDateTimeFormatter stringFromDate:item.defaultValue];
        [textField fitContent:NO];
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = item.type == kDateValue?UIDatePickerModeDate:UIDatePickerModeDateAndTime;
        datePicker.date = item.defaultValue;
        [datePicker addTarget:item action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        //datePicker.tag = indexPath.row;
        
        UIView* raisedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, datePicker.height + 33)];
        raisedView.backgroundColor = [UIColor whiteColor];
        datePicker.y = 33;
        [raisedView addSubview:datePicker];
        UIButton* confirm = [UIButton createButton:CGRectMake(CurrentScreenWidth - 60, 0, 60, 33) font:[UIFont boldSystemFontOfSize:16] color:ClickedColor align:NSTextAlignmentCenter];
        [raisedView addSubview:confirm];
        [confirm setTitle:@"确认" forState:UIControlStateNormal];
        [confirm addTarget:self  action:@selector(pickerConfirmed:) forControlEvents:UIControlEventTouchUpInside];
        
        textField.inputView = raisedView;
        __weak EZInputItem* weakItem = item;
        item.valueChanged = ^(UIDatePicker* picker){
            EZDEBUG(@"Value changed to:%@", picker.date);
            //if(weakItem.type == )
            textField.text =weakItem.type == kDateValue?[[EZDataUtil getInstance].birthDateFormatter stringFromDate:picker.date]:[[EZDataUtil getInstance].generalDateTimeFormatter stringFromDate:picker.date];
            weakItem.changedValue = picker.date;
        };
        _textField = textField;
        textField.backgroundColor = borderColor?[UIColor clearColor]:RGBA(255, 255, 255, 80);
        [inputView addSubview:textField];
        [[EZMessageCenter getInstance] registerEvent:EventKeyboardWillRaise block:_keyboardRaise isWeak:YES];
        [[EZMessageCenter getInstance] registerEvent:EventKeyboardWillHide block:_keyboardHide isWeak:YES];
    }else if(item.type == kToggleValue){
        CGFloat leftGap = 5;
        EZDEBUG(@"unitIs:%@, left is:%f", item.unitName, unitName.left);
        UIButton* toggleBtn = [UIButton createButton:CGRectMake(frame.size.width - 44 - leftGap, (frame.size.height - 44)/2.0, 44, 44) font:[UIFont boldSystemFontOfSize:14] color:inputColor align:NSTextAlignmentCenter];
        [toggleBtn setTitle:[_toggleValue objectAtIndex:[_defaultValue integerValue]]  forState:UIControlStateNormal];
        //toggleBtn.backgroundColor = [UIColor grayColor];
        UIView* cycleView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, 29, 29)];
        cycleView.layer.borderColor = [UIColor whiteColor].CGColor;
        cycleView.layer.borderWidth = 2;
        cycleView.userInteractionEnabled = false;
        [cycleView enableRoundEdge];
        [toggleBtn addSubview:cycleView];
        [toggleBtn addTarget:self action:@selector(toggleClicked:) forControlEvents:UIControlEventTouchUpInside];
        [inputView addSubview:toggleBtn];
        _toggleBtn = toggleBtn;
        //[EZTextField creatTextField:CGRectMake(frame.size.width - 105 - leftGap, (frame.size.height - 30)/2.0, 100, 30) textColor:EZGrayInputTextColor font:[UIFont systemFontOfSize:17] alignment:NSTextAlignmentRight borderColor:EZBorderColor padding:CGSizeMake(10, 0)];
    }else if(item.type == kImageValue){
        _imageAdder = [[EZImageAdder alloc] initWithFrame:CGRectMake(0, 0, inputView.width, inputView.height) padding:CGSizeMake(-1, 0) markSize:CGSizeMake(inputView.height, inputView.height) limit:CGSizeMake(4, 1) controller:nil];
        [inputView addSubview:_imageAdder];
    }
    if(_isFocused){
        //_textField.isFirstResponder = true;
        [_textField becomeFirstResponder];
    }
    return inputView;
}

- (void) pickerConfirmed:(id)obj
{
    [_textField resignFirstResponder];
}

- (void) toggleClicked:(UIButton*)clicked
{
    _togglePos ++;
    if(_togglePos > _toggleValue.count - 1){
        _togglePos = 0;
    }
    _changedValue = @(_togglePos);
    [clicked setTitle:[_toggleValue objectAtIndex:_togglePos] forState:UIControlStateNormal];
}

@end
