//
//  EZInputItem.h
//  BabyCare
//
//  Created by xietian on 14-7-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EZInputItem : NSObject<UITextFieldDelegate>

- (id) initWithName:(NSString*)inputName type:(EZinputValueType)type defaultValue:(id)defaultValue;

@property (nonatomic, strong) NSString* inputName;

@property (nonatomic, strong) id defaultValue;

@property (nonatomic, strong) id changedValue;

@property (nonatomic, assign) EZinputValueType type;

@property (nonatomic, strong) EZEventBlock pickerRaiser;

@property (nonatomic, strong) EZEventBlock valueChanged;

- (void) valueChanged:(id)obj;

- (void) raiseDatePicker:(id)obj;

@end
