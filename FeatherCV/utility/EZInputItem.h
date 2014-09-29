//
//  EZInputItem.h
//  BabyCare
//
//  Created by xietian on 14-7-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EZInputItem : NSObject<UITextFieldDelegate>

- (id) initWithName:(NSString*)inputName type:(EZInputValueType)type defaultValue:(id)defaultValue;

- (id) initWithName:(NSString*)inputName type:(EZInputValueType)type defaultValue:(id)defaultValue unitName:(NSString*)unitName parameterName:(NSString*)paramName;

@property (nonatomic, strong) NSString* inputName;

@property (nonatomic, strong) id defaultValue;

@property (nonatomic, strong) id changedValue;

@property (nonatomic, assign) EZInputValueType type;

@property (nonatomic, strong) EZEventBlock pickerRaiser;

@property (nonatomic, strong) EZEventBlock valueChanged;

@property (nonatomic, strong) NSString* unitName;

@property (nonatomic, strong) NSString* parameterName;

@property (nonatomic, assign) CGFloat widthLimit;

@property (nonatomic, weak) UITextField* textField;

- (void) valueChanged:(id)obj;

- (void) raiseDatePicker:(id)obj;

@end
