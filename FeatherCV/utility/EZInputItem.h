//
//  EZInputItem.h
//  BabyCare
//
//  Created by xietian on 14-7-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EZImageAdder;
@interface EZInputItem : NSObject<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

- (id) initWithName:(NSString*)inputName type:(EZInputValueType)type values:(NSArray*)toggles defaultPos:(NSInteger)pos;

- (id) initWithName:(NSString*)inputName type:(EZInputValueType)type defaultValue:(id)defaultValue;

- (id) initWithName:(NSString*)inputName type:(EZInputValueType)type defaultValue:(id)defaultValue unitName:(NSString*)unitName parameterName:(NSString*)paramName;

@property (nonatomic, strong) NSString* inputName;

@property (nonatomic, strong) NSString* placeholder;

@property (nonatomic, strong) id defaultValue;

@property (nonatomic, strong) id changedValue;

@property (nonatomic, assign) CGFloat widthLimit;

@property (nonatomic, assign) NSInteger togglePos;

@property (nonatomic, assign) EZInputValueType type;

@property (nonatomic, strong) EZEventBlock pickerRaiser;

@property (nonatomic, strong) EZEventBlock valueChanged;

@property (nonatomic, strong) EZEventBlock keyboardRaise;

@property (nonatomic, strong) EZEventBlock keyboardHide;

@property (nonatomic, strong) NSArray* toggleValue;

@property (nonatomic, strong) NSString* unitName;

@property (nonatomic, strong) NSString* parameterName;

@property (nonatomic, weak) UITextField* textField;

@property (nonatomic, assign) CGRect oldFrame;

@property (nonatomic, assign) BOOL isKeyboardFront;

@property (nonatomic, weak) UIView* grandPaView;

@property (nonatomic, weak) UIView* coverView;

@property (nonatomic, assign) BOOL floatingKeyboard;

@property (nonatomic, assign) BOOL notAdjustLength;

@property (nonatomic, strong) UIColor* borderColor;

@property (nonatomic, strong) UIColor* btnTextColor;

@property (nonatomic, strong) UIColor* btnBackground;

@property (nonatomic, strong) EZImageAdder* imageAdder;

@property (nonatomic, weak) UIButton* toggleBtn;

@property (nonatomic, strong) NSArray* pickerValues;

@property (nonatomic, strong) EZEventBlock btnClicked;

@property (nonatomic, assign) BOOL isFocused;

- (id) getChangedValue;

- (id) getChangedValue:(BOOL)raw;

- (void) valueChanged:(id)obj;

- (void) raiseDatePicker:(id)obj;


- (UIView*) renderToView:(CGRect)frame titleFont:(UIFont*)titleFont titleColor:(UIColor*)titleColor inputFont:(UIFont*)inputFont inputColor:(UIColor*)inputColor;

- (void) updateDefault:(id) obj;

@end
