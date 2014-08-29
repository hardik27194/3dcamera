//
//  EZInputItem.m
//  BabyCare
//
//  Created by xietian on 14-7-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZInputItem.h"
#import "EZExtender.h"

@implementation EZInputItem

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //if([textField.text isNotEmpty]){
    //
    //}
    _changedValue = textField.text;
    return true;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    _changedValue = textField.text;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [textField fitContent:NO limit:_widthLimit];
    EZDEBUG(@"origin:%@, added:%@, range:%@", textField.text, string, NSStringFromRange(range));
    if(textField.text){
        _changedValue  = [NSString stringWithFormat:@"%@%@",textField.text,string];
    }else{
        _changedValue = string;
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


- (id) initWithName:(NSString*)inputName type:(EZInputValueType)type defaultValue:(id)defaultValue unitName:(NSString*)unitName parameterName:(NSString*)paramName
{
    self = [super init];
    _inputName = inputName;
    _type = type;
    _defaultValue = defaultValue;
    _changedValue = defaultValue;
    _unitName = unitName;
    _parameterName = paramName;
    return self;
}
//How could I knew to which window to raise it?
- (void) raiseDatePicker:(id)obj
{
    if(_pickerRaiser){
        _pickerRaiser(obj);
    }
}

@end
