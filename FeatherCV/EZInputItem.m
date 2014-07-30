//
//  EZInputItem.m
//  BabyCare
//
//  Created by xietian on 14-7-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZInputItem.h"

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

- (id) initWithName:(NSString*)inputName type:(EZinputValueType)type defaultValue:(id)defaultValue
{
    self = [super init];
    _inputName = inputName;
    _type = type;
    _defaultValue = defaultValue;
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
