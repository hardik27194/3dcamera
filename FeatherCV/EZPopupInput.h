//
//  EZPopupInput.h
//  BabyCare
//
//  Created by xietian on 14-7-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZPopupView.h"

#define EZInputItemHeight 49

#define EZMinimiumHeight 120

#define EZInputViewWidth 290

#define EZPopHeaderHeight 40

@interface EZPopupInput : EZPopupView<UITextFieldDelegate>

//- (id) initWith:(NSArray*)inputItems haveDelete:(BOOL)haveDelete saveBlock:(EZEventBlock)saveBlock deleteBlock:(EZEventBlock)deleteBlock;
- (id) initWithTitle:(NSString*)title  inputItems:(NSArray*)inputItems haveDelete:(BOOL)haveDelete saveBlock:(EZEventBlock)saveBlock deleteBlock:(EZEventBlock)deleteBlock;

@property (nonatomic, strong) NSArray* inputItems;
@property (nonatomic, strong) EZEventBlock deleteBlock;
@property (nonatomic, assign) BOOL haveDelete;

@end
